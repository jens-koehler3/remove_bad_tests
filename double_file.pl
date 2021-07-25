#!/usr/bin/perl
use strict;
use warnings;

use File::Find::Duplicates;

my @dirs = @ARGV;

# Basic Sanity Check
usage() unless scalar @ARGV > 1;

my @dupesets = find_duplicate_files(@dirs);

foreach my $dupeset (@dupesets) {
	print "Duplicate files: ", join(", ", @{ $dupeset->files } ), "\n";
        print "MD5:  ", $dupeset->md5, "\n";
        print "Size: ", $dupeset->size, " Bytes\n";
	print "\n";
}

sub usage {
    warn "Usage: $0 DIR1 DIR2\n";
    exit;
}
