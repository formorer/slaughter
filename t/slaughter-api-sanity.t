#!/usr/bin/perl -w
#
#  We have four sets of modules beneath the Slaughter namespace:
#
#    Slaughter::API::*
#    Slaughter::Info::*
#    Slaughter::Packages::*
#    Slaughter::Transport::*
#
#  Test that each such module implements every method mentioned in the API file,
# and no more.
#
#  There are two exceptions:
#
#    1.  Any class which is derived is excluded from the test.  Because the
#       parent "probably" implemenets missing methods.
#
#    2.  Any method which is prefixed with "_" is considered internal/extra.
#
# Steve
# --



use strict;
use Test::More qw( no_plan );


#
#  Find the location of the modules on disk.
#
my $base = undef;

$base = "./lib/Slaughter"  if ( -d "./lib/Slaughter" );
$base = "../lib/Slaughter" if ( -d "../lib/Slaughter" );
ok( $base,    "We found a library directory." );
ok( -d $base, "The library directory exists." );


#
#  For each subdirectory:
#
foreach my $dir ( sort( glob( $base . "/*/" ) ) )
{
    #
    # skip the API directory for the moment, because
    # the crusty way we implement insertion into the
    # top-level namespace is nasty.
    #
    # The net result is that API::generic implements
    # 100% of the API, but that the other modules do
    # not - their implementation comes from generic.pm
    # even though there is no base/derived relationship
    # between them.
    #
    next if ($dir =~ /API/);

    ok( -d $dir , " Found subdirectory: $dir" );

    #
    #  Look for the API file
    #
    my $api = $dir . "API";
    ok( -e $api , "Found corresponding API file: $api" );

    #
    #  Count the subroutines named in the API file
    #
    #  The format of the API file is:
    #  /
    #  |methodName
    #  |  Mathod Description, prefixed by two spaces.
    #  \
    #
    my %API;

    open( my $handle, "<", $api )
      or die "Failed to open $api - $!";
    while( my $line = <$handle> )
    {
        chomp( $line );
        if ( $line =~ /^([_a-zA-Z]+)/ )
        {
            $API{$1} = 1;
            ok( $1, "\tAPI documents function: $1" );
        }
    }
    close( $handle );

    #
    #  Now ensure that each function is implemented
    #
    foreach my $pm ( sort( glob( $dir . "*.pm" ) ) )
    {
        #
        #  We found a library.
        #
        ok( -e $pm , "Found library: $pm" );


        #
        #  Copy of the expected functions we expect to find
        # implemented.  Here so that we can delete them
        # as we find them.
        #
        my %EXPECTED = %API;


        #
        #  Is this a derived class?  If so we'll be less strict
        # about the API implementation.
        #
        my $derived = 0;


        #
        #  Open the library.
        #
        open( my $handle, "<", $pm )
          or die "Failed open library file $pm - $!";
        while( my $line = <$handle> )
        {
            chomp $line;

            #
            #  Look for derived classes - they don't need to implement
            # the full API, because their parent will supply the bits they
            # don't implement.
            #
            $derived = 1 if ( $line =~ /^use parent/i );

            #
            #  Look for subroutine definitions.
            #
            if ( $line =~ /^sub ([_a-zA-Z]*)/ )
            {
                my $sub = $1;

                #
                #  Skip methods prefixed with "_".
                #
                if ( $sub !~ /^_/ )
                {
                    #
                    #  OK we have a subroutine in the library.
                    #
                    #  If this subroutine name doesn't match one mentioned in
                    # the API then it is a bug.
                    #
                    #  Additional/Local/Private methods must be prefixed with "_".
                    #
                    ok( $EXPECTED{$sub}, "The subroutine $sub is required and present" );
                    delete $EXPECTED{$sub};
                }
            }
        }
        close( $handle );

        #
        #  At this point we've deleted all the functions we found that
        # were documented - so our hash should be empty.
        #
        #  However it might not be if the class is a derived one - because
        # the derived class might assume the parent implements them.
        #
        next if ( $derived );
        is( scalar %EXPECTED, 0, "There were no functions left over!");

        #
        #  Error on the functions that were missing.
        #
        foreach my $key ( keys %EXPECTED )
        {
            ok( ! $key, "Function $key not found in $pm " );
        }
    }
}
