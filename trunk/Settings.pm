package Settings;

sub new
{ 
  my ($class, $filename, $defaults) = @_;
  my $self = 
  {   
    data => {}
  };
  
  bless $self, $class;
  
  $self->load($filename, $defaults) if defined($filename);
  
  return $self;
}

sub set
{
  my ($self, $k => $v) = @_;
  $self->{data}{$k} = $v;
}

sub get
{
  my ($self, $k) = @_;
  return $self->{data}{$k};
}

sub load
{
  my ($self, $filename, $defaults) = @_;

  if(defined($defaults)) {
    $self->{data} = $defaults;  
  } else {
    $self->{data} = {};
  }

  return unless(-e $filename);
  
  open $fh, "<$filename";
  while(<$fh>) {
    chomp;
    next if($_ =~ m/^[ \t]*#/);
    if($_ =~ m/^(.*?)=(.*)/) {
      $key = $1;
      $val = $2;
      $self->{data}{$key} = $val;
    }
  }
  close $fh;
} 

sub dump
{
  my ($self) = @_;
  foreach $k (keys %{$self->{data}}){
    print "$k=".$self->{data}{$k}."\n";
  }
}

sub save
{
  my ($self, $filename) = @_;
  
  open $fh, ">$filename";
  foreach $k (keys %{$self->{data}}){
    print $fh ("$k=".$self->{data}{$k}."\n");
  }
  close $fh;
}

sub keys
{
  my ($self) = @_;
  return keys %{$self->{data}};
}

1;

