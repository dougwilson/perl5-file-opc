package File::OPC::ContentTypesStream::Override;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

###############################################################################
# MOOSE
use Moose 0.62;
use MooseX::StrictConstructor 0.08;

###############################################################################
# MOOSE TYPES
use File::OPC::Library::ContentTypesStream qw(
	ST_ContentType
);
use File::OPC::Library::Core qw(
	PackUri
);

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# ATTRIBUTES
# ECMA-376 Part 2, 10.1.2.2.3, M2.7
has content_type => (
	is       => 'rw',
	isa      => ST_ContentType,
	coerce   => 1,
	required => 1,
);
# ECMA-376 Part 2, 10.1.2.2.3, M2.7
has part_name => (
	is       => 'rw',
	isa      => PackUri,
	coerce   => 1,
	required => 1,
);

###############################################################################
# METHODS
sub applies_to {
	my ($self, $part_name) = @_;

	# Transform the part name if needed
	$part_name = to_PackUri($part_name);

	# According to ECMA-376 Part 2, 10.1.2.4, part name comparison is case-
	# insensitive ASCII (which is privided by the URI package).
	return $part_name eq $self->part_name;
}

###############################################################################
# MAKE MOOSE OBJECT IMMUTABLE
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream::Override - Content Types Stream Markup Override
object

=head1 VERSION

This documnetation refers to L<File::OPC::ContentTypesStream::Override> version
0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream::Override;
  
  my $override = File::OPC::ContentTypesStream::Override->new(
      content_type => 'text/xml',
      part_name    => '/feeds/myfeed.rss',
  );

  my $part_name = $override->part_name();
  $override->content_type('application/xml');

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup element
Override as defined in ECMA-376 section 10.1.2.2.3.

=head1 CONSTRUCTOR

This is fully object-oriented, and as such before any method can be used, the
constructor needs to be called to create an object to work with.

  my $override = File::OPC::ContentTypesStream::Override->new(%options);

=head2 new

This will construct a new object.

=over

=item C<< new(%attributes) >>

C<%attributes> is a HASH where the keys are attributes (specified in the
L</ATTRIBUTES> section).

=item C<< new($attributes) >>

C<$attributes> is a HASHREF where the keys are attributes (specified in the
L</ATTRIBUTES> section).

=back

=head1 ATTRIBUTES

  # Get value for attribute named "my_attribute"
  my $value = $object->my_attribute();

  # Set value for attribute named "my_attrivute"
  $object->my_attribute($value);

=head2 content_type

B<Required>

This is a MIME type for the specified part name.

=head2 part_name

B<Required>

This is the part name.

=head1 METHODS

=head2 applies_to

This method returns a Boolean if the object applies to the given part name.

=head1 DEPENDENCIES

This module is dependent on the following modules:

=over

=item * L<File::OPC::Library::ContentTypesStream>

=item * L<File::OPC::Library::Core>

=item * L<Moose> 0.62

=item * L<MooseX::StrictConstructor> 0.08

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
