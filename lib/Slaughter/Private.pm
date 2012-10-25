#!/usr/bin/perl -w

=head1 NAME

Slaughter::Private - Perl Automation Tool Helper Internal Details

=cut

=head1 SYNOPSIS

This module implements the non-public API of the Slaughter administration tool.

Users are not expected to use, touch, browse, or modify the code in this module!

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



use File::Basename qw/ dirname basename /;
use File::Find;
use File::Path qw/ mkpath /;
use File::Temp qw/ tempfile /;
use LWP::UserAgent;
use Text::Template;



=head2 fetchFromTransport

This primitive will retrieve a file from the central server, using
the specified transport.

The various transports are pluggable and live beneath the Slaughter::Transport
namespace.

=for example begin

  FetchFromTransport( "/etc/motd" );

=for example end

A single parameter is accepted which is the name of the file
to fetch, relative to the transport's root.

On success the file's contents are returned.  On failure undef
is returned.

=cut

sub fetchFromTransport
{
    my ($url) = (@_);

    $verbose && print "\tfetchFromTransport( $url ) \n";

    #
    #  Make requests for:
    #
    #  url.$fqdn
    #  url.$hostname
    #  url.$os
    #  url.$arch
    #  url
    #
    #  Return the first one that matches, if any do.
    #
    my @urls;

    push( @urls, $url . "." . $fqdn );
    push( @urls, $url . "." . $hostname );
    push( @urls, $url . "." . $os );
    push( @urls, $url . "." . $arch );
    push( @urls, $url );


    foreach my $attempt (@urls)
    {
        my $content = $TRANSPORT->fetchContents($attempt);

        if ( defined($content) )
        {
            $verbose && print "\t$attempt OK\n";
            return ($content);
        }
        else
        {
            $verbose && print "\t$attempt failed - continuing\n";
        }
    }

    #
    #  Failed
    #
    $verbose && print "\tFailed to fetch any of our attempts for $url\n";
    return undef;
}





=head2 checksumFile

This primitive will attempt to calculate and return the SHA digest of
the specified file.

The method attempts to use both L<Digest::SHA> & L<Digest::SHA1>,
returning the result from the first one which is present.

=for example begin

  checksumFile( "/etc/motd" );

=for example end

A single parameter is accepted which is the name of the file
to has.

On success the hash is returned, on failure undef is returned.

=cut

sub checksumFile
{
    my ($file) = (@_);

    my $hash = undef;

    foreach my $module (qw! Digest::SHA Digest::SHA1 !)
    {

        # If we succeeded in calculating the hash we're done.
        next if ( defined($hash) );

        # Attempt to load the module
        my $eval = "use $module;";
        eval($eval);

        #
        #  Loaded module, with no errors.
        #
        if ( !$@ )
        {
            my $object = $module->new;

            open my $handle, "<", $file or
              die "Failed to read $file to hash contents with $module - $!";
            $object->addfile($handle);
            close($handle);

            $hash = $object->hexdigest();
        }

    }

    return ($hash);
}




1;
