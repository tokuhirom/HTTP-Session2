use strict;
use warnings;
use utf8;
use Test::More 0.96;
use HTTP::Session2::ClientStore;

my $client = HTTP::Session2::ClientStore->new(
    env => {},
    secret => 'secret',
);
is $client->get('foo'), undef;
$client->set('foo', 'bar');
is $client->get('foo'), 'bar';
is $client->remove('foo'), 'bar';

done_testing;

