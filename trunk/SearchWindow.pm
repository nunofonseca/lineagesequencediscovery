#############################################################
#                                                           #
#   Class Name:  SearchWindow                               #
#   Description: Creates a window that allows to search for #
#                patterns in sequences being used in a      #
#                SequencesViewer                            #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SearchWindow;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';
use PatternManager;
use ARFF;

#my $strfrmSearchWindow = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class, $seqViewer) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder            => undef,
        _frmSearchWindow    => undef,
        _seqViewer          => $seqViewer,
        _storeAvailablePats => undef,
        _storePosRes        => undef,
        _storeNegRes        => undef,
        _treePosRes         => undef,
        _treeNegRes         => undef,
        _treePatterns       => undef,
        _lblPosCaption      => undef,
        _lblNegCaption      => undef,
        _patterns           => {},
        _statControls       => {}
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmSearchWindow))
    {
        $self->{_builder}->add_from_string($strfrmSearchWindow);
    }else
    {
        $self->{_builder}->add_from_file("frmSearchWindow.glade");
    }
    
    $self->{_frmSearchWindow} = $self->{_builder}->get_object("frmSearchWindow");
    $self->{_storeAvailablePats} = $self->{_builder}->get_object("storeAvailablePatterns");
    $self->{_treePosRes} = $self->{_builder}->get_object("treePositiveRes") or die('couldn\'t find');
    $self->{_treeNegRes} = $self->{_builder}->get_object("treeNegativeRes") or die('couldn\'t find');
    $self->{_treePatterns} = $self->{_builder}->get_object("treePatterns");
    $self->{_storePosRes} = $self->{_builder}->get_object("storePosRes");
    $self->{_storeNegRes} = $self->{_builder}->get_object("storeNegRes");
    $self->{_lblPosCaption} = $self->{_builder}->get_object("lblPosCaption");
    $self->{_lblNegCaption} = $self->{_builder}->get_object("lblNegCaption");
    
    $self->{_builder}->connect_signals();
        
    $self->{_builder}->get_object("btnImportPatterns")->signal_connect(clicked => \&on_btnImportPatterns_clicked, $self);
    $self->{_treePosRes}->get_selection()->signal_connect(changed => \&on_treePosRes_selection_on_changed, $self);
    $self->{_treeNegRes}->get_selection()->signal_connect(changed => \&on_treeNegRes_selection_on_changed, $self);
    $self->{_builder}->get_object("treePatterns")->get_selection()->signal_connect(changed => \&on_treePattern_selection_on_changed, $self);
    
    my %statControlsTrain = 
    (
        numMatchesPos => $self->{_builder}->get_object("lblStatTrainPosMatches"),
        numMatchesNeg => $self->{_builder}->get_object("lblStatTrainNegMatches"),
        recallPos     => $self->{_builder}->get_object("lblStatTrainPosRecall"),
        recallNeg     => $self->{_builder}->get_object("lblStatTrainNegRecall"),
        precision     => $self->{_builder}->get_object("lblStatTrainPrecision"),
        fMeasure      => $self->{_builder}->get_object("lblStatTrainFMeasure"),
        stdDevPos     => $self->{_builder}->get_object("lblStatTrainStdDevPos"),
        stdDevNeg     => $self->{_builder}->get_object("lblStatTrainStdDevNeg")
    );
    
    my %statControlsTest = 
    (
        numMatchesPos => $self->{_builder}->get_object("lblStatTestPosMatches"),
        numMatchesNeg => $self->{_builder}->get_object("lblStatTestNegMatches"),
        recallPos     => $self->{_builder}->get_object("lblStatTestPosRecall"),
        recallNeg     => $self->{_builder}->get_object("lblStatTestNegRecall"),
        precision     => $self->{_builder}->get_object("lblStatTestPrecision"),
        fMeasure      => $self->{_builder}->get_object("lblStatTestFMeasure"),
        stdDevPos     => $self->{_builder}->get_object("lblStatTestStdDevPos"),
        stdDevNeg     => $self->{_builder}->get_object("lblStatTestStdDevNeg")
    );
    
    $self->{_statControls}{'train'}= { %statControlsTrain };
    $self->{_statControls}{'test'} = { %statControlsTest};
        
        
    $self->{_builder}->get_object("cellRendererSearch")->signal_connect(toggled => \&on_pattern_search_toggled, $self);
    $self->{_builder}->get_object("cellRendererNot")->signal_connect(toggled => \&on_pattern_not_toggled, $self);
    
    $self->{_builder}->get_object("btnFindPatterns")->signal_connect(clicked => \&on_btnFindPattern_clicked, $self);
    $self->{_builder}->get_object("btnExportPatterns")->signal_connect(clicked => \&on_btnExportPatterns_clicked, $self);
    
    return $self;
}

