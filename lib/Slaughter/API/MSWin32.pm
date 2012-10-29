#!/usr/bin/perl -w

=head1 NAME

Slaughter::API::MSWin32 - Perl Automation Tool Helper Windows implementation

=cut

=head1 SYNOPSIS

This module implements the Win32-specific versions of the Slaughter primitives.

When the module "Slaughter;" is used what happens is that an OS-specific module
is loaded:

=for example begin

  my $module = "Slaughter::API::$^O";
  print "We'd load $module\n";

=for example end

This module is the one that gets loaded upon Windows systems, although it
has only been tested under Strawberry Perl.

The coverage is adequate, but package-related primitives are not implemented.

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


#
#  The modules we use, and the internal functions are defined
# in this module.
#
use Slaughter::Private;

use File::Copy;




=head2 Alert

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub Alert
{
    print "Alert - not implemented for $^O\n";
}




=head2 AppendIfMissing

This primitive will open a local file, and append a line to it if it is not
already present.

=for example begin

  AppendIfMissing( File => "/etc/hosts.allow",
                   Line => "All: 1.2.3.4" );

=for example end

The following parameters are available:

=over

=item File [mandatory]

The filename which should be examined and potentially updated.

=item Line [mandatory]

The line which should be searched for and potentially appended.

=back

=cut

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




=head2 CommentLinesMatching

This primitive will open a local file, and comment out any line which matches
the specified regular expression.

=for example begin

  if ( CommentLinesMatching( Pattern => "telnet|ftp",
                             File    => "/etc/inetd.conf" ) )
  {
        RunCommand( Cmd => "/etc/init.d/inetd restart" );
  }

=for example end

The following parameters are available:

=over

=item Comment [default: "#"]

The value to comment out the line with.

=item File [mandatory]

The filename which should be examined and potentially updated.

=item Pattern [mandatory]

The regular expression to match with.

=back

The return value of this function is the number of lines updated,
or -1 if the file could not be opened.

=cut

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



=head2 DeleteFilesMatching

This primitive will delete files with names matching a particular
pattern, recursively.

=for example begin

  #
  #  Delete *.dpkg-old - recursively
  #
  DeleteFilesMatching( Root    => "/etc",
                       Pattern => "\\.dpkg-old\$" );

=for example end

The following parameters are available:

=over

=item Root [mandatory]

The root directory from which the search begins.

=item Pattern [mandatory]

The regular expression applied to filenames.

The return value of this function is the number of files deleted.

=back

=cut

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



=head2 DeleteOldFiles

This primitive will delete files older than the given number of
days from the specified directory.

Note unlike L</DeleteFilesMatching> this function is not recursive.

=for example begin

  #
  #  Delete files older than ten days from /tmp.
  #
  DeleteFilesMatching( Root  => "/tmp",
                       Age   => 10 );

=for example end

The following parameters are available:

=over


=item Age [mandatory]

The age of files which should be deleted.

=item Root [mandatory]

The root directory from which the search begins.

The return value of this function is the number of files deleted.

=back

=cut

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



=head2 FetchFile

The FetchFile primitive is used to copy a file from the remote server
to the local system.   The file will have be moved into place if the
local file is missing OR if it exists but contains different contents
to the remote version.

The following is an example of usage:

=for example begin

    if ( FetchFile( Source => "/etc/motd",
                    Dest   => "/etc/motd",
                    Owner  => "root",
                    Group  => "root",
                    Mode   => "644" ) )
    {
        # File was created/updated.
    }
    else
    {
        # File already existed locally with the same contents.
    }

=for example end

The following parameters are available:

=over

=item Dest [mandatory]

The destination file to write to, on the local system.

=item Expand [default: false]

This is used to enable template-expansion, documented later.

=item Group

The unix group which should own the file.

=item Mode

The Unix mode to set for the file.  If this doesn't start with "0" it will
be passed through the perl "oct" function.

=item Owner

The Unix owner who should own the file.

=item Source [mandatory]

The path to the remote file.  This is relative to the /files/ prefix beneath
the transport root.

=back

When a file fetch is attempted several variations are attempted, not just the
literal filename.  The first file which exists and matches is returned, and the
fetch is aborted:

=over 8

=item /etc/motd.$fqdn

=item /etc/motd.$hostname

=item /etc/motd.$os

=item /etc/motd.$arch

=item /etc/motd

=back

Template template expansion involves the use of the L<Text::Template> module, of
"Expand => true".  This will convert the following text:

=for example begin

   # This is the config file for SSHD on ${fqdn}

=for example end

To the following, assuming the local host is called "precious.my.flat":

=for example begin

   # This is the config file for SSHD on precious.my.flat

=for example end


=cut

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
    my $content = fetchFromTransport($src);

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
        $verbose && print "\tExpanding content with Text::Template\n";

        my $template =
          Text::Template->new( TYPE   => 'string',
                               SOURCE => $content );

        $content = $template->fill_in( HASH => %template );

        if ( !$content )
        {
            print "Template expansion failed " . $Text::Template::ERROR . "\n";
        }

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
            RunCommand( Cmd => "mv $dst $dst.old" );
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
        RunCommand( Cmd => "mv $name $dst" );
    }

    #
    #  Change Owner/Group/Mode if we should
    #
    SetPermissions( File  => $dst,
                    Owner => $params{ 'Owner' },
                    Group => $params{ 'Group' },
                    Mode  => $params{ 'Mode' } );

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



