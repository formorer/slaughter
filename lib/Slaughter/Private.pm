#!/usr/bin/perl -w

=head1 NAME

Slaughter::Private - Perl Automation Tool Helper Internal Details

=cut

=head1 SYNOPSIS

This module implements the non-public API of the Slaughter administration tool.

=cut


=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2010 by Steve Kemp.  All rights reserved.

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


##
##  PRIVATE
##
sub fetchURL
{
    my ($url) = (@_);

    $verbose && print "\tfetchURL( $url ) \n";

    my $ua = LWP::UserAgent->new( agent => $agent );
    $ua->env_proxy();


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
        my $response = $ua->get($attempt);

        if ( $response->is_success() )
        {
            $verbose && print "\t$attempt OK\n";
            return ( $response->decoded_content() );
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



##
##  Private
##
##  Produce the SHA1 hash of the named files contents.
##
## Notes:
##
## Attempt to use both of the modules Digest::SHA & Digest::SHA1
## stopping the first time one succeeds.
##
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
