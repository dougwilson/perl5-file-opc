package File::OPC::Library::ContentTypesStream;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

use MooseX::Types 0.08 -declare => [qw(
	FileExtension
	ST_ContentType
	ST_Extension
)];
use MooseX::Types::Moose qw(
	Object
	Str
);

use File::OPC::Library::Core qw(
	MimeType
);

use MIME::Type 1.24;
use URI;

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

subtype FileExtension()
	=> as Str()
	=> where { m{ \A [a-z]+ \z }msx; };

coerce FileExtension()
	=> from Object()
		=> via {
			if ( $_->isa( 'URI' ) )
			{
				# This is for converting URI objects
				return lc [ pop( @{ [ $_->path_segments ] } ) =~ m{ \. ( [a-z]+ ) \z }imsx ]->[0];
			}
			return;
		}
	=> from Str()
		=> via { m{ \A [a-z]+ \z }imsx ? lc( $_ ) : lc [ m{ \. ( [a-z]+ ) \z }imsx ]->[0] };

subtype ST_ContentType()
	=> as MimeType();

coerce ST_ContentType()
	=> from Str()
		=> via {
			to_MimeType( $_ );
		};

subtype ST_Extension()
	=> as FileExtension();

1;

__END__

=head1 NAME

File::OPC::Library::ContentTypesStream - Content Types Stream Markup types

=head1 VERSION

This documentation refers to <File::OPC::Library::ContentTypesStream> version
0.001

=head1 SYNOPSIS

  use File::OPC::Library::ContentTypesStream qw( ST_Extension ST_ContentType );
  # This will import ST_Extension and ST_ContentType types into your namespace
  # as well as some helpers like to_ST_ContentType and is_ST_ContentType
  
  # Change the string to a ST_ContentType
  my $contenttype = to_ST_ContentType( 'text/plain' );
  if ( is_ST_ContentType( $contenttype ) ) {
      # Test if $contentype is a ST_ContentType
      print $contenttype->mediaType;
  }

=head1 DESCRIPTION

This module provides types unique to handling Content Types Streams.

=head1 METHODS

No methods.

=head1 TYPES PROVIDED

=over 4

=item * FileExtension

=item * ST_ContentType

=item * ST_Extension

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
