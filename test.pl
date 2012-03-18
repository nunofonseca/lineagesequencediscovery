#!/usr/bin/perl -w

use Gtk2 '-init';
use DoubleFileDialog;


my $b = new DoubleFileDialog();
if($b->run() eq 'ok')
{
    print $b->filePositive . "\n" . $b->fileNegative . "\n";
}else
{
    print "bah";
}

