#!/usr/bin/perl -w

use File::Copy;
use File::Path;

$APPNAME = "LSD";
$TEMPDIR = "tmp";
$OUTPUTDIR = "dist";

$MAIN_SCRIPT = "LSD.pl";

@FILES_TO_INCLUDE = 
(
    "ARFF.pm",
    "NewSessionDialog.pm",
    "PatternManager.pm",
    "Pattern.pm",
    "LSD.pl",
    "SearchWindow.pm",
    "SequencesFile.pm",
    "SequencesViewer.pm", 
    "RunCommand.pm",
    "TCoffee.pm"
);

%GLADE_FILES = 
(
    "frmNewSession.glade" => "NewSessionDialog.pm",
    "frmSearchWindow.glade" => "SearchWindow.pm",
    "frmSequencesViewer.glade" => "SequencesViewer.pm",
    "frmRunCommand.glade" => "RunCommand.pm",
    "frmTCoffee.glade" => "TCoffee.pm"
);

print("Making package for $APPNAME...\n");

print("Copying files to temp dir..\n");

mkdir($TEMPDIR);

foreach $file (@FILES_TO_INCLUDE)
{
    print("\tCopying $file...\n");
    copy($file, "$TEMPDIR/$file");
}

print("Done copying.\n");

print("\nInserting GLADE files into scripts...\n");

foreach $k (keys %GLADE_FILES)
{
    my $script = $k;
    my $outfile = $GLADE_FILES{$k};
    
    print("\tInjecting $script into $outfile...\n");
    
    my $outstr = "";
    open($fh1, "<$TEMPDIR/$outfile");
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
    
    open($fh3, ">$TEMPDIR/$outfile");
    print $fh3 ($outstr);
    close($fh3);
}

print("Done.\n");

print("Using \'pp\' tool to package the application:\n");
system("cd $TEMPDIR && pp -vvv -o \"$APPNAME\" \"$MAIN_SCRIPT\"");
print("Done.\n");

print("Copying final executable to output folder...\n");
mkdir($OUTPUTDIR);
copy("$TEMPDIR/$APPNAME", "$OUTPUTDIR/$APPNAME");
chmod(0755, "$OUTPUTDIR/$APPNAME");
print("Done!\n");

print("Cleaning temporary directory...\n");
#system("rm -rf \"$TEMPDIR\"");
print("Done!\n");

