package File::OPC::ContentTypesStream;

use 5.008;
use strict;
use utf8;
use warnings 'all';

use Moose 0.62;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;

use File::OPC::Library::ContentTypesStream qw(
	FileExtension
	MimeType
	MimeTypeMap
	UriPack
);

use Carp 'cluck';
use XML::XPath 1.13;

our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.01';

has 'defaults' => (
	'isa' => MimeTypeMap,
	'coerce' => 1,
	'default' => sub { { } },
);

has 'overrides' => (
	'isa' => MimeTypeMap,
	'coerce' => 1,
	'default' => sub { { } },
);

# Make the package immutable
__PACKAGE__->meta->make_immutable;

# Remove Moose keywords
no Moose;

sub BUILD {
	my ( $self, $part ) = @_;

	my $xpath;

	if ( exists $part->{ 'string' } ) {
		$xpath = XML::XPath->new( 'xml' => $part->{ 'string' } );
		delete $part->{ 'string' };
	}
	else {
		confess;
	}

	# Set our namespaces
	$xpath->set_namespace( 'ct', 'http://schemas.openxmlformats.org/package/2006/content-types' );

	# Now get all the default values
	foreach my $default_node ( $xpath->findnodes( '/ct:Types/ct:Default' ) ) {
		my $content_type = to_MimeType( $default_node->getAttribute( 'ContentType' ) );
		my $extension    = to_FileExtension( $default_node->getAttribute( 'Extension' ) );

		if ( !defined $content_type || !defined $extension ) {
			next;
		}

		# Add the default to memory
		$self->add_default( $extension => $content_type );
	}

	# Now get all the override values
	foreach my $override_node ( $xpath->findnodes( '/ct:Types/ct:Override' ) ) {
		my $content_type = to_MimeType( $override_node->getAttribute( 'ContentType' ) );
		my $partname     = to_UriPack( $override_node->getAttribute( 'PartName' ) );

		if ( !defined $content_type || !defined $partname ) {
			next;
		}

		# Add the override to memory
		$self->add_override( $partname => $content_type );
	}

	return;
}

sub add_default {
	my ( $self, $extension, $content_type ) = @_;

	# Coerce
	if ( !is_MimeType( $content_type ) ) {
		$content_type = to_MimeType( $content_type );
	}
	if ( !is_FileExtension( $extension ) ) {
		$extension = to_FileExtension( $extension );
	}

	if ( !defined $content_type || !defined $extension ) {
		cluck 'Given extension and/or content type are incorrect.';
	}

	# Set the default in memory
	$self->{ 'defaults' }->{ $extension } = $content_type;

	return;
}

sub add_override {
	my ( $self, $partname, $content_type ) = @_;

	# Coerce
	if ( !is_MimeType( $content_type ) ) {
		$content_type = to_MimeType( $content_type );
	}
	if ( !is_UriPack( $partname ) ) {
		$partname = to_UriPack( $partname );
	}

	if ( !defined $content_type || !defined $partname ) {
		cluck 'Given part name and/or content type are incorrect.';
	}

	# Set the override in memory
	$self->{ 'overrides' }->{ $partname } = $content_type;

	return;
}

sub get_default {
	my ( $self, $extension ) = @_;

	# Coerce
	if ( !is_FileExtension( $extension ) ) {
		$extension = to_FileExtension( $extension );
	}

	return
		if !defined $extension;

	# Return the MIME Type
	return exists $self->{ 'defaults' }->{ $extension } ? $self->{ 'defaults' }->{ $extension } : undef;
}

sub get_mime_type {
	my ( $self, $part ) = @_;

	# Corece
	if ( !is_UriPack( $part ) ) {
		$part = to_UriPack( $part );
	}

	return $self->get_override( $part ) || $self->get_default( $part );
}

sub get_override {
	my ( $self, $partname ) = @_;

	# Coerce
	if ( !is_UriPack( $partname ) ) {
		$partname = to_UriPack( $partname );
	}

	# Return the MIME Type
	return exists $self->{ 'overrides' }->{ $partname } ? $self->{ 'overrides' }->{ $partname } : undef;
}

1;

__END__

=encoding utf8

=head1 NAME

File::OPC::ContentTypesStream - Content Types Stream Markup as defined in ECMA-376 10.1.2.2

=head1 VERSION

This documnetation refers to <File::OPC::ContentTypesStream> version 0.01

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream;
  
  my $content_types = File::OPC::ContentTypesStream->new( 'xml' => $xml_string );
  $content_types->

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup as defined
in ECMA-376 section 10.1.2.2.

=head1 CONSTRUCTOR

  my $content_types = File::OPC::ContentTypesStream->new( %options );

=over 4

=item * xml

Optional. This would be an XML string. It will construct the overrides and
defaults from the provided XML.

=back

=head1 METHODS

=head2 add_default

This will let you add a default file extension mapping to the content types stream.
  $content_types->add_default( 'png' => 'image/png' );

=head2 add_override

This will let you add an override for a certain part name to the content types stream.
  $content_types->add_override( '/text/iam.special' => 'text/html' );

=head2 get_default

This will get the default MIME type for the given extension
  $content_types->get_default( 'png' );

=head2 get_mime_type

This will get the MIME type for the given part name.
  $content_types->get_mime_type( '/images/logo.jpeg' );

=head2 get_override

This will get the override for a certain part name
  $content_types->get_override( '/extras/rss.xml' );

=head1 DEPENDENCIES

This module is dependent on the following modules:

L<Carp>
L<File::OPC::Library::ContentTypesStream>
L<Moose>
L<Moose::Util::TypeConstraints>
L<MooseX::StrictConstructor>
L<XML::XPath>

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to C<bug-file-opc at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-OPC>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 AUTHOR

Douglas Christopher Wilson, C<< <doug at somethingdoug.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2008 Douglas Christopher Wilson

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
