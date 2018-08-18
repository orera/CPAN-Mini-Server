# NAME

CPAN::Mini::Server - Simple http server for hosting local cpan mirror

# SYNOPSIS

Usage: cpanminiserver.pl \[start|helpme\] \[OPTIONS\]

Options:
  \[--mirror|-m\]     &lt;url>         \* Mandatory \*
  \[--cache\_dir|-d\]  &lt;path>        # Default: ./minicpan
  \[--interface|-i\]  &lt;hostname|ip> # Default: localhost
  \[--port|-p\]       &lt;portnumber>  # Default: 9999
  \[--offline|-o\]                  # Do not update local cache
  \[--help|-?\]                     # show this helptext

Example: cpanminiserver.pl -i localhost -p 9999 -m http://example.com

To bind all interfaces use --interface or -i followed by ''
Example: cpanminiserver.pl -i '' -p 9999 -m http://example.com

To find mirror to sync with go to:
http://mirrors.cpan.org

Then using the local server when installing with cpanm

    cpanm -m http://localhost:9999 Some::Module

# DESCRIPTION

Host your own CPAN repo locally.

Main use cases:
  - Host your own full cpan repo locally to make it available when offline.
  - Host your own repo to be a good citizen when using it heavily.

When running the app first we will sync the mirror to the cache directory, then
the built-in server will bind to the provided interface:port.

The first sync will take a long time as all the modules will have to be downloaded,
on the secondary run and beyond the sync process will be much faster as we only update
outdated modules.

See the CPAN::Mini module for more information

# LICENSE

Copyright (C) Tore Andersson.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Tore Andersson <tore.andersson@gmail.com>
