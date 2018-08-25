#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Data::Dumper qw(Dumper);
use Test::Most;

my $example_url       = 'http://example.com/';
my $example_folder    = '/tmp/minicpan';
my $example_interface = '10.0.0.1';
my $example_port      = '1234';

use_ok 'CPAN::Mini::Server';
my $s = new_ok 'CPAN::Mini::Server', [ mirror => $example_url ];

# Attributes
can_ok $s,
  qw(help offline port interface cache_dir mirror cpan_connector httpd);

# Methods
can_ok $s, qw(helpme parse_params main start);

my ( $command, $p ) = $s->parse_params(
  split /\s+/, qq(
  --help
  --offline
  --verbose
  --port      $example_port
  --interface $example_interface
  --cache_dir $example_folder
  --mirror    $example_url
)
);

is $command, 'helpme', 'command is helpme';

{
  # Flags
  ok $p->{help},    'help is true';
  ok $p->{offline}, 'offline is true';
  ok $p->{verbose}, 'verbose is true';

  # Settings
  is $p->{port},      $example_port,      "port is $example_port";
  is $p->{interface}, $example_interface, "interface is $example_interface";
  is $p->{cache_dir}, $example_folder,    "cache_dir is $example_folder";
  is $p->{mirror},    $example_url,       "mirror is $example_url";
}

done_testing;
__END__

