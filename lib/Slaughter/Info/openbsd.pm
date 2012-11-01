#!/usr/bin/perl -w

=head1 NAME

Slaughter::Info::openbsd - Perl Automation Tool Helper openbsd info implementation

=cut

=head1 SYNOPSIS

This module is the openbsd version of the Slaughter information-gathering
module.

Modules beneath the C<Slaughter::Info> namespace are loaded when slaughter
is executed, they are used to populate a hash with information about
the current host.

This module is loaded only on openbsd systems, and will determine such details
as the local hostname, the free RAM, any IP addresses, etc.

Usage is:

=for example begin

    use Slaughter::Info::openbsd;

    my $obj  = Slaughter::Info::openbsd->new();
    my $data = $obj->getInformation();

    # use info now ..
    print "We have $data->{'ip_count'} IPv4 addresses.\n";o
    print "We have $data->{'ip6_count'} IPv6 addresses.\n";o

=for example end

When this module is used an attempt is also made to load the module
C<Slaughter::Info::Local::openbsd> - if that succeeds it will be used to
augment the information discovered and made available to slaughter
policies.

=cut


=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2010-2012 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut


use strict;
use warnings;


package Slaughter::Info::openbsd;




=head2 new

Create a new instance of this object.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );
    return $self;

}


=head2 getInformation

This function retrieves meta-information about the current host.

The return value is a hash-reference of data determined dynamically.

=cut

sub getInformation
{
    my ($self) = (@_);

    #
    #  The data we will return.
    #
    my $ref;

    #
    #  Call "hostname" to determine the local hostname.
    #
    $ref->{ 'fqdn' } = `hostname`;
    chomp( $ref->{ 'fqdn' } );

    #
    #  Get the hostname and domain name as seperate strings.
    #
    if ( $ref->{ 'fqdn' } =~ /^([^.]+)\.(.*)$/ )
    {
        $ref->{ 'hostname' } = $1;
        $ref->{ 'domain' }   = $2;
    }
    else
    {

        #
        #  Better than nothing, right?
        #
        $ref->{ 'hostname' } = $ref->{ 'fqdn' };
        $ref->{ 'domain' }   = $ref->{ 'fqdn' };
    }


    #
    #  Kernel version.
    #
    $ref->{ 'release' } = `uname -r`;
    chomp( $ref->{ 'release' } );

    #
    #  Are we i386/amd64?
    #
    $ref->{ 'arch' } = `uname -p`;
    chomp( $ref->{ 'arch' } );

    #
    #  Count of IPv4/IPv6 addresses.
    #
    my $ipv4 = 1;
    my $ipv6 = 1;

    #
    #  Parse the output of /sbin/ifconfig.
    #
    foreach my $line ( split( /[\r\n]/, `ifconfig` ) )
    {
        chomp($line);
        next unless ( $line =~ /(inet|inet6)/ );

        if ( $line =~ /inet ([^ \t]+)/ )
        {
            my $addr = $1;
            next if ( $addr =~ /^127\./i );
            $ref->{ 'ip_' . $ipv4 } = $addr;
            $ipv4 += 1;
        }
        if ( $line =~ /inet6 ([^ \t]+)/ )
        {
            my $addr = $1;
            next if ( $addr =~ /fe80/i );
            $ref->{ 'ip6_' . $ipv6 } = $addr;
            $ipv6 += 1;
        }
    }

    # counts of addresses
    $ref->{ 'ip_count' }  = $ipv4;
    $ref->{ 'ip6_count' } = $ipv6;

    return ($ref);
}



1;
