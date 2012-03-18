#############################################################
#                                                           #
#   Class Name:  SigDisDialog                               #
#   Description: Shows a dialog to run SigDis.              #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SigDisDialog;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';
use Cwd;
use RunCommand;
use Settings;
use SequencesFile;
use File::Copy;
use File::HomeDir qw(home);

my $SIGDIS_BASEDIR = "";
my $SIGDIS_SCRIPT = 'sigdis.pl';
my $SIGDIS_DEFAULTS = home() . '/.lineagesequencediscovery/sigdis.defaults';

#my $strfrmSigDis = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class, $seqViewer, $refine) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmSigDis            => undef,
        _seqViewer            => $seqViewer,
        _txtCommandLine       => undef,
        _tmpFilePos           => "$$.pos.fasta",
        _tmpFileNeg           => "$$.neg.fasta",
        _tmpOutFile           => "$$.pos.fasta.pat",
        _settings             => undef
    };
    
    bless $self, $class;
    
    $SIGDIS_BASEDIR = $seqViewer->projectDir . "sigdis/";
    mkdir($SIGDIS_BASEDIR) unless (-d $SIGDIS_BASEDIR);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $SIGDIS_BASEDIR .= ($year+1900)."-$mon-$mday-$hour-$min/";
    mkdir($SIGDIS_BASEDIR) unless(-d $SIGDIS_BASEDIR);
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmSigDis))
    {
        $self->{_builder}->add_from_string($strfrmSigDis);
    }else
    {
        $self->{_builder}->add_from_file("frmSigDis.glade");
    }
    
    $self->{_frmSigDis} = $self->{_builder}->get_object("frmSigDis");
    $self->{_txtCommandLine} = $self->{_builder}->get_object("txtCommandLine");
    
    $self->{_builder}->get_object("btnExecute")->signal_connect(clicked => \&on_btnExecute_clicked, $self);
    
    $self->{_settings} = new Settings($SIGDIS_DEFAULTS,
                                     { "minpos" => 70,
                                       "maxneg" => 30,
                                       "similarity" => 50,
                                       "train" => 50,
                                       "maxexpand" => 10,
                                       "seedlength" =>  3,
                                       "inputtype" => 0,
                                       "refine" => "",
                                       "score" => "",
                                       "verbose" => 1 });
                                       
    $self->{_settings}->save($SIGDIS_DEFAULTS) unless(-e $SIGDIS_DEFAULTS);
    $self->{_settings}->set('refine' => $refine) if defined($refine);
    
    for(my $i = 0; $i < 9; ++$i)
    {
        my $obj = $self->{_builder}->get_object("param[" . $i . "]");
        $obj->signal_connect(changed => \&on_field_update, $self);
    }
    $self->{_builder}->get_object("param[9]")->signal_connect(toggled => \&on_field_update, $self);
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

sub show
{
    my ($self) = @_;
    $self->{_frmSigDis}->show();
    
    $self->{_builder}->get_object("param[0]")->set_value($self->{_settings}->get('minpos'));
    $self->{_builder}->get_object("param[1]")->set_value($self->{_settings}->get('maxneg'));
    $self->{_builder}->get_object("param[2]")->set_value($self->{_settings}->get('similarity'));
    $self->{_builder}->get_object("param[3]")->set_value($self->{_settings}->get('train'));
    $self->{_builder}->get_object("param[4]")->set_text($self->{_settings}->get('maxexpand'));
    $self->{_builder}->get_object("param[5]")->set_text($self->{_settings}->get('seedlength'));
    
    $self->{_builder}->get_object("param[6]")->set_active($self->{_settings}->get('inputtype'));
    
    $self->{_builder}->get_object("param[7]")->set_text($self->{_settings}->get('refine'));
    $self->{_builder}->get_object("param[8]")->set_text($self->{_settings}->get('score'));
    
    $self->{_builder}->get_object("param[9]")->set_active( ($self->{_settings}->get('verbose') == 1 ? 1 : 0) );
    
    on_field_update(undef, $self);
}

