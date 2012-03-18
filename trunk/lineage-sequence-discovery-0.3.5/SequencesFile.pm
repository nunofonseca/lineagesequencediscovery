#############################################################
#                                                           #
#   Class Name:  SequencesFile                              #
#   Description: Represents a set of sequences that were    #
#                loaded from a file.                        #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SequencesFile;

use Bio::Seq;
use Bio::SeqIO;
use Bio::AlignIO;
use Bio::Root::Exception;

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        _fileName => "",
        _sequences => [],
        _numSequences => 0,
        _maxHeaderLen => 0
    };
    
    bless $self, $class;
    return $self;
}

# Accessor maxHeaderLength (get)
sub maxHeaderLength
{
    my ($self) = @_;
    return $self->{_maxHeaderLen};
}

# Accessor fileName (get/set)
sub fileName
{
    my ($self, $filename) = @_;
    $self->{_fileName} = $filename if defined($filename);
    return $self->{_fileName};
}

# Accessor numSequences (get)
sub numSequences
{
    my ($self) = @_;
    return $self->{_numSequences};
}

sub processSpaces
{
    my $seq = shift;
    my @spaces;
    
    my $cleanSeq = "";
    my $len = length($seq)-1;
    
    my $startOfTheRun = 0;
    my $onTheRun = 0;  
    
    for $i (0..$len)
    {   
        my $char = substr($seq, $i, 1);
        if( $char =~ m/[A-Z]/i )
        {
            $cleanSeq .= $char;
            if($onTheRun > 0)
            {
                my @tmp = [$startOfTheRun, $onTheRun];
                push(@spaces, @tmp);
                $startOfTheRun = 0;
                $onTheRun = 0;
            }
        }else
        {
            ++$onTheRun;
            $startOfTheRun = $i if($startOfTheRun == 0);
        }
    }
    
    if($onTheRun > 0)
    {
        my @tmp = [$startOfTheRun, $onTheRun];
        push(@spaces, @tmp);
        $startOfTheRun = 0;
        $onTheRun = 0;
    }
    
    my %ret = ( 'seq' => $cleanSeq,
                'spaces' => [@spaces] );
    
    return %ret;
}

# Load a file. Uses BioPerl to load the file. File format is determined automatically by BioPerl
sub load
{
    my ($self, $fileName, $progressHandler) = @_;
    
    # Exit if no filename is given
    return if not defined($fileName);
    
    my @seqs = ();
    my $numseqs = 0;
    
    my $in;

    eval
    {    
        #$in = Bio::SeqIO->new( -file => $fileName );
        $in = Bio::AlignIO->new( -file => $fileName);
    };

    if( $@ )
    {
        print("Couldn't open file: " . $fileName);
        return undef;
    }
    
    my $largestLen = 0;
    
    while(my $aln = $in->next_aln)
    {
        for my $seq ($aln->each_seq)
        {
            $numseqs++;
            
            my $len = length($seq->id);
            $largestLen = $len if( $len > $largestLen );
            
            my %tmpSeq = processSpaces($seq->seq);
            
            my %tmp = ( 'header' => $seq->id,
                        'desc'   => $seq->desc,
                        'seq'    => $tmpSeq{'seq'},
                        'spaces' => $tmpSeq{'spaces'} );
                        
            push(@seqs, {%tmp});
            
            &$progressHandler() if ($numseqs % 50 == 0) and defined($progressHandler);
        }
    }
    
    $self->{_numSequences} = $numseqs;
    @{$self->{_sequences}} = @seqs;
    $self->{_fileName}     = $fileName;
    $self->{_maxHeaderLen} = $largestLen;
    
    return $self;
}

sub save
{
    my ($self, $outFile) = @_;
    
    open $out, ">$outFile";
    
    for(my $i = 0; $i < $self->{_numSequences}; ++$i)
    {
        my %seq = $self->getSequence($i);
        my @spaces = @{$seq{'spaces'}};
        
        my $totalseq = $seq{'seq'};
        
        for $sp (@spaces) {
            my ($start, $count) = @{$sp};
            substr($totalseq, $start, 0) = ('-' x $count);
        }
        
        print $out (">" . $seq{'header'} . "\n" . $totalseq . "\n");
    }
    
    close $out;
}

# Returns a sequence by index (zero-based)
sub getSequence
{
    my ($self, $index) = @_;
    return if not defined($index);
    
    my $seqsPointer = \@{$self->{_sequences}};
    my @seqs = @$seqsPointer;
    my %seq = %{ $seqs[$index] };

    return %seq;
}

sub addSequence
{
    my ($self, $header, $seq, @spaces) = @_;

    $self->{_numSequences}++;
    
    my $len = length($header);
    $self->{_maxHeaderLen} = $len if( $len > $self->{_maxHeaderLen} );
    
    if(@spaces)
    {
        my %tmp = ( 'header' => $header,
                    'desc'   => '',
                    'seq'    => $seq,
                    'spaces' => @spaces );
        
        push(@{$self->{_sequences}}, {%tmp});
    }else
    {
        my %tmpSeq = processSpaces($seq);
        
        my %tmp = ( 'header' => $header,
                    'desc'   => '',
                    'seq'    => $tmpSeq{'seq'},
                    'spaces' => $tmpSeq{'spaces'} );
        
        push(@{$self->{_sequences}}, {%tmp});
    }
}

1;

