package File::OPC::ContentTypesStream::Override;

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
);
use File::OPC::Library::Core qw(
	PackUri
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

has 'part_name' => (
	'coerce'   => 1,
	'is'       => 'rw',
	'isa'      => PackUri(),
	'required' => 1,
);

# Make the package immutable
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

File::OPC::ContentTypesStream::Override - Content Types Stream Markup Override
object

=head1 VERSION

This documnetation refers to <File::OPC::ContentTypesStream::Override> version
0.001

=head1 SYNOPSIS

  use File::OPC::ContentTypesStream::Override;
  
  my $override = File::OPC::ContentTypesStream::Override->new(
      'content_type' => 'text/xml',
      'part_name'    => '/feeds/myfeed.rss',
  );
  my $part_name = $override->get_part_name();
  $override->set_content_type( 'application/xml' );

=head1 DESCRIPTION

This module provides an interface to the Content Types Stream Markup element
Override as defined in ECMA-376 section 10.1.2.2.3.

=head1 CONSTRUCTOR

  my $override = File::OPC::ContentTypesStream::Override->new( %options );

=over 4

=item * content_type

Required. This is a MIME type for the specified part name.

=item * part_name

Required. This is the part name.

=back

=head1 METHODS

=head2 get_content_type

This will get the current MIME type for the override element.
  $override->get_content_type();

=head2 get_part_name

This will get the current file extension for the override element.
  $override->get_part_name();

=head2 set_content_type

This will set a new MIME type for the override element.
  $override->set_content_type( 'text/xml' );

=head2 set_part_name

This will set a new file extension for the override element.
  $override->set_part_name( '/feeds/friend.rss' );

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
