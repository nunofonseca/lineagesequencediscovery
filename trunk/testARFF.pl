#!/usr/bin/perl -w

use ARFF;

my $arff = new ARFF();

my $dataSet = 
[
    ['VPF', '1', '0'],
    ['VPF2', '1', '0'],
    ['VPF3', '1', '0']
];

$arff->relation('Teste');

$arff->addAttribute('pattern', 'string');
$arff->addAttribute('search', 'numeric');
$arff->addAttribute('not', 'numeric');

for $d (@$dataSet)
{
    $arff->addData($d);
}

$arff->writeFile("file.txt");

$arff->readFile("file.txt");

$arff->writeFile("file_out.txt");

