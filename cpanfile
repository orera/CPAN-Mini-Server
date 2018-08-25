requires 'perl', '5.010';

requires 'Mo';
requires 'FindBin';
requires 'Getopt::Long';
requires 'Pod::Usage';

requires 'CPAN::Mini';
requires 'Data::Dumper';
requires 'HTTP::Daemon';
requires 'HTTP::Status';

on 'test' => sub {
  requires 'Test::Most';
};

