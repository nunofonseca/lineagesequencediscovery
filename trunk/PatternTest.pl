#!/usr/bin/perl -w

use PatternManager;

my $pat = new PatternManager;

$pat->loadFromPat("retrovirus5000.fasta.pat");

my @pats = @{ $pat->getPatterns };

for $p (@pats)
{
    $p->print;
}

