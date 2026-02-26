use strict;
use warnings;
use Test::More;
use HTTP::Session2::Random;

my $token1 = HTTP::Session2::Random::generate_session_id();
my $token2 = HTTP::Session2::Random::generate_session_id();
diag "token1: " . $token1;
diag "token2: " . $token2;
is length($token1), 31;
is length($token2), 31;
isnt $token1, $token2;

done_testing;
