
# NAME

HTTP::Session2 - It's new $module

# SYNOPSIS

    package MyApp;
    use HTTP::Session2;

    sub session {
        my $self = shift;
        if (!exists $self->{session}) {
            $self->{session} = HTTP::Session2::CookieStore->new(env => $env);
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

# DESCRIPTION

HTTP::Session2 is ...

# Automatic XSRF token sending.

This is an example code for filling XSRF token.
(Not tested yet)

    $(function () {
        var xsrf_token = getXSRFToken();
        $('form').each(function () {
            var method = $(this).attr('method');
            if (method == 'get' || method == 'GET') {
                return;
            }

            var input = $(document.createElement('input'));
            $(input).attr('type', 'hidden');
            $(input).attr('name', 'XSRF-TOKEN');
            $(input).attr('value', xsrf_token);
            $(this).append(input);
        });

        function getXSRFToken() {
            var cookies = document.cookie.split(/\s*;\s*/);
            for (var i=0,l=cookies.length; i<l; i++) {
                var matched = cookies[i].match(/^XSRF-TOKEN=(.*)$/);
                if (matched) {
                    returm matched[1];
                }
            }
            return undefined;
        }
    });

# Validate XSRF token in your application

You need to call XSRF validator.

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

# What's different from HTTP::Session 1?

## Generate XSRF protection token by session management library

Most of web application needs XSRF protection library.

tokuhirom guess XSRF token is closely related with session management.

## Dropped StickyQuery support

In Japan, old DoCoMo's phone does not support cookie.
Then, we need to support query parameter based session management.

But today, Japanese people are using smart phone :)
We don't have to support legacy phones on new project.

# pros/cons for ServerStore/CookieStore

## ServerStore pros

### pros

- It was used well.
- User can't see anything.
- You can store large data in session.

### cons

- Setup is hard.

    You need to setup some configuration for your application.

## CookieStore

### pros

- You don't need to store anything on your server

    It makes easy to setup your server environment.

- Less server side disk

    It helps your wallet.

### cons

- Security

    I hope this module is secure. Because the data was signed by HMAC. But security thing is hard.

- Session data is readable by users

    You can't store the any secret data to the session. Because this library signed to the data, but not encrypted.

- Bandwidth

    If you store the large data to the session, your session data is send to the server per every request.
    It may hits band-width issue. If you are writing high traffic web site, you should use server side store.

- Capacity

    Cookies are usually limited to 4096 bytes. You can't store large data to the session.
    You should care the cookie size, or checking cookie size by the Plack::Middleware layer.

    Ref. [RFC2965](http://tools.ietf.org/html/rfc2965)

# LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

tokuhirom <tokuhirom@gmail.com>
