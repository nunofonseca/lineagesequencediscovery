#############################################################
#                                                           #
#   Class Name:  MemeDialog                                 #
#   Description: Shows a dialog to run MEME.                #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package MemeDialog;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';
use Cwd qw(abs_path getcwd);
use RunCommand;
use SequencesViewer;
use SearchEngine;
use File::Copy;
use File::HomeDir qw(home);
use Number::Format qw (round);

my $MEME_BASEDIR = "";
my $MEME_SCRIPT = '/usr/local/bin/meme';
my $MEME_DEFAULTS = home() . '/.lineagesequencediscovery/meme.defaults';

#my $strfrmMeme = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class, $seqViewer, $refine) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmMeme              => undef,
        _seqViewer            => $seqViewer,
        _txtCommandLine       => undef,
        _tmpFilePos           => "$$.pos.fasta",
        _tmpFileNeg           => "$$.neg.fasta",
        _tmpOutFile           => "$$.pos.fasta.pat",
        _settings             => undef
    };
    
    bless $self, $class;
    
    $MEME_BASEDIR = $seqViewer->projectDir . "meme/";
    mkdir($MEME_BASEDIR) unless (-d $MEME_BASEDIR);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $MEME_BASEDIR .= ($year+1900)."-$mon-$mday-$hour-$min/";
    mkdir($MEME_BASEDIR) unless(-d $MEME_BASEDIR);
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmMeme))
    {
        $self->{_builder}->add_from_string($strfrmMeme);
    }else
    {
        $self->{_builder}->add_from_file("frmMeme.glade");
    }
    
    $self->{_frmMeme} = $self->{_builder}->get_object("frmMeme");
    $self->{_txtCommandLine} = $self->{_builder}->get_object("txtCommandLine");
    
    $self->{_builder}->get_object("btnExecute")->signal_connect(clicked => \&on_btnExecute_clicked, $self);
    $self->{_builder}->get_object("btnCancel")->signal_connect(clicked => \&on_btnCancel_clicked, $self);
        
    $self->{_settings} = new Settings($MEME_DEFAULTS, 
                                      { "MotifsPerSequence" => 0,
                                        "MaxNumMotifs" => 1,
                                        "MinOptimumWidth" => 8,
                                        "MaxOptimumWidth" => 50,
                                        "MinOptimumNSites" => 1,
                                        "MaxOptimumNSites" =>  50,
                                        "SearchGivenStrand" => 0,
                                        "LookOnlyForPalindromes" => 0});

    $self->{_settings}->save($MEME_DEFAULTS) unless(-e $MEME_DEFAULTS);
    
    for(my $i = 1; $i <= 5; ++$i)
    {
        my $obj = $self->{_builder}->get_object("param[" . $i . "]");
        $obj->signal_connect(changed => \&on_field_update, $self);
    }

    for($i = 0; $i < 3; ++$i) {
        $self->{_builder}->get_object("param[0][$i]")->signal_connect(toggled => \&on_field_update, $self);
    }

    $self->{_builder}->get_object("param[7]")->signal_connect(toggled => \&on_field_update, $self);
    $self->{_builder}->get_object("param[8]")->signal_connect(toggled => \&on_field_update, $self);
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

sub show
{
    my ($self) = @_;
    $self->{_frmMeme}->show();
 
    my $param0val = $self->{_settings}->get('MotifsPerSequence');
    for($i = 0; $i < 3; ++$i) {
        $self->{_builder}->get_object("param[0][$i]")->set_active( ($param0val == $i) ? 1 : 0);
    }
    
    $self->{_builder}->get_object("param[1]")->set_value($self->{_settings}->get('MaxNumMotifs'));
    $self->{_builder}->get_object("param[2]")->set_value($self->{_settings}->get('MinOptimumWidth'));
    $self->{_builder}->get_object("param[3]")->set_value($self->{_settings}->get('MaxOptimumWidth'));
    $self->{_builder}->get_object("param[4]")->set_value($self->{_settings}->get('MinOptimumNSites'));
    $self->{_builder}->get_object("param[5]")->set_value($self->{_settings}->get('MaxOptimumNSites'));
    $self->{_builder}->get_object("param[7]")->set_active($self->{_settings}->get('SearchGivenStrand') ? 1 : 0);
    $self->{_builder}->get_object("param[8]")->set_active($self->{_settings}->get('LookOnlyForPalindromes') ? 1 : 0);
    
    on_field_update(undef, $self);
}

