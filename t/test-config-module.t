#!/usr/bin/perl -w
#
#  Simple test program to ensure that the Perl config module has values
# we expect.
#
# Steve
# --

use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw/ tempfile /;



#
#  Load the library
#
BEGIN {use_ok('Config');}
require_ok('Config');


ok( %Config, "The config hash is available" );
ok( $Config{'vendorlib'}, "The vendor-lib path is defined: $Config{'vendorlib'}" );
ok( -d $Config{'vendorlib'}, "The vendor-lib path is a directory that exists" );
