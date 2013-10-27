package HTTP::Session2::Expired;
use strict;
use warnings;
use utf8;
use 5.008_001;
use Carp ();
use parent qw(HTTP::Session2::Base);

sub set    { Carp::croak("You cannot set anything to expired session") }
sub get    { Carp::croak("You cannot get anything from expired session") }
sub remove { Carp::croak("You cannot remove anything from expired session") }

1;

