package HTTP::Session2::Base;
use strict;
use warnings;
use utf8;
use 5.008_001;

use Digest::SHA;
use Plack::Util;

use Moo;

has env => (
    is => 'ro',
    required => 1,
);

has session_cookie => (
    is => 'ro',
    required => 1,
    default => sub {
        +{
            httponly => 1,
            secure   => 0,
            name     => 'hss_session',
            path     => '/',
        },
    },
);

has xsrf_cookie => (
    is => 'ro',
    required => 1,
    default => sub {
        # httponly must be false. AngularJS need to read this value.
        +{
            httponly => 0,
            secure   => 0,
            name     => 'XSRF-TOKEN',
            path     => '/',
        },
    },
);

has hmac_function => (
    is => 'ro',
    default => sub { \&Digest::SHA::sha1_hex },
);

has is_dirty => (
    is => 'rw',
    default => sub { 0 },
);

has is_fresh => (
    is => 'rw',
    default => sub { 0 },
);

has necessary_to_send => (
    is => 'rw',
    default => sub { 0 },
);

has xsrf_token => (
    is => 'lazy',
);

has secret => (
    is => 'ro',
    required => 1,
);

no Moo;

sub _data {
    my $self = shift;
    unless ($self->{_data}) {
        $self->load_session();
    }
    $self->{_data};
}

sub id {
    my $self = shift;
    unless ($self->{id}) {
        $self->load_session();
    }
    $self->{id};
}

sub load_session { die "Abstract method" }

sub set {
    my ($self, $key, $value) = @_;
    $self->_data->{$key} = $value;
    $self->is_dirty(1);
}

sub get {
    my ($self, $key) = @_;
    $self->_data->{$key};
}

sub remove {
    my ($self, $key) = @_;
    delete $self->_data->{$key};
    $self->is_dirty(1);
}

sub validate_xsrf_token {
    my ($self, $token) = @_;
    # If user does not have any session data, user don't need a XSRF protection.
    return 1 unless %{$self->_data};
    return 0 unless defined $token;
    return 1 if $token eq $self->xsrf_token;
    return 0;
}

sub finalize_plack_response {
    my ($self, $res) = @_;
    my %cookies = $self->make_cookies();
    while (my ($name, $cookie) = each %cookies) {
        $res->cookies->{$name} = $cookie;
    }
}

sub finalize_psgi_response {
    my ($self, $res) = @_;
    my @cookies = $self->make_cookies();
    while (my ($name, $cookie) = splice @cookies, 0, 2) {
        my $baked = Cookie::Baker::bake_cookie( $name, $cookie );
        Plack::Util::header_push(
            $res->[1],
            'Set-Cookie',
            $baked,
        );
    }
}

sub make_cookies { die "Abstract method" }

1;

