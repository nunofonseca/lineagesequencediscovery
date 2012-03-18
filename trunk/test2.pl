#!/usr/bin/perl -w

use SequencesFile;

my %seq = &SequencesFile::processSpaces("A-B-C-D");
my @spaces = $seq{'spaces'};

print $seq{'seq'} . "\n";

my $len = @{$seq{'spaces'}}-1;
for $p (0..$len)
{
    my $start = (@{$seq{'spaces'}}[$p])[0][0];
    my $count = (@{$seq{'spaces'}}[$p])[0][1];
    print "Start: " . $start . ", Count: " . $count . "\n";
}

