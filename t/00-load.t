#!perl -T

use Test::More tests => 7;

use_ok 'File::OPC';
use_ok 'File::OPC::ContentTypesStream';
use_ok 'File::OPC::ContentTypesStream::Default';
use_ok 'File::OPC::ContentTypesStream::Override';
use_ok 'File::OPC::Library::ContentTypesStream';
use_ok 'File::OPC::Library::Core';
use_ok 'File::OPC::Utils';

diag(sprintf 'Testing File::OPC %s, Perl %s, %s', $File::OPC::VERSION, $], $^X);