sub show
{
    my ($self) = @_;
    $self->{_frmSearchWindow}->show;
}

sub hide
{
    my ($self) = @_;
    $self->{_frmSearchWindow}->hide;
}

sub on_btnImportPatterns_clicked
{
    my ($sender, $self) = @_;
    
    my $diag = Gtk2::FileChooserDialog->new('Choose pat file', $window, 'open', 'Cancel' => 'cancel', 'Open' => 'ok');
    
    if( $diag->run eq 'ok')
    {
        my $filename = $diag->get_filename;
        
        my $patManager = new PatternManager;
        
        if( $filename =~ m/.pat/i )
        {
            $patManager->loadFromPat($filename);
        }else
        {
            return;
        }
        
        my @loadedPats = @{ $patManager->getPatterns() };
        
        $self->{_storeAvailablePats}->clear();
                    
        for $p (@loadedPats)
        {
            my $pat =
            {
                'pattern' => $p,
                'search'  => 0,
                'not'     => 0
            };
 
            $self->{_patterns}{$p->name} = $pat;
            
            my $newrow = $self->{_storeAvailablePats}->append();

            $self->{_storeAvailablePats}->set_value($newrow, 0, $p->name);
            $self->{_storeAvailablePats}->set_value($newrow, 1, $p->pattern);
        }    
    }
    
    $diag->destroy;
    
    return;
}

sub on_treePattern_selection_on_changed
{
    my ($selection, $self) = @_;

    my $model = $self->{_treePatterns}->get_model();
    my $selected = $selection->get_selected();
    
    my $patName = $model->get_value($selected, 0);
    
    return if not defined($self->{_patterns}{$patName});
    
    my %patInfo = %{ $self->{_patterns}{$patName} };
    my $pat = $patInfo{'pattern'};
    
    $self->{_builder}->get_object("lblSeed")->set_text($pat->name);
    $self->{_builder}->get_object("txtPattern")->set_text($pat->pattern);
    
    my %statControls = %{ $self->{_statControls} };
    my %statControlsTrain = %{ $statControls{'train'} };
    my %statControlsTest  = %{ $statControls{'test'} };
    
    my %patStatsTrain = %${$pat->trainData};
    my %patStatsTest = %${$pat->testData};
    
    foreach $k (keys %patStatsTrain)
    {
        $statControlsTrain{$k}->set_text($patStatsTrain{$k});
    }
    
    foreach $k (keys %patStatsTest)
    {
        $statControlsTest{$k}->set_text($patStatsTest{$k});
    }
    
    return;
}

sub on_pattern_search_toggled
{
    my ($cellrenderer, $pathstr, $self) = @_;
    my $iter = $self->{_storeAvailablePats}->get_iter_from_string($pathstr);

    my $patName = $self->{_storeAvailablePats}->get_value($iter, 0);
    return if not defined($self->{_patterns}{$patName});
    
    my %patInfo = %{ $self->{_patterns}{$patName} };

    my $value = $self->{_storeAvailablePats}->get_value($iter, 2);

    $value = !$value;
    
    $self->{_patterns}{$patName}{'search'} = $value;
    
    $self->{_storeAvailablePats}->set($iter, 2 => $value);
}

sub on_pattern_not_toggled
{
    my ($cellrenderer, $pathstr, $self) = @_;
    my $iter = $self->{_storeAvailablePats}->get_iter_from_string($pathstr);
    
    my $patName = $self->{_storeAvailablePats}->get_value($iter, 0);
    return if not defined($self->{_patterns}{$patName});
        
    my $value = $self->{_storeAvailablePats}->get_value($iter, 3);

    $value = !$value;
    
    $self->{_patterns}{$patName}{'not'} = $value;
    
    $self->{_storeAvailablePats}->set($iter, 3 => $value);
}

