#!/usr/bin/perl -w
#
#  Because we have a generic module which throws "Not implemented" errors
# we expect that every platform-specific module will implement each of those
# same functions to get 100% functional.
#
#  This test checks that the modules in :
#
#     /lib/Slaughter/API/
#     /lib/Slaughter/Info/
#
#  Contain the same number of subroutines as present in the generic.pm
#  module in that same directory.
#
# Steve
# --



use strict;
use Test::More qw( no_plan );


#
# Find the directory
#
my $base = "./lib";
if ( !-d $base ) {$base = "../lib/";}


foreach my $dir (qw! Slaughter/API Slaughter/Info !)
{
    ok( -d ( $base . "/" . $dir ), "Directory present" );

    # open the generic module - and count the subroutines
    my $expected = countSubs("$base/$dir/generic.pm");
    ok( $expected,
        "We found a number of subroutines in $base/$dir/generic.pm [$expected]"
      );

    #
    #  Now that value should be present in every other file.
    #
    foreach my $file ( sort( glob("$base/$dir/*.pm") ) )
    {
        next if ( $file =~ /generic.pm/ );

        my $found = countSubs($file);
        is( $found, $expected, "Number of subroutines matches in $file" );
    }
}



=begin doc

Count the number of subroutines in the specified perl file.

=end doc

=cut

sub countSubs
{
    my ($file) = (@_);

    my $count = 0;

    open( FILE, "<", "$file" ) or
      die "Failed to open $file - $!";
    while ( my $line = <FILE> )
    {
        $count += 1 if ( $line =~ /^sub / );
    }
    close(FILE);

    return ($count);
}
