package Parse::Diagnostics;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw/parse_diagnostics $diagnostics_re/;
%EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
use warnings;
use strict;
use Carp;
use Path::Tiny;
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

sub parse_diagnostics
{
    my ($file, %options) = @_;
    my $contents = path ($file)->slurp ();
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

1;