sub find_matches_on_sequences
{
    my ($self, $seqType, $typeSearch) = @_;
    
    my $pos;
    my $model;
    my $tree;
    
    if($seqType eq 'positive')
    {
        $pos = $self->{_seqViewer}->positiveSequences;
        $model = $self->{_storePosRes};
        $tree = $self->{_treePosRes};
    }else
    {
        $pos = $self->{_seqViewer}->negativeSequences;
        $model = $self->{_storeNegRes};
        $tree = $self->{_treeNegRes};
    }
    
    return if not defined($pos);
    
    my $countPosSequences = $pos->numSequences();
    
        
    # Delete all existing columns
    @columns = $tree->get_columns();
    foreach $column (@columns)
    { $tree->remove_column($column); }
    
    
    my %patternToColumn;
    my $maxPatterns = 0;

    my $renderer2 = Gtk2::CellRendererText->new;
    $tree->insert_column_with_attributes(-1, 'SeqNum', $renderer2, text => 0);
    
    foreach $p (keys %{$self->{_patterns}})
    {
        next if not $self->{_patterns}{$p}{'search'};
        my $renderer = Gtk2::CellRendererText->new;
        ++$maxPatterns;
        $tree->insert_column_with_attributes(-1, $p, $renderer, text => $maxPatterns);
        $patternToColumn{$p} = $maxPatterns;
    }
    
    $renderer2 = Gtk2::CellRendererText->new;
    $tree->insert_column_with_attributes(-1, 'Header', $renderer2, text => $maxPatterns+1);
    
    $renderer2 = Gtk2::CellRendererText->new;
    $tree->insert_column_with_attributes(-1, 'Sequence', $renderer2, text => $maxPatterns+2);
    
    my @tmpList;
    push(@tmpList, Glib::Int);
    
    for $i (1..$maxPatterns)
    { push(@tmpList, Glib::Int); }
    
    push(@tmpList, Glib::String);
    push(@tmpList, Glib::String);
    
    if($seqType eq 'positive')
    {
        $self->{_storePosRes} = Gtk2::TreeStore->new(@tmpList);
        $model = $self->{_storePosRes};
    }else
    {
        $self->{_storeNegRes} = Gtk2::TreeStore->new(@tmpList);
        $model = $self->{_storeNegRes};
    }
    
    $tree->set_model($model);
    
    my $countPatternMatches = 0;
    my $countPatternsWithMatches = 0;
    
    for $i( 0..$countPosSequences-1)
    {
        my %seq = $pos->getSequence($i);
        my $seqStr = $seq{'seq'};
        
        my @matches;
        
        my $consectiveMatches = 0;
        $consectiveMatches = 1 if $typeSearch eq 'and';
        
        foreach $p (keys %{$self->{_patterns}})
        {
            next if not $self->{_patterns}{$p}{'search'};
            
            my $pattern = $self->{_patterns}{$p}{'pattern'}->pattern;
            my $patMatch = ($seqStr =~ m/$pattern/i);
            
            $patMatch = !$patMatch if $self->{_patterns}{$p}{'not'};
            
            if( $typeSearch eq 'and' )
            {
                $consectiveMatches = $consectiveMatches & $patMatch;
                push(@matches, $self->{_patterns}{$p}{'pattern'}->name) if $consectiveMatches;
            }else
            {
                $consectiveMatches = $consectiveMatches | $patMatch;
                push(@matches, $self->{_patterns}{$p}{'pattern'}->name) if $patMatch;
            }
        }
        
        my $matchCount = @matches;
        
        $countPatternMatches += $matchCount;
        
        if($consectiveMatches && $matchCount > 0)
        {
            my $iter = $model->append(undef);
            
            for $j (1..$maxPatterns)
            { $model->set($iter, $j => 0); }
            
            for $p (@matches)
            {
                my $col = $patternToColumn{$p};
                my $val = $model->get($iter, $col);
                ++$val;
                $model->set($iter, $col => $val);
            }
            
            $model->set($iter, 0 => $i+1);
            $model->set($iter, $maxPatterns+1 => $seq{'header'});
            $model->set($iter, $maxPatterns+2 => $seq{'seq'});
            
            ++$countPatternsWithMatches;
        }
    }
    
    if($seqType eq 'positive')
    {
        $self->{_lblPosCaption}->set_text($countPatternMatches . " Matches in " . $countPatternsWithMatches . " Positive Sequences");
    }else
    {
        $self->{_lblNegCaption}->set_text($countPatternMatches . " Matches in " . $countPatternsWithMatches . " Negative Sequences");
    }
}

