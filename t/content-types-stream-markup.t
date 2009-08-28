#!perl -T

use strict;
use warnings 'all';

###############################################################################
# TEST MODULES
use Test::Exception 0.10;
use Test::More 0.88;

###############################################################################
# MODULES
use File::OPC::ContentTypesStream;
use File::Spec;
use URI 0.07;

###############################################################################
# VARIABLES
my %file_mapping = (
	'[Content_Types].Simple.xml' => {
		Default => {
			png  => 'image/png',
			wmf  => 'image/x-wmf',
			rels => 'application/vnd.openxmlformats-package.relationships+xml',
			xml  => 'application/xml',
		},
		Override => {
			'/test/image.jpg' => 'image/jpeg',
			'/test/rss.xml'   => 'application/rss+xml',
		},
	},
	'[Content_Types].Excel.xml' => {
		Default => {
			rels => 'application/vnd.openxmlformats-package.relationships+xml',
			xml  => 'application/xml',
		},
		Override => {
			'/xl/theme/theme1.xml'  => 'application/vnd.openxmlformats-officedocument.theme+xml',
			'/xl/styles.xml'        => 'application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml',
			'/xl/workbook.xml'      => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml',
			'/docProps/app.xml'     => 'application/vnd.openxmlformats-officedocument.extended-properties+xml',
			'/xl/sharedStrings.xml' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml',
			'/docProps/core.xml'    => 'application/vnd.openxmlformats-package.core-properties+xml',
		},
	},
);

my $stream_simple_filename = File::Spec->catfile(qw(t res [Content_Types].Simple.xml));

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

###############################################################################
# TEST OF CREATING ELEMENT OBJECTS
{
	# Create stream object
	my $stream = File::OPC::ContentTypesStream->new;

	# Default element
	isa_ok $stream->new_default_element(
		content_type => 'text/plain',
		extension    => 'txt',
	), 'File::OPC::ContentTypesStream::Default', '->new_default_element()';

	dies_ok {$stream->new_default_element()} '->new_default_element() dies';

	# Override element
	isa_ok $stream->new_override_element(
		content_type => 'text/rtf',
		part_name    => '/test.rtf',
	), 'File::OPC::ContentTypesStream::Override', '->new_override_element()';

	dies_ok {$stream->new_override_element()} '->new_override_element() dies';
}

###############################################################################
# TEST OF ADDING ELEMENT OBJECTS
{
	# Create stream object
	my $stream = File::OPC::ContentTypesStream->new;

	my $default_element = $stream->new_default_element(
		content_type => 'text/plain',
		extension    => 'txt',
	);

	my $override_element = $stream->new_override_element(
		content_type => 'text/rtf',
		part_name    => '/test.rtf',
	);

	lives_ok {$stream->add_element($default_element)}
		'->add_element($default_element)';
	lives_ok {$stream->add_element($override_element)}
		'->add_element($override_element)';

	# Repeat an object
	dies_ok {$stream->add_element($default_element)}
		'->add_element($default_element) dies (it was added already)';

	# Bad values
	dies_ok {$stream->add_element('I am no object')}
		'->add_element("string") dies';
	dies_ok {$stream->add_element(URI->new('google.com'))}
		'->add_element($object) dies';

	# Verify
	ok defined $stream->override_element('/test.rtf'), 'Verified addition of /test.rtf';
	ok defined $stream->default_element('txt'), 'Verified addition of .txt';
}

