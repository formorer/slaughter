#!/usr/bin/perl -w

=head1 NAME

Slaughter - Perl Automation Tool Helper

=cut

=head1 SYNOPSIS

This module is the distribution and architecture independant library
which is used to abstract away platform differences for the Slaughter
administration tool.

It is loaded via:

=for example begin

   use Slaughter;

=for example end

This usage actually dynamically loads the appropriate module from beneath the
Slaughter::API namespace - which will contain the implementation of the primitives
distributed with Slaughter.

If no appropriate module is located to match the current system then the fall-backup
module (Slaughter::API::generic) is loaded.  The generic module contains stub
primitives which merely output the message:

=for example begin

  This module is not implemented for $^O

=for example end

This allows compiled policies to execute, without throwing errors, and also report
upon the primitives which need to be implemented or adapted.

=cut

=head1 EXTENSIONS

At the same time as loading the appropriate module from beneath the
Slaughter::API name-space this module will attempt to load an identically
named module from beneath the Slaughter::API::Local namespace.

This allows you to keep develop your own custom-primitives.

=cut

=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2010-2012 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut


use strict;
use warnings;



BEGIN
{

    my $generic  = "use Slaughter::API::generic";
    my $specific = "use Slaughter::API::$^O;";

    ## no critic (Eval)
    eval($specific);
    ## use critic

    #
    # If there were no errors we'll look for a local extension module too:
    #
    if ( !$@ )
    {
        my $ext = "use Slaughter::API::Local::$^O;";

        ## no critic (Eval)
        eval($ext);
        ## use critic

        #
        #  We don't care if the local-module fails to load because we expect
        # it to be missing in the general case.
        #
    }
    else
    {

        #
        #  We found errors so we'll fall-back to the generic implementation
        #

        ## no critic (Eval)
        eval($generic);
        ## use critic
    }
}


1;
