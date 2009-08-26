package File::OPC::Utils;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

###############################################################################
# MOOSE TYPES
use File::OPC::Library::Core qw(
	PackUri
);

###############################################################################
# MODULE IMPORTS
use Sub::Exporter 0.980 -setup => {
	exports => [qw(
		get_extension_from_part_name
	)],
};
use Sub::Name qw(subname);

BEGIN {
	# temporary hack to make import into a real named method until
	# Sub::Exporter does it for us.
	*import = subname __PACKAGE__ . '::import', \&import;
}

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(import)];

###############################################################################
# FUNCTIONS
sub get_extension_from_part_name {
	my ($part_name) = @_;

	# Transform the part name if needed
	$part_name = to_PackUri($part_name);

	if (!defined $part_name) {
		return;
	}

	# Get the list of path segments
	my @path_segments = $part_name->path_segments;

	# According to ECMA-376 Part 2, 10.1.2.4, the extension is the substring
	# to the right of the rightmost occurance of the dot character (.) from the
	# rightmost segment.
	my $rightmost_segment = pop @path_segments;

	# Find the position of the rightmost dot character
	my $dot_character_position = rindex $rightmost_segment, q{.};

	if ($dot_character_position < 0) {
		# No dot character was found in the rightmost segment
		return;
	}

	# Get the extension from the part name
	my $extension = substr $rightmost_segment, $dot_character_position + 1;

	# Return the extension
	return $extension;
}

1;

__END__


=head1 NAME

File::OPC::Utils - Library of different utility functions

=head1 VERSION

This documnetation refers to L<File::OPC::Utils> version 0.001

=head1 SYNOPSIS

  use File::OPC::Utils qw(get_extension_from_part_name);

  my $extension = get_extension_from_part_name('/image.png');

=head1 DESCRIPTION

This module provides utility functions for use in the L<File::OPC>
distribution.

=head1 METHODS

This this is not an object module, this module contains no methods.

=head1 FUNCTIONS

=head2 get_extension_from_part_name

This function takes a single argument that is a part name and returns the
extension from the part name or C<undef> if the part name does not contain an
extension.

=head1 DEPENDENCIES

This module is dependent on the following modules:

=over

=item * L<File::OPC::Library::Core>

=item * L<Sub::Exporter> 0.980

=item * L<namespace::clean> 0.04

=back

=head1 AUTHOR

Douglas Christopher Wilson, C<< <doug at somethingdoug.com> >>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to C<bug-file-opc at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-OPC>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

I highly encourage the submission of bugs and enhancements to my modules.

=head1 LICENSE AND COPYRIGHT

Copyright 2009 Douglas Christopher Wilson.

This program is free software; you can redistribute it and/or
modify it under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

=item * the Artistic License version 2.0.

=back
