package File::OPC::ContentTypesStream;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

###############################################################################
# MOOSE
use Moose 0.74;
use MooseX::StrictConstructor 0.08;

###############################################################################
# MOOSE TYPES
use File::OPC::Library::ContentTypesStream qw(
	CT_Default
	CT_Override
);
use File::OPC::Library::Core qw(
	PackUri
);
use MooseX::Types::Moose qw(
	ArrayRef
);

###############################################################################
# MODULE IMPORTS
use File::OPC::ContentTypesStream::Default;
use File::OPC::ContentTypesStream::Override;
use File::OPC::Utils qw(
	get_extension_from_part_name
);
use List::Util 1.18 qw(first);
use Readonly 1.03;
use XML::XPath 1.13;

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# LOCAL CONSTANTS
Readonly my $CONTENT_TYPES_STREAM_NAMESPACE =>
	'http://schemas.openxmlformats.org/package/2006/content-types';

###############################################################################
# PRIVATE ATTRIBUTES
has _defaults => (
	is      => 'rw',
	isa     => ArrayRef[CT_Default],
	default => sub { [] },
);
has _overrides => (
	is      => 'rw',
	isa     => ArrayRef[CT_Override],
	default => sub { [] },
);

###############################################################################
# METHODS
sub add_mapping {
	my ($self, @mappings) = @_;

	# Add according to ECMA-376 Part 2, 10.1.2.3

	PAIR: while (my ($part_name, $content_type) = splice @mappings, 0, 2) {
		# Get the extension from the part name
		my $extension = get_extension_from_part_name($part_name);

		if (!defined $extension) {
			# The part name has no extension, so just add an override
			$self->add_element(
				$self->new_override_element(
					content_type => $content_type,
					part_name    => $part_name,
				)
			);

			next PAIR;
		}

		# Get any existing default element for the extension
		my $default_element = $self->default_element($extension);

		if (defined $default_element) {
			# Since the default exists for the extension, check the MIME type to
			# determine if any rule needs to be applied.
			if ($default_element->content_type eq $content_type) {
				# They match and nothing needs to be done
				next PAIR;
			}
		}

		# Add an override by default
		$self->add_element(
			$self->new_override_element(
				content_type => $content_type,
				part_name    => $part_name,
			)
		);
	}

	return $self;
}

sub add_default_mapping {
	my ($self, @mappings) = @_;

	PAIR: while (my ($extension, $content_type) = splice @mappings, 0, 2) {
		# Add the default element
		$self->add_element(
			$self->new_default_element(
				content_type => $content_type,
				extension    => $extension,
			)
		);
	}

	return $self;
}

sub add_element {
	my ($self, @elements) = @_;

	foreach my $element (@elements) {
		# Determine the type of element
		if (is_CT_Default($element)) {
			# Check to see if the default already exists
			if (defined $self->default_element($element->extension)) {
				confess 'Unable to add default element, as the mapping already exists [M2.5]';
			}

			# Add this element to the default elements
			push @{$self->_defaults}, $element;
		}
		elsif (is_CT_Override($element)) {
			# Check to see if the override already exists
			if (defined $self->override_element($element->part_name)) {
				confess 'Unable to add default element, as the mapping already exists [M2.5]';
			}

			# Add this element to the override elements
			push @{$self->_overrides}, $element;
		}
		else {
			# Not sure what this is
			confess sprintf 'Encountered unknown element %s and unable to add.',
				$element;
		}
	}

	return $self;
}

sub add_from_xml {
	my ($self, $type, $value) = @_;

	# Get the elements from the XML
	my @elements = $self->_parse_xml($type, $value);

	foreach my $element (@elements) {
		# Just all each element
		$self->add_element($element);
	}

	# Return self for chaining
	return $self;
}

sub applied_element {
	my ($self, $part_name) = @_;

	# Get element according to ECMA-376 Part 2, 10.1.2.4

	# Get the override element if it exists
	my $override_element = $self->override_element($part_name);

	if (defined $override_element) {
		# There is an override element for this part name, so return the
		# override element
		return $override_element;
	}

	# Since there was no matching override, get the applying default element
	my $default_element = $self->default_element(get_extension_from_part_name($part_name));

	if (defined $default_element) {
		# There is a default element for this part name, so return the default
		# element.
		return $default_element;
	}

	# Nothing matched, so the mapping is not defined
	return;
}

