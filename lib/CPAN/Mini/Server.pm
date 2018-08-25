package CPAN::Mini::Server;

# ABSTRACT Host a local CPAN mirror for I<DEVELOPMENT USE ONLY>

use 5.010;
use strict;
use warnings;

our $VERSION = "0.02";

use Carp qw();
use Mo qw(default builder is required);
use Getopt::Long qw(GetOptionsFromArray);
use Pod::Usage qw();

local $SIG{__WARN__} = sub { die @_ };
local $SIG{__DIE__}  = sub { Carp::confess @_ };

has 'help'      => ( is => 'ro', default  => undef );
has 'offline'   => ( is => 'ro', default  => undef );
has 'verbose'   => ( is => 'ro', default  => undef );
has 'port'      => ( is => 'ro', default  => 9999 );
has 'interface' => ( is => 'ro', default  => 'localhost' );
has 'cache_dir' => ( is => 'ro', default  => 'minicpan' );
has 'mirror'    => ( is => 'ro', required => 1 );
has '_run'      => ( is => 'rw', default  => 1 );

has 'cpan_connector' => ( builder => '_build_cpan_connector' );

sub _build_cpan_connector {
  my ($self) = @_;

  use CPAN::Mini qw();
  return CPAN::Mini->new(
    remote    => $self->mirror,
    local     => $self->cache_dir,
    log_level => 'debug',
  );
}

# Make it so the http server can be replaced easily
has 'httpd' => ( default => sub { \&_default_httpd_server } );

sub parse_params {
  my ( $self, @tokens ) = @_;

  my %params;
  GetOptionsFromArray(
    \@tokens,    \%params,   'help|?',        'offline|o',
    'verbose|v', 'port|p=i', 'interface|i=s', 'cache_dir|d=s',
    'mirror|m=s'
  );

  my $command = $params{help} ? 'helpme' : shift @tokens // 'start';

  die "command not recognized: $command"
    unless $command =~ m/^(?:start|helpme)$/;

  return $command, \%params;
}

sub helpme {
  my ($self) = @_;

  Pod::Usage::pod2usage(
    exitval  => 'NOEXIT',
    verbose  => $self->verbose ? 2 : 1,
    sections => "NAME|SYNOPSIS|DESCRIPTION",
    input    => __FILE__
  );

  return '0 but true';
}

sub main {
  my ( $class,   @params ) = @_;
  my ( $command, $params ) = $class->parse_params(@params);
  exit $class->new( %{$params} )->$command;
}

sub start {
  my ($self) = @_;

  $self->cpan_connector->update_mirror
    unless $self->offline;

  return $self->httpd->($self);
}

sub _default_httpd_server {
  my ($self) = @_;

  local $SIG{INT} = local $SIG{HUP} = sub { $self->_run(0) };

  use HTTP::Daemon qw();
  use HTTP::Status qw(RC_FORBIDDEN);

  my $d = HTTP::Daemon->new(
    LocalHost => $self->interface,
    LocalPort => $self->port
  );

  die sprintf "Failed to bind daemon to host: %s on port %s",
    $self->interface, $self->port
    unless $d;

  say sprintf 'Service available at %s', $d->url;

  while ( my $c = $d->accept ) {
    while ( my $r = $c->get_request ) {
      print sprintf 'processing request for %s', $r->url->as_string;

      my $path = $self->cache_dir . $r->url->as_string;

      die "illegal path: $path, '..' possible dangerous path"
        if $path =~ m/\.\./;

      if ( -e $path and -f $path and -r $path ) {
        say $c->send_file_response($path) ? ' ... OK' : ' ... FAILED';
      }
      else {
        $c->send_error(RC_FORBIDDEN);
      }

      last unless $self->_run;
    }

    $c->close;
    undef $c;

    last unless $self->_run;
  }

  say 'exiting';
  return '0 but true';
}

1;

__END__

=encoding utf-8

=pod

=head1 NAME

CPAN::Mini::Server or minicpanserver.pl - Host a local CPAN mirror for I<DEVELOPMENT USE ONLY>

=head1 SYNOPSIS

cpanminiserver.pl [start|helpme] [OPTIONS]

Options:

  --mirror    [-m] <url>         * Mandatory *
  --cache_dir [-d] <path>        # Default: ./minicpan
  --interface [-i] <hostname|ip> # Default: localhost
  --port      [-p] <portnumber>  # Default: 9999
  --offline   [-o]               # Do not update local cache
  --help      [-?]               # Show this helptext
  --verbose   [-v]               # Show more extensive help text

=head2 STEP-BY-STEP

Find mirror to sync with, probably want to go here if you do not know about any:

L<http://mirrors.cpan.org>

Relying on default to bind to localhost:

cpanminiserver.pl -m http://example.com

Thats it it! This should sync data from the mirror to F<./minicpan>
and bind the server to L<http://localhost:9999>

If you want to bind to all interfaces or a spesific one use the --interface or -i option:

cpanminiserver.pl -m http://example.com -i ''

To use the local server when installing with cpanm:

cpanm -m http://localhost:9999 Some::Module

=head1 DESCRIPTION

Host your own I<complete> CPAN repo locally and serve it locally via http for I<DEVELOPMENT PURPOSES ONLY>.

Download the full repo (many gigabytes of data) from a chosen mirror
and start a single process, single threaded non-forking webserver

=head2 USE CASES

=over 2

=item Host your own I<full> cpan repo locally to make it available when offline.

=item Host your own repo to be a good citizen when using it heavily.

=item Run I<cpanm> commands while building a docker image and not copying the
repo directory.

=back

When running the app first we will sync the mirror to the cache directory, then
the built-in server will bind to the provided interface:port.

The first sync will take a long time as all the modules will have to be downloaded,
on the secondary run and beyond the sync process will be much faster as we only update
outdated modules.

See the CPAN::Mini module for more information

=head1 DISCLAIMER

This software is for development use only, do not not expose this to anything other than
your local machine or your very small local network which you fully control.

No effort has gone into making this secure, reliable or performant.

I made this to make CPAN available via HTTP on my development machine while offline.

=head1 LICENSE

Copyright (C) Tore Andersson.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tore Andersson E<lt>tore.andersson@gmail.comE<gt>

=cut

