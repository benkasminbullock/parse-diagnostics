#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use lib '/home/ben/projects/parse-diagnostics/lib';
use Parse::Diagnostics 'parse_diagnostics_file';
for (@ARGV) {
    my $diagnostics = parse_diagnostics_file ($_);
    for my $d (@$diagnostics) {
	print "$_:$d->{line}: $d->{type}: $d->{message}\n";
    }
}
