#!/usr/bin/env perl

use strict;
use warnings;

use v5.20;

use JSON;
use Git;
use File::Slurp::Tiny qw(write_file);

my $filespec = shift || die "Usage: $0 <ficheros> [git directory]\n";
my $dir = shift || ".";

my $repo = Git->repository (Directory => $dir);
my @filespec = split(/ /,$filespec);

my @revs = $repo->command('rev-list', '--all', '--', @filespec);
my @data = ("Lines changed");

my $prev_commit = pop @revs; #Throwaway first commit
$prev_commit = pop @revs;
for my $commit ( reverse @revs ) {
  my $file_contents = $repo->command('diff','--shortstat',  "$commit..$prev_commit", "--", @filespec );
  my ($insertions) = ($file_contents =~ /(\d+)\s+insertion\S+/s);
  my ($deletions) = ($file_contents =~ /(\d+)\s+deletion\S+/s);
  $insertions = $insertions || 0;
  $deletions = $deletions || 0;

  my $lines_changed = ($insertions > $deletions)?$insertions:$deletions;
  push @data, $lines_changed;
  $prev_commit = $commit;
}

my ($last_dir_name)  = ($dir =~ m{/([^/]+)/?$} );
my $flat_file_name = $filespec;

$flat_file_name =~ s/\*/ALL/g;
$flat_file_name =~ s/\./_/g;
$flat_file_name =~ s/\//_/g;
$flat_file_name =~ s/ /_/g;

write_file("lines_$last_dir_name"."_$flat_file_name.csv", join("\n", @data));

