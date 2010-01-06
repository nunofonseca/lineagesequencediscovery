#!/usr/bin/perl -w

use RunCommand;
use Gtk2 -init;

my $cmd = new RunCommand;

$cmd->runCommand("t_coffee teste.fasta -outfile=stdout -out_lib=stdout");

$cmd->{_window}->signal_connect( destroy => sub{Gtk2->main_quit} );

Gtk2->main();

