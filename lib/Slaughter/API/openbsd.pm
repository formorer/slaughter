#!/usr/bin/perl -w

=head1 NAME

Slaughter::API::openbsd - Perl Automation Tool Helper OpenBSD implementation

=cut

=head1 SYNOPSIS

This module is the one that gets loaded upon OpenBSD systems, and implements 100%
of the available primitives for such systems.

When the module "Slaughter;" is used what happens is that an OS-specific module
is loaded:

=for example begin

  my $module = "Slaughter::API::$^O";
  print "We'd load $module\n";

=for example end

We also attempt to load C<Slaughter::API::Local::openbsd>, where site-specific primitives
may be implemented.  If the loading of this additional module fails we report no error/warning.

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
# Standard libraries we require.
#
use File::Basename qw! basename dirname !;
use File::Find;
use File::Temp qw/ tempfile /;
use Text::Template;


#
#  The modules we use, and the internal functions are defined
# in this module.
#
use Slaughter::Private;

#
#  Package abstraction helpers.
#
use Slaughter::Packages::openbsd;



=head2 Alert

The alert primitive is used to send an email.  Sample usage is:

=for example begin

 Alert( Message => "Server on fire: $hostname",
             To => 'steve[at]steve.org.uk',
        Subject => "Alert: $fqdn" );

=for example end

The following parameters are available:

=over

=item From [default: "root"]

The sender address of the email.

=item Message [mandatory]

The content of the message to send

=item Sendmail [default: "/usr/lib/sendmail -t"]

The path to the sendmail binary.

=item Subject [mandatory]

The subject to send.

=item To [mandatory]

The recipient of the message.

=back

=cut

sub Alert
{
    my (%params) = (@_);

    my $message  = $params{ 'Message' }  || "No message";
    my $subject  = $params{ 'Subject' }  || "No subject";
    my $to       = $params{ 'Email' }    || "root";
    my $from     = $params{ 'From' }     || "root";
    my $sendmail = $params{ 'Sendmail' } || "/usr/lib/sendmail -t";

    open( SENDMAIL, "|$sendmail -f $from" ) or
      return;
    print SENDMAIL <<EOF;
To: $to
From: $from
Subject: $subject

$message
EOF
    close(SENDMAIL);

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
        #  Now write out the modified file.
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

=over 8

=item Age [mandatory]

The age of files which should be deleted.

=item Root [mandatory]

The root directory from which the search begins.

=back

The return value of this function is the number of files deleted.

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

The Unix mode to set for the file.  B<NOTE> If this doesn't start with "0" it will
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

        $content = $template->fill_in( HASH => \%template );

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
      $ENV{ 'PATH' } ||
      "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

    foreach my $dir ( split( /:/, $path ) )
    {
        if ( ( -d $dir ) && ( -x ( $dir . "/" . $binary ) ) )
        {
            return $dir . "/" . $binary;
        }
    }

    return undef;
}


=head2 InstallPackage

The InstallPackage primitive will allow you to install a system package.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  foreach my $package ( qw! bash tcsh ! )
  {
      if ( PackageInstalled( Package => $package ) )
      {
          print "$package installed\n";
      }
      else
      {
          InstallPackage( Package => $package );
      }
  }

=for example end

The following parameters are available:

=over

=item Package [mandatory]

The name of the package to install.

=back

=cut

sub InstallPackage
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, install the package
    #
    if ( $helper->recognised() )
    {
        $helper->installPackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
}




=head2 Mounts

Return a list of all the mounted filesystems upon the current system.

=for example begin

  my @mounts = Mounts();

=for example end

No parameters are required or supported in this method, and the
return value is an array of all mounted filesystems upon this
host.

=cut

sub Mounts
{
    my @results;

    open my $handle, "-|", "mount" or
      die "Failed to run mount: $!";

    while ( my $line = <$handle> )
    {
        chomp($line);

        if ( $line =~ /^([^ \t]+)[ \t]+on[ \t]+([^ \t]+)/ )
        {
            my ( $dev, $point ) = ( $1, $2 );
            push( @results, $point ) if ( $dev =~ /dev/ );
        }
    }
    close($handle);

    return (@results);
}




=head2 PackageInstalled

Test whether a given system package is installed.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  if ( PackageInstalled( Package => "exim4-config" ) )
  {
      print "$package installed\n";
  }

=for example end

The following parameters are supported:

=over 8

=item Package

The name of the package to test.

=back

The return value will be a 0 if not installed, or 1 if it is.

=cut

sub PackageInstalled
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, test the package installation state.
    #
    if ( $helper->recognised() )
    {
        $helper->isInstalled($package);
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
}




=head2 PercentageUsed

Return the percentage of space used in in the given mounted-device.

=for example begin

  foreach my $point ( Mounts() )
  {
     if ( PercentageUsed( Path => $point ) > 80 )
     {
        Alert( To      => "root",
               From    => "root",
               Subject => "$server is running out of space on $point",
               Message => "This is a friendly warning." );
     }
  }

=for example end

The following parameters are supported:

=over 8

=item Path

The mount-point to the filesystem in question.

=back

The return value will be a percentage in the range 0-100.

=cut

