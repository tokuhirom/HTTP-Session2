use strict;
use warnings;
use lib 't/lib';
use Cache;
use HTTP::Session2::ServerStore;
use Test::More;

{
    my $warn = '';
    local $SIG{__WARN__} = sub {
        $warn .= "@_";
    };
    my $session = HTTP::Session2::ServerStore->new(
        env => {
        },
        secret => 's3cret',
        get_store => sub { Cache->new() },
    );
    like $warn, qr/Secret string too short/;
}
{
    my $warn = '';
    local $SIG{__WARN__} = sub {
        $warn .= "@_";
    };
    my $session = HTTP::Session2::ServerStore->new(
        env => {
        },
        secret => 's3cretooooooooooooooooo',
        get_store => sub { Cache->new() },
    );
    unlike $warn, qr/Secret string too short/;
}

done_testing;
