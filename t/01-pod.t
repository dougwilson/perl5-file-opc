#!perl -T

use strict;
use warnings 'all';

use Test::More;

# Ensure a recent version of Test::Pod
my $min_tp = 1.22;
eval sprintf 'use Test::Pod %.2f', $min_tp;
plan skip_all => sprintf 'Test::Pod %.2f required for testing POD', $min_tp
	if $@;

# Only authors test POD
plan skip_all => 'set TEST_POD to enable this test'
	unless $ENV{ 'TEST_POD' } || -e 'inc/.author';

all_pod_files_ok();
