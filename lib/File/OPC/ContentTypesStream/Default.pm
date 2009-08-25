package File::OPC::ContentTypesStream::Default;

use 5.008001;
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
	ST_Extension
);

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

###############################################################################
# ATTRIBUTES
has content_type => (
	'is'       => 'rw',
	'isa'      => ST_ContentType,
	'coerce'   => 1,
	'required' => 1,
);
has extension => (
	'is'       => 'rw',
	'isa'      => ST_Extension,
	'coerce'   => 1,
	'required' => 1,
);

###############################################################################
# MAKE MOOSE OBJECT IMMUTABLE
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream::Default - Content Types Stream Markup Default
object

=head1 VERSION

This documnetation refers to L<File::OPC::ContentTypesStream::Default> version
0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream::Default;
  
  my $default = File::OPC::ContentTypesStream::Default->new(
      content_type => 'text/xml',
      extension    => 'xml',
  );

  my $extension = $default->extension();
  $default->content_type('application/xml');

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup element
Default as defined in ECMA-376 section 10.1.2.2.2.

=head1 CONSTRUCTOR

This is fully object-oriented, and as such before any method can be used, the
constructor needs to be called to create an object to work with.

  my $default = File::OPC::ContentTypesStream::Default->new(%options);

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

This is a MIME type for the default file extension.

=head2 extension

B<Required>

This is the file extension.

=head1 METHODS

This module has no methods.

=head1 DEPENDENCIES

This module is dependent on the following modules:

=over

=item * L<File::OPC::Library::ContentTypesStream>

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
