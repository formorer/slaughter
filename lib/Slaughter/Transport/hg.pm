
=head1 NAME

Slaughter::Transport::hg - Transport class.

=head1 SYNOPSIS

...

=cut

=head1 DESCRIPTION

This module contains code for dealing with a single registered site
user.


=cut


package Slaughter::Transport::hg;

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
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};

    #
    #  Allow user supplied values to override our defaults
    #
    foreach my $key ( keys %supplied )
    {
        $self->{ lc $key } = $supplied{ $key };
    }

    bless( $self, $class );
    return $self;

}




sub name
{
    return "hg";
}
