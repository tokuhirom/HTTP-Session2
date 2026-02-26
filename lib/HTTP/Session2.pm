package HTTP::Session2;
use 5.008005;
use strict;
use warnings;

our $VERSION = "1.11";

1;
__END__

=for stopwords checkbox

=encoding utf-8

=head1 NAME

HTTP::Session2 - HTTP session management

=head1 DEPRECATION NOTICE

This module is B<DEPRECATED> and no longer maintained.
Please do not use this module for new projects.

=head1 SYNOPSIS

    package MyApp;
    use HTTP::Session2;

    sub session {
        my $self = shift;
        if (!exists $self->{session}) {
            $self->{session} = HTTP::Session2::ServerStore->new(
                env => $env,
                secret => 'very long secret string',
                store  => $cache,
            );
        }
        $self->{session};
    }

    __PACKAGE__->add_trigger(
        AFTER_DISPATCH => sub {
            my ($c, $res) = @_;
            if ($c->{session}) {
                $c->{session}->finalize_plack_response($res);
            }
        },
    );

=head1 DESCRIPTION

HTTP::Session2 is yet another HTTP session data management library.

=head1 RELEASE STATE

Alpha. Any API will change without notice.

=head1 MOTIVATION

We need a thrifty session management library.

=head1 What's different from HTTP::Session 1?

=head2 Generate XSRF protection token by session management library

Most of web application needs XSRF protection library.

tokuhirom guess XSRF token is closely related with session management.

=head2 Dropped StickyQuery support

In Japan, old DoCoMo's phone does not support cookie.
Then, we need to support query parameter based session management.

But today, Japanese people are using smart phone :)
We don't have to support legacy phones on new project.


=head1 Automatic XSRF token sending.

This is an example code for filling XSRF token.
This code requires jQuery.

    $(function () {
        "use strict";

        var xsrf_token = getXSRFToken();
        $("form").each(function () {
            var form = $(this);
            var method = form.attr('method');
            if (method === 'get' || method === 'GET') {
                return;
            }

            var input = $(document.createElement('input'));
            input.attr('type',  'hidden');
            input.attr('name',  'XSRF-TOKEN');
            input.attr('value',  xsrf_token);
            form.prepend(input);
        });

        function getXSRFToken() {
            var cookies = document.cookie.split(/\s*;\s*/);
            for (var i=0,l=cookies.length; i<l; i++) {
                var matched = cookies[i].match(/^XSRF-TOKEN=(.*)$/);
                if (matched) {
                    return matched[1];
                }
            }
            return undefined;
        }
    });

=head1 Validate XSRF token in your application

You need to call XSRF validator.

    __PACKAGE__->add_trigger(
        BEFORE_DISPATCH => sub {
            my $c = shift;
            my $req = $c->req;

            if ($req->method ne 'GET' && $req->method ne 'HEAD') {
                my $xsrf_token = $req->header('X-XSRF-TOKEN') || $req->param('xsrf-token');
                unless ($session->validate_xsrf_token($xsrf_token)) {
                    return [
                        403,
                        [],
                        ['XSRF detected'],
                    ];
                }
            }
            return;
        }
    );

=head1 Session Store

This module provides L<HTTP::Session2::ServerStore> for server-side session storage.

=head1 FAQ

=over 4

=item How can I implement "Keep me signed in" checkbox?

You can implement it like following:

    sub dispatch_login {
        my $c = shift;
        if ($c->request->parameters->{'keep_me_signed_in'}) {
            $c->session->session_cookie->{expires} = '+1M';
        }
        $c->session->regenerate_id();
        my $user = User->login($c->request->parameters);
        $c->session->set('user_id' => $user->id);
    }

=back

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=head1 CONTRIBUTORS

magai

=cut