sub on_btnFindPattern_clicked
{
    my ($sender, $self) = @_;
    
    my $typeSearch = 'or';
    $typeSearch = 'and' if $self->{_builder}->get_object("radAnd")->get_active;
    
    find_matches_on_sequences($self, 'positive', $typeSearch);
    find_matches_on_sequences($self, 'negative', $typeSearch);
}

sub exportPatternsARFF
{
    my ($self, $filename) = @_;
    
    my $outfile = new ARFF;
        
    $outfile->relation("Patterns: stats and search methods");
            
    $outfile->addAttribute('name', 'string');
    $outfile->addAttribute('pattern', 'string');
    
    $outfile->addAttribute('trainnumMatchesPos', 'numeric');
    $outfile->addAttribute('trainnumMatchesNeg', 'numeric');
    $outfile->addAttribute('trainrecallPos', 'numeric');
    $outfile->addAttribute('trainrecallNeg', 'numeric');
    $outfile->addAttribute('trainprecision', 'numeric');
    $outfile->addAttribute('trainfMeasure', 'numeric');
    $outfile->addAttribute('trainstdDevPos', 'numeric');
    $outfile->addAttribute('trainstdDevNeg', 'numeric');
    
    $outfile->addAttribute('testnumMatchesPos', 'numeric');
    $outfile->addAttribute('testnumMatchesNeg', 'numeric');
    $outfile->addAttribute('testrecallPos', 'numeric');
    $outfile->addAttribute('testrecallNeg', 'numeric');
    $outfile->addAttribute('testprecision', 'numeric');
    $outfile->addAttribute('testfMeasure', 'numeric');
    $outfile->addAttribute('teststdDevPos', 'numeric');
    $outfile->addAttribute('teststdDevNeg', 'numeric');
    
    $outfile->addAttribute('search', 'numeric');
    $outfile->addAttribute('not', 'numeric');
    
    for $p (keys %{ $self->{_patterns} })
    {
        next if not $self->{_patterns}{$p}{'search'};
        
        my @data;
        
        push @data, $self->{_patterns}{$p}{'pattern'}->name;
        push @data, $self->{_patterns}{$p}{'pattern'}->pattern;
        
        my %patStatsTrain = %${$self->{_patterns}{$p}{'pattern'}->trainData};
        my %patStatsTest = %${$self->{_patterns}{$p}{'pattern'}->testData};
        
        foreach $k (keys %patStatsTrain)
        {
            push @data, $patStatsTrain{$k};
        }
        
        foreach $k (keys %patStatsTest)
        {
            push @data, $patStatsTest{$k};
        }
        
        push @data, $self->{_patterns}{$p}{'search'};
        push @data, $self->{_patterns}{$p}{'not'};
        
        $outfile->addData([@data]);
    }
    
    $outfile->writeFile($filename);
}

