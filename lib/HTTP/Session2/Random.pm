package HTTP::Session2::Random;
use strict;
use warnings;
use utf8;
use 5.008_001;

# DO NOT USE THIS DIRECTLY.

use MIME::Base64 ();
use Crypt::SysRandom ();

# RECOMMEND PREREQ: Crypt::SysRandom::XS

sub generate_session_id {
    my $buf = Crypt::SysRandom::random_bytes(24);
    my $result = MIME::Base64::encode_base64($buf, '');
    $result =~ tr|+/=|\-_|d; # make it url safe
    return substr($result, 0, 31);
}

1;
