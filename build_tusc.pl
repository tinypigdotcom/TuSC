#!/usr/bin/perl

use strict;
use Text::Template;

my $template = Text::Template->new(
    TYPE       => 'FILE',
    SOURCE     => 'tusc.t',
    DELIMITERS => ['{%', '%}'],
);

our $HASH;

use lib '.';
require 'build_tusc.cfg';

my $text = $template->fill_in(HASH => $HASH);

print STDERR "Building tusc.ahk ... ";

open OUT, ">tusc.ahk" or die;
print OUT $text;
close OUT;

print STDERR "done!\n";

