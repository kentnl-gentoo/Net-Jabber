package Net::Jabber::X::Ident;

=head1 NAME

Net::Jabber::X::Ident - Jabber X Ident Delegate

=head1 SYNOPSIS

  Net::Jabber::X::Ident is a companion to the Net::Jabber::X module.
  It provides the user a simple interface to set and retrieve all 
  parts of a Jabber X Ident.

=head1 DESCRIPTION

  To initialize the Ident with a Jabber <x/> you must pass it the 
  XML::Parser Tree array from the module trying to access the <x/>.  
  In the callback function:

    use Net::Jabber;

    sub iq {
      my $foo = new Net::Jabber::Foo(@_);

      my @xTags = $foo->GetX("jabber:x:ident");

      my $xTag;
      foreach $xTag (@xTags) {
	$xTag->....
	
      }
      .
      .
      .
    }

  You now have access to all of the retrieval functions available.

  To create a new Ident to send to the server:

    use Net::Jabber;

    $foo = new Net::Jabber::Foo();
    $x = $foo->NewX("jabber:x:ident");

  Now you can call the creation functions below.

  For more information about the array format being passed to the CallBack
  please read the Net::Jabber::Client documentation.

=head2 Retrieval functions

    $from      = $xTag->GetFrom();
    $stamp     = $xTag->GetStamp();
    $message   = $xTag->GetMessage();
    $xmlns     = $xTag->GetXMLNS();

=head2 Creation functions

    $xTag->SetX(FRom=>"jabber:foo.bar.com",
	        message=>"Stored offline");
    $xTag->SetFrom("bob@jabber.org");
    $xTag->SetStamp();
    $xTag->SetStamp("20000124T10:54:00");
    $xTag->SetMessage("Stored Offline");

=head1 METHODS

=head2 Retrieval functions

  GetFrom() - returns a string with the Jabber Identifier of the 
              person who added the ident.

  GetStamp() - returns a string that represents the time stamp of
               the ident.

  GetMessage() - returns a string with the message that describes
                 the nature of the ident.

  GetXMLNS() - returns a string with the namespace of the query that
               the <iq/> contains.

=head2 Creation functions

  SetX(from=>string,       - set multiple fields in the <x/> at one
       stamp=>string,        time.  This is a cumulative and over
       message=>string)      writing action.  If you set the "from"
                             attribute twice, the second setting is
                             what is used.  If you set the status, and
                             then set the priority then both will be in
                             the <x/> tag.  For valid settings read the
                             specific Set functions below.

  SetFrom(string) - sets the from attribute of the server adding the
                    ident.

  SetStamp(string) - sets the timestamp of the ident.  If the string is
                     left blank then the module adds the current date/time
                     in the proper format as the stamp.

  SetMessage(string) - sets description of the ident.
 
=head1 AUTHOR

By Ryan Eatmon in January of 2000 for http://jabber.org..

=head1 COPYRIGHT

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

require 5.003;
use strict;
use Carp;
use vars qw($VERSION);

$VERSION = "0.8.1";

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self = { };
  
  $self->{VERSION} = $VERSION;

  bless($self, $proto);

  return $self;
}


##############################################################################
#
# GetFrom - returns from of the jabber:x:ident
#
##############################################################################
sub GetFrom {
  my $self = shift;
  my $self = shift;
  return &Net::Jabber::GetXMLData("value",$self->{X},"","from");
}


##############################################################################
#
# GetStamp - returns the stamp of the jabber:x:ident
#
##############################################################################
sub GetStamp {
  my $self = shift;
  my $self = shift;
  return &Net::Jabber::GetXMLData("value",$self->{X},"","stamp");
}


##############################################################################
#
# GetMessage - returns the cdata of the jabber:x:ident
#
##############################################################################
sub GetMessage {
  my $self = shift;
  my $self = shift;
  return &Net::Jabber::GetXMLData("value",$self->{X},"","");
}


##############################################################################
#
# GetXMLS - returns the namespace of the jabber:x:ident
#
##############################################################################
sub GetXMLNS {
  my $self = shift;
  my $self = shift;
  return &Net::Jabber::GetXMLData("value",$self->{X},"","xmlns");  
}


##############################################################################
#
# SetX - takes a hash of all of the things you can set on a jabber:x:ident and
#        sets each one.
#
##############################################################################
sub SetX {
  my $self = shift;
  my $master = shift;
  my %x;
  while($#_ >= 0) { $x{ lc pop(@_) } = pop(@_); }

  $self->SetFrom($master,$x{from}) if exists($x{from});
  $self->SetStamp($master,$x{stamp}) if exists($x{stamp});
  $self->SetData($master,$x{data}) if exists($x{data});
}


##############################################################################
#
# SetFrom - sets the from attribute in the jabber:x:ident
#
##############################################################################
sub SetFrom {
  my $self = shift;
  my $self = shift;
  my ($from) = @_;
  &Net::Jabber::SetXMLData("single",$self->{X},"","",{from=>$from});
}


##############################################################################
#
# SetStamp - sets the stamp attribute in the jabber:x:ident
#
##############################################################################
sub SetStamp {
  my $self = shift;
  my $self = shift;
  my ($stamp) = @_;
  
  if ($stamp eq "") {
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $stamp = ($year + 1900).($mon+1).$mday."T".$hour.":".$min.":".$sec;
  }
  &Net::Jabber::SetXMLData("single",$self->{X},"","",{stamp=>$stamp});
}


##############################################################################
#
# SetMessage - sets the cdata of the jabber:x:ident
#
##############################################################################
sub SetMessage {
  my $self = shift;
  my $self = shift;
  my ($message) = @_;
  &Net::Jabber::SetXMLData("single",$self->{X},"","$message",{});
}


1;