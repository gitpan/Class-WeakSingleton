#!perl

use Test::More;

unless ( eval 'use Test::Signature; 1' ) {
    plan( skip_all => "Missing Test::Signature" );
    exit;
}

plan( tests => 1 );
signature_ok();
