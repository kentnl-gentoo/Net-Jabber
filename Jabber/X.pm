package Net::Jabber::X;

=head1 NAME

Net::Jabber::X - Jabber X Module

=head1 SYNOPSIS

  Net::Jabber::X is a companion to the Net::Jabber module. It
  provides the user a simple interface to set and retrieve all 
  parts of a Jabber X.

=head1 DESCRIPTION

  Net::Jabber::X differs from the other Net::Jabber::* modules in that
  the XMLNS of the query is split out into more submodules under
  X.  For specifics on each module please view the documentation
  for each Net::Jabber::X::* module.  The available modules are:

    Net::Jabber::X::Delay     - Message Routing and Delay Information
    Net::Jabber::X::Ident     - Rich Identification
    Net::Jabber::X::Oob       - Out Of Band File Transfers

  Each of these modules provided Net::Jabber::X with the functions
  to access the data.  By using delegates and the AUTOLOAD function
  the functions for each namespace is used when that namespace is
  active.

  To initialize the X with a Jabber <x/> you must pass it the 
  XML::Parser Tree array from the Net::Jabber::Client module.  In the
  callback function for the x:

    use Net::Jabber;

    sub x {
      my $x = new Net::Jabber::X(@_);
      .
      .
      .
    }

  You now have access to all of the retrieval functions available.

  To create a new x to send to the server:

    use Net::Jabber;

    $X = new Net::Jabber::X();
    $XType = $X->NewQuery( type );
    $XType->SetXXXXX("yyyyy");

  Now you can call the creation functions for the X, and for the <query/>
  on the new Query object itself.  See below for the <x/> functions, and
  in each query module for those functions.

  For more information about the array format being passed to the CallBack
  please read the Net::Jabber::Client documentation.

=head2 Basic functions

    $X->SetDelegates("com:ti:foo"=>"TI::Foo",
                     "bar:foo"=>"Foo::Bar");

=head2 Retrieval functions

    $xmlns     = $X->GetXMLNS();

    $str       = $X->GetXML();
    @x         = $X->GetTree();

=head2 Creation functions

    $X->SetXMLNS("jabber:x:delay");

    $X->SetDelegates("com:bar:foo"=>"Foo::Bar::X");

=head1 METHODS

=head2 Basic functions

  SetDelegates(hash) - sets the appropriate delegate for each namespace
                       in the list.  Format is namspace=>package.  When
                       a function is called against the X object and
                       it is not defined in this package, the delegate
                       is searched for that function.  This allows for
                       easy development of a package to handle new <x/>
                       tags for what ever application.

=head2 Retrieval functions

  GetXMLNS() - returns a string with the namespace of the query that
               the <x/> contains.

  GetXML() - returns the XML string that represents the <x/>. This 
             is used by the Send() function in Client.pm to send
             this object as a Jabber X.

  GetTree() - returns an array that contains the <x/> tag in XML::Parser 
              Tree format.

=head2 Creation functions

  SetXMLNS(string) - sets the xmlns of the <x/> to the string.

=head1 CUSTOM X MODULES

  Part of the flexability of this module is that you can write your own
  module to handle a new namespace if you so choose.  The SetDelegates
  function is your way to register the xmlns and which module will
  provide the missing access functions.

  To register your namespace and module, you can either create an X
  object and register it once, or you can use the SetDelegates
  function in Client.pm to do it for you:

    my $X = new Net::Jabber::X();
    $X->SetDelegates("blah:blah"=>"Blah::Blah");

  or

    my $Client = new Net::Jabber::Client();
    $Client->SetDelegates("blah:blah"=>"Blah::Blah");

  Once you have the delegate registered you need to define the access
  functions.  Here is a an example module:

    package Blah::Blah;

    sub new {
      my $proto = shift;
      my $class = ref($proto) || $proto;
      my $self = { };
      $self->{VERSION} = $VERSION;
      bless($self, $proto);
      return $self;
    }

    sub SetBlah {
      my $delegate = shift;
      my $owner = shift;

    }

    sub GetBlah {
      my $delegate = shift;
      my $owner = shift;
      return &Net::Jabber::GetXMLData("value",$owner->{X},"blah","");
    }

    1;

  Now when you create a new X object and call GetBlah on that object
  it will AUTOLOAD the above function and handle the request.

