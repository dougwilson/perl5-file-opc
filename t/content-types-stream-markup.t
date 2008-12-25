#!perl -T

use strict;
use warnings 'all';

use Test::More tests => 7;

use URI 1.37;

BEGIN
{
	use_ok( 'File::OPC::ContentTypesStream' );
}

my $stream_simple = <<STREAM_SIMPLE;
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
	<Override PartName="/test/image.jpg" ContentType="image/jpeg"/>
	<Default Extension="png" ContentType="image/png"/>
	<Override PartName="/test/rss.xml" ContentType="application/rss+xml"/>
	<Default Extension="wmf" ContentType="image/x-wmf"/>
	<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
	<Default Extension="xml" ContentType="application/xml"/>
</Types>
STREAM_SIMPLE

my $ct_simple = new_ok 'File::OPC::ContentTypesStream' => [ 'string' => $stream_simple ];

is( $ct_simple->get_mime_type( '/image.png' )                    , 'image/png'          , 'Default MIME type from path name' );
is( $ct_simple->get_mime_type( URI->new( '/image.png', 'pack' ) ), 'image/png'          , 'Default MIME type from path URI' );
is( $ct_simple->get_mime_type( '/rss.xml' )                      , 'application/xml'    , 'Override MIME type' );
is( $ct_simple->get_mime_type( '/test/rss.xml' )                 , 'application/rss+xml', 'Override MIME type' );
is( $ct_simple->get_mime_type( '/test/rss.xmlx' )                , undef                , 'Non-existant mapping' );
