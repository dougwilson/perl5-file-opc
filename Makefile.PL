use inc::Module::Install;

name     'File-OPC';
all_from 'lib/File/OPC.pm';
author   'Douglas Christopher Wilson <doug@somethingdoug.com>';

build_requires 'Test::More';

auto_install;

WriteAll;

