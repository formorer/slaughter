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



use LWP::UserAgent;
use Digest::SHA1;
use File::Basename qw/ dirname basename /;
use File::Find;
use File::Temp qw/ tempfile /;
use File::Path qw/ mkpath /;
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
sub checksumFile
{
    my ($file) = (@_);

    my $sha1 = Digest::SHA1->new;
    open my $handle, "<", $file;
    $sha1->addfile($handle);
    close($handle);

    return ( $sha1->hexdigest() );

}




1;
