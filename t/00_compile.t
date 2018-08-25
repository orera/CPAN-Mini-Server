use strict;

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Test::More;

use_ok $_ for qw(
  CPAN::Mini::Server
);

done_testing;

