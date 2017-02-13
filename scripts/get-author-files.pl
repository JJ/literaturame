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
use SNA::Network;

my $dir = shift || ".";
my $owner = shift || die "Need an owner";
my $token = shift || die "Need a token";
my ($repo_name)  = ($dir =~ m{/([^/]+)/?$} );
my $repo = Git->repository (Directory => $dir);
my $gh = Net::GitHub::V3->new( access_token => $token );
my $git_search = $gh->search;
my @these_revs = `cd $dir; git rev-list --all`;

my (%author_graph, %files_graph,  %nick_for);
my $commit_net = SNA::Network->new();
my %commit_nodes;
for my $commit ( reverse @these_revs ) {
  chop $commit;
  my $commit_info = $repo->command('show', '--pretty=full', $commit);
  my ($author) = ($commit_info =~ /Author:\s+(.+)/);
  my @files = ($commit_info =~ /\+\+\+\s+b\/(.+)/g);
  if ( !$nick_for{$author} ) {
    my ($name,$email) = ($author =~ /(.+)\s+<([^>]+)>/);
    my $user = $git_search->users( { q => "$email in:email"});
    say "Sleeping after $email...";
    sleep 1; # To avoid hitting rate limit
    if ( $user->{'items'}[0]->{'login'} ) {
      $nick_for{$author} = $user->{'items'}[0]->{'login'};
    } else {
	$user = $git_search->users( { q => $name });
	say "Sleeping after $name...";
	sleep 1; # To avoid hitting rate limit
      if ( $user->{'items'}[0]->{'login'} ) {
	$nick_for{$author} = $user->{'items'}[0]->{'login'};
      } else  {
	$nick_for{$author} = $author;
      }
    }
  }
      
  for (my $i = 0; $i <= $#files; $i++ ) {
    my $f = $files[$i];
    if ( !$commit_nodes{$f} ) {
      my $this_node = $commit_net->create_node( name => $f );
      $commit_nodes{$f} = $this_node;
    }
    $author_graph{$nick_for{$author}}{$f}++;
    $files_graph{$f}{$nick_for{$author}}++;
    if ( $i < $#files ) {
      for ( my $j = $i+1; $j<=$#files; $j++ ) {
	if ( !$commit_nodes{$files[$j]} ) {
	  my $this_node = $commit_net->create_node( name => $files[$j] );
	  $commit_nodes{$files[$j]} = $this_node;
	}
	$commit_net->create_edge( source_index => $commit_nodes{$f}->{'index'},
				  target_index => $commit_nodes{$files[$j]}->{'index'});
      }
    }
  }
}

my @authors = keys %author_graph;
my %author_nodes;
my $author_net = SNA::Network->new();
for my $a (@authors) {
  my $this_node = $author_net->create_node( name => $a );
  $author_nodes{$a} = $this_node;
}

my %file_nodes;
my $file_net = SNA::Network->new();
for my $f (keys %files_graph) {
  my $this_node = $file_net->create_node( name => $f );
  $file_nodes{$f} = $this_node;
}


# Author graph
for my $f (keys %files_graph) {
  my @authors = keys %{$files_graph{$f}};
  if ( $#authors > 0 ) {
    for ( my $i = 0; $i < $#authors; $i ++ ) {
      for ( my $j = $i+1; $j <= $#authors; $j++ ) {
	$author_net->create_edge( source_index => $author_nodes{$authors[$i]}->{'index'},
				  target_index => $author_nodes{$authors[$j]}->{'index'} );
      }
    }
  }
}

$author_net->calculate_authorities_and_hubs();
$author_net->calculate_betweenness;
$author_net->save_to_pajek_net("author-$repo_name.net");
$author_net->save_to_gdf(filename => "author-$repo_name.gdf", node_fields => ['betweenness','authority','hub']);


for my $a (keys %author_graph) {
  my @files = keys %{$author_graph{$a}};
  if ( $#files > 0 ) {
    for ( my $i = 0; $i < $#files; $i ++ ) {
      for ( my $j = $i+1; $j <= $#files; $j++ ) {
	$file_net->create_edge( source_index => $file_nodes{$files[$i]}->{'index'},
				target_index => $file_nodes{$files[$j]}->{'index'} );
      }
    }
  }
}

$file_net->calculate_authorities_and_hubs();
$file_net->calculate_betweenness;
$file_net->save_to_pajek_net("files-$repo_name.net");
$file_net->save_to_gdf(filename => "files-$repo_name.gdf",  node_fields => ['betweenness','authority','hub'] );

$commit_net->calculate_authorities_and_hubs();
$commit_net->calculate_betweenness;
$commit_net->save_to_pajek_net("commit-$repo_name.net");
$commit_net->save_to_gdf(filename => "commit-$repo_name.gdf",  node_fields => ['betweenness','authority','hub'] );

