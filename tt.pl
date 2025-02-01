#!/usr/bin/perl
use strict;
use warnings;

my @array = (1, 2, 3, 4);
my $ref_array = \@array;  # $ref_array est une référence à @array
print "@{$ref_array}\n";  # Affiche : 1 2 3 4
print $ref_array;
