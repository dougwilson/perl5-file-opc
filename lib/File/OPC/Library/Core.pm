package File::OPC::Library::Core;

use 5.008;
use strict;
use utf8;
use version 0.74;
use warnings 'all';

use MooseX::Types 0.08 -declare => [qw(
	MimeType
	PackUri
)];
use MooseX::Types::Moose qw(
	Object
	Str
);

use MIME::Type 1.24;
use URI 0.07;

# Module metadata
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.01_01';

subtype MimeType()
	=> as Object()
	=> where { $_->isa( 'MIME::Type' ) };

coerce MimeType()
	=> from Str()
		=> via { MIME::Type->new( 'type' => $_ ) };

subtype PackUri()
	=> as Object()
	=> where { $_->isa( 'URI' ) };

coerce PackUri()
	=> from Str()
		=> via { URI->new( $_, 'pack' ) };

1;

__END__

=encoding utf8

=head1 NAME

File::OPC::Library::Core - Core types

=head1 VERSION

This documentation refers to <File::OPC::Library::Core> version 0.01

=head1 SYNOPSIS

  use File::OPC::Library::Core qw( MimeType PackUri );
  # This will import MimeType and PackUri types into your namespace as well as
  # some helpers like to_MimeType and is_MimeType
  
  # Change the string to a MIME type type
  my $text_mime = to_MimeType( 'text/plain' );
  if ( is_MimeType( $text_mime ) ) {
      # Test if $text_mime is a MIME type
      print $text_mime->mediaType;
  }

=head1 DESCRIPTION

This module provides core types for File::OPC.

=head1 METHODS

No methods.

=head1 TYPES PROVIDED

=over 4

=item * MimeType

=item * PackUri

=back

=head1 DEPENDENCIES

This module is dependent on the following modules:

L<MIME::Type>
L<MooseX::Types>
L<MooseX::Types::Moose>
L<URI>

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
