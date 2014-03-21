package Pegex::Cmd;

#-----------------------------------------------------------------------------#
package Pegex::Cmd::Command;
use App::Cmd::Setup -command;
use Mouse;
extends 'MouseX::App::Cmd::Command';

#-----------------------------------------------------------------------------#
package Pegex::Cmd;
use App::Cmd::Setup -app;
use Mouse;
extends 'MouseX::App::Cmd';

use Module::Pluggable
  require     => 1,
  search_path => [ 'Pegex::Cmd::Command' ];
  Pegex::Cmd->plugins;

#-----------------------------------------------------------------------------#
package Pegex::Cmd::Command::compile;
Package->import( -command );
use Mouse;
extends 'Pegex::Cmd::Command';

use constant abstract =>
    'Compile a Pegex grammar to some format.';
use constant usage_desc =>
    'pegex compile --to=<output format> [grammar_file.pgx]';

has to => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    documentation => 'Output format. One of: yaml, json, perl, perl6, python.',
);

has regex => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->to eq 'perl' ? 'perl' : 'raw';
    },
    documentation => "Regex format: raw, perl.",
);

has boot => (
    is => 'ro',
    isa => 'Bool',
    default => sub { 0 },
    documentation => 'Use the bootstrap compiler',
);

my %formats = map {($_,1)} qw'yaml json perl perl6 python';
my %regexes = map {($_,1)} qw'perl raw';

sub slurp {
    my ($file_name) = @_;
    open INPUT, $file_name or die "Can't open $file_name for input";
    local $/;
    <INPUT>
}

sub execute {
    my ($self, $opt, $args) = @_;
    my $to = $self->to;
    my $regex = $self->regex;
    die "'$to' is an invalid --to= format"
        unless $formats{$to};
    die "'$regex' is an invalid --regex= format"
        unless $regexes{$regex};
    my $input = scalar(@$args)
        ? slurp($args->[0])
        : do { local $/; <> };
    my $compiler_class = $self->boot
        ? 'Pegex::Bootstrap'
        : 'Pegex::Compiler';
    eval "use $compiler_class; 1" or die $@;
    my $compiler = $compiler_class->new();
    $compiler->parse($input)->combinate;
    $compiler->native if $regex eq 'perl';
    my $output =
        $to eq 'perl' ? $compiler->to_perl :
        $to eq 'yaml' ? $compiler->to_yaml :
        $to eq 'json' ? $compiler->to_json :
        do { die "'$to' format not supported yet" };
    print STDOUT $output;
}

1;

=encoding utf8

=head1 NAME

Pegex::Cmd - Support module for the 'pegex' CLI command

=head1 SYNOPSIS

From the command line:

    > pegex help

    > pegex compile --to=yaml your-grammar.pgx
    > pegex compile --to=json your-grammar.pgx
    > pegex compile --to=perl your-grammar.pgx
    > pegex compile --to=perl6 your-grammar.pgx
    > pegex compile --to=python your-grammar.pgx

=head1 DESCRIPTION

The C<pegex> command line tool compiles a L<Pegex> grammar into a particular
format and prints it to STDOUT. This tool just provides a simple way to invoke
L<Pegex::Compiler> from the command line. See the L<Pegex> documentation for
more information.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2011-2014. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
