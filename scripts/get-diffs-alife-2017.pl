#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

my @repos = qw( /processone/ejabberd /tensorflow/tensorflow /mojolicious/mojo/
                /piotrmurach/tty /cask/cask /webpack/webpack
                /perl6/atom-language-perl6 /EpistasisLab/tpot 
                /scalatra/scalatra /moose/Moose /django/django
                /docker/docker /fission/fission /vuejs/vue
                /PerlDancer/Dancer2 /rakudo/rakudo );

my @extensions =  ('erl hrl yrl escript ex exs','py cc h',
                   'pl pm PL','rb','el py','js','coffee p6',
                   'py','scala','pl pm xs t','py','go',
                   'go py js','js','pl pm t','pm pm6 pl pl6 nqp');

my @depths = (3,2,2,2,5,2,4,5,2,2,8,2,4,2,2,4);

for ( my $i = 0; $i < 16; $i++ ) {
  my ($dir) = $repos[$i] =~ m{/(\w+)$};
  say "Analyzing $extensions[$i] $dir $depths[$i]";
  `~/Code/literaturame/scripts/get-diffs-by-extension.pl "$extensions[$i]" $dir $depths[$i]`;
}
