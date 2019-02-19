#!/usr/bin/env perl

=head1 NAME

get-diffs-by-extension.pl - Quantify diffs in a software repository by extensions

=head1 SYNOPSIS

First, install needed modules

    cpanm install Git File::Slurp::Tiny

Then run it. If there is a git repo in C</home/thatsme/repo>

    ./get-diff-by-extension.pl "pl pm" /home/thatsme/repo

The quotes are important so that it is not expanded by bash.

=head1 SEE ALSO

Check out L<http://github.com/JJ/literaturame>, for some results, generated reports, R files for analyzing them, and so on. I would be grateful if you added your results to the L<https://github.com/JJ/literaturame/blob/master/data.md> file via pull request.
=cut

use strict;
use warnings;

use v5.20;

use Git;
use File::Slurp::Tiny qw(write_file);

my $extensions = shift || die "Usage: $0 <extensions> [depth (defaults to 1, that is, */*.ext)] [git directory (defaults to .)]\n";
my $dir = shift || ".";
my $min_depth = shift || 1;

my $repo = Git->repository (Directory => $dir);

my @filespec;
my @extensions = split(/\s+/,$extensions);
for my $j (@extensions ) {
    push @filespec, "*.$j"
}

my @revs;
my $revs = "cd $dir; git rev-list --all -- ".join(" ",@filespec);
my @these_revs = `$revs`;
my $depth = 1;
do {
  @revs = @these_revs;
  my $glob = "*/"x$depth;
  for my $j ( @extensions ) {
    push @filespec, "$glob*.$j"
  }
  $revs = "cd $dir; git rev-list --all -- ".join(" ",@filespec);
  say "Testing ", join(" ", @filespec );
  @these_revs = `$revs`;
  $depth++;
  say "Found $#these_revs";
} until $#these_revs == $#revs and $depth > $min_depth ;


my @data = ("Lines changed");

chop @revs;
my $prev_commit = pop @revs; #Throwaway first commit
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
my $flat_file_name = "$depth-$extensions";

write_file("lines_$last_dir_name"."_$flat_file_name.csv", join("\n", @data));

