package File::OPC::ContentTypesStream;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

use Moose 0.62;
use MooseX::FollowPBP;
use MooseX::StrictConstructor;

use File::OPC::ContentTypesStream::Default;
use File::OPC::ContentTypesStream::Override;
use File::OPC::Library::ContentTypesStream qw(
	FileExtension
);
use File::OPC::Library::Core qw(
	PackUri
);

use XML::XPath 1.13;

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

has 'defaults' => (
	'default' => sub { [ ] },
	'is'      => 'rw',
	'isa'     => 'ArrayRef[File::OPC::ContentTypesStream::Default]',
);

has 'overrides' => (
	'default' => sub { [ ] },
	'is'      => 'rw',
	'isa'     => 'ArrayRef[File::OPC::ContentTypesStream::Override]',
);

# Make the package immutable
__PACKAGE__->meta->make_immutable;

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
		my $content_type = $default_node->getAttribute( 'ContentType' );
		my $extension    = $default_node->getAttribute( 'Extension' );

		# Add the default to memory
		$self->add_default( $extension => $content_type );
	}

	# Now get all the override values
	foreach my $override_node ( $xpath->findnodes( '/ct:Types/ct:Override' ) ) {
		my $content_type = $override_node->getAttribute( 'ContentType' );
		my $partname     = $override_node->getAttribute( 'PartName' );

		# Add the override to memory
		$self->add_override( $partname => $content_type );
	}

	return;
}

sub add_default {
	my ( $self, $extension, $content_type ) = @_;

	# Create a new default element
	my $default = File::OPC::ContentTypesStream::Default->new(
		'content_type' => $content_type,
		'extension'    => $extension,
	);

	# Set the default in memory
	push @{ $self->get_defaults() }, $default;

	# Not sure what to return yet
	return;
}

sub add_override {
	my ( $self, $partname, $content_type ) = @_;

	# Create a new override element
	my $override = File::OPC::ContentTypesStream::Override->new(
		'content_type' => $content_type,
		'part_name'    => $partname,
	);

	# Set the override in memory
	push @{ $self->get_overrides() }, $override;

	# Not sure what to return yet
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
	foreach my $default ( @{ $self->get_defaults() } ) {
		if ( $default->extension() eq $extension ) {
			return $default->content_type();
		}
	}

	# Nothing found
	return;
}

sub get_mime_type {
	my ( $self, $partname ) = @_;

	# Corece
	if ( !is_PackUri( $partname ) ) {
		$partname = to_PackUri( $partname );
	}

	return $self->get_override( $partname ) || $self->get_default( $partname );
}

sub get_override {
	my ( $self, $partname ) = @_;

	# Coerce
	if ( !is_PackUri( $partname ) ) {
		$partname = to_PackUri( $partname );
	}

	return
		if !defined $partname;

	# Return the MIME Type
	foreach my $override ( @{ $self->get_overrides() } ) {
		if ( $override->get_part_name() eq $partname ) {
			return $override->get_content_type();
		}
	}

	# Nothing found
	return;
}

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream - Content Types Stream Markup as defined in
ECMA-376 10.1.2.2

=head1 VERSION

This documnetation refers to L<File::OPC::ContentTypesStream> version 0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream;
  
  my $content_types = File::OPC::ContentTypesStream->new( 'xml' => $xml_string );

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

=over

=item * L<File::OPC::ContentTypesStream::Default>

=item * L<File::OPC::ContentTypesStream::Override>

=item * L<File::OPC::Library::ContentTypesStream>

=item * L<File::OPC::Library::Core>

=item * L<Moose> 0.62

=item * L<MooseX::FollowPBP>

=item * L<MooseX::StrictConstructor>

=item * L<XML::XPath> 1.13

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
