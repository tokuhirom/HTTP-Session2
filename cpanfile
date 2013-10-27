requires 'perl', '5.008_001';

requires 'Cookie::Baker';
requires 'Digest::HMAC';
requires 'Digest::SHA1';
requires 'Mouse';
requires 'parent';
requires 'Digest::SHA';
requires 'MIME::Base64';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'Plack::Response';
};

