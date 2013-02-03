
=head1 NAME

Apache - An interface to the apache webserver.

=cut

=head1 SYNOPSIS

    use strict;
    use warnings;

    use Apache;

    # Create the helper.
    my $apache = Apache->new();

    # find enabled sites
    my @sites = $apache->enabled_sites();

    # find loaded modules
    my @modules = $apache->enabled_modules();

    # Ensure that mod_rewrite is enabled
    $apache->enable_module(  "mod_rewrite" );

=cut

=head1 DESCRIPTION

This class wraps some common things you might wish to do with Apache.

=cut

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version,
or

b) the Perl "Artistic License".

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut

=head1 METHODS

=cut



use File::Basename qw! basename !;


package Apache;



=head2 new

Constructor

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};

    bless( $self, $class );
    return $self;
}


=head2 enabled_sites

Return an array of the names of sites which are enabled; fully-qualfied.

=cut

sub enabled_sites
{
    my ($self) = (@_);

    return ( $self->_glob("/etc/apache2/sites-enabled/*") );
}


=head available_sites

Return an array of the names of all sites which are available,
whether they are live or not.

=cut

sub available_sites
{
    my ($self) = (@_);

    return ( $self->_glob("/etc/apache2/sites-available/*") );
}



=head2 enabled_modules

Return an array of all enabled modules names.

For example "mod_dir", "mod_rewrite", etc.

=cut

sub enabled_modules
{
    my ($self) = (@_);

    my @all = $self->_find_modules("/etc/apache2/mods-enabled/*.load");
    my @res;

    foreach my $mod (@all)
    {
        push( @res, $mod->{ 'module' } );
    }

    return (@res);
}




=head available_modules

Return an array of the names of all modules which are available,
whether they are live or not.

This will return things like "mod_ldap", "mod_rewrite", etc.

=cut

sub available_modules
{
    my ($self) = (@_);

    my @all = $self->_find_modules("/etc/apache2/mods-available/*.load");
    my @res;

    foreach my $mod (@all)
    {
        push( @res, $mod->{ 'module' } );
    }

    return (@res);
}



=head2 enable_site

Enable a site.

=end doc

=cut

sub enable_site
{
    my ( $self, $site ) = (@_);

    #
    #  The src.
    #
    my $src = $site;
    if ( $src !~ /^\// )
    {
        $src = "/etc/apache2/sites-available/$site";
    }

    #
    #  The destination
    #
    my $dst = $src;
    $dst = File::Basename::basename($src);

    if ( !-e $dst )
    {
        return ( symlink( $src, $dst ) );
    }
    return 0;
}



=head2 disable_site

Disable a site.

=end doc

=cut


sub disable_site
{
    my ( $self, $site ) = (@_);

    #
    #  The file, qualified
    #
    if ( $site !~ /^\// )
    {
        $site = "/etc/apache2/sites-enabled/$site";
    }

    if ( -e $site )
    {
        unlink($site);
        return 1;
    }
    return 0;
}


=head2 enable_module

Enable a module.

=end doc

=cut

sub enable_module
{
    my ( $self, $module ) = (@_);

    # find all modules
    my @all = $self->_find_modules("/etc/apache2/mods-available/*.load");

    foreach my $mod (@all)
    {
        if ( $mod->{ 'module' } eq $module )
        {
            my $file = $mod->{ 'file' };
            my $dest = $file;
            $dest = File::Basename::basename($dest);
            symlink( $file, "/etc/apache2/mods-enabled/$dest" );
        }
    }
}



=begin doc

Private method.  Return an array of filenames matching the given glob-pattern.

=end doc

=cut

sub _glob
{
    my ( $self, $pattern ) = (@_);

    my @results;

    foreach my $file ( sort( glob($pattern) ) )
    {
        push( @results, $file );
    }
    return (@results);
}



=begin doc

Private method.

Return an array of hashes for modules.  The hashs will have to members, for example:

    "module" => "mod_rewrite"
    "file"   => "/etc/apache2/mods-avaible/rewrite.load".

=end doc

=cut

sub _find_modules
{
    my ( $self, $glob ) = (@_);

    #
    # Find the .load files.
    #
    my @files = $self->_glob($glob);

    #
    #  The modules we find.
    #
    my @modules;

    foreach my $file (@files)
    {
        open( FILE, "<", $file ) or next;
        while ( my $line = <FILE> )
        {
            chomp($line);
            if ( $line =~ /^LoadModule\s+(.*)\s+(.*)$/ )
            {
                my $mod = $2;
                $mod = File::Basename::basename($mod);

                #
                #  Strip off the suffix.
                #
                if ( $mod =~ /^(.*)\.(.*)$/ )
                {
                    $mod = $1;
                }
                push( @modules, { file => $file, module => $mod } );
            }
        }
        close(FILE);
    }

    return (@modules);
}


1;



my $a = Apache->new();

print "available modules:\n";
foreach my $a ( $a->available_modules() )
{
    print "\t$a\n";
}

print "enabled modules:\n";
foreach my $a ( $a->enabled_modules() )
{
    print "\t$a\n";
}


$a->enable_module("mod_rewrite");
