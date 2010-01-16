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


sub Define
{
    my ( $name, $value ) = (@_);

    $value = 1 if ( !defined($value) );

    $DEFINES{ $name } = $value;
}


sub Defined
{
    my ($name) = (@_);

    return ( $template{ $name } || $DEFINES{ $name } || undef );
}

sub FetchFile
{
    print "FetchFile - not implemented for $^O\n";
}


sub InstallPackage
{
    print "InstallPackage - not implemented for $^O\n";
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
    my ($cmd) = (@_);

    system($cmd );
}

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


sub Value
{
    my ($name) = (@_);
    return ( Defined($name) );
}





1;
