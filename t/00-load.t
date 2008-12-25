#!perl -T

use Test::More tests => 3;

BEGIN
{
	use_ok 'File::OPC';
	use_ok 'File::OPC::ContentTypesStream';
	use_ok 'File::OPC::Library::ContentTypesStream';
}

#diag( sprintf 'Testing File::OPC %.2f, Perl %s, %s', $File::OPC::VERSION, $], $^X );
