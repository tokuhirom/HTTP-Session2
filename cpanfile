requires 'perl', '5.008_001';

requires 'Cookie::Baker';
requires 'Digest::HMAC';
requires 'Digest::SHA1';
requires 'Moo';
requires 'parent';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