sub on_field_update
{
    my ($caller, $self) = @_;

    @params = ("-mod ",
               "-nmotifs ",
               "-minw ",
               "-maxw ",
               "-minsites ",
               "-maxsites ",
               "-bfile ",
               "-revcomp",
               "-pal");

    @param0_opts = ("oops", "zoops", "anr");
    
    for($i = 0; $i < 3; ++$i) {
        my $obj = $self->{_builder}->get_object("param[0][$i]");
        if($obj->get_active) {
            $params[0] .= $param0_opts[$i];
            last;
        }
    }

    for($i = 1; $i <= 5; ++$i) {
        my $obj = $self->{_builder}->get_object("param[$i]");
        if($obj->get_value == 0) {
            $params[$i] = "";
        } else {
            $params[$i] .= $obj->get_value;
        }
    }

    for($i = 7; $i <= 8; ++$i) {
        my $obj = $self->{_builder}->get_object("param[$i]");
        $params[$i] = "" unless($obj->get_active);
    }

    my $obj = $self->{_builder}->get_object("param[6]");
    if(defined($obj->get_filename) && length($obj->get_filename) > 0) {
        $params[6] .= "\"" . $obj->get_filename . "\"";
    } else {
        $params[6] = "";
    }

    $finalPar = "";
    for($i = 0; $i <= 8; ++$i) {
        $finalPar .= $params[$i] . " ";
    }

    $self->{_txtCommandLine}->set_text($finalPar);
}


sub prepare_out_files
{
    my ($self) = @_;
    
    my $pos = $self->{_seqViewer}->positiveSequences;
    my $neg = $self->{_seqViewer}->negativeSequences;
    
    my $countPos = $pos->numSequences;
    my $countNeg = $neg->numSequences;
        
    open my $fhPos, ">$MEME_BASEDIR/" . $self->{_tmpFilePos};

    for(my $i = 0; $i < $countPos; ++$i)
    {
        my %seq = $pos->getSequence($i);
        my $seqTxt = $seq{'seq'};
        $seqTxt = $self->{_seqViewer}->getSequenceSelectedColumns('pos', $i) if ($self->{_seqViewer}->{_selPosStart} != -1);
        print $fhPos (">" . $seq{'header'} . "\n" . $seqTxt . "\n"); 
    }
    
    close($fhPos);
    
    open my $fhNeg, ">$MEME_BASEDIR/" . $self->{_tmpFileNeg};
    
    for(my $i = 0; $i < $countNeg; ++$i)
    {
        my %seq = $neg->getSequence($i);
        my $seqTxt = $seq{'seq'};
        $seqTxt = $self->{_seqViewer}->getSequenceSelectedColumns('neg', $i) if ($self->{_seqViewer}->{_selNegStart} != -1);
        print $fhNeg (">" . $seq{'header'} . "\n" . $seqTxt . "\n"); 
    }
    
    close($fhNeg);
}

sub num_matches {
	my ($self, $set, $exp) = @_;
	if($set eq 'pos') {
		my $pos = $self->{_seqViewer}->positiveSequences;
		my $countPos = $pos->numSequences;
		my $n = 0;
				
		my %settings = SearchEngine::setup_search($exp, 'fuzzy');
		for(my $i = 0; $i < $countPos; ++$i)
		{
		    my %seq = $pos->getSequence($i);
		    my $seqTxt = $seq{'seq'};
		    my %matches = SearchEngine::search(\%settings, $seqTxt);
		    $n += $matches{"num_matches"};
		}
		
		return $n;
		
	} elsif($set eq 'neg') {
		my $neg = $self->{_seqViewer}->negativeSequences;
		my $countNeg = $neg->numSequences;
		my $n = 0;
		
		my %settings = SearchEngine::setup_search($exp, 'fuzzy');
		for(my $i = 0; $i < $countNeg; ++$i)
		{
		    my %seq = $neg->getSequence($i);
		    my $seqTxt = $seq{'seq'};
		    my %matches = SearchEngine::search(\%settings, $seqTxt);
		    $n += $matches{"num_matches"};
		}
		return $n;
	} else {
		return 0;
	}
}

