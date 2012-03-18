package SearchEngine;
use FuzzySearch qw(amatch setup_amatch);

sub fuzzy_search_is_possible
{
  my $pat = shift;
  return not $pat =~ m/[\.\*\?\+]/i;
}

sub setup_search
{
  my ($pat, $type, $s) = @_;
  my %settings;
  %settings = %{$s} if defined($s);
  
  $type = 'regex' if($type eq 'fuzzy' and not fuzzy_search_is_possible($pat));
  
  my %ret;
  $ret{'type'} = $type;

  if($type eq 'fuzzy') {  
    my $max_mismatches = undef;
    $max_mismatches = $settings{'max_mismatches'} if exists($settings{'max_mismatches'});
    $ret{'fuzzy_settings'} = [FuzzySearch::setup_amatch($pat, $max_mismatches)];
  } elsif($type eq 'regex') {
    my @regex_settings;
    $regex_settings[0] = $pat;
    $ret{'regex_settings'} = [@regex_settings];
  }
  
  return %ret;
}

sub search
{
  my ($s, $str) = @_;
  return unless defined($s) and defined($str);
  my %settings = %{$s};
  my $type = $settings{'type'};
  
  if($type eq 'fuzzy') {  
    my @amatch_settings = $settings{'fuzzy_settings'};
    return FuzzySearch::amatch(@amatch_settings, $str);
  } elsif($type eq 'regex') {
    my @regex_settings = @{$settings{'regex_settings'}};
    my $pat = $regex_settings[0];
    my @matches;
    
    my $patMatch = 0;
    
    do {
      $patMatch = $str =~ m/$pat/gi;
      my $strMatched = $&;
      
      if($patMatch > 0 and defined($strMatched))
      {
        my $endPosition   = pos($str);
        my $startPosition = $endPosition - length($strMatched);
        my %match = ( "start" => $startPosition,
                      "end" => $endPosition,
                      "match" => $strMatched,
                      "mismatches" => [] );
        push @matches, \%match;
      }
    } while($patMatch > 0);
    
    my %res = ( "num_matches" => scalar @matches, 
                "matches" => \@matches ); 
    return %res;
  }
}

sub dump_matches
{
  my $r = shift;
  my $txt = shift;
  my %res = %{$r};
  
  return if not defined($res{"num_matches"}) or not defined($res{"matches"});
  
  print "Num matches: " . $res{"num_matches"} . "\n";
  my @matches = @{$res{"matches"}};

  foreach $m (@matches) {
    my %match = %{$m};
    print "Start: " . $match{"start"} . "\n";
    print "End: " . $match{"end"} . "\n";
    print "Text: " . $match{"match"} . "\n";
    print "Mismatches: \n";
    my @mismatches = @{$match{"mismatches"}};
    foreach $index (@mismatches) {
      print "    at position $index: ". substr($txt, $index, 1) ."\n";
    }
    print "\n";
  }
}

1;

