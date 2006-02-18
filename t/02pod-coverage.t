#!perl

use Test::More;

unless ( eval 'use Test::Pod::Coverage 1.04; 1' ) {
    plan( skip_all => "Missing Test::Pod::Coverage 1.04" );
    exit;
}

all_pod_coverage_ok();
