package HTTP::Session2::CookieStore;
use strict;
use warnings;
use utf8;
use 5.008_001;

use parent qw(HTTP::Session2::Base);

use Cookie::Baker ();

use Moo;

has serializer => (
    is => 'ro',
    default => sub {
        sub {
            MIME::Base64::encode(Storable::nfreeze($_[0]), '' )
        }
    },
);

has deserializer => (
    is => 'ro',
    default => sub {
        sub {Storable::thaw(MIME::Base64::decode($_[0]))}
    },
);

has ignore_old => (
    is => 'ro',
);

no Moo;

sub load_session {
    my $self = shift;

    # Load from cookie.
    my $cookies = Cookie::Baker::crush_cookie($self->env->{HTTP_COOKIE});
    my $session_cookie = $cookies->{$self->session_cookie->{name}};
    if ($session_cookie) {
        my ($time, $id, $serialized, $sig) = split /:/, $session_cookie->{value}, 4;
        _compare($self->sig($serialized), $sig) or return;

        if (defined $self->ignore_old) {
            if ($time < $self->ignore_old()) {
                $self->_new_session();
                return;
            }
        }

        my $data = $self->deserializer->($serialized);
        $self->{id}    = $id;
        $self->{_data} = $data;
        return;
    }

    $self->_new_session();
}

sub _new_session {
    my $self = shift;

    $self->{id}    = $self->_generate_session_id();
    $self->{_data} = +{};
}

sub _generate_session_id {
    substr(Digest::SHA::sha1_hex(rand() . $$ . {} . time),int(rand(4)),31);
}

sub regenerate_id {
    my ($self) = @_;

    # Create new session.
    $self->_new_session();
    $self->necessary_to_send(1);
}

sub _build_xsrf_token {
    my $self = shift;
    Digest::HMAC::hmac_hex($self->id, $self->secret, $self->hmac_function);
}

sub make_cookies {
    my ($self) = @_;

    return unless $self->necessary_to_send || $self->is_dirty;

    my %cookies;

    # Finalize session cookie
    {
        my %cookie = %{$self->session_cookie};
        my $name = delete $cookie{name};
        my $value = $self->_serialize($self->data);
        $cookies{$name} = +{
            %cookie,
            value => $value,
        };
    }

    # Finalize XSRF cookie
    {
        my %cookie = %{$self->xsrf_cookie};
        my $name = delete $cookie{name};
        $cookies{$name} = +{
            %cookie,
            value => $self->xsrf_token,
        };
    }

    return %cookies;
}

sub _serialize {
    my ($self, $id, $data) = @_;

    my $serialized = $self->serializer->($data);
    join ":", time(), $id, $serialized, $self->sig($serialized);
}

1;
__END__

=head1 NAME

=head1 DESCRIPTION

This is a part of L<HTTP::Session2> library.

This module stores the data to the cookie value.

