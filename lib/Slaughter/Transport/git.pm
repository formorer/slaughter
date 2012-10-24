
=head1 NAME

Slaughter::Transport::git - Transport class.

=head1 SYNOPSIS

...

=cut

=head1 DESCRIPTION

=cut


package Slaughter::Transport::git;

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

    #
    # Explicitly ensure we have no error.
    #
    $self->{ 'error' } = "";

    bless( $self, $class );
    return $self;

}




sub name
{
    return "git";
}

sub isAvailable
{
    return 0;
}
sub error
{
}
