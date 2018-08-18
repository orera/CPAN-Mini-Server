#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use CPAN::Mini::Server;

exit CPAN::Mini::Server->main(@ARGV) unless caller 0;

__END__
