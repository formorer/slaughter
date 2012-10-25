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


sub DeleteFilesMatching
{
    print "DeleteFilesMatching - not implemented for $^O\n";
}


sub DeleteOldFiles
{
    print "DeleteOldFiles - not implemented for $^O\n";
}


sub FetchFile
{
    print "FetchFile - not implemented for $^O\n";
}


sub FileMatches
{
    print "FileMatches - not implemented for $^O\n";
}


sub FindBinary
{
    print "FindBinary - not implemented for $^O\n";
}


sub InstallPackage
{
    print "InstallPackage - not implemented for $^O\n";
}


sub ReplaceRexexp
{
    print "ReplaceRegexp- not implemented for $^O\n";
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
