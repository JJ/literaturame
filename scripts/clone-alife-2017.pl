#!/usr/bin/env perl

use strict;
use warnings;
use v5.14; # for say

my @repos = qw( /processone/ejabberd /tensorflow/tensorflow /mojolicious/mojo/
                /piotrmurach/tty /cask/cask /webpack/webpack
                /perl6/atom-language-perl6 /EpistasisLab/tpot 
                /scalatra/scalatra /moose/Moose /django/django
                /docker/docker /fission/fission /vuejs/vue
                /PerlDancer/Dancer2 /rakudo/rakudo );

for my $r (@repos) {
  `git clone https://github.com/$r`;
}
