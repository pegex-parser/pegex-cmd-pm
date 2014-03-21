# NAME

Pegex::Cmd - Support module for the 'pegex' CLI command

# SYNOPSIS

From the command line:

    > pegex help

    > pegex compile --to=yaml your-grammar.pgx
    > pegex compile --to=json your-grammar.pgx
    > pegex compile --to=perl your-grammar.pgx
    > pegex compile --to=perl6 your-grammar.pgx
    > pegex compile --to=python your-grammar.pgx

# DESCRIPTION

The `pegex` command line tool compiles a [Pegex](http://search.cpan.org/perldoc?Pegex) grammar into a particular
format and prints it to STDOUT. This tool just provides a simple way to invoke
[Pegex::Compiler](http://search.cpan.org/perldoc?Pegex::Compiler) from the command line. See the [Pegex](http://search.cpan.org/perldoc?Pegex) documentation for
more information.

# AUTHOR

Ingy döt Net <ingy@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (c) 2011-2014. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html
