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


sub RunCommand
{
    print "RunCommand - not implemented for $^O\n";
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
