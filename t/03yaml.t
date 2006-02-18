#!perl

use Test::More;

unless ( eval 'use YAML qw( LoadFile ); 1' ) {
    plan( skip_all => "Missing YAML" );
    exit;
}

plan( tests => 1 );
ok( LoadFile("META.yml") );
