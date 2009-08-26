package File::OPC::Library::ContentTypesStream;

use 5.008;
use strict;
use warnings 'all';

###############################################################################
# METADATA
our $AUTHORITY = 'cpan:DOUGDUDE';
our $VERSION   = '0.001';

###############################################################################
# MOOSE TYPE LIBRARY
use MooseX::Types 0.08 -declare => [qw(
	CT_Default
	CT_Override
	ST_ContentType
	ST_Extension
)];

###############################################################################
# MOOSE TYPES
use File::OPC::Library::Core qw(
	MimeType
	PackUri
);
use MooseX::Types::Moose qw(
	Object
	Str
);

###############################################################################
# MODULE IMPORTS
use File::OPC::Utils qw(
	get_extension_from_part_name
);
use Readonly 1.03;

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# LOCAL CONSTANTS
Readonly my $ST_EXTENSION_RE => qr{\A (?:
	\&amp;|                 # Ampersand
	\%[[:xdigit:]]{2}|      # Percent-encoded byte
	[!\$'\(\)\*\+,:=\-_~@]| # Various punctuation
	[[:alnum:]]             # Alpha-numeric
)+ \z}msx;

###############################################################################
# TYPE DECLARATIONS
# CT_Default
class_type CT_Default,
	{ class => 'File::OPC::ContentTypesStream::Default' };

# CT_Override
class_type CT_Override,
	{ class => 'File::OPC::ContentTypesStream::Override' };

# ST_ContentType
# ECMA-376 Part 2, D.1
subtype ST_ContentType,
	as MimeType;

coerce ST_ContentType,
	from Str,
		via { to_MimeType($_) };

# ST_Extension
# ECMA-376 Part 2, D.1
subtype ST_Extension,
	as Str,
	where { $_ =~ $ST_EXTENSION_RE };

coerce ST_Extension,
	from PackUri,
		via { get_extension_from_part_name($_) };

1;

__END__

=head1 NAME

File::OPC::Library::ContentTypesStream - Content Types Stream Markup types

=head1 VERSION

This documentation refers to L<File::OPC::Library::ContentTypesStream> version
0.001

=head1 SYNOPSIS

  use File::OPC::Library::ContentTypesStream qw(ST_Extension ST_ContentType);
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

This module has no methods.

=head1 TYPES PROVIDED

=over 4

=item * CT_Default

=item * CT_Override

=item * ST_ContentType

=item * ST_Extension

=back

=head1 DEPENDENCIES

This module is dependent on the following modules:

=over

=item * L<File::OPC::Library::Core>

=item * L<MooseX::Types> 0.08

=item * L<MooseX::Types::Moose>

=item * L<Readonly> 1.03

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
