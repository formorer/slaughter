
=head2 MetaInformation

This function retrieves meta-information about the current host,
and is invoked on Microsoft Windows systems.

=for example begin

  my %data = MetaInformation();

=for example end

NOTE:  This has only been tested under Strawberry perl.

=cut

sub MetaInformation
{
    my ($ref) = (@_);

    #
    #  Kernel version.
    #
    $ref->{ 'kernel' } = $ENV{ 'OS' };
    chomp( $ref->{ 'kernel' } );

    #
    #  Are we i386/amd64?
    #
    my $type = $ENV{ 'PROCESSOR_ARCHITECTURE' };
    if ( $type =~ /x86/i )
    {
        $ref->{ 'arch' } = "i386";
        $ref->{ 'bits' } = 32;
    }
    else
    {
        $ref->{ 'arch' } = "amd64";
        $ref->{ 'bits' } = 64;
    }


    #
    #  IP address(es).
    #
    my $ip = undef;

    $ip = "ipconfig";

    if ( defined($ip) )
    {
        my $count = 1;

        foreach my $line ( split( /[\r\n]/, `$ip` ) )
        {
            next if ( !defined($line) || !length($line) );
            chomp($line);

            #
            #  This matches something like:
            #
            #  IP Address. . . . . . . . . . . . : 10.6.11.138
            #
            #
            if ( $line =~ /IP Address.* : (.*)/ )
            {
                my $ip = $1;

                #
                # Save away the IP address in "ip0", "ip1", "ip2" .. etc.
                #
                $ref->{ "ip" . $count } = $ip;
                $count += 1;
            }
        }

        if ( $count > 0 )
        {
            $ref->{ 'ipcount' } = ( $count - 1 );
        }
    }


    #
    #  Find the name of our release
    #
    my @win_info = Win32::GetOSVersion();
    my $version  = $win_info[0];
    my $distrib  = Win32::GetOSName();

    # work around for historical reasons
    $distrib = 'WinXP' if $distrib =~ /^WinXP/;
    $ref->{ 'version' }      = $version;
    $ref->{ 'distribution' } = $distrib;

}

1;
