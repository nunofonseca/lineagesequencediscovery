#############################################################
#                                                           #
#   Class Name:  TCoffee                                    #
#   Description: Shows a dialog to configure a TCoffee      #
#                session. Allows the aligning of sequences  #
#                negative sequence files.                   #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package TCoffee;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';

use Settings;
use RunCommand;
use SequencesFile;
use File::HomeDir qw(home);

my $TCOFFEE_DEFAULTS = home() . '/.lineagesequencediscovery/tcoffee.defaults';

#my $strfrmTCoffee = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmTCoffee           => undef,
        _chkProfiles          => undef,
        _expAdvanced          => undef,
        baseDir               => "",
        fileToAlign           => "",
        posFile               => "",
        negFile               => "",
        cntPos                => 0,
        cntNeg                => 0,
        callback              => undef,
        _settings             => undef
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmTCoffee))
    {
        $self->{_builder}->add_from_string($strfrmTCoffee);
    }else
    {
        $self->{_builder}->add_from_file("frmTCoffee.glade");
    }
    
    $self->{_frmTCoffee} = $self->{_builder}->get_object("frmTCoffee");
    $self->{_chkProfiles} = $self->{_builder}->get_object("chkProfiles");
    $self->{_expAdvanced} = $self->{_builder}->get_object("expAdvanced");
    
    $self->{_builder}->get_object("btnExecute")->signal_connect(clicked => \&on_btnExecute_clicked, $self);
    
    $self->{_builder}->get_object("cmbComputationMode")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("spinMaxNumSequences")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("spinMaximumLengthSequences")->signal_connect(changed => \&updateCommandLine, $self);

    for(my $i = 0; $i < 6; ++$i)
    {
        $self->{_builder}->get_object("PairwiseMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);
    }    

    for(my $i = 0; $i < 4; ++$i)
    {
        $self->{_builder}->get_object("PairwiseStructuralMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    for(my $i = 0; $i < 8; ++$i)
    {
        my $obj = $self->{_builder}->get_object("MultipleMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    for(my $i = 0; $i < 11; ++$i)
    {
        my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    $self->{_builder}->get_object("cmbAdvancedCase")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("cmbAdvancedResidueNumber")->signal_connect(changed => \&updateCommandLine, $self);
    
    $self->{_expAdvanced}->signal_connect(activate => \&updateCommandLine, $self);
    
    $self->{_builder}->connect_signals();
    
    $self->{_settings} = new Settings($TCOFFEE_DEFAULTS, 
      {
        'ComputationMode' => 0,
        'MaxNumSequences' => 2000,
        'MaximumLengthSequences' => -1,
        'Profiles' => 1,
        
        # PairwiseMethods
        'PairwiseMethods[0]' => 0, 'PairwiseMethods[1]' => 0, 'PairwiseMethods[2]' => 0,
        'PairwiseMethods[3]' => 0, 'PairwiseMethods[4]' => 0, 'PairwiseMethods[5]' => 0,
        
        # PairwiseStructuralMethods
        'PairwiseStructuralMethods[0]' => 0, 'PairwiseStructuralMethods[1]' => 0,
        'PairwiseStructuralMethods[2]' => 0, 'PairwiseStructuralMethods[3]' => 0,
        
        # MultipleMethods
        'MultipleMethods[0]' => 0, 'MultipleMethods[1]' => 0, 'MultipleMethods[2]' => 0, 'MultipleMethods[3]' => 0,
        'MultipleMethods[4]' => 0, 'MultipleMethods[5]' => 0, 'MultipleMethods[6]' => 0, 'MultipleMethods[7]' => 0,
        
        # AlignmentFormat
        'AlignmentFormat[0]' => 1, 'AlignmentFormat[1]' => 0, 'AlignmentFormat[2]' => 0, 'AlignmentFormat[3]' => 1,
        'AlignmentFormat[4]' => 0, 'AlignmentFormat[5]' => 1, 'AlignmentFormat[6]' => 0, 'AlignmentFormat[7]' => 0,
        'AlignmentFormat[8]' => 0, 'AlignmentFormat[9]' => 1, 'AlignmentFormat[10]' => 1,
        
        # Case
        'Case' => 2,
        
        # ResidueNumber
        'ResidueNumber' => 1
      }
    );
    
    $self->{_settings}->save($TCOFFEE_DEFAULTS) unless(-e $TCOFFEE_DEFAULTS);
    
    return $self;
}

sub alignFile
{
    my ($self, $basedir, $file, $posFile, $negFile, $cntPos, $cntNeg, $onDone) = @_;
    $self->{baseDir} = $basedir;
    $self->{fileToAlign} = $file;
    $self->{posFile} = $posFile;
    $self->{negFile} = $negFile;
    $self->{cntPos} = $cntPos;
    $self->{cntNeg} = $cntNeg;
    $self->{callback} = $onDone;
    $self->{_frmTCoffee}->show();
    
    $self->{_builder}->get_object("spinMaxNumSequences")->set_value($self->{_settings}->get('MaxNumSequences'));
    $self->{_builder}->get_object("spinMaximumLengthSequences")->set_value($self->{_settings}->get('MaximumLengthSequences'));
    $self->{_builder}->get_object("cmbComputationMode")->set_active($self->{_settings}->get('ComputationMode'));
    $self->{_builder}->get_object("chkProfiles")->set_active($self->{_settings}->get('Profiles'));
    
    for(my $i = 0; $i < 6; ++$i)
    {
        $self->{_builder}->get_object("PairwiseMethods[$i]")->set_active($self->{_settings}->get("PairwiseMethods[$i]"));
    }    

    for(my $i = 0; $i < 4; ++$i)
    {
        $self->{_builder}->get_object("PairwiseStructuralMethods[$i]")->set_active($self->{_settings}->get("PairwiseStructuralMethods[$i]"));
    }
    
    for(my $i = 0; $i < 8; ++$i)
    {
        my $obj = $self->{_builder}->get_object("MultipleMethods[$i]")->set_active($self->{_settings}->get("MultipleMethods[$i]"));
    }
    
    for(my $i = 0; $i < 11; ++$i)
    {
        my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]")->set_active($self->{_settings}->get("AlignmentFormat[$i]"));
    }
    
    $self->{_builder}->get_object("cmbAdvancedCase")->set_active($self->{_settings}->get('Case'));
    $self->{_builder}->get_object("cmbAdvancedResidueNumber")->set_active($self->{_settings}->get('ResidueNumber'));
}

sub do_it
{
    my ($self, $useProfiles) = @_;
    
    if($useProfiles)                     
    {
        my $cmd = 't_coffee ';
        my $outfile = '"' . $self->{negFile} . '"';        
        $cmd .= $outfile;
        #for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }        
        $cmd .= $self->{_builder}->get_object("txtCommandLine")->get_text;
        $cmd .= ' -outfile=\''.$self->{baseDir}.'/negfile.aln\' 2>&1';
        
        #print("Running: $cmd\n");
        
        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd,
        sub {
            my $canceled = shift;
            if($canceled == 1) {
                $self->{_frmTCoffee}->destroy(); 
                return;
            }
            
            $cmd = 't_coffee ';
            $outfile = '"'. $self->{posFile} . '"';   
            $cmd .= $outfile;
            $cmd .= ' -profile \''.$self->{baseDir}.'/negfile.aln\' -outfile=\''.$self->{baseDir}.'/out.aln\' 2>&1';
            print("Running: $cmd\n");
            $runcmd = new RunCommand;
            $runcmd->runCommand($cmd,
                sub { 
                    my $canceled = shift;
                    $self->{_frmTCoffee}->destroy(); 
                    return if($canceled == 1);
                    process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); 
                    });
        });
        
    }else
    {
        my $cmd = 't_coffee ';
        my $outfile = '"'.$self->{baseDir}. '/'. $self->{fileToAlign} . '"';

        $cmd .= $outfile;

        #for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }        
        $cmd .= $self->{_builder}->get_object("txtCommandLine")->get_text;
        
        $cmd .= ' 2>&1';

        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd, 
        sub { 
            my $canceled = shift;
            $self->{_frmTCoffee}->destroy(); 
            return if($canceled == 1);
            process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); });
    }
}

