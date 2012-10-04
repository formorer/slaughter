#!/usr/bin/perl -w -I../lib -I./lib/
#
#  Some simple tests that validate the Slaughter code is correct.
#
#  Here we use the single API method:
#
#    DeleteFilesMatching
#
# Steve
# --
#


use strict;
use Test::More qw! no_plan !;
use File::Temp qw/ tempdir /;

#
#  Load the Slaughter module
#
BEGIN {use_ok('Slaughter');}
require_ok('Slaughter');


#
#  Create a temporary directory to host our files.
#
my $dir = tempdir( CLEANUP => 1 );


ok( -d $dir, "We created a temporary directory" );
is( countFiles($dir), 0, "The temporary directory is empty" );

#
#  Create several files
#
createFile( $dir, "foo.txt" );
createFile( $dir, "bar.txt" );
createFile( $dir, "baz.txt" );
createFile( $dir, "steve.kemp" );
is( countFiles($dir), 4, "The temporary directory has now been populated" );

#
#  Set the permissions to be executable
#
foreach my $name( qw! foo.txt bar.txt baz.txt ! )
{
    my $file = $dir . "/" . $name;

    ok( ! -x $file , "The file is not executable: $file" );
    is( SetPermissions( File => $file, Mode => "755" ),
        1,
        "Changing permissions succeeded" );

    ok(  -x $file , "The file is now executable: $file" );

    # Function returns -2 on invalid group/owner
    is( SetPermissions( File => $file,
                        Owner => "fsjlsdkfjlj"),
        -2,
        "Setting to invalid owner fails as expected" );
    is( SetPermissions( File => $file,
                        Group => "fsjlsdkfjlj"),
        -2,
        "Setting to invalid group fails as expected" );
}

#
#  Remove files matching the pattern "*.kemp".
#
my $removed = DeleteFilesMatching( Root => $dir, Pattern => "\.kemp\$" );
is( $removed,         1, "We removed one file" );
is( countFiles($dir), 3, "The temporary directory now has one fewer files" );


#
#  Remove "b*"
#
$removed = DeleteFilesMatching( Root => $dir, Pattern => "^b.*" );
is( $removed,         2, "We removed two file" );
is( countFiles($dir), 1, "The temporary directory now has one  file left" );


#
#  Unlink the last file manually
#
unlink("$dir/foo.txt");
is( countFiles($dir), 0, "Post-test we have zero files." );



#
#  Create a file with the given name/contents in the given directory.
#
sub createFile
{
    my ( $dir, $file, $contents ) = (@_);

    $contents = "OK\n" if ( !defined($contents) );

    open( FILE, ">", "$dir/$file" );
    print FILE $contents;
    close(FILE);
}


#
#  Count the files in a given directory.
#
sub countFiles
{
    my ($dir) = (@_);

    my $count = 0;

    foreach my $file ( sort( glob( $dir . "/*" ) ) )
    {
        $count += 1;
    }

    return ($count);
}
