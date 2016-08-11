#!/usr/bin/env perl

use strict;
use warnings;

use v5.20;

use JSON;
use Git;
use File::Slurp::Tiny qw(write_file);

my $status = `travis show`;

my ($num_builds) = ($status =~ /\s+\#(\d+)/);

my %commits;
say "Build Commit";
for my $i (1..$num_builds) {
  my $this_status = `travis show $i`;
  if ( $this_status =~ /Type:\s+push/ &&  $this_status =~ /Branch:\s+master/) {
      my ($state,$commit) = ($this_status =~ /State:\s+(\w+).+\.\.\.(\w+)/s);
      if ( $state ne 'errored' ) {
	  say "$i $commit";
      }
  }
}



