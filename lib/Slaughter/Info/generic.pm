=head2 MetaInformation

This function retrieves meta-information about the current host,
it is the fall-back module which is used if a system-specific
information module cannot be loaded.

=for example begin

  my %data = MetaInformation();

=for example end

=cut

sub MetaInformation()
{
    my ($ref) = (@_);

    $ref->{ 'unknown' } = "all";
}


1;
