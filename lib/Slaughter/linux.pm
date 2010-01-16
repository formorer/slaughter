#!/usr/bin/perl -w

=head1 NAME

Slaughter::linux - Perl Automation Tool Helper Linux implementation

=cut

=head1 SYNOPSIS

This module implements the Linux-specific versions of the Slaughter
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



#
#  The modules we use, and the internal functions are defined
# in this module.
#
use Slaughter::Private;




##
##  Public
##
##  Send an email
##
##  Parameters:
##       Message   defaults to: "No message".
##       Subject   defaults to: "No subject".
##       To        defaults to: "root".
##       From      defaults to: "root".
##       Sendmail  defaults to: "/usr/lib/sendamil -t"
##
sub Alert
{
    my (%params) = (@_);

    my $message = $params{ 'Message' } || "No message";
    my $subject = $params{ 'Subject' } || "No subject";
    my $to      = $params{ 'Email' }   || "root";
    my $from    = $params{ 'From' }    || "root";

    my $sendmail = $params{ 'Sendmail' } || "/usr/lib/sendmail -t";

    open( SENDMAIL, "|$sendmail -f $from" ) or
      return;
    print SENDMAIL <<EOF;
To: $to
From: $from
Subject: $subject

$message
EOF
    close(SENDMAIL);

}


##
##  Public
##
sub Define
{
    my ( $name, $value ) = (@_);

    $value = 1 if ( !defined($value) );

    $DEFINES{ $name } = $value;
}


##
##  Defined
##
sub Defined
{
    my ($name) = (@_);

    return ( $template{ $name } || $DEFINES{ $name } || undef );
}


##
##  Public
##
##  Return the value of the named definition.
##
sub Value
{
    my ($name) = (@_);
    return ( Defined($name) );
}



##
##  Public
##
##  Run a command, via system.
##
##
sub RunCommand
{
    my ($cmd) = (@_);

    $verbose && print "runCommand( $cmd )\n";

    system($cmd );
}


##
##  Public
##
##  Fetch a file, via HTTP.
##
##
sub FetchFile
{
    my (%params) = (@_);

    $verbose && print "FetchFile( $params{'Source'} );\n";

    my $src = $params{'Source'};
    my $dst = $params{'Dest'};

    if ( !$src || !$dst )
    {
        print "Missing source/dest\n";
        return 0;
    }

    #
    #  Fetch the source.
    #
    my $content = fetchURL( "http://" . $server . "/slaughter/files/" . $src );

    if ( !defined($content) )
    {
        return 0;
    }


    #
    #  If we're to expand content do so.
    #
    if ( !defined( $params{ 'Expand' } ) ||
         ( defined $params{ 'Expand' } && $params{ 'Expand' } =~ /true/i ) )
    {
        my $template =
          Text::Template->new( TYPE   => 'string',
                               SOURCE => $content );

        $content = $template->fill_in( HASH => %template );
    }

    #
    #  OK now we want to write out the content.
    #
    my ( $handle, $name ) = File::Temp::tempfile();

    open my $fh, ">", $name
      or return;
    print $fh $content;
    close($fh);


    #
    #  We have the file, does it differ from the live filesystem?
    #
    #  Or is the local copy missing?
    #
    #  If so we replace
    #
    my $replace = 0;

    if ( !-e $dst )
    {
        $verbose && print "\tDestination not present - will move into place\n";
        $replace = 1;
    }
    else
    {
        my $cur = checksumFile($dst);
        my $new = checksumFile($name);

        if ( $new != $cur )
        {
            $replace = 1;

            $verbose && print "\tContents don't match - will replace\n";
        }
    }

    #
    #  Replace
    #
    if ($replace)
    {
        $verbose && print "\tReplacing $dst\n";
        if ( -e $dst )
        {
            RunCommand("mv $dst $dst.old");
        }

        #
        #  Ensure the destination directory exists.
        #
        my $dir = dirname($dst);
        if ( !-d $dir )
        {
            mkpath( $dir, { verbose => 0 } );
        }


        RunCommand("mv $name $dst");

        $FILES{ $dst } = 1;
    }

    #
    #  Change Owner/Group/Mode if we should
    #
    if ( -e $dst && ( $params{ 'Owner' } ) )
    {
        my $owner = $params{ 'Owner' };
        RunCommand("chown $owner $dst");
    }
    if ( -e $dst && ( $params{ 'Group' } ) )
    {
        my $group = $params{ 'Group' };
        RunCommand("chgrp $group $dst");
    }
    if ( -e $dst && ( $params{ 'Mode' } ) )
    {
        my $mode = $params{ 'Mode' };
        RunCommand("chmod $mode $dst");
    }

    return ($replace);
}

##
##  Public
##
##  Return an array of mountpoints.
##
sub Mounts
{
    my @results;

    if ( open( my $handle, "<", "/proc/mounts" ) )
    {
        foreach my $line ( <$handle> )
        {
            chomp( $line );
            my ( $dev, $point, $type ) = split( / /, $line );
            if ( $dev =~ /^\/dev/ )
            {
                push( @results, $point );
            }
        }
        close( $handle );
    }

    return( @results );
}

##
## Public
##
## Return the percentage of space used on the given mount-point.
##
sub PercentageUsed
{
    my( %params ) = ( @_ );

    #
    #  The mount-point
    #
    my $point = $params{'path'} || "/";

    my $perc = 0;

    #
    #  Call df to get the output
    #
    my $out = `df -P $point`;
    foreach my $line ( split( /[\r\n]/, $out ) )
    {
        next unless( $line =~ /%/ );

        if ( $line =~ /[ \t]([0-9]*)%[ \t]/ )
        {
            $perc = $1;
        }
    }

    return( $perc );
}



##
##  Public
##
##  Install a package
##
##
sub InstallPackage
{
    my (%params) = (@_);

    RunCommand("apt-get install -q -y $params{'Name'}");
}


##
##  See if the user exists.
##
sub UserExists
{
    my (%params) = (@_);

    my ( $login, $pass, $uid, $gid ) = getpwnam( $params{ 'User' } );

    if ( !defined($login) )
    {
        return 0;
    }
    else
    {
        return 1;
    }
}


1;
