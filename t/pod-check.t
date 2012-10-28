#!/usr/bin/perl -w
#
#  Test that the POD we include in library files is valid.
#
# Steve
# --
#

use strict;
use File::Find;
use Test::More qw( no_plan );


#
#  The prefix to test from
#
my $prefix = undef;
$prefix = "." if ( -d "bin/" && -d "lib/" );
$prefix = "../" if ( -d "../bin/" && -d "../lib/" );
ok( $prefix, "We found a prefix : $prefix" );


#
#  Find *.pm, then check their POD
#
find( { wanted => \&checkFile, no_chdir => 1 }, $prefix );

#
#  Now check other files too.
#
checkPOD( "$prefix/bin/slaughter" );

#
#  Check a file.
#
#
sub checkFile
{
    # The file.
    my $file = $File::Find::name;

    if ( $file =~ /\.pm$/ )
    {
        checkPOD( $file );
    }
}


=begin doc

Check the POD contents of the named file.

=end doc

=cut

sub checkPOD
{
    my( $file ) = ( @_ );

    ok( -e $file,  "$file" );
    ok( !-d $file, " File is not a directory: $file" );

    #
    #  Execute the command giving STDERR to STDOUT where we
    # can capture it.
    #
    my $cmd    = "podchecker $file";
    my $output = `$cmd 2>&1`;
    chomp($output);

    is( $output,
        "$file pod syntax OK.",
        " File has correct POD syntax: $file" );
}