sub prepare_out_files
{
    my ($self) = @_;
    
    my $pos = $self->{_seqViewer}->positiveSequences;
    my $neg = $self->{_seqViewer}->negativeSequences;
    
    my $countPos = $pos->numSequences;
    my $countNeg = $neg->numSequences;
        
    open my $fhPos, ">$SIGDIS_BASEDIR/" . $self->{_tmpFilePos};

    for(my $i = 0; $i < $countPos; ++$i)
    {
        my %seq = $pos->getSequence($i);
        my $seqTxt = $seq{'seq'};
        $seqTxt = $self->{_seqViewer}->getSequenceSelectedColumns('pos', $i) if ($self->{_seqViewer}->{_selPosStart} != -1);
        print $fhPos (">" . $seq{'header'} . "\n" . $seqTxt . "\n"); 
    }
    
    close($fhPos);
    
    open my $fhNeg, ">$SIGDIS_BASEDIR/" . $self->{_tmpFileNeg};
    
    for(my $i = 0; $i < $countNeg; ++$i)
    {
        my %seq = $neg->getSequence($i);
        my $seqTxt = $seq{'seq'};
        $seqTxt = $self->{_seqViewer}->getSequenceSelectedColumns('neg', $i) if ($self->{_seqViewer}->{_selNegStart} != -1);
        print $fhNeg (">" . $seq{'header'} . "\n" . $seqTxt . "\n"); 
    }
    
    close($fhNeg);
}

sub on_field_update
{
    my ($caller, $self) = @_;
    
    my $str = "";
    
    if( $self->{_builder}->get_object("param[4]")->get_text !~ m/[0-9]+/ or
        $self->{_builder}->get_object("param[5]")->get_text !~ m/[0-9]+/)
    {
        $self->{_txtCommandLine}->set_text("Invalid parameters!");
    }else
    {
        $str .= "-p \"" . $self->{_tmpFilePos} . "\"";
        $str .= " -n \"" . $self->{_tmpFileNeg} . "\"";
        $str .= sprintf(" --minpos %.4f", ($self->{_builder}->get_object("param[0]")->get_value / 100.0));
        $str .= sprintf(" --maxneg %.4f", ($self->{_builder}->get_object("param[1]")->get_value / 100.0));
        $str .= sprintf(" -e %.4f", ($self->{_builder}->get_object("param[2]")->get_value / 100.0));
        $str .= sprintf(" -t %.4f", ($self->{_builder}->get_object("param[3]")->get_value / 100.0));
        $str .= sprintf(" -l %d", ($self->{_builder}->get_object("param[4]")->get_text));
        $str .= sprintf(" -w %d", ($self->{_builder}->get_object("param[5]")->get_text));
        $str .= " -i " . ($self->{_builder}->get_object("param[6]")->get_active_text);                      
        $str .= " -r \"" . $self->{_builder}->get_object("param[7]")->get_text() . "\"" if(length $self->{_builder}->get_object("param[7]")->get_text() > 0);
        $str .= " -s \"" . $self->{_builder}->get_object("param[8]")->get_text() . "\"" if(length $self->{_builder}->get_object("param[8]")->get_text() > 0);
        $str .= " -v" if $self->{_builder}->get_object("param[9]")->get_active();
        $self->{_txtCommandLine}->set_text($str);
    };
}

sub on_btnExecute_clicked
{
    my ($btn, $self) = @_;

    $self->prepare_out_files;
    
    my $cmd = "cd $SIGDIS_BASEDIR && $SIGDIS_SCRIPT " . $self->{_txtCommandLine}->get_text . ' 2>&1';
    
    #print("Running: $cmd\n");
    
    my $oldDir = getcwd;

    my $runcmd = new RunCommand(0); # Don't auto hide!

    $runcmd->runCommand($cmd,
    sub {
            if(-e "$SIGDIS_BASEDIR/" . $self->{_tmpOutFile}) {
                my $diag = new Gtk2::FileChooserDialog("Save patterns", $self->{_frmDoubleFileDialog}, 'save', 'gtk-cancel' => 'cancel', 'gtk-save' => 'ok');
                
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
                    copy("$SIGDIS_BASEDIR/" . $self->{_tmpOutFile}, $filename);
                    
                    my $swin = new SearchWindow($self->{_seqViewer});
                    $swin->show();
                    $swin->openPatternFile($filename);
                }
                
                $diag->destroy;
                $runcmd->destroy;
                $self->{_frmSigDis}->destroy();
            }else{
                my $output = $runcmd->getOutput;
                $runcmd->destroy;
                SequencesViewer::error("SigDis didn't generate the patterns file.\nPlease, check your settings and try again!\n\n" . $output);
            }
            
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFilePos});
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFilePos} . ".test");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFilePos} . ".train");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFilePos} . ".seq");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFilePos} . ".words");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFileNeg});
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFileNeg} . ".test");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFileNeg} . ".train");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpFileNeg} . ".seq");
            unlink("$SIGDIS_BASEDIR/" . $self->{_tmpOutFile});
            
            chdir($oldDir);
    });

}

1;

