#!perl

use 5.010;
use strict;
use warnings;

use Perinci::AccessUtil qw(strip_riap_stuffs_from_res);
use Test::More 0.98;

subtest "strip_riap_stuffs_from_res" => sub {
    is_deeply(strip_riap_stuffs_from_res([200,"OK",undef,{"riap.v"=>1.3}])->[0], 501,
              "unsupported version");

    subtest "v1.1" => sub {
        is_deeply(strip_riap_stuffs_from_res([200,"OK",undef,{"riap.v"=>1.1}]), [200,"OK",undef,{"riap.v"=>1.1}],
                  "pass, riap.* keys not stripped");
        is_deeply(strip_riap_stuffs_from_res([200,"OK",undef,{"riap.v"=>1.1, "riap.foo"=>1}])->[0], 200,
                  "pass, doesn't check riap.* keys");
    };

    subtest "v1.2" => sub {
        is_deeply(strip_riap_stuffs_from_res([200,"OK",undef,{"riap.v"=>1.2, "riap.foo"=>1}])->[0], 501,
                  "unknown riap.* key");
        is_deeply(strip_riap_stuffs_from_res([200,"OK",undef,{"riap.v"=>1.2, "riap.result_encoding"=>"foo"}])->[0], 501,
                  "unknown riap.result_encoding value");
        is_deeply(strip_riap_stuffs_from_res([200,"OK","AAAA",{"riap.v"=>1.2, "riap.result_encoding"=>"base64"}]), [200,"OK","\0\0\0",{}],
                  "base64 decoding of result");
    };
};

done_testing;
