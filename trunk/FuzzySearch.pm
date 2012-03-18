package FuzzySearch;

sub compile_pattern
{
  my ($pat) = @_;
  
  my %compiled_pat;
  
  $compiled_pat{'mismatches'} = 0;
  $compiled_pat{'pattern'} = $pat;
  $compiled_pat{'table'} = ();
  $compiled_pat{'word-length'} = 0;
  
  my $current_state = 0;
  my $brackets = 0;
  
  for(my $i = 0; $i < length($pat); ++$i) {
    my $c = substr($pat, $i, 1);
    if($c eq '[') {
      ++$brackets;
    } elsif($c eq ']') {
      --$brackets;
    } else {
      $compiled_pat{'table'}[$current_state] = {} unless exists($compiled_pat{'table'}[$current_state]);
      $compiled_pat{'table'}[$current_state]{$c} = $current_state + 1;
    }
    
    unless($brackets > 0) {
      ++$current_state;
      ++$compiled_pat{'word-length'};
    }
  }
  
  return %compiled_pat;
}

sub setup_amatch
{
  my ($pattern, $max_mismatches) = @_;
  my %pat = compile_pattern(lc $pattern);
  
  $max_mismatches = '15%' unless defined($max_mismatches); # default to 15%
   
  if($max_mismatches =~ m/([0-9\.]+)%/) {
    my $perc = $1;
    $perc /= 100.0;
    $max_mismatches = int($pat{'word-length'} * $perc);
  }
  
  my @res = ( \%pat, $max_mismatches );
  return @res;
}

sub amatch_full
{
  my ($pattern, $str, $max_mismatches) = @_;
  my @settings = setup_amatch($pattern, $max_mismatches);
  return amatch(\@settings, $str);
}

sub amatch
{
  my ($s, $str) = @_;
  $str = lc($str);
  my @settings = @{$s};
  my %pat = %{$settings[0]};
  my $max_mismatches = $settings[1];

  #print "Max mismatches: $max_mismatches\n";
  
  my @table = @{$pat{'table'}};
  my $num_states = scalar @table;
  
  my $current_state = 0;
  my %current_state_entries = %{$table[$current_state]};
  
  my $num_matches = 0;
  my @matches = ();
  my @mismatches = ();
    
  for(my $j = 0; $j < length($str); ++$j ) {
    $pat{'mismatches'} = 0;
    @mismatches = ();
    $current_state = 0;
    %current_state_entries = %{$table[$current_state]};
        
    for(my $i = $j; $i < length($str); ++$i ) {
      my $c = substr($str, $i, 1);
      #print "c: $c, cur_s: $current_state, ";
      if(exists $current_state_entries{$c}) {
        #print "match!, ";
        $current_state = $current_state_entries{$c};
        if($current_state >= $num_states) {
          #print "end!\n";
          my %match = ( "start" => $j,
                        "end" => $i,
                        "match" => substr($str, $j, $i - $j + 1),
                        "mismatches" => [ @mismatches ] );
                        
          push @matches, \%match;
          $j = $i;
          ++$num_matches;
          last;
        } else {
          %current_state_entries = %{$table[$current_state]};
        }
        #print "next_state: $current_state\n";
      } else {
        #print "mismatch!\n";
        ++$pat{'mismatches'};
        if($pat{'mismatches'} > $max_mismatches) {
          last;
        } else {
          push @mismatches, $i;
          ++$current_state;
          if($current_state >= $num_states) {
            #print "end!\n";
            my %match = ( "start" => $j,
                          "end" => $i,
                          "match" => substr($str, $j, $i - $j + 1),
                          "mismatches" => [ @mismatches ] );
                        
            push @matches, \%match;
            $j = $i;
            ++$num_matches;
            last;
          }
          %current_state_entries = %{$table[$current_state]};
        }
      } 
    }
  }

  my %res = ( "num_matches" => $num_matches, 
              "matches" => \@matches );

  return %res;
}

1;