=head1 AUTHOR

By Ryan Eatmon in January of 2000 for http://jabber.org..

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

require 5.003;
use strict;
use Carp;
use vars qw($VERSION $AUTOLOAD %DELEGATES);

$VERSION = "0.8.1";

use Net::Jabber::X::Delay;
($Net::Jabber::X::Delay::VERSION < $VERSION) &&
  die("Net::Jabber::X::Delay $VERSION required--this is only version $Net::Jabber::X::Delay::VERSION");

#use Net::Jabber::X::Ident;
#($Net::Jabber::X::Ident::VERSION < $VERSION) &&
#  die("Net::Jabber::X::Ident $VERSION required--this is only version $Net::Jabber::X::Ident::VERSION");

#use Net::Jabber::X::Oob;
#($Net::Jabber::X::Oob::VERSION < $VERSION) &&
#  die("Net::Jabber::X::Oob $VERSION required--this is only version $Net::Jabber::X::Oob::VERSION");

$DELEGATES{'jabber:x:delay'} = "Net::Jabber::X::Delay";
$DELEGATES{'jabber:x:ident'} = "Net::Jabber::X::Ident";
$DELEGATES{'jabber:x:oob'}   = "Net::Jabber::X::Oob";

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = { };
  
  $self->{VERSION} = $VERSION;

  bless($self, $proto);

  if (@_ != ("")) {
    my @temp = @_;
    $self->{X} = \@temp;
    $self->GetDelegate();
  } else {
    $self->{X} = [ "x" , [{}]];
  }

  return $self;
}


##############################################################################
#
# AUTOLOAD - This function calls the delegate with the appropriate function
#            name and argument list.
#
##############################################################################
sub AUTOLOAD {
  my $self = $_[0];
  return if ($AUTOLOAD =~ /::DESTROY$/);
  $AUTOLOAD =~ s/^.*:://;
  $self->{DELEGATE}->$AUTOLOAD(@_);
}


##############################################################################
#
# GetDelegate - sets the delegate for the AUTOLOAD function based on the
#               namespace.
#
##############################################################################
sub GetDelegate {
  my $self = shift;
  my $xmlns = $self->GetXMLNS();
  return if $xmlns eq "";
  if (exists($DELEGATES{$xmlns})) {
    eval("\$self->{DELEGATE} = new ".$DELEGATES{$xmlns}."()");
  }
}


##############################################################################
#
# SetDelegates - adds the namespace and corresponding pacakge onto the list
#                of availbale delegates based on the namespace.
#
##############################################################################
sub SetDelegates {
  my $self = shift;
  my (%delegates) = @_;
  my $delegate;
  foreach $delegate (keys(%delegates)) {
    $Net::Jabber::X::DELEGATES{$delegate} = $delegates{$delegate};
  }
}


##############################################################################
#
# GetXMLS - returns the namespace of the <x/>
#
##############################################################################
sub GetXMLNS {
  my $self = shift;
  return &Net::Jabber::GetXMLData("value",$self->{X},"","xmlns");  
}


##############################################################################
#
# GetXML - returns the XML string that represents the data in the XML::Parser
#          Tree.
#
##############################################################################
sub GetXML {
  my $self = shift;
  return &Net::Jabber::BuildXML(@{$self->{X}});
}


##############################################################################
#
# GetTree - returns the XML::Parser Tree that is stored in the guts of
#           the object.
#
##############################################################################
sub GetTree {
  my $self = shift;
  return @{$self->{X}};
}


##############################################################################
#
# SetXMLS - sets the namespace of the <x/>
#
##############################################################################
sub SetXMLNS {
  my $self = shift;
  my ($xmlns) = @_;
  
  &Net::Jabber::SetXMLData("single",$self->{X},"","",{"xmlns"=>$xmlns});
  $self->GetDelegate();
}


##############################################################################
#
# debug - prints out the XML::Parser Tree in a readable format for debugging
#
##############################################################################
sub debug {
  my $self = shift;

  print "debug X: $self\n";
  &Net::Jabber::printData("debug: \$self->{X}->",$self->{X});
}

1;