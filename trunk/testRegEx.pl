#!/usr/bin/perl -w

my $str = "Hello World 12345";

my $patMatch = ($str =~ m/World/);
my $strMatched = $&;
if($patMatch == 1)
{
    print("$patMatch\n");
    print($strMatched);
}else
{
    print("Not found");
}