=head2 FileMatches

This allows you to test whether the contents of a given file match
either a literal line of text, or a regular expression.

=for example begin

  if ( FileMatches( File    => "/etc/sudoers",
                    Pattern => "steve" ) )
  {
     # OK "steve" is in sudoers.  Somewhere.
  }

=for example end

The following parameters are available:

=over


=item File [mandatory]

The name of the file to test.

=item Line [or Pattern mandatory]

A line to look for within the file literally.

=item Pattern [or Line mandatory]

A regular expression to match against the file contents.

=back

The return value of this function will be the number of matches
found - regardless of whether a regular expression or literal
match is in use.

=cut

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




=head2 FindBinary

This method allows you to search for an executable upon your
system $PATH, or a supplied alternative string.

=for example begin

  if ( FindBinary( Binary => "ls" ) )
  {
      # we have ls!
  }

=for example end

The following parameters are available:

=over


=item Binary [mandatory]

The name of the binary file to find.

=item Path [default: $ENV{'PATH'}]

This is assumed to be a semi-colon deliminated list of directories to search
for the binary within.

=back

If the binary is found the full path will be returned, otherwise undef.

=cut

sub FindBinary
{
    my (%params) = (@_);

    my $binary = $params{ 'Binary' } || $params{ 'binary' } || return;
    my $path = $params{ 'Path' } ||
      $params{ 'path' } ||
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




=head2 InstallPackage

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub InstallPackage
{
    print "InstallPackage - not implemented for $^O\n";
}



=head2 Mounts

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub Mounts
{
    print "Mounts - not implemented for $^O\n";
}



=head2 PackageInstalled

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub PackageInstalled
{
    print "PackageInstalled - not implemented for $^O\n";
}




=head2 PercentageUsed

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub PercentageUsed
{
    print "PercentageUsed - not implemented for $^O\n";
}



=head2 ReplaceRegexp

This primitive will open a local file, and replace any lines matching a given
regular expression.

=for example begin

  ReplaceRegexp( File    => "/etc/ssh/sshd_config",
                 Pattern => "^PermitRootLogin.*yes.*",
                 Replace => "PermitRootLogin no" );

=for example end

The following parameters are available:

=over

=item File [mandatory]

The filename which should be examined and potentially updated.

=item Pattern [mandatory]

The pattern to test and potentially replace.

=item Replace [mandatory]

The replacement text to use.

=back

The return value of this function is the number of lines updated,
0 if none, or -1 if the file could not be opened.

=cut

sub ReplaceRegexp
{
    my (%params) = (@_);

    my $pattern = $params{ 'Pattern' };
    my $replace = $params{ 'Replace' } || "";
    my $file    = $params{ 'File' };

    if ( open( my $handle, "<", $file ) )
    {
        my @lines;
        my $found = 0;

        # Read and replace as appropriate.
        foreach my $read (<$handle>)
        {
            chomp($read);
            my $orig = $read;

            if ( $replace =~ /\$/ )
            {
                $read =~ s/$pattern/$replace/gee;
            }
            else
            {
                $read =~ s/$pattern/$replace/g;
            }

            $found = 1 if ( $read ne $orig );

            push( @lines, $read );
        }
        close($handle);

        #  Now write out the possibly modified fils.
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



=head2 RemovePackage

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub RemovePackage
{
    print "RemovePackage - not implemented for $^O\n";
}




=head2 RunCommand

This primitive will execute a system command.

=for example begin

   RunCommand( Cmd => "/usr/bin/id" );

=for example end

The following parameters are available:

=over

=item Cmd [mandatory]

The command to execute.  If no redirection is present in the command to execute
then STDERR will be redirected to STDOUT automatically.

=back

The return value of this function is the result of the perl system function.

=cut

sub RunCommand
{
    my (%params) = (@_);

    my $cmd = $params{ 'Cmd' } || return;
    $verbose && print "RunCommand( $cmd )\n";

    system($cmd );
}




=head2 SetPermissions

This method allows the file owner,group, and mode-bits of a local file
to be changed.

=for example begin

  SetPermissions( File => "/etc/motd" ,
                  Owner => "root",
                  Group => "root",
                  Mode => "644" );

=for example end

The following parameters are supported:

=over 8

=item File [mandatory]

The filename to work with.

=item Group

The group to set as the owner for the file.

=item User

The username to set as the files owner.

=item Mode

The permissions mas to set for the file.  Note if this doesn't start with a leading
"0" then it will be passed through the "oct" function - this allows you to use the
obvious construct :

for example begin

  Mode => "755"

=for example end

=back

=cut

sub SetPermissions
{
    print "SetPermissions - not implemented for $^O\n";
}


=head2 UserExists

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub UserExists
{
    print "UserExists - not implemented for $^O\n";
}


=head2 UserDetails

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub UserDetails
{
    print "UserDetails - not implemented for $^O\n";
}


1;
