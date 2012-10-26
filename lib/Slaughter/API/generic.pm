#!/usr/bin/perl -w

=head1 NAME

Slaughter::API::generic - Perl Automation Tool Helper generic implementation

=cut

=head1 SYNOPSIS

This module implementes generic versions of the Slaughter primitives.

When the module "Slaughter;" is used what happens is that a more OS-specific
module is loaded:

=for example begin

  my $module = "Slaughter::API::$^O";
  print "We'd load $module\n";

=for example end

This generic module is the fall-back for when the appropriate module
cannot be found.

All the functions here should merely print a message to show they're
unimplemented.

The code here will only be used if Slaughter is executed upon a system
which has no platform-API coded.

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

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub Alert
{
    print "Alert - not implemented for $^O\n";
}



=head2 AppendIfMissing

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub AppendIfMissing
{
    print "AppendIfMissing - not implemented for $^O\n";
}




=head2 CommentLinesMatching

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub CommentLinesMatching
{
    print "CommentLinesMatching - not implemented for $^O\n";
}




=head2 DeleteFilesMatching

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub DeleteFilesMatching
{
    print "DeleteFilesMatching - not implemented for $^O\n";
}




=head2 DeleteOldFiles

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub DeleteOldFiles
{
    print "DeleteOldFiles - not implemented for $^O\n";
}



=head2 FetchFile

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub FetchFile
{
    print "FetchFile - not implemented for $^O\n";
}




=head2 FileMatches

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub FileMatches
{
    print "FileMatches - not implemented for $^O\n";
}



=head2 FindBinary

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub FindBinary
{
    print "FindBinary - not implemented for $^O\n";
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

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub ReplaceRexexp
{
    print "ReplaceRegexp- not implemented for $^O\n";
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

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

=cut

sub RunCommand
{
    print "RunCommand - not implemented for $^O\n";
}



=head2 SetPermissions

This method is a stub which does nothing but output a line of text to
inform the caller that the method is not implemented.

For an implementation, and documentation, please consult Slaughter::API::linux

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
