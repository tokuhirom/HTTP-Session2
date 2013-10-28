use strict;
use warnings;
use utf8;
use Test::More 0.96;
use HTTP::Session2::ClientStore;

subtest 'get/set/remove' => sub {
    my $client = HTTP::Session2::ClientStore->new(
        env => {},
        secret => 'secret',
    );
    is $client->get('foo'), undef;
    $client->set('foo', 'bar');
    is $client->get('foo'), 'bar';
    is $client->remove('foo'), 'bar';
};

subtest 'ignore_old' => sub {
    my $t1 = time();
    my $session_data = do {
        my $client = HTTP::Session2::ClientStore->new(
            env => {},
            secret => 'secret',
        );
        $client->set(x => 3);
        my $res = [200,[],[]];
        $client->finalize_psgi_response($res);
        $res->[1]->[1] =~ /hss_session=([^;]+)/;
        $1;
    };
    subtest 'ignore_old disabled' => sub {
        my $client = HTTP::Session2::ClientStore->new(
            env => {
                HTTP_COOKIE => "hss_session=${session_data}",
            },
            secret => 'secret',
            ignore_old => $t1-86400,
        );
        is $client->get('x'), 3;
    };
    subtest 'ignore_old enabled' => sub {
        my $client = HTTP::Session2::ClientStore->new(
            env => {
                HTTP_COOKIE => "hss_session=${session_data}",
            },
            secret => 'secret',
            ignore_old => $t1+86400,
        );
        is $client->get('x'), undef;
    };
};

done_testing;

