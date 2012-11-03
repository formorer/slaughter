#!/usr/bin/perl -w

=head1 NAME

Slaughter::Packages::openbsd - Abstractions for OpenBSD package management.

=cut

=head1 DESCRIPTION

This module contains code for dealing with system packages, using the system
commands C<pkg_add>, C<pkg_info>, etc.

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
    #  Get the type of the system, to make sure we can continue.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    #
    #  Found it installed?
    #
    my $found = 0;

    #
    #  Output the information about the package - this contains
    # "inst:" if the package is installed locally.
    #
    open my $handle, "-|", "/usr/sbin/pkg_info '$package' 2>/dev/null" or
      die "Failed to run pkg_info: $!";

    while ( my $line = <$handle> )
    {
        chomp($line);

        $found = 1 if ( $line =~ /^Information for inst:/ );
    }
    close($handle);

    #
    # Return the result.
    #
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
    #  Get the type of the system, to make sure we can continue.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    #
    #  Add the package.
    #
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
    #  Get the type of the system, to make sure we can continue.
    #
    my $type = $self->recognised();
    return 0 unless ( defined($type) );

    #
    #  Remove the package
    #
    system( "/usr/sbin/pkg_delete", $package );
}


#
#  End of the module
#
1;
