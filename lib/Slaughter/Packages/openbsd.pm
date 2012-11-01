#!/usr/bin/perl -w

=head1 NAME

Slaughter::Packages::openbsd - Abstractions for OpenBSD package management.

=cut

=head1 DESCRIPTION

This module contains code for dealing with system packages.

=cut



package Slaughter::Packages::openbsd;



=begin doc

  Create a new instance of this object.

=end doc

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



=begin doc

Does the local system match a known type?

=end doc

=cut

sub recognised
{
    my ($self) = (@_);

    #
    #  RPM?
    #
    if ( ( -x "/usr/sbin/pkg_add" ) &&
         ( -x "/usr/sbin/pkg_info" ) )
    {
        return ("pkg");
    }

    return undef;
}



=begin doc

Is the specified package installed?

=end doc

=cut

sub isInstalled
{
    my ( $self, $package ) = (@_);

    #
    #  Get the type of the system.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    my $found = 0;

    open my $handle, "-|", "/usr/sbin/pkg_info '$package'" or
      die "Failed to run pkg_info: $!";

    while ( my $line = <$handle> )
    {
        chomp($line);
        if ( $line =~ /^Information for inst:/ )
        {
            $found = 1;
        }
    }
    close($handle);

    return ($found);
}



=begin doc

Install a package upon the local system.

=end doc

=cut

sub installPackage
{
    my ( $self, $package ) = (@_);

    #
    #  Get the type of the system.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    system( "/usr/sbin/pkg_add", $package );
}



=begin doc

Remove the specified package.

=end doc

=cut

sub removePackage
{
    my ( $self, $package ) = (@_);

    #
    #  Get the type of the system.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    system( "/usr/sbin/pkg_delete", $package );
}


#
#  End of the module
#
1;
