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

Copyright (c) 2010 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut



sub Alert
{
    print "Alert - not implemented for $^O\n";
}


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


sub FetchFile
{
    print "FetchFile - not implemented for $^O\n";
}


sub FileMatches
{
    print "FIleMatches - not implemented for $^O\n";
}


sub InstallPackage
{
    print "InstallPackage - not implemented for $^O\n";
}


sub PackageInstalled
{
    print "PackageInstalled - not implemented for $^O\n";
}


sub RemovePackage
{
    print "RemovePackage - not implemented for $^O\n";
}


sub Mounts
{
    print "Mounts - not implemented for $^O\n";
}


sub PercentageUsed
{
    print "PercentageUsed - not implemented for $^O\n";
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
