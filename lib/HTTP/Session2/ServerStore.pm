package HTTP::Session2::ServerStore;
use strict;
use warnings;
use utf8;
use 5.008_001;

our $VERSION = "0.01";

use parent qw(HTTP::Session2::Base);

use Carp ();
use Digest::HMAC;
use Digest::SHA ();
use Cookie::Baker ();

use Moo;

has store => (
    is => 'ro',
    default => sub { $_[0]->get_store->() },
);

has get_store => (
    is => 'ro',
    required => 1,
);

no Moo;

sub load_session {
    my $self = shift;

    # Load from cookie.
    my $cookies = Cookie::Baker::crush_cookie($self->env->{HTTP_COOKIE});
    if (my $session_id = $cookies->{$self->session_cookie->{name}}) {
        my $data = $self->store->get($session_id);
        if (defined $data) {
            $self->{id}   = $session_id;
            $self->{_data} = $data;
            return;
        }
    }

    $self->_new_session();
}

sub _new_session {
    my $self = shift;

    $self->{id}   = $self->_generate_session_id();
    $self->{_data} = +{};
    $self->is_fresh(1);
}

sub _generate_session_id {
    substr(Digest::SHA::sha1_hex(rand() . $$ . {} . time),int(rand(4)),31);
}

sub regenerate_id {
    my ($self) = @_;

    # Load original session first.
    $self->load_session();

    # Remove original session from storage.
    my $cookies = Cookie::Baker::crush_cookie($self->env->{HTTP_COOKIE});
    if (my $session_id = $cookies->{$self->session_cookie->{name}}) {
        $self->store->remove($session_id);
    }

    # Create new session.
    $self->{id} = $self->_generate_session_id();
    $self->necessary_to_send(1);
    $self->is_dirty(1);
}

sub expire {
    my $self = shift;

    # Load original session first.
    $self->load_session();

    # Remove original session from storage.
    my $cookies = Cookie::Baker::crush_cookie($self->env->{HTTP_COOKIE});
    if (my $session_id = $cookies->{$self->session_cookie->{name}}) {
        $self->store->remove($session_id);
    }

    # Rebless to expired object.
    bless $self, 'HTTP::Session2::ServerStore::Expired';

    return;
}

sub _build_xsrf_token {
    my $self = shift;
    Digest::HMAC::hmac_hex($self->id, $self->secret, $self->hmac_function);
}

sub make_cookies {
    my ($self, $res) = @_;

    # Store data
    if ($self->is_dirty) {
        $self->store->set($self->id, $self->_data);

        if ($self->is_fresh) {
            $self->necessary_to_send(1);
        }
    }

    unless ($self->necessary_to_send) {
        return ();
    }

    my @cookies;

    # Finalize session cookie
    {
        my %cookie = %{$self->session_cookie};
        my $name = delete $cookie{name};
        push @cookies, $name => +{
            %cookie,
            value => $self->id,
        };
    }

    # Finalize XSRF cookie
    {
        my %cookie = %{$self->xsrf_cookie};
        my $name = delete $cookie{name};
        push @cookies, $name => +{
            %cookie,
            value => $self->xsrf_token,
        };
    }

    return @cookies;
}

package HTTP::Session2::ServerStore::Expired;
use parent qw(HTTP::Session2::Base);

sub set    { Carp::croak("You cannot set anything to expired session") }
sub get    { Carp::croak("You cannot get anything from expired session") }
sub remove { Carp::croak("You cannot remove anything from expired session") }

sub make_cookies {
    my ($self, $res) = @_;

    my @cookies;

    # Finalize session cookie
    {
        my %cookie = %{$self->session_cookie};
        my $name = delete $cookie{name};
        push @cookies, $name => +{
            %cookie,
            value => '',
            expires => '-1d',
        };
    }

    # Finalize XSRF cookie
    {
        my %cookie = %{$self->xsrf_cookie};
        my $name = delete $cookie{name};
        push @cookies, $name => +{
            %cookie,
            value => '',
            expires => '-1d',
        };
    }

    return @cookies;
}

1;

