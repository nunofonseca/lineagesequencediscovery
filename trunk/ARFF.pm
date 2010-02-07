#############################################################
#                                                           #
#   Class Name:  ARFF                                       #
#   Description: Creates and reads file in the              #
#                Attribute-Relation File Format.            #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package ARFF;

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        relation => "",
        attributes => [],
        data => [],
        comments => []
    };
    
    bless $self, $class;
    
    return $self;
}

# Get/Set the relation
sub relation
{
    my ($self, $index) = @_;
    $self->{relation} = $index if defined($index);
    return $self->{relation};
}

sub addAttribute
{
    my ($self, $attribName, $attribType) = @_;
    
    my $attrib = {};
    
    $attrib->{'name'} = $attribName;
    $attrib->{'type'} = $attribType;
    
    push @{ $self->{attributes} }, $attrib;
    return;
}

sub addComment
{
    my ($self, $cmt) = @_;   
    push @{ $self->{comments} }, $cmt;
    return;
}

sub addData
{
    my $self = shift;
    
    if(@_)
    {
        my @datalist = @_;
        push @{ $self->{data} }, @datalist;
    }
    
    return;
}

sub getAttributes
{
    my($self) = @_;
    return $self->{attributes};
}

sub readFile
{
    my ($self, $filename) = @_;
    
    if(not defined($filename))
    { 
        warn("Please indicate an input filename!");
        return;
    }
    
    if(not -e $filename)
    {
        warn("File $filename doesn't exist!\n");
        return;
    }
        
    open($fh, "<$filename");
    
    if(! $fh)
    {
        warn("Error opening file: $filename\n");
        return;
    }
    
    $self->relation("");
    $self->{attributes} = [];
    $self->{data} = [];
    
    my $dataMode = 0;        
    
    while(defined($_ = <$fh>))
    {
        chomp($_);
        
        next if( /^( )*#/ );
        
        if( m{\@relation (\w+)}i )
        {
            $self->relation($1);
        }elsif( m{\@attribute (\w+) (\w+)}i )
        {
            $self->addAttribute($1, $2);
        }elsif( m{\@data}i )
        {
            $dataMode = 1;
        }else
        {
            next if($dataMode != 1);
            my @dataItems = split /,/, $_;
            $self->addData([@dataItems]);
        }
    }
    
    close($fh);
    
    return;
}

sub writeFile
{
    my ($self, $filename) = @_;
    
    if(not defined($filename))
    { 
        warn("Please indicate an output filename!");
        return;
    }
    
    open($fh, ">$filename");
    
    if(not $fh)
    {
        warn("Error opening file: $filename\n");
        return;
    }
    
    # Write comments
    my @cmts = @{ $self->{comments} };
    
    for $a (@cmts)
    {     
        printf $fh ("%% %s\n", $a);
    }
        
    # Write relation
    printf $fh ("\n\@RELATION %s\n\n", $self->{relation});
    
    # Write attributes
    my @attribs = @{ $self->{attributes} };
    
    for $a (@attribs)
    {
        my $name = $a->{'name'};
        my $type = $a->{'type'};
        
        printf $fh ("\@ATTRIBUTE %s %s\n", $name, $type);
    }
    
    # Write data
    print $fh ("\n\@DATA\n");
    my @data = @{ $self->{data} };
    my $colCount = 0;
    my $maxCols = @attribs;
    
    for $d (@data)
    {
        for $f (@$d)
        {
            print $fh ("$f");
            if (++$colCount >= $maxCols)
            {
                $colCount = 0;
                print $fh ("\n");
            }else
            {
                print $fh (",");
            }
        }     
    }

    print $fh ("\n");

    close($fh);
    
    return;
}

1;


