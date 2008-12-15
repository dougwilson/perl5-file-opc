#!perl -T

use strict;
use warnings 'all';

use Test::More;

# Ensure a recent version of Test::Pod::Coverage
my $min_tpc = 1.08;
eval sprintf 'use Test::Pod::Coverage %.2f', $min_tpc;
plan skip_all => sprintf 'Test::Pod::Coverage %.2f required for testing POD coverage', $min_tpc
	if $@;

# Only authors test POD coverage
plan skip_all => 'set TEST_POD to enable this test'
	unless $ENV{ 'TEST_POD' } || -e 'inc/.author';

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval sprintf 'use Pod::Coverage %.2f', $min_pc;
plan skip_all => sprintf 'Pod::Coverage %.2f required for testing POD coverage', $min_pc
	if $@;

# Test the POD. BUILD is private in Moose
all_pod_coverage_ok({
	'also_private' => [qw{ BUILD }]
});
