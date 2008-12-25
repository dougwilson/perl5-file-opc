package File::OPC::Library::ContentTypesStream;

use 5.008;
use strict;
use warnings 'all';

use MooseX::Types 0.08
	-declare => [qw(
		FileExtension
		MimeType
		MimeTypeMap
		UriPack
	)];
use MooseX::Types::Moose
	qw(
		HashRef
		Object
		Str
	);

use MIME::Type 1.24;
use URI;

our $VERSION = '0.01';

subtype FileExtension()
	=> as Str()
	=> where { /^[a-z]+$/x; };

coerce FileExtension()
	=> from Object()
		=> via {
			if ( $_->isa( 'URI' ) )
			{
				# This is for converting URI objects
				return lc( [ pop( @{ [ $_->path_segments ] } ) =~ /\.([a-z]+)$/ix ]->[0] );
			}
			return;
		}
	=> from Str()
		=> via { /^[a-z]+$/ix ? lc( $_ ) : lc( [ /\.([a-z]+)$/ix ]->[0] ) };

subtype MimeType()
	=> as Object()
	=> where { $_->isa( 'MIME::Type' ) };

coerce MimeType()
	=> from Str()
		=> via { MIME::Type->new( 'type' => $_ ) };

subtype MimeTypeMap()
	=> as HashRef[MimeType()];

subtype UriPack()
	=> as Object()
	=> where { $_->isa( 'URI' ) };

coerce UriPack()
	=> from Str()
		=> via { URI->new( $_, 'pack' ) };

1;

__END__

=head1 NAME

File::OPC::Library::ContentTypesStream - Content Types Stream Markup types

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This module provides types unique to handling Content Types Sctreams.

=head1 TYPES PROVIDED

=over 4

=item * MimeType

=item * MimeTypeMap

=item * UriPack

=back

=head1 AUTHOR

Douglas Christopher Wilson, C<< <doug at somethingdoug.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-opc at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-OPC>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Douglas Christopher Wilson

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
