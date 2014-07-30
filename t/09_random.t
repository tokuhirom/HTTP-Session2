use strict;
use warnings;
use Test::More;
use HTTP::Session2::Random;

if (-e '/dev/urandom') {
    diag "/dev/urandom available";
    my $token_urandom1 = HTTP::Session2::Random::generate_session_id_from_urandom();
    my $token_urandom2 = HTTP::Session2::Random::generate_session_id_from_urandom();
    my $token_perl = HTTP::Session2::Random::generate_session_id_from_perl();
    diag "/dev/urandom(1): " . $token_urandom1;
    diag "/dev/urandom(2): " . $token_urandom2;
    diag "perl:            " . $token_perl;
    is length($token_urandom1), length($token_perl);

    isnt $token_urandom1, $token_urandom2;
} else {
    diag "No /dev/urandom";
}

subtest 'perl random test', sub {
    my $token = HTTP::Session2::Random::generate_session_id_from_perl();
    is length($token), 31;
};

done_testing;
