#!/usr/bin/perl -w

=head1 NAME

Slaughter - Perl Automation Tool Helper

=cut

=head1 SYNOPSIS

This module provides stub facilities for OS-specific versions of the
Slaughter administration tool.

When the module "Slaughter;" is used what happens is that a more OS-specific
module is loaded:

=for example begin

  my $module = "Slaughter::$^O";

  print "We'd load $module\n";

=for example end

This generic module is the fall-back for when the appropriate module
cannot be found.  All the functions here should merely show they're
unimplemented.

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

The content of the mssage to send

=item Sendmail [default: "/usr/lib/sendmail -t"]

The path to the sendmail binary.

=item Subject [mandatory]

The subject to send.

=item To [mandatory]

The receipient of the message.

=back

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
    print "AppendIfMissing - not implemented for $^O\n";
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
    print "CommentLinesMatching - not implemented for $^O\n";
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
    print "DeleteFilesMatching - not implemented for $^O\n";
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
    print "DeleteOldFiles - not implemented for $^O\n";
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
    print "FetchFile - not implemented for $^O\n";
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
    print "FileMatches - not implemented for $^O\n";
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
    print "FindBinary - not implemented for $^O\n";
}



=head2 InstallPackage

The InstallPackage primitive will allow you to install a system package.
Currently apt-get and yum are supported.

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
    print "InstallPackage - not implemented for $^O\n";
}



=head2 Mounts

Return a list of all the mounted filesystems upon the current
system.

=for example begin

  my @mounts = Mounts();

=for example end

No parameters are required or supported in this method, and the
return value is an array of all mounted filesystems upon this
host.

=cut

sub Mounts
{
    print "Mounts - not implemented for $^O\n";
}



=head2 PackageInstalled

Test whether a given system package is installed.

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

This primitive supports both RPM and Debian packages, when running
on such a system.

=cut

sub PackageInstalled
{
    print "PackageInstalled - not implemented for $^O\n";
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

sub ReplaceRexexp
{
    print "ReplaceRegexp- not implemented for $^O\n";
}



=head2 RemovePackage

Remove the specified system package from the system.

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

This primitive supports both RPM and Debian packages, when running
on such a system.

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
    print "RunCommand - not implemented for $^O\n";
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
    print "UserExists - not implemented for $^O\n";
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
    print "UserDetails - not implemented for $^O\n";
}




1;
