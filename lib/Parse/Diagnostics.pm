package Parse::Diagnostics;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/parse_diagnostics parse_diagnostics_pp parse_diagnostics_xs/;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
use Path::Tiny;
use C::Tokenize '$string_re';
our $VERSION = '0.01';

our $message_re = qr
/
    (
	"([^"]|\\")+"
    |
	'([^']|\\')+'
    )
    (?:,.*?)?
/x;

our $diagnostics_re = qr
/
    (
	croak
    |
	carp
    |
	die
    |
	warn
    |
	confess
    |
	cluck
    )
    \s*
    (
	\(
	$message_re
	\)
    |
	$message_re
    )
/x;

our $xs_diagnostics_re = qr
    /
	(
	    croak
	|
	    warn
	|
	    vwarn
	|
	    vcroak
	|
	    die
	|
	    croak_sv
	|
	    die_sv
	)
	\s*
	\(
	\s*
	($string_re)
    /x;

our $c_diagnostics_re = qr
    /
	(v?fprintf)
	\s*\(\s*
	stderr
	\s*,\s*
	($string_re)
    /x;

sub parse_diagnostics_pp
{
    my ($contents, %options) = @_;
    my @diagnostics;
    while ($contents =~ /$diagnostics_re/g) {
	push @diagnostics, {
	    type => $1,
	    message => $2,
	    line => 0,
	};
    }
    return \@diagnostics;
}

sub parse_diagnostics_xs
{
    my ($contents, %options) = @_;
    my @diagnostics;
    while ($contents =~ /$xs_diagnostics_re/g) {
	push @diagnostics, {
	    type => $1,
	    message => $2,
	    line => 0,
	};
    }
    while ($contents =~ /$c_diagnostics_re/g) {
	push @diagnostics, {
	    type => $1,
	    message => $2,
	    line => 0,
	};
    }
    return \@diagnostics;
}

sub parse_diagnostics
{
    my ($file, %options) = @_;
    my $contents = path ($file)->slurp ();
    my @diagnostics;
    if ($file =~ /\.(c|xs)$/) {
	my $xsdiagnostics = parse_diagnostics_xs ($contents, %options);
	push @diagnostics, @$xsdiagnostics;
    }
    else {
	my $ppdiagnostics = parse_diagnostics_pp ($contents, %options);
	push @diagnostics, @$ppdiagnostics;
    }
    if ($options{user_re}) {
	while ($contents =~ /$options{user_re}/g) {
	    push @diagnostics, {
		type => $1,
		message => $2,
		line => 0,
	    }
	}
    }
    return \@diagnostics;
}

1;