###############################################################################
# TEST ADDING OF ELEMENTS
{
	# Create stream object
	my $stream = File::OPC::ContentTypesStream->new;

	# Add a default mapping for txt
	lives_ok {$stream->add_default_mapping(txt => 'text/plain')}
		'->add_default_mapping(extension => mime)';

	# Add multiple default mappings at once
	lives_ok {$stream->add_default_mapping(png => 'image/png', jpg => 'image/jpeg')}
		'->add_default_mapping->(extension => mime, extension => mime, ...)';

	# Add part mapping
	lives_ok {$stream->add_mapping('/images/logo.gif' => 'image/gif')}
		'->add_mapping(part => mime)';

	# Add part mapping where the default matches
	lives_ok {$stream->add_mapping('/images/logo.png' => 'image/png')}
		'->add_mapping(part => mime) where part extension has a default of mime';

	# Add part mapping where the default is different
	lives_ok {$stream->add_mapping('/images/logo.jpg' => 'image/x-ms-bmp')}
		'->add_mapping(part => mime) where part extnesion has a default not of mime';

	# Add multiple part mappings at once
	lives_ok {$stream->add_mapping('/docs/help.rtf' => 'text/rtf', '/docs/help.doc' => 'application/msword')}
		'->add_mapping(part => mime, part => mime, ...)';

	# Add a default mapping for existing override
	lives_ok {$stream->add_default_mapping(rtf => 'text/rtf')}
		'->add_default_mapping(extnesion => mime)';

	# Verfiy
	ok defined $stream->default_element('txt'), 'Default mapping for txt set';
	ok defined $stream->default_element('png'), 'Default mapping for png set';
	ok defined $stream->default_element('jpg'), 'Default mapping for jpg set';
	ok defined $stream->default_element('rtf'), 'Default mapping for rtf set';
	ok defined $stream->override_element('/images/logo.gif'), 'Part mapping for logo.gif set';
	ok defined $stream->override_element('/images/logo.jpg'), 'Part mapping for logo.jpg set';
	ok defined $stream->override_element('/docs/help.rtf'  ), 'Part mapping for help.rtf set';
	ok defined $stream->override_element('/docs/help.doc'  ), 'Part mapping for help.doc set';

	is $stream->content_type('/new.txt'        ), 'text/plain'        , 'Default mapping for txt applied';
	is $stream->content_type('/new.png'        ), 'image/png'         , 'Default mapping for png applied';
	is $stream->content_type('/new.jpg'        ), 'image/jpeg'        , 'Default mapping for jpg applied';
	is $stream->content_type('/images/logo.gif'), 'image/gif'         , 'Type for logo.gif set';
	is $stream->content_type('/images/logo.png'), 'image/png'         , 'Type for logo.png set';
	is $stream->content_type('/images/logo.jpg'), 'image/x-ms-bmp'    , 'Type for logo.jpg set';
	is $stream->content_type('/docs/help.rtf'  ), 'text/rtf'          , 'Type for help.rtf set';
	is $stream->content_type('/docs/help.doc'  ), 'application/msword', 'Type for help.doc set';

	# Clear all mappings
	lives_ok {$stream->clear_mappings()} '->clear_mappings()';

	# Verify
	ok !defined $stream->default_element('txt'), 'Default mapping for txt unset';
	ok !defined $stream->default_element('png'), 'Default mapping for png unset';
	ok !defined $stream->default_element('jpg'), 'Default mapping for jpg unset';
	ok !defined $stream->default_element('rtf'), 'Default mapping for rtf unset';
	ok !defined $stream->override_element('/images/logo.gif'), 'Part mapping for logo.gif unset';
	ok !defined $stream->override_element('/images/logo.jpg'), 'Part mapping for logo.jpg unset';
	ok !defined $stream->override_element('/docs/help.rtf'  ), 'Part mapping for help.rtf unset';
	ok !defined $stream->override_element('/docs/help.doc'  ), 'Part mapping for help.doc unset';
}

###############################################################################
# TEST PARSING METHODS
{
	my %parse_args = (
		content     => [content     => $stream_simple         ],
		content_ref => [content_ref => \$stream_simple        ],
	#	file_name   => [file_name   => $stream_simple_filename],
	);

	foreach my $parse_args_key (keys %parse_args) {
		# Create a new stream
		my $stream = File::OPC::ContentTypesStream->new;

		# Use provided parse arguments
		lives_ok { $stream->add_from_xml(@{$parse_args{$parse_args_key}}); }
			'Parse XML with given arguments in ' . $parse_args_key;

		# Perform basic tests to make sure the parse worked correctly
		is $stream->content_type('/image.png')    , 'image/png'          , 'Default MIME type from path name';
		is $stream->content_type('/rss.xml')      , 'application/xml'    , 'Override MIME type';
		is $stream->content_type('/test/rss.xml') , 'application/rss+xml', 'Override MIME type';
		is $stream->content_type('/test/rss.xmlx'), undef                , 'Non-existant mapping';
	}
}

###############################################################################
# TEST MULTIPLE PARSING
{
	my $stream = File::OPC::ContentTypesStream->new;

	# Parse in from the string
	lives_ok {$stream->add_from_xml(content => $stream_simple)}
		'Parse a string of XML';

	# Parse in from the file the same contents
	dies_ok {$stream->add_from_xml(file_name => $stream_simple_filename)}
		'Parse a file of XML with rules already present';

	# Override the png default
	lives_ok {$stream->set_default_mapping(png => 'image/gif') }
		'Change the default for png to image/gif';

	# Add a new default
	lives_ok {$stream->add_default_mapping(taco => 'text/x-taco') }
		'Set taco to text/x-taco';

	# Check to be sure override occurred
	is $stream->content_type('/image.png'), 'image/gif',
		'Default MIME type from path name is image/gif';

	# Parse in from the string
	dies_ok {$stream->add_from_xml(content => $stream_simple)}
		'Parse a string of XML with existing mappings';

	# Check to be sure default is not back
	is $stream->content_type('/image.png'), 'image/gif',
		'Default MIME type from path name is still image/gif';

	# Check to be sure taco defualt is still present
	is $stream->content_type('/image.taco'), 'text/x-taco',
		'Parsing XML did not replace what was not specified';

	# Parse in from the string
	lives_ok {$stream->set_from_xml(content => $stream_simple)}
		'->set_from_xml() with existing mappings';

	# Check to be sure default is not back
	is $stream->content_type('/image.png'), 'image/png',
		'Default MIME type from path name is back to image/png';
}