sub updateCommandLine
{
    my ($btn, $self) = @_;
    
    my $useAdvanced = $self->{_expAdvanced}->get_expanded;
    $useAdvanced = !$useAdvanced if($btn == $self->{_expAdvanced});
    my %params = ();
    
    $params{'mode'} = lc($self->{_builder}->get_object("cmbComputationMode")->get_active_text);
    $params{'-maxnseq'} = $self->{_builder}->get_object("spinMaxNumSequences")->get_value;
    $params{'-maxlen'}  = $self->{_builder}->get_object("spinMaximumLengthSequences")->get_value;
    
    if($useAdvanced)
    {
        my $modeStr = "";
        for(my $i = 0; $i < 6; ++$i)
        {
            my $obj = $self->{_builder}->get_object("PairwiseMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }    

        for(my $i = 0; $i < 4; ++$i)
        {
            my $obj = $self->{_builder}->get_object("PairwiseStructuralMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-in'} = $modeStr if(length($modeStr) > 0);
        
        $modeStr = "";
        for(my $i = 0; $i < 8; ++$i)
        {
            my $obj = $self->{_builder}->get_object("MultipleMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-method'} = $modeStr if(length($modeStr) > 0);

        $modeStr = "";
        for(my $i = 0; $i < 11; ++$i)
        {
            my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-output'} = $modeStr if(length($modeStr) > 0);
        
        $params{'-case'} = lc($self->{_builder}->get_object("cmbAdvancedCase")->get_active_text);
        $params{'-seqnos'} = lc($self->{_builder}->get_object("cmbAdvancedResidueNumber")->get_active_text);
    }
    
    my $cmd = "";
    for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }
    
    $self->{_builder}->get_object("txtCommandLine")->set_text($cmd);
}

sub on_btnExecute_clicked
{
    my ($btn, $self) = @_;
    my $useProfiles = $self->{_chkProfiles}->get_active;    
    updateCommandLine($btn, $self);
    $self->do_it($useProfiles);
}

sub process_out_file
{
    my ($callback, $outfile, $posFile, $negFile, $cntPos, $cntNeg, $self) = @_;
    
    my $outSeqs = new SequencesFile();
    $outSeqs->load($self->{baseDir}.'/'.$outfile);
    
    if( $outSeqs->numSequences > $cntPos + $cntNeg )
    {
        print("WARNING: Number of sequences on out file is greater than the sum of sequences from the positive and negatives files! Continuing...\n");
    }elsif ($outSeqs->numSequences < $cntPos + $cntNeg)
    {
        print("ERROR: Number of sequences on out file is lower than the sum of sequences from the positive and negatives files! Exiting!\n");
        return;
    }
    
    my $posSeqs = new SequencesFile();
    my $negSeqs = new SequencesFile();
    
    my $totSeqs = $cntPos + $cntNeg;
    
    for(my $i = 0; $i < $cntPos; ++$i)
    {
        my %seq = $outSeqs->getSequence($i);
        $posSeqs->addSequence($seq{'header'}, $seq{'seq'}, $seq{'spaces'});
    }
    
    for(my $i = $cntPos; $i < $totSeqs; ++$i)
    {
        my %seq = $outSeqs->getSequence($i);
        $negSeqs->addSequence($seq{'header'}, $seq{'seq'}, $seq{'spaces'});
    }
    
    &{$callback}($posSeqs, $negSeqs);
}

1;