sub clear_mappings {
	my ($self) = @_;

	# Remove all the defaults and overrides
	$self->{_defaults } = [];
	$self->{_overrides} = [];

	return $self;
}

sub content_type {
	my ($self, $part_name) = @_;

	# Get the element that applies to the part name
	my $applied_element = $self->applied_element($part_name);

	if (defined $applied_element) {
		# Return the corresponding content type
		return $applied_element->content_type;
	}

	# Nothing matched, so the content type is not defined
	return;
}

sub default_element {
	my ($self, $extension) = @_;

	# Get the matching default
	my $default = first { $_->applies_to($extension) }
		@{$self->_defaults};

	return $default;
}

sub new_default_element {
	my ($self, @args) = @_;

	# Return a new default element
	return File::OPC::ContentTypesStream::Default->new(@args);
}

sub new_override_element {
	my ($self, @args) = @_;

	# Return a new override element
	return File::OPC::ContentTypesStream::Override->new(@args);
}

sub override_element {
	my ($self, $part_name) = @_;

	# Get the matching override
	my $override = first { $_->applies_to($part_name) }
		@{$self->_overrides};

	return $override;
}

sub remove_default_mapping {
	my ($self, @extensions) = @_;

	foreach my $extension (@extensions) {
		# Filter out the corresponding default element
		my @new_defaults = grep { !$_->applies_to($extension) } @{$self->_defaults};

		# Set the new defaults list
		$self->_defaults(\@new_defaults);
	}

	return $self;
}

sub remove_mapping {
	my ($self, @part_names) = @_;

	foreach my $part_name (@part_names) {
		# Filter out the corresponding override element
		my @new_overrides = grep { !$_->applies_to($part_name) } @{$self->_overrides};

		# Set the new overrides list
		$self->_overrides(\@new_overrides);
	}

	return $self;
}

sub set_default_mapping {
	my ($self, @mappings) = @_;

	PAIR: while (my ($extension, $content_type) = splice @mappings, 0, 2) {
		# Get the default element for the extnesion
		my $default_element = $self->default_element($extension);

		if (!defined $default_element) {
			# There is no mapping for this extension
			$self->add_default_mapping($extension => $content_type);

			next PAIR;
		}

		if ($default_element->content_type eq $content_type) {
			# The mapping is already set correctly
			next PAIR;
		}

		$default_element->content_type($content_type);
	}

	return $self;
}

sub set_from_xml {
	my ($self, $type, $value) = @_;

	# Get the elements from the XML
	my @elements = $self->_parse_xml($type, $value);

	foreach my $element (@elements) {
		if (is_CT_Default($element)) {
			# Set the default mapping
			$self->set_default_mapping($element->extension, $element->content_type);
		}
		else {
			# Set the override mapping
			$self->set_mapping($element->part_name, $element->content_type);
		}
	}

	# Return self for chaining
	return $self;
}

sub set_mapping {
	my ($self, @mappings) = @_;

	PAIR: while (my ($part_name, $content_type) = splice @mappings, 0, 2) {
		# Get the applied element for the part name
		my $applied_element = $self->applied_element($part_name);

		if (!defined $applied_element) {
			# There is no mapping for this part name
			$self->add_mapping($part_name => $content_type);

			next PAIR;
		}

		if ($applied_element->content_type eq $content_type) {
			# The mapping is already set correctly
			next PAIR;
		}

		if (is_CT_Default($applied_element)) {
			# Add a new override element
			$self->add_mapping($part_name => $content_type);
		}
		else {
			# Change the content type of the override element
			$applied_element->content_type($content_type);
		}
	}

	return $self;
}

