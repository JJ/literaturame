#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp qw(read_file);
use v5.14;

my $dir = shift || ".";
my @logs = glob("$dir/log*.log");

my @data;
for my $l ( @logs ) {
  my ($number) = ( $l =~ /(\d+)/);
  my $file_content = read_file ($l );
  if ( $file_content =~ /Tests=(\d+)/ ) {
    $data[$number] = $1;
  }
}


say "Words,Delta";
my $old_number_of_words = 0;
for (my $i = 0; $i <=$#data; $i ++ ) {
  if ( $data[$i] ) {
    say "$i, $data[$i], ", $data[$i]- $old_number_of_words;
    $old_number_of_words = $data[$i];
  }
}
  
