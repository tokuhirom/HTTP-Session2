use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use Cache;
use HTTP::Session2::ServerStore;

my $conf = {
    session_cookie => {
        httponly => 1,
        secure   => 0,
        name     => 'hss_session',
        path     => '/',
    },
};
my $session = HTTP::Session2::ServerStore->new(
    env => {
    },
    secret => 's3cretooooooooooooooooo',
    session_cookie => $conf->{session_cookie},
    get_store => sub { Cache->new() },
);
$session->session_cookie->{expires} = '+1M';
$session->set(x => 3);
my $res = [200, [], []];
$session->finalize_psgi_response($res);
use Data::Dumper; note Dumper($res);
like $res->[1]->[1], qr{\Ahss_session=.*; expires=.*;};
is $conf->{session_cookie}->{expires}, undef, 'Original configuration is not modified';

done_testing;
