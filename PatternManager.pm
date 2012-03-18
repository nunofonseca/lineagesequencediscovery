#############################################################
#                                                           #
#   Class Name:  PatternManager                             #
#   Description: Loads pat files, exports to ARFF           #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################


package PatternManager;

use Pattern;

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        patterns => []
    };
    
    bless $self, $class;
        
    return $self;
}

sub loadFromPat
{
    my ($self, $filename) = @_;
    
    if( not -e $filename )
    {
        warn("File $filename doesn't exist!\n");
        return;
    }
    
    open($fh, "<$filename");
    
    while(defined($_ = <$fh>))
    {
        chomp($_);
        my $pat = new Pattern;
        $pat->loadFromString($_);
        push @{ $self->{patterns} }, $pat;
    }
    
    close($fh);
}

sub getPatterns
{
    my ($self) = @_;
    return \@{ $self->{patterns} };
}

1;

