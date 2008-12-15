#!perl -T

use strict;
use warnings 'all';

use File::Spec;
use Test::More;

# Only authors criticize code
plan skip_all => 'set TEST_CRITIC to enable this test'
	unless $ENV{ 'TEST_CRITIC' } || -e 'inc/.author';

eval 'use Test::Perl::Critic';
plan skip_all => 'Test::Perl::Critic required to criticise code'
	if $@;

Test::Perl::Critic->import(
	'-profile' => File::Spec->catfile( 't', '03-perlcriticrc' )
);

all_critic_ok();
