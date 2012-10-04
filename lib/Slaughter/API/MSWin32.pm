#!/usr/bin/perl -w

=head1 NAME

Slaughter::MSWin32 - Perl Automation Tool Helper Linux implementation

=cut

=head1 SYNOPSIS

This module implements the Win32-specific versions of the Slaughter
administration tool.

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


#
#  The modules we use, and the internal functions are defined
# in this module.
#
use Slaughter::Private;

use File::Copy;


sub Alert
{
    print "Alert - not implemented for $^O\n";
}


##
##
##  Public:  Append a line to a file, if that line is not already present.
##
##  Parameters:
##       File   The filename to examine.
##       Line   The line to search for, or append.
##
##
sub AppendIfMissing
{
    my (%params) = (@_);

    my $line  = $params{ 'Line' };
    my $file  = $params{ 'File' };
    my $found = 0;

    if ( open( my $handle, "<", $file ) )
    {

        foreach my $read (<$handle>)
        {
            chomp($read);

            if ( $line eq $read )
            {
                $found = 1;
            }
        }
        close($handle);
    }


    #
    #  If it wasn't found append
    #
    if ( !$found )
    {
        if ( open( my $handle, ">>", $file ) )
        {
            print $handle $line . "\n";
            close($handle);
            return 1;
        }
        else
        {
            return -1;
        }
    }
    return 0;
}


