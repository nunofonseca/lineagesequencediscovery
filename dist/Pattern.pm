#############################################################
#                                                           #
#   Class Name:  Pattern                                    #
#   Description: Represents a pattern for search purposes.  #
#                Holds its name, pattern string and         #
#                statistical data.                          #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################


package Pattern;

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self =
    {
        trainData =>
        {
            numMatchesPos => 0,
            numMatchesNeg => 0,
            recallPos => 0,
            recallNeg => 0,
            precision => 0,
            fMeasure => 0,
            stdDevPos => 0,
            stdDevNeg => 0
        },
        
        testData =>
        {
            numMatchesPos => 0,
            numMatchesNeg => 0,
            recallPos => 0,
            recallNeg => 0,
            precision => 0,
            fMeasure => 0,
            stdDevPos => 0,
            stdDevNeg => 0
        },
        
        name => "",
        pattern => ""
    };
    
    bless $self, $class;
    
    return $self;
}

# Gets/Sets the name that is used to identify this pattern
sub name
{
    my ($self, $newName) = @_;
    $self->{name} = $newName if defined($newName);
    return $self->{name};
}

# Gets/Sets the pattern string
sub pattern
{
    my ($self, $newPattern) = @_;
    $self->{pattern} = $newPattern if defined($newPattern);
    return $self->{pattern};
}

# Gets/Sets the statistical data from the train file.
# Example: my %trainData = %${$pat->trainData};
sub trainData
{
    my ($self, $newTrainData) = @_;
    $self->{trainData} = $newTrainData if defined($newTrainData);
    return \$self->{trainData};
}

# Gets/Sets the statistical data from the test file.
# Example: my %testData = %${$pat->testData};
sub testData
{
    my ($self, $newTestData) = @_;
    $self->{testData} = $newTestData if defined($newTestData);
    return \$self->{testData};
}

sub loadFromString
{
    my ($self, $str) = @_;

    my @splitted;
    if($str =~ m/\t/)
    {
        @splitted = split(/\t/, $str);    
    }else {
        @splitted = split(/ /, $str);
    }

    $self->{name} = $splitted[17];
    $self->{pattern} = $splitted[16];
    
    $self->{trainData}=
    {
        numMatchesPos => $splitted[0],
        numMatchesNeg => $splitted[1],
        recallPos     => $splitted[2],
        recallNeg     => $splitted[3],
        precision     => $splitted[4],
        fMeasure      => $splitted[5],
        stdDevPos     => $splitted[6],
        stdDevNeg     => $splitted[7]
    };
        
    $self->{testData}=
    {
        numMatchesPos => $splitted[8],
        numMatchesNeg => $splitted[9],
        recallPos     => $splitted[10],
        recallNeg     => $splitted[11],
        precision     => $splitted[12],
        fMeasure      => $splitted[13],
        stdDevPos     => $splitted[14],
        stdDevNeg     => $splitted[15]
    };
}

sub toString {
	my $self = shift;
	
	my $res = "";
	
	$res .= $self->{trainData}{numMatchesPos} . " ";
	$res .= $self->{trainData}{numMatchesNeg} . " ";
	$res .= $self->{trainData}{recallPos} . " ";
	$res .= $self->{trainData}{recallNeg} . " ";
	$res .= $self->{trainData}{precision} . " ";
	$res .= $self->{trainData}{fMeasure} . " ";
	$res .= $self->{trainData}{stdDevPos} . " ";
	$res .= $self->{trainData}{stdDevNeg} . " ";

	$res .= $self->{testData}{numMatchesPos} . " ";
	$res .= $self->{testData}{numMatchesNeg} . " ";
	$res .= $self->{testData}{recallPos} . " ";
	$res .= $self->{testData}{recallNeg} . " ";
	$res .= $self->{testData}{precision} . " ";
	$res .= $self->{testData}{fMeasure} . " ";
	$res .= $self->{testData}{stdDevPos} . " ";
	$res .= $self->{testData}{stdDevNeg} . " ";
	
	$res .= $self->{pattern} . " ";
	$res .= $self->{name};
	return $res;
}

sub print
{
    my ($self) = @_;
    
    print("Name: " . $self->{name} . "\n");
    print("Pattern: " . $self->{pattern} . "\n\n");

    %trainData = %{ $self->{trainData} };

    print("Train Data:\n");
    for $f (keys %trainData)
    {
        print("\t$f = " . $trainData{$f} . "\n");
    }

    print("Test Data:\n");
    %testData = %{$self->{testData}};

    for $f (keys %testData)
    {
        print("\t$f => " . $testData{$f} . "\n");
    }
}

1;

