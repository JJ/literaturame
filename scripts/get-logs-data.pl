#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(read_file);
use v5.14;

my $dir = shift || ".";
my @logs = glob("$dir/log*.log");

my @tests;
for my $l ( @logs ) {
  my ($number) = ( $l =~ /(\d+)/);
  my $file_content = read_file ($l );
  if ( $file_content =~ /Tests=(\d+)/ ) {
    $tests[$number] = $1;
  }
}


say "Tests";
for (my $i = 0; $i <=$#tests; $i ++ ) {
  if ( $tests[$i] ) {
    say $tests[$i];
  }
}
  
