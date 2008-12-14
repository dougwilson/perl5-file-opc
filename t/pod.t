#!perl -T

use strict;
use warnings 'all';

use Test::More;

# Ensure a recent version of Test::Pod
my $min_tp = 1.22;
eval sprintf 'use Test::Pod %.2f', $min_tp;
plan skip_all => sprintf 'Test::Pod %.2f required for testing POD', $min_tp
	if $@;

all_pod_files_ok();
