#!/usr/bin/perl -w
use Cwd qw(realpath getcwd);
use File::Basename;

my $dir = getcwd();
my $perlPath = dirname(realpath(__FILE__));

print(__FILE__);
print("$dir\n");
print("$perlPath\n");


