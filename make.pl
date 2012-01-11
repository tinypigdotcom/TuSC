#!/usr/bin/perl

use strict;
use Text::Template;

my $template = Text::Template->new(
    TYPE       => 'FILE',
    SOURCE     => 'tusc_addon.t',
    DELIMITERS => ['{%', '%}'],
);

our $HASH;

use lib '.';
require 'config.pl';

my $text = $template->fill_in(HASH => $HASH);

print STDERR "Building tusc_addon.ahk ... ";

open OUT, ">tusc_addon.ahk" or die;
print OUT $text;
close OUT;

print STDERR "done!\n";

