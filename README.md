# NAME

CPAN::Mini::Server or minicpanserver.pl - Host a local CPAN mirror for _DEVELOPMENT USE ONLY_

# SYNOPSIS

cpanminiserver.pl \[start|helpme\] \[OPTIONS\]

Options:

    --mirror    [-m] <url>         * Mandatory *
    --cache_dir [-d] <path>        # Default: ./minicpan
    --interface [-i] <hostname|ip> # Default: localhost
    --port      [-p] <portnumber>  # Default: 9999
    --offline   [-o]               # Do not update local cache
    --help      [-?]               # Show this helptext
    --verbose   [-v]               # Show more extensive help text

## STEP-BY-STEP

Find mirror to sync with, probably want to go here if you do not know about any:

[http://mirrors.cpan.org](http://mirrors.cpan.org)

Relying on default to bind to localhost:

cpanminiserver.pl -m http://example.com

Thats it it! This should sync data from the mirror to `./minicpan`
and bind the server to [http://localhost:9999](http://localhost:9999)

If you want to bind to all interfaces or a spesific one use the --interface or -i option:

cpanminiserver.pl -m http://example.com -i ''

To use the local server when installing with cpanm:

cpanm -m http://localhost:9999 Some::Module

# DESCRIPTION

Host your own _complete_ CPAN repo locally and serve it locally via http for _DEVELOPMENT PURPOSES ONLY_.

Download the full repo (many gigabytes of data) from a chosen mirror
and start a single process, single threaded non-forking webserver

## USE CASES

- Host your own _full_ cpan repo locally to make it available when offline.
- Host your own repo to be a good citizen when using it heavily.
- Run _cpanm_ commands while building a docker image and not copying the
repo directory.

When running the app first we will sync the mirror to the cache directory, then
the built-in server will bind to the provided interface:port.

The first sync will take a long time as all the modules will have to be downloaded,
on the secondary run and beyond the sync process will be much faster as we only update
outdated modules.

See the CPAN::Mini module for more information

# DISCLAIMER

This software is for development use only, do not not expose this to anything other than
your local machine or your very small local network which you fully control.

No effort has gone into making this secure, reliable or performant.

I made this to make CPAN available via HTTP on my development machine while offline.

# LICENSE

Copyright (C) Tore Andersson.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Tore Andersson <tore.andersson@gmail.com>
