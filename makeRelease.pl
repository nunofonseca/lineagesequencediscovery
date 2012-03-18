#!/usr/bin/perl -w

use File::Copy;
use File::Path;

$APPNAME = "LSD";
$OUTPUTDIR = "dist";

@FILES_TO_INCLUDE = 
(
    "sigdis/biored",
    "sigdis/biored-mpi",
    "sigdis/bioredx",
    "sigdis/bioredx-mpi",
    "sigdis/fasta2flat.pl",
    "sigdis/fasta2seq",
    "sigdis/fastarandom.sh",
    "sigdis/fastatoseq",
    "sigdis/gui-clean",
    "sigdis/maximal_words",
    "sigdis/pdx",
    "sigdis/rsplit_seqs.sh",
    "sigdis/sigdis.pl",
    "sigdis/wd",
    "ARFF.pm",
    "DoubleFileDialog.pm",
    "Executable.pm",
    "FuzzySearch.pm",
    "MemeDialog.pm",
    "NewSessionDialog.pm",
    "PatternManager.pm",
    "Pattern.pm",
    "RunCommand.pm",
    "SearchEngine.pm",
    "SearchExportDialog.pm",
    "SearchWindow.pm",
    "SequencesFile.pm",
    "SequencesViewer.pm",
    "Settings.pm",
    "SigDisDialog.pm",
    "TCoffee.pm",
    "LSD.pl",
    "LSD.png",
    "arrow-right.png"
);

%GLADE_FILES = 
(
    "frmDoubleFileDialog.glade" => "DoubleFileDialog.pm",
    "frmMeme.glade" => "MemeDialog.pm",
    "frmRunCommand.glade" => "RunCommand.pm",
    "frmSearchExport.glade" => "SearchExport.pm",
    "frmSearchWindow.glade" => "SearchWindow.pm",
    "frmSequencesViewer.glade" => "SequencesViewer.pm",
    "frmSigDis.glade" => "SigDisDialog.pm",
    "frmTCoffee.glade" => "TCoffee.pm"
);

print("Making package for $APPNAME...\n");

print("Copying files to output dir..\n");

mkdir($OUTPUTDIR);
mkdir("$OUTPUTDIR/sigdis/");

foreach $file (@FILES_TO_INCLUDE)
{
    print("\tCopying $file...\n");
    system("cp", $file, "$OUTPUTDIR/$file");
}

print("Done copying.\n");

print("Correcting permissions...\n");
#chmod();
print("Done!\n");

print("\nInserting GLADE files into scripts...\n");

foreach $k (keys %GLADE_FILES)
{
    my $script = $k;
    my $outfile = $GLADE_FILES{$k};
    
    print("\tInjecting $script into $outfile...\n");
    
    my $outstr = "";
    open($fh1, "<$OUTPUTDIR/$outfile");
    $outstr .= $_ while($_ = <$fh1>);
    close($fh1);
    
    my $instr = "";
    open($fh2, "<$script");
    $instr .= $_ while($_ = <$fh2>);
    close($fh2);
    
    my $scriptPrefix = $script;
    $scriptPrefix =~ s/.glade//;
    
    $instr =~ s/(["'\\\/])/\\$1/g;
    $instr =~ s/\n//g;
    
    my $searchfor = '#my \$str' . $scriptPrefix . ' = "REPLACE_HERE";';
    my $replacewith = 'my $str' . $scriptPrefix . " = \"$instr\";";
    
    $outstr =~ s/$searchfor/$replacewith/;
    
    open($fh3, ">$OUTPUTDIR/$outfile");
    print $fh3 ($outstr);
    close($fh3);
}

print("Done.\n");

#print("Using \'pp\' tool to package the application:\n");
#system("cd $OUTPUTDIR && pp -vvv -o \"$APPNAME\" \"$MAIN_SCRIPT\"");
#print("Done.\n");

#print("Copying final executable to output folder...\n");
#mkdir($OUTPUTDIR);
#copy("$OUTPUTDIR/$APPNAME", "$OUTPUTDIR/$APPNAME");
#chmod(0755, "$OUTPUTDIR/$APPNAME");
#print("Done!\n");

#system("cd scripts && sh makeDeb.sh");

