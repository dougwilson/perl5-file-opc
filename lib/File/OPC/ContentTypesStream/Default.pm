package File::OPC::ContentTypesStream::Default;

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

use File::OPC::Library::ContentTypesStream qw(
	ST_ContentType
	ST_Extension
);

###############################################################################
# ALL IMPORTS BEFORE THIS WILL BE ERASED
use namespace::clean 0.04 -except => [qw(meta)];

has 'content_type' => (
	'coerce'   => 1,
	'is'       => 'rw',
	'isa'      => ST_ContentType(),
	'required' => 1,
);

has 'extension' => (
	'coerce'   => 1,
	'is'       => 'rw',
	'isa'      => ST_Extension(),
	'required' => 1,
);

# Make the package immutable
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream::Default - Content Types Stream Markup Default
object

=head1 VERSION

This documnetation refers to <File::OPC::ContentTypesStream::Default> version
0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream::Default;
  
  my $default = File::OPC::ContentTypesStream::Default->new(
      'content_type' => 'text/xml',
      'extension'    => 'xml',
  );
  my $extension = $default->get_extension();
  $default->set_content_type( 'application/xml' );

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup element
Default as defined in ECMA-376 section 10.1.2.2.2.

=head1 CONSTRUCTOR

  my $default = File::OPC::ContentTypesStream::Default->new( %options );

=over 4

=item * content_type

Required. This is a MIME type for the default file extension.

=item * extension

Required. This is the file extension.

=back

=head1 METHODS

=head2 get_content_type

This will get the current MIME type for the default element.
  $default->get_content_type();

=head2 get_extension

This will get the current file extension for the default element.
  $default->get_extension();

=head2 set_content_type

This will set a new MIME type for the default element.
  $default->set_content_type( 'text/xml' );

=head2 set_extension

This will set a new file extension for the default element.
  $default->set_extension( 'rel' );

=head1 DEPENDENCIES

This module is dependent on the following modules:

L<File::OPC::Library::ContentTypesStream>
L<Moose>
L<MooseX::FollowPBP>
L<MooseX::StrictConstructor>

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
