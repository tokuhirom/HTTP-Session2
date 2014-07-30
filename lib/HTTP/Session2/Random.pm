package HTTP::Session2::Random;
use strict;
use warnings;
use utf8;
use 5.010_001;

# DO NOT USE THIS DIRECTLY.

use MIME::Base64 ();
use Digest::SHA ();
use Time::HiRes;

*generate_session_id = -e '/dev/urandom' ? \&generate_session_id_from_urandom : \&generate_session_id_from_perl;

# Generate session id from /dev/urandom.
sub generate_session_id_from_urandom {
    my $length = 24;
    open my $fh, '<:raw', '/dev/urandom'
        or die "Cannot open /dev/urandom: $!";
    my $read = read($fh, my $buf, $length);
    if ($read != $length) {
        die "Cannot read bytes from /dev/urandom: $!";
    }
    my $result = MIME::Base64::encode_base64($buf, '');
    $result =~ tr|+/=|\-_|d; # make it url safe
    close $fh;
    return substr($result, 0, 31);
}

# It's weaker than abover. But it's portable.
sub generate_session_id_from_perl {
    substr(Digest::SHA::sha1_hex(rand() . $$ . {} . Time::HiRes::time()),int(rand(4)),31);
}

1;

