
=head1 NAME

Slaughter::Transport::local - Local filesystem transport class.

=head1 SYNOPSIS

This transport copes with fetching files and policies from the local filesystem.
It is designed to allow you to test policies on a single host.

=cut

=head1 DESCRIPTION

This transport is slightly different from the others supplied with slaughter
as it involves fetching files from the I<local> filesystem - so there is no
remote server involved at all.

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



package Slaughter::Transport::local;



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
    return ("local");
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

Fetch the policies which are required from local filesystem.

=cut

sub fetchPolicies
{
    my ($self) = (@_);

    #
    #  OK we've been given a local directory as our prefix - we append
    # the /default/policy to it, and process that file.
    #
    my $base = $self->{ 'prefix' } . "/policies/default.policy";
    if ( !-e $base )
    {
        $self->{ 'verbose' } && print "File not found: $base\n";
        return undef;
    }
    $self->{ 'verbose' } && print "Processing $base\n";


    #
    #  Open the file, and expand it.
    #
    my $content = "";

    open( my $handle, "<", $base );
    foreach my $line (<$handle>)
    {
        chomp($line);

        # Skip lines beginning with comments
        next if ( $line =~ /^([ \t]*)\#/ );

        # Skip blank lines
        next if ( length($line) < 1 );

        if ( $line =~ /FetchPolicy([ \t]+)(.*)[ \t]*\;/i )
        {
            my $inc = $2;
            $self->{ 'verbose' } &&
              print "\tFetching include: $inc\n";

            #
            #  OK this is an icky thing ..
            #
            if ( $inc =~ /\$/ )
            {
                $self->{ 'verbose' } &&
                  print "\tTemplate expanding file: $inc\n";

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
            my $policy =
              $self->readFile( $self->{ 'prefix' } . "/policies/" . $inc );
            if ( defined($policy) )
            {
                $content .= $policy;
            }
            else
            {
                $self->{ 'verbose' } && print "Policy inclusion failed: $inc\n";
            }
        }
        else
        {
            $content .= $line;
        }

        $content .= "\n";
    }
    close($handle);

    return ($content);
}



=head2 fetchContents

Fetch the contents of a remote URL, using HTTP basic-auth if we should

=cut

sub fetchContents
{
    my ( $self, $file ) = (@_);

    my $complete = $self->{ 'prefix' } . "/files/" . $file;

    return ( $self->readFile($complete) );
}


=begin doc

This is an internal/private method that merely returns the contents of the
named file - or undef on error.

=end doc

=cut

sub readFile
{
    my ( $self, $file ) = (@_);

    my $txt;

    open( my $handle, "<", $file ) or return undef;

    while ( my $line = <$handle> )
    {
        $txt .= $line;
    }
    close($handle);

    return $txt;
}



1;