###############################################################################
# PRIVATE METHODS
sub _parse_xml {
	my ($self, $type, $value) = @_;

	my @elements;

	# Get the XML::XPath object from the arguments
	my $xpath = $type eq 'content'     ? XML::XPath->new(xml   => $value   )
	          : $type eq 'content_ref' ? XML::XPath->new(xml   => ${$value})
	          : $type eq 'io'          ? XML::XPath->new(ioref => $value   )
	          : undef;

	if (!defined $xpath) {
		confess 'No known arguments were provided';
	}

	# Set our namespace
	$xpath->set_namespace(ct => $CONTENT_TYPES_STREAM_NAMESPACE);

	# Now get all the default values
	foreach my $default_node ($xpath->findnodes('/ct:Types/ct:Default')) {
		my $content_type = $default_node->getAttribute('ContentType');
		my $extension    = $default_node->getAttribute('Extension'  );

		# Add the default to memory
		push @elements, $self->new_default_element(
			content_type => $content_type,
			extension    => $extension,
		);
	}

	# Now get all the override values
	foreach my $override_node ($xpath->findnodes('/ct:Types/ct:Override')) {
		my $content_type = $override_node->getAttribute('ContentType');
		my $part_name    = $override_node->getAttribute('PartName'   );

		# Add the override to memory
		push @elements, $self->new_override_element(
			content_type => $content_type,
			part_name    => $part_name,
		);
	}

	# Return parsed elements
	return @elements;
}

###############################################################################
# MAKE MOOSE OBJECT IMMUTABLE
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream - Content Types Stream Markup as defined in
ECMA-376 10.1.2.2

=head1 VERSION

This documnetation refers to L<File::OPC::ContentTypesStream> version 0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream;

  # Create a new stream object and store somewhere
  my $content_types = File::OPC::ContentTypesStream->new();

  # Add in the mappings from a [Content_Types].xml file
  $content_types->add_from_xml(content_ref => \$xml_contents);

  # Get the mapping for a part
  my $content_type = $content_types->content_type($part_name);

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup as defined
in ECMA-376 Part 2, section 10.1.2.2.

=head1 DOCUMENTATION NOTES

=head2 C<add_> methods

There are a range of methods beginning with C<add_> that behave according to
the ECMA-376 Part 2, section 10.1.2.3 in which the addition will not occur
if there is an existing mapping for the given part name or extension.

=head2 Chaining

This module allows the caller to make use of "chaining." This means that a
method that normally would not return any information (because the method was
a mutator, not an accessor), then a refernece to the object is returned. In
this documentation, any method that returns the object states B<chained>.

  # Create a new stream object, set a bunch of common default mappings
  # and then read in the XML, overriding any current rule.
  my $stream = File::OPC::ContentTypesStream->new
    ->set_default_mapping(
      txt => 'text/plain',
      png => 'image/png',
      jpg => 'image/jpeg',
      rtf => 'text/rtf',
    )
    ->set_from_xml(content_ref => \$xml_content);

=head2 C<set_> methods

There are a range of methods beginning with C<set_> that does not behave
according to the ECMA-376 Part 2, section 10.1.2.3. These are convience methods
to make sure the mapping is applied or created. It is essentially the same ass
checking that an override exists for the given part name, and if so it changes
the content type, otherwise a new override will be added.

=head1 CONSTRUCTOR

This is fully object-oriented, and as such before any method can be used, the
constructor needs to be called to create an object to work with.

  my $content_types = File::OPC::ContentTypesStream->new(%options);

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

This object has no attributes.

=head1 METHODS

=head2 add_default_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->add_default_mapping(%mappings);
  $content_types->add_default_mapping($extension => $content_type, ...);

This will let you add a default file extension mapping to the content types
stream. The argument is a HASH in which the keys are the part names and the
values are the content types. Please read about L</add_ methods>.

=head2 add_element

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->add_element(@elements);

This will add the given elements to the object. The element is an object,
either L<File::OPC::ContentTypesStream::Default> or
L<File::OPC::ContentTypesStream::Override>. Please read about L</add_ methods>.

  # Add an element to the object
  $content_types->add_element($default_element);

  # Add a bunch of elements all at once.
  $content_types->add_element(@elements);

=head2 add_from_xml

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->add_from_xml($argument_type => $argument);

This will parse the given XML and incorporate the contents into the object.
This method takes a HASH as the argument, and the following options can be
used. Please note that only one should be used. Please read about
L</add_ methods>.

=over

=item content

This specifies the XML content as a string.

=item content_ref

This specifies the XML content as a reference to the content string. This is
the suggested method, as it will not copy the entire XML contents multiple
times across the stack.

=item io

This specifies the IO coderef to read the XML from.

=back

=head2 add_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->add_mapping(%mappings);
  $content_types->add_mapping($part_name => $content_type, ...);

This will let you add a part name mapping to the content types stream. The
argument is a HASH in which the keys are the part names and the values are the
content types. Please read about L</add_ methods>.

=head2 applied_element

