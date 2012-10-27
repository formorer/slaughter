
=head1 NAME

Slaughter::Transport::svn - Transport class.

=head1 SYNOPSIS

This transport copes with cloning a remote subversion repository to the local filesystem.

=cut

=head1 DESCRIPTION

This module uses the Slaughter::Transport::revisionControl base-class in such
a way as to offer a Subversion-based transport.

All the implementation, except for the setup of some variables, comes from that
base class.

=cut

=head1 IMPLEMENTATION

The following commands are set in the constructor, and these are sufficient
for our base-class to implement the full transport:

=over 8

=item cmd_clone

This is set to "svn checkout".

=item cmd_update

This is set to "svn update".

=item cmd_version

This is set to "svn --version".

=item name

This is set to "svn".

=back

=cut

=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2012 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut


package Slaughter::Transport::svn;
use base 'Slaughter::Transport::revisionControl';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);


require Exporter;
require AutoLoader;

@ISA    = qw(Exporter AutoLoader);
@EXPORT = qw();

($VERSION) = '0.1';


use strict;
use warnings;



=head2 new

Create a new instance of this object.

=cut

sub new
{

    #
    #  Unpleasant setup of the parent class
    #
    my $classname = shift;
    my $self      = {};
    bless $self, $classname;
    $self = Slaughter::Transport::revisionControl->new(@_);

    #
    # The name of our derived transport.
    #
    $self->{ 'name' } = "svn";

    #
    # The command to invoke the version of our revision control system.
    #
    # Used to test that it is installed.
    #
    $self->{ 'cmd_version' } = "svn --version";

    #
    # The command to clone our remote repository.
    #
    $self->{ 'cmd_clone' } = "svn checkout ";
    $self->{ 'cmd_clone' } .= " $self->{'transportargs'} "
      if ( $self->{ 'transportargs' } );

    #
    #  The command to update our repository - NOT USED
    #
    $self->{'cmd_update'} = "svn update";

    #
    #  All done.
    #
    return $self;

}


1;
