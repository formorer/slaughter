#!/usr/bin/perl -w -I../lib -I./lib/
#
#  Some simple tests that validate the Slaughter code is correct.
#
#  Here we use the three API methods:
#
#    AppendIfMissing      +
#    CommentLinesMatching +
#    FileMatches
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
#  Create a temporary file.
#
my ( $fh, $filename ) = tempfile();

ok( -e $filename, "We created a temporary file" );
is( -s $filename, 0, "The file is empty" );


#
#  Write out known-contents to the file
#
open( FILE, ">", $filename ) or die "Failed to write to temporary file: $!";
print FILE <<EOF;
Steve
Kemp
1234567890
ABCDEFGHI
EOF
close(FILE);

#
#  File contents are known, so size is known
#
is( -s $filename, 32, "The file has our test data present" );

#
#  Does the file match our simple pattern?
#
is( FileMatches( File => $filename, Pattern => '^[0-9]*$' ),
    1,
    "File matches a simple regular expression" );

#
#  And the file should now contain a comment.
#
is( FileMatches( File => $filename, Pattern => '^#' ),
    0,
    "File does not contain a comment." );

#
#  Now we'll comment lines containing numeric code.
#
CommentLinesMatching( File => $filename, Pattern => '^[0-9]*$' );

#
#  Which means the filesize is one more than it was.
#
is( -s $filename, 33, "The file has grown, as expected" );

#
#  And the file no longer should match our simple pattern?
#
is( FileMatches( File => $filename, Pattern => '^[0-9]*$' ),
    0,
    "File no longer matches our simple regular expression" );

#
#  And the file should now contain a comment.
#
is( FileMatches( File => $filename, Pattern => '^#' ),
    1,
    "File contains a comment." );

#
#  Append a new line
#
AppendIfMissing( File => $filename, Line => "Testing is fun!" );

#
#  The file size should have grown.
#
is( -s $filename, 49, "The file has grown, as expected" );

#
#  Repeating a few times should result in no change though,
# as the line is present.
#
for ( my $i = 0 ; $i < 5 ; $i++ )
{
    AppendIfMissing( File => $filename, Line => "Testing is fun!" );
    is( -s $filename, 49, "Appending a new line is not required" );
}

#
# system( "cat $filename" );
#

#
#  Cleanup
#
unlink($filename);
ok( !-e $filename, "Post-testing our temporary file is gone" );
