
=head2 MetaInformation

This function retrieves meta-information about the current host,
it is the fall-back module which is used if a system-specific
information module cannot be loaded.

=for example begin

  my %data = MetaInformation();

=for example end

Currently the following OS-specific modules exist:

=over 8

=item Slaughter::Info::linux

=item Slaughter::Info::MSWin32

=back

=cut

sub MetaInformation
{
    my ($ref) = (@_);

    $ref->{ 'unknown' } = "all";
}


1;
