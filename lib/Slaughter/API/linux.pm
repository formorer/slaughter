#!/usr/bin/perl -w

=head1 NAME

Slaughter::API::linux - Perl Automation Tool Helper Linux implementation

=cut

=head1 SYNOPSIS

This module is the one that gets loaded upon Linux systems, after the generic
API implementation.  It implements the platform-specific parts of our
primitives.

We also attempt to load C<Slaughter::API::Local::linux>, where site-specific primitives
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


package Slaughter::API::linux;


#
#  Package abstraction helpers.
#
use Slaughter::Packages::linux;



=begin doc

Export all subs in this package into the main namespace.

This is nasty.

=end doc

=cut

sub import
{
    no strict 'refs';

    my $caller = caller;

    while ( my ( $name, $symbol ) = each %{ __PACKAGE__ . '::' } )
    {
        next if $name eq 'BEGIN';     # don't export BEGIN blocks
        next if $name eq 'import';    # don't export this sub
        next unless *{ $symbol }{ CODE };    # export subs only

        my $imported = $caller . '::' . $name;
        *{ $imported } = \*{ $symbol };
    }
}



=head2 InstallPackage

The InstallPackage primitive will allow you to install a system package.

Currently C<apt-get> and C<yum> are supported, via C<Slaughter::Packages::linux>.

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
    #  Gain access to the Linux package helper.
    #
    my $helper = Slaughter::Packages::linux->new();

    #
    #  If we recognise the system, install the package
    #
    if ( $helper->recognised() )
    {
        $helper->installPackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown Linux type.  Packaging support not present\n";
    }
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

Currently C<apt-get> and C<yum> are supported, via C<Slaughter::Packages::linux>.

=cut

sub PackageInstalled
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the Linux package helper.
    #
    my $helper = Slaughter::Packages::linux->new();

    #
    #  If we recognise the system, test the package installation state.
    #
    if ( $helper->recognised() )
    {
        $helper->isInstalled($package);
    }
    else
    {
        print "Unknown Linux type.  Packaging support not present\n";
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

Currently C<apt-get> and C<yum> are supported, via C<Slaughter::Packages::linux>.

=cut

sub RemovePackage
{
    my (%params) = (@_);

    my $package = $params{ 'Package' } || return;

    #
    #  Gain access to the Linux package helper.
    #
    my $helper = Slaughter::Packages::linux->new();

    #
    #  If we recognise the system, remove the package
    #
    if ( $helper->recognised() )
    {
        $helper->removePackage( $params{ 'Package' } );
    }
    else
    {
        print "Unknown Linux type.  Packaging support not present\n";
    }
}



1;
