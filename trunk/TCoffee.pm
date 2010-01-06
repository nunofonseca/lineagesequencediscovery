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

use RunCommand;
use SequencesFile;

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
        fileToAlign           => "",
        posFile               => "",
        negFile               => "",
        cntPos                => 0,
        cntNeg                => 0,
        callback              => undef
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
    
    $self->{_builder}->get_object("btnStartRegular")->signal_connect(clicked => \&on_btnStartRegular_clicked, $self);
    $self->{_builder}->get_object("btnStartAdvanced")->signal_connect(clicked => \&on_btnStartAdvanced_clicked, $self);
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

sub alignFile
{
    my ($self, $file, $posFile, $negFile, $cntPos, $cntNeg, $onDone) = @_;
    $self->{fileToAlign} = $file;
    $self->{posFile} = $posFile;
    $self->{negFile} = $negFile;
    $self->{cntPos} = $cntPos;
    $self->{cntNeg} = $cntNeg;
    $self->{callback} = $onDone;
    $self->{_frmTCoffee}->show();
}

sub on_btnStartRegular_clicked
{
    my ($btn, $self) = @_;

    my $useProfiles = $self->{_chkProfiles}->get_active;

    my %params = ('mode'    => lc($self->{_builder}->get_object("cmbRegularComputationMode")->get_active_text),
                  '-maxnseq' => $self->{_builder}->get_object("spinRegularMaxNumSequences")->get_value,
                  '-maxlen'  => $self->{_builder}->get_object("spinMaximumLengthSequences")->get_value
                  );

    if($useProfiles)                     
    {
        my $cmd = 't_coffee ';
        my $outfile = '"' . $self->{negFile} . '"';        
        $cmd .= $outfile;
        for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }        
        $cmd .= ' -outfile=\'negfile.aln\' 2>&1';
        
        print("Running: $cmd\n");
        
        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd,
        sub {
        
            $cmd = 't_coffee ';
            $outfile = '"' . $self->{posFile} . '"';   
            $cmd .= $outfile;
            $cmd .= ' -profile \'negfile.aln\' -outfile=\'out.aln\' 2>&1';
            print("Running: $cmd\n");
            $runcmd = new RunCommand;
            $runcmd->runCommand($cmd,  sub { $self->{_frmTCoffee}->destroy(); process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); });
        });
        
    }else
    {
        my $cmd = 't_coffee ';
        my $outfile = '"' . $self->{fileToAlign} . '"';

        $cmd .= $outfile;

        for my $k (keys %params)
        {
            $cmd .= ' ' . $k . ' ' . $params{$k};
        }
        
        $cmd .= ' 2>&1';

        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd, sub { $self->{_frmTCoffee}->destroy(); process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); });
    }
}

sub process_out_file
{
    my ($callback, $outfile, $posFile, $negFile, $cntPos, $cntNeg, $self) = @_;
    
    my $outSeqs = new SequencesFile();
    $outSeqs->load($outfile);
    
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

sub on_btnStartAdvanced_clicked
{
    my ($btn, $self) = @_;
}

1;

