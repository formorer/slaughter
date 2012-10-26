
=head1 NAME

Slaughter::Transport::revisionControl - Transport class.

=head1 SYNOPSIS

This is a base-class of a generic revision control based transport.

=cut

=head1 DESCRIPTION

This module implements the primitives which our transport API demands, but
it does so in an abstract fashion - allowing a derived class to specify the
actual commands used.

Therefore this module may be used by any revision-control system that allows
a checkout to be carried out by a command such as:

=for example begin

  $cmd repository-location destination-path

=for example end

In our derived Mercurical class we set the command to "hg clone", similarly
in the GIT class we use "git clone".

If required in the future this module may be updated to work with other
revision control systems, which have different requirements.

B<NOTE>:  A full checkout of the remote repository is inititated.
It is possible that a future extension to this module will allow an existing
repository to be uploaded in place.  If that is the case we'll need to use a
fixed transport-location, rather than a new directory per-execution.

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


package Slaughter::Transport::revisionControl;

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
    $self->{ 'error' } = undef;

    bless( $self, $class );
    return $self;

}


=head2 isAvailable

Is this module available?  This uses the details from the derived class
to determine whether I<that> transport is available.

=cut

sub isAvailable
{
    my ($self) = (@_);

    if ( !-d $self->{ 'transportdir' } )
    {
        $self->{ 'error' } =
          "Transport directory went away: $self->{'transportdir'}\n";
        return 0;
    }

    if ( system("$self->{'version'} >/dev/null 2>/dev/null") == 0 )
    {

        $self->{ 'error' } =
          "Failed to execute '$self->{'version'}', is $self->{'name'} installed?\n";
        return 1;
    }
    return 0;
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

Fetch the policies which are required from the remote server.

This method begins by looking for the file "default.policy" within
the top-level policies sub-directory of the repository.  Additional
included policies are fetched and interpolated.

=cut

sub fetchPolicies
{
    my ($self) = (@_);

    #
    #  The repository, and the destination to which we clone it.
    #
    my $repo = $self->{ 'prefix' };
    my $dst  = $self->{ 'transportdir' };

    $self->{ 'verbose' } && print "Fetching $repo into $dst\n";

    #
    #  Do the cloning
    #
    if ( system("$self->{'cmd'} $repo $dst") != 0 )
    {
        $self->{ 'verbose' } && print "FAILED TO FETCH POLICY";
        return undef;
    }

    #
    #  OK we've cloned the policies/files to the local filesystem
    # now we need to return to the caller an expanded policy file.
    #
    #
    #  The name of the policy we fetch by default.
    #
    my $base = $dst . "/policies/default.policy";
    if ( !-e $base )
    {
        $self->{ 'verbose' } && print "File not found, post-clone: $base\n";
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
            my $policy = $self->readFile( $dst . "/policies/" . $inc );
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



=head2 name

Return the name of this transport.  This will be setup in the derived class.

=cut

sub name
{
    my ($self) = (@_);
    return ( $self->{ 'name' } );
}



=begin doc

Internal/Private method.

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



=head2 fetchContents

Fetch a file from within the checked out repository.

Given a root repository of /path/to/repo/ the file is looked for beneath
/path/to/repo/files.

=cut

sub fetchContents
{
    my ( $self, $file ) = (@_);

    my $complete = $self->{ 'transportdir' } . "/files/" . $file;

    return ( $self->readFile($complete) );
}


1;
