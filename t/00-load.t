#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'File::OPC' );
}

diag( "Testing File::OPC $File::OPC::VERSION, Perl $], $^X" );
