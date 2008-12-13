#!perl -T

use strict;
use warnings 'all';

use Test::More;

# Ensure a recent version of Test::Pod::Coverage
my $min_tpc = 1.08;
eval sprintf 'use Test::Pod::Coverage %.2f', $min_tpc;
plan skip_all => sprintf 'Test::Pod::Coverage %.2f required for testing POD coverage', $min_tpc
	if $@;

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval sprintf 'use Pod::Coverage %.2f', $min_pc;
plan skip_all => sprintf 'Pod::Coverage %.2f required for testing POD coverage', $min_pc
	if $@;

all_pod_coverage_ok();
