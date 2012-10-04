#!/usr/bin/perl -w
#
#  Simple test program to ensure that we can load modules
# and hash files.
#
# Steve
# --

use strict;
use warnings;

use Test::More qw! no_plan !;
use File::Temp qw/ tempfile /;


#
#  Create a temporary file.
#
my ( $fh, $filename ) = tempfile();

ok( -e $filename, "We created a temporary file" );
is( -s $filename, 0, "The file is empty" );


#
#  Create some stub content
#
open( FILE, ">", $filename );
print FILE<<EOF;
Steve Kemp Testing Hashes.
Hashes are nice.   They're like signatures.
But less messy.

(No ink!)

EOF
close(FILE);

#
#  OK run a sanity check
#
if ( -x "/usr/bin/sha1sum" )
{
    my $validation = `sha1sum $filename | awk '{print \$1}'`;
    chomp($validation);

    is( $validation,
        "b57e303d4466e3aac4ea20f3935fb6d77951e2c4",
        "SHA1Sum utility confirmed the temporary file has the hash we expect" );
}

#
#  Attempt to test both digest modules in turn.
#
foreach my $module (qw! Digest::SHA Digest::SHA1 !)
{

    #
    #  Attempt to load the module
    #
    my $eval = "use $module;";
    eval($eval);

    ok( !$@, "Loaded module: $module" );
    ok( UNIVERSAL::can( $module, 'new' ),     "module implements new()" );
    ok( UNIVERSAL::can( $module, 'addfile' ), "module implements addfile()" );
    ok( UNIVERSAL::can( $module, 'hexdigest' ),
        "module implements hexdigest()" );

    #
    #  Hash the file
    #
    my $hash = $module->new;
    open my $handle, "<", $filename;
    $hash->addfile($handle);
    close($handle);

    #
    #  Compare what we expected
    #
    is( $hash->hexdigest(),
        "b57e303d4466e3aac4ea20f3935fb6d77951e2c4",
        "Our sample data received the correct result" );
}

#
#  Cleanup
#
unlink($filename);

ok( !-e $filename, "Post-test the temporary file is gone" );
