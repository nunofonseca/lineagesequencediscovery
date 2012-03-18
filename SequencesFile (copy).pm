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

# Accessor fileName (get)
sub fileName
{
    my ($self) = @_;
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
    my $len = length($seq);
    
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
    my ($self, $fileName) = @_;
    
    # Exit if no filename is given
    return if not defined($fileName);
    
    my @seqs = ();
    my $numseqs = 0;
    
    my $in;

    eval
    {    
        $in = Bio::SeqIO->new( -file => $fileName );
        $in = Bio::AlignIO->new( -file => $fileName);

    };


    if( $@ )
    {
        warn("Couldn't open file: " . $fileName);
        return undef;
    }
    
    my $largestLen = 0;
    
    while( my $seq = $in->next_seq )
    {
        $numseqs++;
        
        my $len = length($seq->id);
        $largestLen = $len if( $len > $largestLen );
        
        my %tmpSeq = processSpaces($seq->seq);
        
        my %tmp = ( 'header' => $seq->id,
                    'seq'    => $tmpSeq{'seq'},
                    'spaces' => [ $tmpSeq{'spaces'} ] );
        
        push(@seqs, {%tmp});
    }
    
    $self->{_numSequences} = $numseqs;
    @{$self->{_sequences}} = @seqs;
    $self->{_fileName}     = $fileName;
    $self->{_maxHeaderLen} = $largestLen;
    
    return $self;
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


1;

