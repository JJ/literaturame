#!/usr/bin/env perl

=head1 NAME

get-diffs.pl - Quantify diffs in a software repository

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
use Net::GitHub::V3;
use File::Slurp::Tiny qw(write_file);
use Graph;

my $dir = shift || ".";
my $owner = shift || die "Need an owner";
my $token = shift || die "Need a token";
my ($repo_name)  = ($dir =~ m{/([^/]+)/?$} );
my $repo = Git->repository (Directory => $dir);
my $gh = Net::GitHub::V3->new( access_token => $token );
my $git_search = $gh->search;
my @these_revs = `cd $dir; git rev-list --all`;

my (%author_graph, %files_graph);
my %author_nicks;
for my $commit ( reverse @these_revs ) {
  chop $commit;
  my $commit_info = $repo->command('show', '--pretty=full', $commit);
  my ($author) = ($commit_info =~ /Author:\s+(.+)/);
  my @files = ($commit_info =~ /\+\+\+\s+b\/(.+)/g);
  if ( !$author_nicks{$author} ) {
    my ($name,$email) = ($author =~ /(.+)\s+<([^>]+)>/);
    my $user = $git_search->users( { q => "$email in:email"});
    if ( $user ) {
      $author_nicks{$author} = $user->{'items'}[0]->{'login'};
    } else {
      $user = $git_search->users( { q => $name });
      $author_nicks{$author} = $user;
      if ( !$user ) {
	$author_nicks{$author} = $author;
      }
    }
  }
      
  for my $f (@files ) {
    $author_graph{$author}{$f}++;
    $files_graph{$f}{$author}++;
  }
}

my @authors = keys %author_graph;
my $author_real_graph = Graph::Undirected->new( unionfind => 1,
						vertices => \@authors );
for my $f (keys %files_graph) {
  my @authors = keys %{$files_graph{$f}};
  for ( my $i = 0; $i <= $#authors; $i ++ ) {
    for ( my $j = $i; $j <= $#authors; $j++ ) {
      $author_real_graph->add_edge( $authors[$i], $authors[$j] );
    }
  }
}

say "Graph is $author_real_graph";



#write_file("info_$last_dir_name.csv", join("\n", @data));