Returns: The default or override element that applies to the part name (either
a L<File::OPC::ContentTypesStream::Default> or
L<File::OPC::ContentTypesStream::Override>).

  # Prototype
  my $applied_element = $content_types->applied_element($part_name);

This will get the applied element that corresponds to the given part name. If
there is no mapping for the given part name, then C<undef> is returned (as the
mapping is undefined).

=head2 clear_mappings

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->clear_mappings();

This will clear all mappings in the object. This is rarely used, but provided
if the need should arrise.

=head2 content_type

Returns: The content type of the part (a L<MIME::Type>).

  # Prototype
  my $content_type = $content_types->content_type($part_name);

This will get the content type for the given part name. If there is no mapping
for the given part name, then C<undef> is returned (as the mapping is
undefined).

=head2 default_element

Returns: The default element for the extension (a
L<File::OPC::ContentTypesStream::Default>).

  # Prototype
  my $default_element = $content_types->default_element($extension);

This will get the L<File::OPC::ContentTypesStream::Default> object that
corresponds to the given extension. If there is no default element for the
given extension, then C<undef> is returned (as the mapping is undefined).

=head2 new_default_element

Returns: The newly created default element (a
L<File::OPC::ContentTypesStream::Default>).

  # Prototype
  my $default_element = $content_types->new_default_element(%options);

This will create a new L<File::OPC::ContentTypesStream::Default> object with
the provided options. The default element will not be associated with the
object in any way. Please see L<File::OPC::ContentTypesStream::Default> for
what options to specify.

=head2 new_override_element

Returns: The default element for the extension (a
L<File::OPC::ContentTypesStream::Override>).

  # Prototype
  my $override_element = $content_types->new_override_element(%options);

This will create a new L<File::OPC::ContentTypesStream::Override> object with
the provided options. The override element will not be associated with the
object in any way. Please see L<File::OPC::ContentTypesStream::Override> for
what options to specify.

=head2 override_element

Returns: The default element for the extension (a
L<File::OPC::ContentTypesStream::Override>).

  # Prototype
  my $override_element = $content_types->override_element($part_name);

This will get the L<File::OPC::ContentTypesStream::Override> object that
corresponds to the given part name. The first argument is the part name. If
there is no override element for the given part name, then C<undef> is returned
(as the mapping is undefined).

=head2 remove_default_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->remove_default_mapping(@extensions);

This will remove the mappings for the specified extensions. This should be used
with care, as this object does not track if there are any part names using a
default mapping, and so the mappings for some part names may become lost.

=head2 remove_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->remove_mapping(@part_names);

This will remove the mappings for the specified part names. If the part name
was mapped using a default mapping, then it won't look like it was removed, but
any override for the specified part name will have been removed.

=head2 set_default_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->set_default_mapping(%mappings);
  $content_types->set_default_mapping($extension => $content_type, ...);

This will let you set a default file extension mapping in the content types
stream. Please read about L</set_ methods>.

=head2 set_from_xml

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->set_from_xml($argument_type => $argument);

This will parse the given XML and incorporate the contents into the object.
This method takes a HASH as the argument, and the following options can be
used. Please note that only one should be used. Please read about
L</set_ methods>.

=over

=item content

This specifies the XML content as a string.

=item content_ref

This specifies the XML content as a reference to the content string. This is
the suggested method, as it will not copy the entire XML contents multiple
times across the stack.

=item io

This specifies the IO coderef to read the XML from.

=back

=head2 set_mapping

Returns: B<chained> (See L</Chaining>).

  # Prototype
  $content_types->set_mapping(%mappings);
  $content_types->set_mapping($part_name => $content_type, ...);

This will set a mapping in content types stream. The first argument is the part
name and the second argument is the content type of the part. Please read about
L</set_ methods>.

=head1 DEPENDENCIES

This module is dependent on the following modules:

=over

=item * L<File::OPC::ContentTypesStream::Default>

=item * L<File::OPC::ContentTypesStream::Override>

=item * L<File::OPC::Library::ContentTypesStream>

=item * L<File::OPC::Library::Core>

=item * L<File::OPC::Utils>

=item * L<List::Util> 1.18

=item * L<Moose> 0.74

=item * L<MooseX::StrictConstructor> 0.08

=item * L<Readonly> 1.03

=item * L<XML::XPath> 1.13

=item * L<namespace::autoclean> 0.08

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
