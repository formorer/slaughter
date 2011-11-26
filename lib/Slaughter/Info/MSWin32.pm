
#
#  Return meta-information about a Microsoft Windows host.
#
#  NOTE:  This has only been tested under Strawberry perl.
#
sub MetaInformation()
{
    my ($ref) = (@_);

    #
    #  Fully Qualified hostname
    #
    #
    #  Call "hostname".
    #
    $ref->{ 'fqdn' } = `hostname`;
    chomp( $ref->{ 'fqdn' } );

    #
    #  Get the hostname and domain name as seperate strings.
    #
    if ( $ref->{ 'fqdn' } =~ /^([^.]+)\.(.*)$/ )
    {
        $ref->{ 'hostname' } = $1;
        $ref->{ 'domain' }   = $2;
    }
    else
    {

        #
        #  Better than nothing, right?
        #
        $ref->{ 'hostname' } = $ref->{ 'fqdn' };
        $ref->{ 'domain' }   = $ref->{ 'fqdn' };
    }


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
    # Platform/OS (linux or MSWin32)
    #
    $ref->{ 'os' } = $^O;

    #
    #  Xen?
    #
    $ref->{ 'xen' } = 1 if -d "/proc/xen/capabilities";

    #
    #  KVM / Qemu?
    #
    if ( open( my $cpu, "<", "/proc/cpuinfo" ) )
    {
        foreach my $line (<$cpu>)
        {
            chomp($line);

            $ref->{ 'kvm' } = 1 if ( $line =~ /model/ && $line =~ /qemu/i );
        }
        close($cpu);
    }


    #
    #  Softare RAID?
    #
    if ( ( -e "/proc/mdstat" ) &&
         ( -x "/sbin/mdadm" ) )
    {
        if ( open( my $mdstat, "<", "/proc/mdstat" ) )
        {
            foreach my $line (<$mdstat>)
            {
                if ( ( $line =~ /^md([0-9]+)/ ) &&
                     ( $line =~ /active/i ) )
                {
                    $ref->{ 'softwareraid' } = 1;
                    $ref->{ 'raid' }         = "software";
                }
            }
            close($mdstat);
        }
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

    #
    #  TODO: 3Ware RAID?
    #

    #
    #  TODO: HP RAID?
    #
}

1;
