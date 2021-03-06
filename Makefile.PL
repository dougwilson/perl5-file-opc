use inc::Module::Install;

name     'File-OPC';
all_from 'lib/File/OPC.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';
license  'perl';

requires 'List::Util'                   => '1.18';
requires 'MIME::Type'                   => '1.24';
requires 'Moose'                        => '0.74';
requires 'Moose::Util::TypeConstraints' => 0;
requires 'MooseX::StrictConstructor'    => '0.08';
requires 'MooseX::Types'                => '0.08';
requires 'Readonly'                     => '1.03';
requires 'Sub::Exporter'                => '0.980';
requires 'Sub::Name'                    => 0;
requires 'URI'                          => '0.07';
requires 'XML::XPath'                   => '1.13';
requires 'namespace::clean'             => '0.04';

test_requires 'File::Spec' => 0;
test_requires 'Test::More' => '0.88';
test_requires 'URI'        => '0.07';

# Enable tests to be in multi-level directories
tests_recursive;

# Author tests in xt/
recursive_author_tests('xt');

WriteAll;
