use inc::Module::Install;

name     'File-OPC';
all_from 'lib/File/OPC.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';

requires 'Carp';
requires 'MIME::Type' => 1.24;
requires 'Moose' => 0.62;
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::Types' => 0.08;
requires 'URI';
requires 'XML::XPath' => 1.13;

test_requires 'File::Spec';
test_requires 'Test::More';

WriteAll;
