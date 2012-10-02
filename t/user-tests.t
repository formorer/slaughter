#!/usr/bin/perl -w -I../lib -I./lib/
#
#  Some simple tests that validate the Slaughter code is correct.
#
#  Here we use the two API methods:
#
#    UserExists +
#    UserDetails
#
#  We attempt to fetch the username we're currently running under,
# fetching that from the $USER environmental variable.
#
#


use strict;
use Test::More;


plan skip_all => "The USER environmental variable is not set"
  if ( !$ENV{ 'USER' } );

#
#  Ensure we have a user we're running as.
#
ok( length( $ENV{ 'USER' } ) > 0, "We have a user" );

#
#  Load the Slaughter module
#
BEGIN {use_ok('Slaughter');}
require_ok('Slaughter');

#
#  Ensure the user exists
#
my $user = undef;
$user = UserExists( User => $ENV{ 'USER' } );
ok( $user, "We found a username" );

#
#  Get the details
#
$user = UserDetails( User => $ENV{ 'USER' } );
is( $user->{ 'Login' }, $ENV{ 'USER' },
    "The username matches the environment" );
ok( -d $user->{ 'Home' }, "The username has a home directory that exists" );
