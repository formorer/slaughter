#!/usr/bin/perl -w -Ilib/ -I../lib/
#
#  Simple test program to ensure that we can handle "FetchPolicy" statements
# in all the wonderful ways they might be written.
#
# Steve
# --

use strict;
use warnings;

use Test::More qw! no_plan !;


#
#  Environmental variables
#
our %CONFIG = ( "fqdn" => "my.host.name",
                "steve" => "kemp" );


#
#  A list of tests that should give the specific files.
#
my %TESTS = (
             "FetchPolicy 'steve.policy';"  => "steve.policy",
             "FetchPolicy 'steve.policy'"   => "steve.policy",
             "FetchPolicy steve.policy;"    => "steve.policy",
             "FetchPolicy steve.policy"     => "steve.policy",
             "FetchPolicy('steve.policy')" => "steve.policy",
             "FetchPolicy(\"steve.policy')" => "steve.policy",
             "FetchPolicy(\"steve.policy\");" => "steve.policy",
             "FetchPolicy ('steve.policy')" => "steve.policy",
             "FetchPolicy (\"steve.policy')" => "steve.policy",
             "FetchPolicy (\"steve.policy\");" => "steve.policy",
             "FetchPolicy (\$fqdn.policy);" => "my.host.name.policy",
             "FetchPolicy ('\$steve.policy');" => "kemp.policy",
             "FetchPolicy (\$fqdn.\$steve.policy');" => "my.host.name.kemp.policy",
            );


#
#  Make our private module available
#
BEGIN {use_ok('Slaughter::Private');}
require_ok('Slaughter::Private');

#
#  For each input we'll look to see we get the expected
# output from our function.
#
foreach my $input ( keys %TESTS )
{
    my $output = expandPolicyInclusion( $input );

    is( $output, $TESTS{ $input }, "Processing succeeded: $input" );
}