##
##
##  Public:  Comment every line of a file matching a regexp.
##
##  Parameters:
##       File      The filename to examine.
##       Pattern   The pattern to search for.
##       Comment   The string to use to insert the coomment
##
##
sub CommentLinesMatching
{
    my (%params) = (@_);

    my $pattern = $params{ 'Pattern' };
    my $comment = $params{ 'Comment' } || "#";
    my $file    = $params{ 'File' };

    if ( open( my $handle, "<", $file ) )
    {
        my @lines;
        my $found = 0;

        foreach my $read (<$handle>)
        {
            chomp($read);

            if ( $read =~ /$pattern/ )
            {
                $read = $comment . $read;
                $found += 1;
            }
            push( @lines, $read );
        }
        close($handle);

        #
        #  Now write out the possibly modified fils.
        #
        if ($found)
        {
            if ( open( my $handle, ">", $file ) )
            {
                foreach my $line (@lines)
                {
                    print $handle $line . "\n";
                }
                close($handle);

                return $found;
            }
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return -1;
    }
}



##
##  Public:  Delete files from a given root directory matching a given pattern.
##
##  Parameters:
##       Root      The root directory to search within.
##       Pattern   The pattern to look for.
##
##
sub DeleteFilesMatching
{
    my (%params) = (@_);

    my $root    = $params{ 'Root' }    || return;
    my $pattern = $params{ 'Pattern' } || return;
    my $removed = 0;

    $verbose && print "Removing files matching $pattern from $root\n";

    #
    #  Reference to our routine.
    #
    my $wanted = sub {
        my $file = $File::Find::name;
        if ( basename($file) =~ /$pattern/ )
        {
            unlink($file);

            $removed += 1;
            $verbose &&
              print "\tRemoving $file\n";
        }
    };

    #
    #
    #
    File::Find::find( { wanted => $wanted, no_chdir => 1 }, $root );

    return ($removed);
}




##
##  Public:  Delete files in a given root directory older than N days.
##
##  Parameters:
##       Root    The directory to cleanup.
##       Age     The age of files above which they should be removed.
##
##  NOTE:  This function is not recursive, and ignores directories.
##
sub DeleteOldFiles
{
    my (%params) = (@_);

    my $root = $params{ 'Root' } || return;
    my $age  = $params{ 'Age' }  || return;
    my $removed = 0;

    $verbose && print "Removing files older than $age days from $root\n";

    #
    #  Find each file.
    #
    foreach my $file ( sort( glob( $root . "/*" ) ) )
    {

        # skip directories
        next if ( -d $file );

        my $fage = -M $file;

        if ( $fage >= $age )
        {
            $verbose &&
              print "\tRemoving $file age $fage is >= $age\n";

            unlink($file);
            $removed += 1;
        }
    }

    $verbose && print "\tRemoved $removed files\n";

    return $removed;
}



##
##  Public
##
##  Fetch a file, via HTTP.
##
##
sub FetchFile
{
    my (%params) = (@_);

    $verbose && print "FetchFile( $params{'Source'} );\n";

    my $src = $params{ 'Source' };
    my $dst = $params{ 'Dest' };

    if ( !$src || !$dst )
    {
        $verbose && print "\tMissing source or destination.\n";
        return 0;
    }

    #
    #  Fetch the source.
    #
    my $content = fetchURL( $protocol . $server . $prefix . "/files/" . $src );

    if ( !defined($content) )
    {
        $verbose && print "\tFailed to fetch.\n";
        return 0;
    }


    #
    #  If we're to expand content do so.
    #
    if ( ( defined $params{ 'Expand' } ) && ( $params{ 'Expand' } =~ /true/i ) )
    {
        $verbose && print "\tExpanding content with Slaughter::Template\n";

        my $template =
          Slaughter::Template->new( TYPE   => 'string',
                                    SOURCE => $content );

        $content = $template->fill_in( HASH => %template );
    }
    else
    {
        $verbose && print "\tUsing contents literally; no template expansion\n";
    }


    #
    #  OK now we want to write out the content to a temporary location.
    #
    my ( $handle, $name ) = File::Temp::tempfile();
    open my $fh, ">", $name or
      return;
    binmode($fh);
    print $fh $content;
    close($fh);

    #
    #  We have the file, does it differ from the live filesystem?
    #  Or is the local copy missing?
    #
    #  If so we'll move the new file into place.
    #
    my $replace = 0;

    if ( !-e $dst )
    {
        $verbose && print "\tDestination not already present.\n";
        $replace = 1;
    }
    else
    {
        my $cur = checksumFile($dst);
        my $new = checksumFile($name);

        if ( $new ne $cur )
        {
            $replace = 1;

            $verbose && print "\tContents don't match - will replace\n";
        }
        else
        {
            $verbose && print "\tCurrent file equals new one - not replacing\n";
        }
    }

    #
    #  Replace
    #
    if ($replace)
    {
        if ( -e $dst )
        {
            $verbose && print "\tMoving existing file out of the way.\n";
            copy( $dst, $dst . ".old" );
            unlink($dst);
            RunCommand( Cmd => "move $dst $dst.old" );
        }


        #
        #  Ensure the destination directory exists.
        #
        my $dir = dirname($dst);
        if ( !-d $dir )
        {
            mkpath( $dir, { verbose => 0 } );
        }


        $verbose && print "\tReplacing $dst\n";
        copy( $name, $dst );
        unlink($name);
    }

    #
    #  If we didn't replace then we'll remove the temporary file
    # which would otherwise be orphaned.
    #
    if ( -e $name )
    {
        unlink($name);
    }

    return ($replace);
}


##
##  Public:  See if file contents match either a line or a regexp.
##
##  Parameters:
##       File     The file to examine.
##       Pattern  The pattern to look for (regexp).
##       Line     A literal line match to look for.
##
##  Returns 0 if no match, otherwise the number of matches.
##
##
sub FileMatches
{
    my (%params) = (@_);

    my $file    = $params{ 'File' }    || return;
    my $pattern = $params{ 'Pattern' } || undef;
    my $line    = $params{ 'Line' }    || undef;
    my $count   = 0;

    if ( !defined($line) && !defined($pattern) )
    {
        return -1;
    }

    #
    #  Open
    #
    if ( open( my $handle, "<", $file ) )
    {
        foreach my $read (<$handle>)
        {
            chomp($read);

            if ( defined($line) && ( $line eq $read ) )
            {
                $count += 1;
            }
            if ( defined($pattern) && ( $read =~ /$pattern/ ) )
            {
                $count += 1;
            }
        }
        close($handle);

        return ($count);
    }
    else
    {
        return -1;
    }
}

##
##
##  Public:  Find a binary upon the system, or specified, path.
##
##  Parameters:
##       binary  The name of the binary to locate.  Mandatory.
##       path    The path to search.  Optional
##
##
sub FindBinary
{
    my (%params) = (@_);

    my $binary = $params{ 'binary' } || return;
    my $path = $params{ 'path' } ||
      $ENV{ 'PATH' };

    foreach my $dir ( split( /;/, $path ) )
    {
        if ( ( -d $dir ) && ( -x ( $dir . "\\" . $binary ) ) )
        {
            return $dir . "\\" . $binary;
        }
        if ( ( -d $dir ) && ( -x ( $dir . "\\" . $binary . ".exe" ) ) )
        {
            return $dir . "\\" . $binary . ".exe";
        }
        if ( ( -d $dir ) && ( -x ( $dir . "\\" . $binary . ".bat" ) ) )
        {
            return $dir . "\\" . $binary . ".bat";
        }
        if ( ( -d $dir ) && ( -x ( $dir . "\\" . $binary . ".cmd" ) ) )
        {
            return $dir . "\\" . $binary . ".cmd";
        }
    }

    return undef;
}


##
##
##  Public:  Execute a command, via system().
##
##  Parameters:
##       Cmd  The command to execute.
##
##
##
sub RunCommand
{
    my (%params) = (@_);

    my $cmd = $params{ 'Cmd' } || return;

    $verbose && print "runCommand( $cmd )\n";

    system($cmd );
}


sub InstallPackage
{
    print "InstallPackage - not implemented for $^O\n";
}


sub RemovePackage
{
    print "RemovePackage - not implemented for $^O\n";
}


sub PackageInstalled
{
    print "PackageInstalled - not implemented for $^O\n";
}


sub Mounts
{
    print "Mounts - not implemented for $^O\n";
}


sub PercentageUsed
{
    print "PercentageUsed - not implemented for $^O\n";
}


sub SetPermissions
{
    print "SetPermissions - not implemented for $^O\n";
}


sub UserExists
{
    print "UserExists - not implemented for $^O\n";
}


sub UserDetails
{
    print "UserDetails - not implemented for $^O\n";
}


1;
