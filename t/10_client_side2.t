use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/lib';
use HTTP::Session2::ClientStore2;

sub scenario {
    subtest(@_);
}
sub step { note $_[0]; goto $_[1] }
sub empty_res { [200, [], []] }

my $cipher = Crypt::CBC->new(
    {
        key              => 'abcdefghijklmnop',
        cipher           => 'Rijndael',
    }
);

scenario 'First request' => sub {
    my $session;
    step 'client -> server: request without cookie' => sub {
        $session = HTTP::Session2::ClientStore2->new(
            env => {
            },
            secret => 's3cret',
            cipher => $cipher,
        );
    };
    step 'server -> client: response without cookie' => sub {
        my $res = empty_res();
        $session->finalize_psgi_response($res);
        is_deeply $res->[1], [];
    };
};

scenario 'Store something without login' => sub {
    my $session;
    step 'client -> server: request without cookie' => sub {
        $session = HTTP::Session2::ClientStore2->new(
            env => {
            },
            secret => 's3cret',
            cipher => $cipher,
        );
    };
    step 'server -> store: save data' => sub {
        $session->set('foo' => 'bar');
    };
    step 'server -> client: response with session/xsrf cookie' => sub {
        my $res = empty_res();
        $session->finalize_psgi_response($res);
        is $res->[1]->[0], 'Set-Cookie';
        my ($session) = ($res->[1]->[1] =~ qr{\Ahss_session=([^;]*); path=/; HttpOnly\z});
        ok $session or diag $res->[1]->[1];
        is $res->[1]->[2], 'Set-Cookie';
        like $res->[1]->[3], qr{\AXSRF-TOKEN=([^;]*); path=/\z};
        my $xsrf_token = $1;

        note $session;
    };
};


scenario 'Login' => sub {
    my $session;
    step 'client -> server: request without cookie' => sub {
        $session = HTTP::Session2::ClientStore2->new(
            env => {
                HTTP_COOKIE => 'hss_session=1406888765%3AW8FOt_W50dUE3y9OmGaIL0WJSl9PrmT%3AU2FsdGVkX1_w6JJjwL0qYxAozvRXWyLpwA-bTDzUYdCxKbG5I_dA7PgPuZyk8j9f9L0Ib0ms4cGXxIniHXLkkQ%3A61306463343264613164393535376437353634356362303563616530633539373565643730393331',
            },
            secret => 's3cret',
            cipher => $cipher,
        );
    };
    step 'server -> server: regenerate_id' => sub {
        $session->regenerate_id();
    };
    step 'server -> store: save data' => sub {
        $session->set('user_id' => '5963');
    };
    step 'server -> client: response with session/xsrf cookie' => sub {
        my $res = empty_res();
        $session->finalize_psgi_response($res);
        is 0+@{$res->[1]}, 4;
        is $res->[1]->[0], 'Set-Cookie';
        my ($sess_id) = ($res->[1]->[1] =~ qr{\Ahss_session=([^;]*); path=/; HttpOnly\z});
        ok $sess_id;
        is $res->[1]->[2], 'Set-Cookie';
        like $res->[1]->[3], qr{\AXSRF-TOKEN=([^;]*); path=/\z};
        my $xsrf_token = $1;

        note $sess_id;
    };
};


scenario 'In a login session' => sub {
    my $session;
    step 'client -> server: request without cookie' => sub {
        $session = HTTP::Session2::ClientStore2->new(
            env => {
                HTTP_COOKIE => 'hss_session=1406888829%3A1Ma0tOlOoMUn0WjIcKdt7ht81h-_1jq%3AU2FsdGVkX18abCO8LNcFZ_Hn2-1O3mKOk79-Yw_L1ZHginGQmrXFEkeL72AGDQwWdWXGQT_0zh01g5oVGfd_UQ%3A61306463343264613164393535376437353634356362303563616530633539373565643730393331',
            },
            secret => 's3cret',
            cipher => $cipher,
        );
    };
    step 'server -> store: set more data' => sub {
        $session->set('foo' => 'bar');
    };
    step 'server -> client: response without session/xsrf cookie' => sub {
        my $res = empty_res();
        $session->finalize_psgi_response($res);
        is 0+@{$res->[1]}, 4;
    };
};

scenario 'Logout' => sub {
    my $session;
    step 'client -> server: request without cookie' => sub {
        $session = HTTP::Session2::ClientStore2->new(
            env => {
                HTTP_COOKIE => 'hss_session=SsEeSsIiOoNn',
            },
            secret => 's3cret',
            cipher => $cipher,
        );
    };
    step 'server -> server: expire' => sub {
        $session->expire();
    };
    step 'server -> client: response with expiration session/xsrf cookie' => sub {
        my $res = empty_res();
        $session->finalize_psgi_response($res);
        is $res->[1]->[0], 'Set-Cookie';
        like $res->[1]->[1], qr{\Ahss_session=; path=/; expires=[^;]+; HttpOnly\z};
        is $res->[1]->[2], 'Set-Cookie';
        like $res->[1]->[3], qr{\AXSRF-TOKEN=; path=/; expires=[^;]*\z};
        my $xsrf_token = $1;
    };
};

done_testing;

