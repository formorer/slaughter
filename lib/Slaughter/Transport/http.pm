
=head1 NAME

Slaughter::Transport::http - HTTP transport class.

=head1 SYNOPSIS

This transport copes with fetching files and policies from a remote server
using HTTP or HTTPS as a transport.

=cut

=head1 DESCRIPTION

This transport is slightly different to the others, as each file is fetched
on-demand, with no local filesystem access and no caching.

If HTTP Basic-Auth is required the appropriate details should be passed to
slaughter with the "--username" & "--password" flags.

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


use strict;
use warnings;



package Slaughter::Transport::http;

use LWP::UserAgent;



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
    $self->{ 'error' } = undef;

    bless( $self, $class );
    return $self;

}



=head2 name

return the name of this module.

=cut

sub name
{
    return ("http");
}



=head2 isAvailable

Return whether this transport is available.

As we're pure-perl it should be always available, so we unconditionally return 1.

=cut

sub isAvailable
{
    my ($self) = (@_);

    return 1;
}



=head2 error

Return the last error from the transport.

This is only set in L</isAvailable>.

=cut

sub error
{
    my ($self) = (@_);
    return ( $self->{ 'error' } );
}



=head2 fetchPolicies

Fetch the policies which are required from the remote HTTP site.

If we've been given a username & password we'll use HTTP basic-authentication.

=cut

sub fetchPolicies
{
    my ($self) = (@_);

    #
    #  The name of the policy we fetch by default.
    #
    my $url = $self->{ 'prefix' } . "/policies/default.policy";

    #
    #  Recursively expand the policy
    #
    my $contents = $self->fetchContents($url);

    if ( defined $contents )
    {
        my $ret = "";

        foreach my $line ( split( /[\r\n]/, $contents ) )
        {

            # Skip lines beginning with comments
            next if ( $line =~ /^([ \t]*)\#/ );

            # Skip blank lines
            next if ( length($line) < 1 );

            if ( $line =~ /FetchPolicy([ \t]+)(.*)[ \t]*\;/i )
            {
                my $inc = $2;
                $self->{ 'verbose' } &&
                  print "\tFetching include: $inc\n";

                ##
                ## If this doesn't look like a fully qualified URL ..
                ##
                if ( $inc !~ /^https?:\/\//i )
                {

                    #
                    #  Try to resolve the path.
                    #
                    if ( $url =~ /^(.*)\/([^\/]+)$/ )
                    {
                        $inc = $1 . "/" . $inc;

                        $self->{ 'verbose' } &&
                          print "\tTurned relative URL into: $inc\n";
                    }
                }

                #
                #  OK this is an icky thing ..
                #
                if ( $inc =~ /\$/ )
                {
                    $self->{ 'verbose' } &&
                      print "\tTemplate expanding URL: $inc\n";

                    #
                    #  Looks like the policy has a template variable in
                    # it.  We might be wrong.
                    #
                    foreach my $key ( sort keys %$self )
                    {
                        while ( $inc =~ /(.*)\$\Q$key\E(.*)/ )
                        {
                            $inc = $1 . $self->{ $key } . $2;

                            $self->{ 'verbose' } &&
                              print
                              "\tExpanded '\$$key' into '$self->{$key}' giving: $inc\n";
                        }
                    }
                }

                #
                #  Now fetch it, resolved or relative.
                #
                my $policy = $self->fetchContents($inc);
                if ( defined($policy) )
                {
                    $ret .= $policy;
                }
                else
                {
                    $self->{ 'verbose' } && print "Policy inclusion failed\n";
                }
            }
            else
            {
                $ret .= $line;
            }

            $ret .= "\n";

        }
        return ($ret);
    }
}



=head2 fetchContents

Fetch the contents of a remote URL, using HTTP basic-auth if we should

=cut

sub fetchContents
{
    my ( $self, $url ) = (@_);

    $self->{ 'verbose' } &&
      print "\tfetchURLContents( $url ) \n";


    #
    #  If the file isn't already qualified then setup the prefix.
    #
    #  In this module we'll internally use "fetchContents" in
    # "fetchPolicies" and in that case we'll resolve things to make
    # requests absolute.
    #
    #  Otherwise we'll ultimately end up being called by user-code which
    # will never be absolute
    #
    #   e.g. Policy -> Slaughter::Private -> Us
    #
    if ( $url !~ /^http/i )
    {
        $url = "$self->{'prefix'}/files/$url";

        $self->{ 'verbose' } &&
          print "\tExpanded to: $url  \n";
    }


    my $ua;

    if ( $LWP::UserAgent::VERSION < 6.00 )
    {
        $ua = LWP::UserAgent->new();
    }
    else
    {
        $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 1 } );
    }

    #
    # Use a proxy, if we should.
    #
    $ua->env_proxy();

    #
    #  Make a request, do it in this fashion so we can use Basic-Auth if we need to.
    #
    my $req = HTTP::Request->new( GET => $url );
    if ( $self->{ 'username' } && $self->{ 'password' } )
    {
        $req->authorization_basic( $self->{ 'username' },
                                   $self->{ 'password' } );
    }

    #
    #  Send the request
    #
    my $response = $ua->request($req);
    if ( $response->is_success() )
    {
        $self->{ 'verbose' } &&
          print "\tOK\n";
        return ( $response->decoded_content() );
    }

    #
    #  Failed
    #
    $self->{ 'verbose' } &&
      print "\tFailed to fetch: $url\n";
    return undef;
}


1;
