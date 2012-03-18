#!/usr/bin/perl -w

use RunCommand;

my %params = ('-maxnseq' => 1000,
              '-maxlen'  => 2000,
              'mode'    => lc("Regular"));

my $cmd = 't_coffee ';
my $outfile = 'teste.fasta';

$cmd .= $outfile;

for my $k (keys %params)
{
    $cmd .= ' ' . $k . ' ' . $params{$k};
}

print $cmd;