# recall: matches(p,S1)/|S1|
# precision: matches(p,S1)/(matches(p,S1)+matches(p,S2))
# f=2*precision*recall/(recall+precision)
sub _stats {
	my $self = shift;
	my $pat = shift;
    
    my $npos = $self->{_seqViewer}->positiveSequences->numSequences;
    my $nneg = $self->{_seqViewer}->negativeSequences->numSequences;
    
    my $POS = $self->num_matches('pos', $pat);
    my $NEG = $self->num_matches('neg', $pat);
    
    my $recall = round(($POS / $npos), 3);
    my $recall_neg = round(($NEG / $nneg), 3);
    my $prec;
    my $f;
    
    if (($NEG + $POS) == 0) {
		$prec = 0.0;
    } else {
		$prec = round($POS / ($NEG + $POS), 3);
    }
    
    if (($prec + $recall) == 0) {
		$f = 0.0;
    } else {
		$f = round(2 * $prec * $recall / ($prec + $recall), 3);
    }

    my $std_desv_pos = round(sqrt($recall * (1 - $recall) / $npos), 4);
    my $std_desv_neg = round(sqrt($recall_neg * (1 - $recall_neg) / $nneg), 4);
    
    return "$POS $NEG $recall $recall_neg $prec $f $std_desv_pos $std_desv_neg " . 
           "0 0 0.0 0.0 0.0 0.0 0.0 0.0";
}

sub on_btnExecute_clicked
{
    my ($btn, $self) = @_;

  	$self->prepare_out_files;

  	my $cmd = "cd $MEME_BASEDIR && $MEME_SCRIPT " . $self->{_tmpFilePos} . " -oc $$  ". $self->{_txtCommandLine}->get_text . ' 2>&1';
    my $oldDir = getcwd;
    my $runcmd = new RunCommand(0); # Don't auto hide!

    $runcmd->runCommand($cmd,
    sub {
      if(-e "$MEME_BASEDIR/$$/meme.html") {
         	my $resultsHTML = "";
         	open $fh, "<$MEME_BASEDIR/$$/meme.xml";
         	while($_ = <$fh>) {
         		$resultsHTML .= $_;
         	}
          close $fh;
          
          my @regexps;
          my $i = 1;

          while($resultsHTML =~ m/<regular_expression>\n(.*?)\n<\/regular_expression>/gsi) {
	          $regexp = $1;
	          $regexp =~ s/[\n \t\r]//g;
	          chomp($regexp);
	          my $stats = $self->_stats($regexp) . " $regexp Motif$i";
	          my $newpat = new Pattern;
	          $newpat->loadFromString($stats);
	          push @regexps, $newpat;
	          ++$i;
          }

          if($i > 1) {
				    my $diag = new Gtk2::FileChooserDialog("Save patterns", $self->{_frmMeme}, 'save', 'gtk-cancel' => 'cancel', 'gtk-save' => 'ok');
                  
            my $filter = new Gtk2::FileFilter();
            $filter->set_name("Pattern Files");
            $filter->add_pattern("*.pat");
            $diag->add_filter($filter);

            $filter = new Gtk2::FileFilter();
            $filter->set_name("All Files");
            $filter->add_pattern("*");
            $diag->add_filter($filter);
            
            if('ok' eq $diag->run)
            {
                my $filename = $diag->get_filename;
                open $fh, ">$filename";
                foreach $pat (@regexps){
                    print $fh ($pat->toString() . "\n");
                }
                close $fh;
                
                my $swin = new SearchWindow($self->{_seqViewer});
                $swin->show();
                $swin->openPatternFile($filename);
            }
            
            $diag->destroy;
          } else {
            SequencesViewer::error("MEME didn't find any patterns!\nTry changing the settings...");
          }
          
          $runcmd->destroy;
          
          $diag = Gtk2::MessageDialog::new(undef,
                                           $self->{_frmMeme},
                                           qw(destroy-with-parent),
                                           'question',
                                           'yes-no',
                                           "Wanna open the results page on your browser?");
          my $resp = $diag->run;
          $diag->destroy;
          
          if($resp eq 'yes') {
            my $path = abs_path("$MEME_BASEDIR/$$/meme.html");
            system("xdg-open \"file://$path\"");
          }
          
          $self->{_frmMeme}->destroy();
      }else{
          my $output = $runcmd->getOutput;
          $runcmd->destroy;
          SequencesViewer::error("MEME didn't generate the patterns file.\nPlease, check your settings and try again!\n\n" . $output);
      }
                  
      chdir($oldDir);
    });
}

sub on_btnCancel_clicked
{
    my ($btn, $self) = @_;
    $self->{_frmMeme}->destroy();
}

1;

