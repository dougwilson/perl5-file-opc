#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok( 'File::OPC' );
}

diag( sprintf 'Testing File::OPC %.2f, Perl %s, %s', $File::OPC::VERSION, $], $^X );