sub exportResultsARFF
{
    my ($self, $filename, $patfilename) = @_;
    
    my $outfile = new ARFF;
    $outfile->relation("Pattern search results");
    
    $outfile->addComment("Positive file: " . $self->{_seqViewer}->positiveFile);
    $outfile->addComment("Negative file: " . $self->{_seqViewer}->negativeFile);
    $outfile->addComment("Patterns file: " . $patfilename);
    
    $outfile->addAttribute('positive', 'numeric');
    
    @columns = $self->{_treePosRes}->get_columns();
    pop @columns;
    pop @columns;
    
    foreach $column (@columns)
    { 
        $outfile->addAttribute($column->get_title, 'numeric');
    }
    
    $outfile->addAttribute('Header', 'string');
    $outfile->addAttribute('Sequence', 'string');
    
    my $model = $self->{_treePosRes}->get_model;
    my $iter = $model->get_iter_first();
    while($iter)
    {
        my @data = (1, $model->get($iter));
        $outfile->addData([@data]);
        $iter = $model->iter_next($iter);
    }
    
    $model = $self->{_treeNegRes}->get_model;
    $iter = $model->get_iter_first();
    while($iter)
    {
        my @data = (0, $model->get($iter));
        $outfile->addData([@data]);
        $iter = $model->iter_next($iter);
    }
                    
    $outfile->writeFile($filename);
}

sub exportResultsCSV
{
    my ($self, $filename, $patfilename) = @_;
    
    open $outfile, ">$filename";
            
    @columns = $self->{_treePosRes}->get_columns();
    
    printf $outfile ("Positive file:,%s\n", $self->{_seqViewer}->positiveFile);
    printf $outfile ("Negative file:,%s\n", $self->{_seqViewer}->negativeFile);    
    printf $outfile ("Patterns file:,%s\n\n", $patfilename);  
    
    my $columnsHeader = ",";
    foreach $column (@columns)
    { 
        $columnsHeader .= "," . $column->get_title;
    }
    
    print $outfile (",,Positive Matches\n");
    print $outfile ("$columnsHeader\n");
        
    my $model = $self->{_treePosRes}->get_model;
    my $iter = $model->get_iter_first();
    while($iter)
    {
        my $out = ",";
        my @data = $model->get($iter);
        foreach $val (@data) { $out .= "," . $val; }
        print $outfile ("$out\n");
        $iter = $model->iter_next($iter);
    }
    
    print $outfile ("\n,,Negative Matches\n");
    print $outfile ("$columnsHeader\n");
    
    $model = $self->{_treeNegRes}->get_model;
    $iter = $model->get_iter_first();
    while($iter)
    {
        my $out = ",";
        my @data = $model->get($iter);
        foreach $val (@data) { $out .= "," . $val; }
        print $outfile ("$out\n");
        $iter = $model->iter_next($iter);
    }
    
    print $outfile ("\n");
                    
    close $outfile;
}

sub on_btnExportPatterns_clicked
{
    my ($sender, $self) = @_;
    
    my $diag = Gtk2::FileChooserDialog->new('Choose ARFF location', $window, 'save', 'Cancel' => 'cancel', 'Export' => 'ok');

    if( $diag->run eq 'ok')
    {
        my $filename = $diag->get_filename;
        $diag->destroy;
        
        if($filename =~ m/(.+)\.arff$/i)
        {
            my $basename = $1;
            $self->exportPatternsARFF($basename . ".pat.arff");
            $self->exportResultsARFF($filename, $basename . ".pat.arff");
            SequencesViewer::info("ARFF exportation successful!");
        }elsif($filename =~ m/(.+)\.csv$/i)
        {
            my $basename = $1;
            $self->exportPatternsARFF($basename . ".pat.arff");
            $self->exportResultsCSV($filename, $basename . ".pat.arff");
            SequencesViewer::info("CSV exportation successful!");
        }else
        {
            SequencesViewer::error("Invalid extension! Valid extensions: arff, csv.");
        }
    }else
    { $diag->destroy; }
        
    
    return;
}

sub on_treePosRes_selection_on_changed
{
    my ($selection, $self) = @_;
    my ($model, $selected) = $selection->get_selected();  
    
    return if not defined($model) or not defined($selected);
    
    my $seqNum = $model->get_value($selected, 0) - 1;
    
    $self->{_seqViewer}->jumpToLine('pos', $seqNum);
    
}

sub on_treeNegRes_selection_on_changed
{
    my ($selection, $self) = @_;
    my ($model, $selected) = $selection->get_selected();  
    
    return if not defined($model) or not defined($selected);
    
    my $seqNum = $model->get_value($selected, 0) - 1;
    
    $self->{_seqViewer}->jumpToLine('neg', $seqNum);
}

1;

