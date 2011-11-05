##
# name:      Pegex::Command
# abstract:  Support module for the 'pegex' CLI command
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011
# see:
# - pegex
# - Pegex
# - Pegex::Compiler

use 5.008003;

use Mouse 0.93 ();
use MouseX::App::Cmd 0.08 ();
use Pegex 0.19 ();

#------------------------------------------------------------------------------#
package Pegex::Cmd;

our $VERSION = '0.11';

#------------------------------------------------------------------------------#
package Pegex::Cmd::Command;
use App::Cmd::Setup -command;
use Mouse;
extends 'MouseX::App::Cmd::Command';

sub validate_args {}

# Semi-brutal hack to suppress extra options I don't care about.
around usage => sub {
    my $orig = shift;
    my $self = shift;
    my $opts = $self->{usage}->{options};
    @$opts = grep { $_->{name} ne 'help' } @$opts;
    return $self->$orig(@_);
};

#-----------------------------------------------------------------------------#
package Pegex::Cmd;
use App::Cmd::Setup -app;
use Mouse;
extends 'MouseX::App::Cmd';

use Module::Pluggable
  require     => 1,
  search_path => [ 'Pegex::Cmd::Command' ];
  Pegex::Cmd->plugins;

#------------------------------------------------------------------------------#
package Pegex::Cmd::Command::compile;
Package->import( -command );
use Mouse;
extends 'Pegex::Cmd::Command';

use Pegex::Compiler;

use constant abstract => 'Compile a Pegex grammar to some format.';
use constant usage_desc => 'pegex compile --to=<output format> [grammar_file.pgx]';

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

my %formats = map {($_,1)} qw'yaml json perl perl6 python';
my %regexes = map {($_,1)} qw'perl raw';

sub execute {
    my ($self, $opt, $args) = @_;
    my $to = $self->to;
    my $regex = $self->regex;
    die "'$to' is an invalid --to= format"
        unless $formats{$to};
    die "'$regex' is an invalid --regex= format"
        unless $regexes{$regex};
    my $input = scalar(@$args)
        ? $args->[0]
        : do { local $/; <> };
    my $compiler = Pegex::Compiler->new();
    $compiler->parse($input)->combinate;
    $compiler->perlify if $regex eq 'perl';
    my $output =
        $to eq 'perl' ? $compiler->to_perl :
        $to eq 'yaml' ? $compiler->to_yaml :
        $to eq 'json' ? $compiler->to_json :
        do { die "'$to' format not supported yet" };
    print STDOUT $output;
}

1;

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
<Pegex::Compiler> from the command line. See the C<Pegex> documentation for
more information.
