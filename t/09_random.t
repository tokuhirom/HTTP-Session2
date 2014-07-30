use strict;
use warnings;
use Test::More;
use HTTP::Session2::Random;

if (-e '/dev/urandom') {
    diag "/dev/urandom available";
    my $token_urandom = HTTP::Session2::Random::generate_session_id_from_urandom();
    my $token_perl = HTTP::Session2::Random::generate_session_id_from_perl();
    diag "/dev/urandom: " . $token_urandom;
    diag "perl: " . $token_perl;
    is length($token_urandom), length($token_perl);
} else {
    diag "No /dev/urandom";
}

subtest 'perl random test', sub {
    my $token = HTTP::Session2::Random::generate_session_id_from_perl();
    is length($token), 31;
};

done_testing;
