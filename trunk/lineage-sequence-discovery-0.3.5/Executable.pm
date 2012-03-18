package Executable;

sub is_executable_available
{
  my ($program) = @_;
  my $output = `which $program`;  
  return 1 if(length($output) > 0);
  return 0;
}

sub get_executable_full_path
{
  my ($program) = @_;
  my $output = `which $program`;
  return $output;
}

1;
