package HTTP::Session2::ClientStore;
use strict;
use warnings;
use utf8;
use 5.008_001;

use Storable ();
use Carp ();

use Mouse;

extends 'HTTP::Session2::ClientStore2';

# Backward compatibility.

has '+serializer' => (
    is => 'ro',
    default => sub {
        sub {
            Carp::cluck("Do not use HTTP::Session2::ClientStore. Use HTTP::Session2::ServerStore or HTTP::Session2::ClientStore2 instead.");
            MIME::Base64::encode(Storable::nfreeze($_[0]), '' )
        }
    },
);

has '+deserializer' => (
    default => sub {
        sub {
            Carp::cluck("Do not use HTTP::Session2::ClientStore. Use HTTP::Session2::ServerStore or HTTP::Session2::ClientStore2 instead.");
            Storable::thaw(MIME::Base64::decode($_[0]))
        }
    },
);

no Mouse;

1;
__END__

=head1 NAME

HTTP::Session2::ClientStore - (Deprecated)Client store

=head1 DESCRIPTION

Use L<HTTP::Session2::ClientStore2> instead.

