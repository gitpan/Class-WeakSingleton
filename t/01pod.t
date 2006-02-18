#!perl

use Test::More;

unless ( eval 'use Test::Pod 1.14; 1' ) {
    plan( skip_all => "Missing Test::Pod 1.14" );
    exit;
}

all_pod_files_ok();
