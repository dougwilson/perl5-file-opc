use inc::Module::Install;

name     'File-OPC';
all_from 'lib/File/OPC.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';

requires 'MIME::Type' => 1.24;
requires 'Moose' => 0.62;
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::StrictConstructor';
requires 'MooseX::FollowPBP';
requires 'MooseX::Types' => 0.08;
requires 'URI' => 0.07;
requires 'XML::XPath' => 1.13;

test_requires 'File::Spec';
test_requires 'Test::More';
test_requires 'URI' => 0.07;

WriteAll;
