
=head1 NAME

Slaughter::Transport::hg - Transport class.

=head1 SYNOPSIS

This transport copes with cloning a remote mercurial repository to the local filesystem.

=cut

=head1 DESCRIPTION

When loaded this transport will clone a remote mercurial repository to a local
directory.

It is assumed that the repository cloning will require zero special arguments,
and zero prompting.  If required such things my be specified via "--transport-args".

=cut


package Slaughter::Transport::hg;

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



=head2 name

return the name of this module.

=cut

sub name
{
    return "hg";
}



=head isAvailable

Return whether this transport is available.

This module is available iff an executable hg is found.

=end doc

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

    if ( system("hg --version >/dev/null 2>/dev/null") == 0 )
    {

        $self->{ 'error' } =
          "Failed to execute 'hg --version', is hg installed?\n";
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
    return ( $self->{ 'error' } || undef );
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

    #
    #  Do the cloning
    #
    if ( system("hg clone $self->{'transportargs'} $repo $dst") != 0 )
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
