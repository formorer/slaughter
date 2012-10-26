
=head2 MetaInformation

This function retrieves meta-information about the current host,
and is invoked solely on Linux hosts.

=for example begin

  my %data = MetaInformation();

=for example end

=cut

sub MetaInformation
{
    my ($ref) = (@_);

    #
    #  Fully Qualified hostname
    #
    #  1.  If we can find /etc/hostname, then use that.
    #
    if ( -e "/etc/hostname" )
    {
        open( my $file, "<", "/etc/hostname" ) or
          die "Failed to read /etc/hostname - $!";
        $ref->{ 'fqdn' } = <$file>;
        chomp( $ref->{ 'fqdn' } );
        close($file);
    }
    else
    {

        #
        #  Call "hostname".
        #
        $ref->{ 'fqdn' } = `hostname`;
        chomp( $ref->{ 'fqdn' } );

        #
        # If it is unqualified retry with --fqdn.
        #
        if ( $ref->{ 'fqdn' } !~ /\./ )
        {
            $ref->{ 'fqdn' } = `hostname --fqdn`;
            chomp( $ref->{ 'fqdn' } );
        }
    }


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
    #  Is this a xen host, or guest?
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
    #  Software RAID?
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
    #  Kernel version.
    #
    $ref->{ 'kernel' } = `uname -r`;
    chomp( $ref->{ 'kernel' } );

    #
    #  Are we i386/amd64?
    #
    my $type = `file /bin/ls`;
    if ( $type =~ /64-bit/i )
    {
        $ref->{ 'arch' } = "amd64";
        $ref->{ 'bits' } = 64;
    }
    else
    {
        $ref->{ 'arch' } = "i386";
        $ref->{ 'bits' } = 32;
    }

    #
    #  IP address(es).
    #
    my $ip = undef;

    $ip = "/sbin/ip" if ( -x "/sbin/ip" );
    $ip = "/bin/ip"  if ( -x "/bin/ip" );

    if ( defined($ip) )
    {
        my $count = 1;

        foreach my $line (
                   split( /[\r\n]/, `$ip -o -f inet  addr show scope global` ) )
        {
            next if ( !defined($line) || !length($line) );
            chomp($line);

            #
            #  This matches something like:
            #
            #  2: eth0    inet 192.168.1.9/24 brd 192.168.1.255 scope global eth0
            #
            #
            if ( $line =~ /^([0-9]+):[ \t]+([^ ]+)[ \t]*inet[ \t]+([0-9\.]+)/ )
            {
                my $eth = $2;
                my $ip  = $3;

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
    my $version = "unknown";
    my $distrib = "unknown";
    my $release = "unknown";
    if ( -x "/usr/bin/lsb_release" )
    {
        foreach
          my $line ( split( /[\r\n]/, `/usr/bin/lsb_release -a 2>/dev/null` ) )
        {
            chomp $line;
            if ( $line =~ /Distributor ID:\s*(.*)/ )
            {
                $distrib = $1;
            }
            if ( $line =~ /Release:\s*(.*)/ )
            {
                $version = $1;
            }
            if ( $line =~ /Codename:\s*(.*)/ )
            {
                $release = $1;
            }
        }
    }
    $ref->{ 'version' }      = $version;
    $ref->{ 'distribution' } = $distrib;
    $ref->{ 'release' }      = $release;


    #
    #  TODO: 3Ware RAID?
    #

    #
    #  TODO: HP RAID?
    #

}

1;