###############################################################################
# EMCA-376 Part 2, 10.1.2.3-4 M2.8, M2.9
# SETTING AND GETTING THE CONTENT TYPE OF A PART
{
	my $ct_simple = File::OPC::ContentTypesStream->new
		->add_from_xml(content => $stream_simple);

	# Add a part name with no extension
	lives_ok {$ct_simple->add_mapping('/test/noextension' => 'text/plain')}
		'Add a part name with no extension';

	# Get the MIME type for the no extension part name
	is $ct_simple->content_type('/test/noextension'), 'text/plain',
		'Get the MIME type for a part name with no extension';

	# Make sure the part name without an extension is an override rule
	isa_ok $ct_simple->applied_element('/test/noextension'),
		'File::OPC::ContentTypesStream::Override', 'No extension is an override element';

	# Add a part name with existing extension and matching MIME type
	lives_ok {$ct_simple->add_mapping('/test/secondimage.png' => 'image/png')}
		'Add a part name with extension in which a default exists';

	# The previous part name should have no override element
	ok !defined $ct_simple->override_element('/test/secondimage.png'),
		'Add a part name with extension in which a default exists makes no override';
}

###############################################################################
# REMOVING A MAPPING
{
	my $stream = File::OPC::ContentTypesStream->new
		->add_from_xml(content => $stream_simple);

	isa_ok $stream->applied_element('/test/image.jpg'),
		'File::OPC::ContentTypesStream::Override', 'image.jpg is an override';

	lives_ok {$stream->remove_mapping('/test/image.jpg')}
		'->remove_mapping($part) for image.jpg';

	ok !defined $stream->applied_element('/test/image.jpg'),
		'Mapping for image.jpg was removed';

	isa_ok $stream->applied_element('/test/image.png'),
		'File::OPC::ContentTypesStream::Default', 'image.png is a default';

	lives_ok {$stream->remove_mapping('/test/image.png')}
		'->remove_mapping($part) for image.png';

	ok defined $stream->applied_element('/test/image.png'),
		'Mapping for image.png still exists since it was a default';

	isa_ok $stream->applied_element('/test/image.wmf'),
		'File::OPC::ContentTypesStream::Default', 'image.wmf is a default';

	lives_ok {$stream->add_mapping('/test/image.wmf' => 'test/plain')}
		'Add mapping for image.wmf, overriding a default';

	isa_ok $stream->applied_element('/test/image.wmf'),
		'File::OPC::ContentTypesStream::Override', 'image.wmf is an override';

	lives_ok {$stream->remove_mapping('/test/image.wmf')}
		'->remove_mapping($part) for image.wmf';

	isa_ok $stream->applied_element('/test/image.wmf'),
		'File::OPC::ContentTypesStream::Default', 'image.wmf is a default again';

	lives_ok {$stream->remove_default_mapping('wmf')}
		'->remove_default_mapping(wmf) lives';

	ok !defined $stream->applied_element('/test/image.wmf'),
		'image.wmf no longer has a mapping';

	lives_ok {$stream->remove_mapping('/test/image.non')}
		'->remove_mapping($part) for non-existant lives';

	# Check return types
	isa_ok $stream->remove_mapping('/test/image.non'),
		'File::OPC::ContentTypesStream', '->remove_mapping() returns $object';
	isa_ok $stream->remove_default_mapping('non'),
		'File::OPC::ContentTypesStream', '->remove_default_mapping() returns $object';
}

###############################################################################
# CHANGING A MAPPING
{
	my $stream = File::OPC::ContentTypesStream->new
		->add_from_xml(content => $stream_simple);

	is $stream->content_type('/test/image.jpg'), 'image/jpeg',
		'Mapping for image.jpg is image/jpeg';

	lives_ok {$stream->set_mapping('/test/image.jpg' => 'image/png')}
		'Changed image.jpg to image/png';

	is $stream->content_type('/test/image.jpg'), 'image/png',
		'Mapping for image.jpg is image/png';

	is $stream->content_type('/test.xml'), 'application/xml',
		'Mapping for test.xml is application/xml';

	isa_ok $stream->applied_element('/test.xml'),
		'File::OPC::ContentTypesStream::Default', 'test.xml is a default element';

	lives_ok {$stream->set_default_mapping('xml' => 'text/xml')}
		'Changed xml to text/xml';

	is $stream->content_type('/test.xml'), 'text/xml',
		'Mapping for test.xml is text/xml';

	# Check return types
	isa_ok $stream->set_mapping('/test/image.jpg' => 'image/png'),
		'File::OPC::ContentTypesStream', '->set_mapping(part => mime) returns $object';
	isa_ok $stream->set_default_mapping('xml' => 'application/xml'),
		'File::OPC::ContentTypesStream', '->set_default_mapping(extension => mime) returns $object';
}

###############################################################################
# SIGNAL END OF TESTS
done_testing;

exit 0;
