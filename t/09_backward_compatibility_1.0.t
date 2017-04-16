use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use Cache;
use HTTP::Session2::ServerStore;

my $session = HTTP::Session2::ServerStore->new(
    env => {},
    get_store => sub { },
    secret => 's3cret',
);
$session->set('yappo' => 1);

isnt $session->xsrf_token, $session->xsrf_token_00x;
ok $session->validate_xsrf_token($session->xsrf_token);
ok $session->validate_xsrf_token($session->xsrf_token_00x);

done_testing;
