#!/usr/bin/perl -w

=head1 NAME

Slaughter - Perl Automation Tool Helper

=cut

=head1 SYNOPSIS

This module is the distribution and architecture independant library
which is used to abstract away platform differences for the Slaughter
administration tool.

=cut


=head1 AUTHOR

 Steve
 --
 http://www.steve.org.uk/

=cut

=head1 LICENSE

Copyright (c) 2010 by Steve Kemp.  All rights reserved.

This module is free software;
you can redistribute it and/or modify it under
the same terms as Perl itself.
The LICENSE file contains the full text of the license.

=cut



BEGIN
{

    my $generic  = "use Slaughter::generic";
    my $specific = "use Slaughter::$^O;";

    ## no critic (Eval)
    eval($specific);
    ## use critic

    # if there were errors then we'll use the generic
    # handler
    if ($@)
    {
        eval($generic);
    }
}


1;
