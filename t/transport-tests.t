#!/usr/bin/perl -w -I../lib -I./lib/
#
#  Test we can load the transport modules
#
# Steve
# --
#


use strict;
use Test::More qw! no_plan !;
use File::Temp qw/ tempfile /;

#
#  Load the Slaughter module
#
BEGIN {use_ok('Slaughter');}
require_ok('Slaughter');


#
#  Find the location
#
my $dir = undef;

$dir = "./lib/Slaughter/Transport"  if ( -d "./lib/Slaughter/Transport" );
$dir = "../lib/Slaughter/Transport" if ( -d "../lib/Slaughter/Transport" );

ok( -d $dir, "We found the transport directory" );


#
#  Look for each module
#
foreach my $name ( sort( glob( $dir . "/*.pm" ) ) )
{
    if ( $name =~ /(.*)\/(.*)\.pm/ )
    {
        my $module = $2;

        #
        # Load the module
        #
        use_ok("Slaughter::Transport::$module");
        require_ok("Slaughter::Transport::$module");

        #
        # Create
        #
        $module = "Slaughter::Transport::$module";
        my $handle = $module->new();

        #
        # Test that our required methods are present
        #
        foreach my $method (
                   qw! error isAvailable fetchContents fetchPolicies name new !)
        {
            ok( UNIVERSAL::can( $handle, $method ),
                "required method available in Slaughter::Transport::$module - $method"
              );
        }

    }
}