sub PercentageUsed
{
    my (%params) = (@_);

    #
    #  The mount-point
    #
    my $point = $params{ 'Path' } || "/";

    my $perc = 0;

    #
    #  Call df to get the output, use posix mode.
    #
    my $out = `df -P $point`;

    foreach my $line ( split( /[\r\n]/, $out ) )
    {
        next unless ( $line =~ /%/ );

        if ( $line =~ /[ \t]([0-9]*)%[ \t]/ )
        {
            $perc = $1;
        }
    }

    return ($perc);
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
    my $found   = 0;

    if ( open( my $handle, "<", $file ) )
    {
        my @lines;

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

            $found += 1 if ( $read ne $orig );

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

Remove the specified system package from the system.

This method uses C<Slaughter::Packages::openbsd>.

=for example begin

  if ( PackageInstalled( Package => 'telnetd' ) )
  {
      RemovePackage( Package => 'telnetd' );
  }

=for example end

The following parameters are supported:

=over 8

=item Package

The name of the package to remove.

=back

=cut

sub RemovePackage
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the package helper.
    #
    my $helper = Slaughter::Packages::openbsd->new();

    #
    #  If we recognise the system, remove the package
    #
    if ( $helper->recognised() )
    {
        $helper->removePackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown package-type.  Packaging support not present.\n";
    }
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

    #
    # Capture STDERR as well as STDOUT.
    #
    if ( $cmd !~ />/ )
    {
        $cmd .= "  1>&2";
    }

    $verbose && print "runCommand( $cmd )\n";

    return ( system($cmd ) );
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

The permissions bits to set for the file.  B<NOTE> if this doesn't start with a leading
"0" then it will be passed through the "oct" function - this allows you to use the
obvious construct :

=for example begin

  Mode => "755"

=for example end

=back

=cut

sub SetPermissions
{
    my (%params) = (@_);

    my $file  = $params{ 'File' }  || return;
    my $group = $params{ 'Group' } || undef;
    my $owner = $params{ 'Owner' } || undef;
    my $mode  = $params{ 'Mode' }  || undef;

    # file missing is an error
    return (-1) if ( !-e $file );

    # Numeric values
    my $uid = undef;
    my $gid = undef;

    # invalid user?
    if ( defined($owner) )
    {
        $uid = getpwnam($owner);
        return -2 if ( !defined($uid) );

        $verbose && print "Owner:$owner -> UID:$uid\n";
    }

    # invalid group?
    if ( defined($group) )
    {
        $gid = getgrnam($group);
        return -2 if ( !defined($gid) );
        $verbose && print "Group:$group -> GID:$gid\n";
    }

    my $changed = 0;

    if ( $params{ 'Owner' } )
    {

        #
        #  Find the current UID/GID of the file, so we
        # can change just the owner.
        #
        my ( $dev,      $ino,     $mode, $nlink, $orig_uid,
             $orig_gid, $rdev,    $size, $atime, $mtime,
             $ctime,    $blksize, $blocks
           ) = stat($file);

        $verbose && print "\tSetting owner to $owner/$uid\n";
        chown( $uid, $orig_gid, $file );

        $changed += 1;
    }
    if ( $params{ 'Group' } )
    {

        #
        #  Find the current UID/GID of the file, so we
        # can change just the group.
        #
        my ( $dev,      $ino,     $mode, $nlink, $orig_uid,
             $orig_gid, $rdev,    $size, $atime, $mtime,
             $ctime,    $blksize, $blocks
           ) = stat($file);

        $verbose && print "\tSetting group to $group/$gid\n";
        chown( $orig_uid, $gid, $file );

        $changed += 1;
    }
    if ( $params{ 'Mode' } )
    {
        $verbose && print "\tSetting mode to $mode\n";
        my $mode = $params{ 'Mode' };
        if ( $mode !~ /^0/ )
        {
            $mode = oct("0$mode");
            $verbose && print "\tOctal mode is now $mode\n";
        }
        chmod( $mode, $file );
        $changed += 1;
    }

    return ($changed);
}



=head2 UserExists

This primitive will test to see whether the given local user exists.

=for example begin

   if ( UserExists( User => "skx" ) )
   {
      # skx exists
   }

=for example end

The following parameters are available:

=over

=item User [mandatory]

The unix username to test for.

=back

The return value of this function is 1 if the user exists, and 0 otherwise.

=cut


sub UserExists
{
    my (%params) = (@_);

    my ( $login, $pass, $uid, $gid ) = getpwnam( $params{ 'User' } );

    if ( !defined($login) )
    {
        return 0;
    }
    else
    {
        return 1;
    }
}



=head2 UserDetails

This primitive will return a hash of data about the local Unix user
specified, if it exists.

=for example begin

   if ( UserExists( User => "skx" ) )
   {
      my %data = UserDetails( User => "skx" );
   }

=for example end

The following parameters are available:

=over

=item User [mandatory]

The unix username to retrieve details of.

=back

The return value of this function is a hash of data conprising of the
following Keys/Values

=over

=item Home

The user's home directory

=item UID

The user's UID

=item GID

The user's GID

=item Quota

The user's quota.

=item Comment

The user's comment

=item Shell

The user's login shell.

=item Login

The user's username.

=back

Undef will be returned on failure.

=cut

sub UserDetails
{
    my (%params) = (@_);


    my ( $name, $pwcode, $uid, $gid, $quota, $comment, $gcos, $home, $logprog )
      = getpwnam( $params{ 'User' } );

    if ( !defined($name) )
    {
        return undef;
    }

    #
    #  Return the values as a hash
    #
    return ( { Home    => $home,
               UID     => $uid,
               GID     => $gid,
               Quota   => $quota,
               Comment => $comment,
               Shell   => $logprog,
               Login   => $name
             } );
}




1;
