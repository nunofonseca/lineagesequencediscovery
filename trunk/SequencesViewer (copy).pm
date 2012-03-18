#############################################################
#                                                           #
#   Class Name:  SequencesViewer                            #
#   Description: Creates a window that allows to show two   #
#                SequencesFile's side by side.              #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SequencesViewer;

use SequencesFile;
use NewSessionDialog;
use SearchWindow;
use TCoffee;
use Glib qw/TRUE FALSE/;
use Gtk2::SourceView;
use Gtk2::Helper;
use Gtk2 '-init';
use Cwd qw(realpath);
use File::Basename;

#my $strfrmSequencesViewer = "REPLACE_HERE";

my $basePath = dirname(realpath(__FILE__));

my $patternPixBufFile  = "/usr/share/pixmaps/apple-green.png";
my $defaultfont = "mono 10";
my $font = undef;
my $headerbackcolor    = "#7B68EE";
my $headerforecolor    = "#FFFFFF";

my $viewerCounter = 0;

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # The sequence files
        _posFile => undef,
        _negFile => undef,
        
        # GTK libbuilder stuff
        _builder            => undef,
        _frmSequencesViewer => undef,
        _txtPosFile         => undef,
        _txtNegFile         => undef,
        _bufferPos          => undef,      
        _bufferNeg          => undef,
        
        # The search window
        _searchWindow => undef,
        
        # Change the display orientation
        _mainPan => undef,
        
        # Flags
        _showHeaders  => 1,
        _showSequence => 1,
        _showAligned  => 1
    };
    
    bless $self, $class;
    return $self;
}

#################### METHODS ##################

# Initialize all necessary stuff
sub init
{
    my ($self) = @_;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmSequencesViewer))
    {
        $self->{_builder}->add_from_string($strfrmSequencesViewer);
    }else
    {
        $self->{_builder}->add_from_file("frmSequencesViewer.glade");
    }

    $self->{_frmSequencesViewer} = $self->{_builder}->get_object("frmSequencesViewer");
    
    $font = Gtk2::Pango::FontDescription->from_string($defaultfont);
    
    my $markerPixBuf = Gtk2::Gdk::Pixbuf->new_from_file($patternPixBufFile);
    
    # Hack for adding a sourceview widget
    my $scrollPosFile = $self->{_builder}->get_object("scrollPosFile");
    $self->{_bufferPos} = Gtk2::SourceView::Buffer->new(undef);
    $self->{_txtPosFile} = Gtk2::SourceView::View->new_with_buffer($self->{_bufferPos});
    $scrollPosFile->add($self->{_txtPosFile});
    addStyleTags($self->{_bufferPos});
    $self->{_txtPosFile}->set_marker_pixbuf('patternmatch', $markerPixBuf);
    $self->{_txtPosFile}->set_show_line_numbers(1); 
    $self->{_txtPosFile}->set_show_line_markers(1);
    $self->{_txtPosFile}->set_editable(1);
    $self->{_txtPosFile}->modify_font($font);
    $self->{_txtPosFile}->show();
        
    # Hack for adding a sourceview widget    
    my $scrollNegFile = $self->{_builder}->get_object("scrollNegFile");
    $self->{_bufferNeg} = Gtk2::SourceView::Buffer->new(undef);
    $self->{_txtNegFile} = Gtk2::SourceView::View->new_with_buffer($self->{_bufferNeg});
    $scrollNegFile->add($self->{_txtNegFile});    
    addStyleTags($self->{_bufferNeg});
    $self->{_txtNegFile}->set_marker_pixbuf('patternmatch', $markerPixBuf);
    $self->{_txtNegFile}->set_show_line_numbers(1);
    $self->{_txtNegFile}->set_show_line_markers(1);
    $self->{_txtNegFile}->set_editable(1);
    $self->{_txtNegFile}->modify_font($font);
    $self->{_txtNegFile}->show();
    
    $self->{_builder}->connect_signals();
    
    # Connect signals
    
    $self->{_builder}->get_object("mnuNewSession")->signal_connect( activate => \&on_mnuNewSession_activate, $self);
    $self->{_builder}->get_object("mnuExportToHTML")->signal_connect( activate => \&on_mnuExportToHTML_activate, $self);
    $self->{_builder}->get_object("mnuShowHeaders")->signal_connect( toggled => \&on_mnuShowHeaders_toggled, $self);
    $self->{_builder}->get_object("mnuShowSequences")->signal_connect( toggled => \&on_mnuShowSequences_toggled, $self);
    $self->{_builder}->get_object("mnuShowAligned")->signal_connect( toggled => \&on_mnuShowAligned_toggled, $self);
    $self->{_builder}->get_object("mnuAlignSequences")->signal_connect( activate => \&on_mnuAlignSequences_activate, $self);
    $self->{_builder}->get_object("mnuShowSearchWindow")->signal_connect( toggled => \&on_mnuShowSearchWindow_toggled, $self);
    $self->{_builder}->get_object("mnuHorizontal")->signal_connect( toggled => \&on_mnuHorizontal_toggled, $self);
    
    $self->{_mainPan} = $self->{_builder}->get_object("mainPan");
    
    $self->{_searchWindow} = new SearchWindow($self);
    
    ++$viewerCounter;
}

# Show the viewer
sub show
{
    my ($self) = @_;
    $self->{_frmSequencesViewer}->show();
}

# Show form and give control to the viewer
sub run
{
    my ($self) = @_;
    $self->show();
    Gtk2->main();
}

sub jumpToLine
{
    my ($self, $view, $line) = @_;
    
    if($view eq 'pos')
    {
        $textview = $self->{_txtPosFile};
    }else
    {
        $textview = $self->{_txtNegFile};
    }
    
    my ($iter, $linetop) = $textview->get_buffer()->get_iter_at_line($line);
    $textview->scroll_to_iter($iter, 0, 1, 0.0, 0.0);    
    $textview->place_cursor_onscreen();
}

sub putSequenceOnBuffer
{
    my ($self, $seqfile, $i, $buffer, $iter) = @_;

    my %seq = $seqfile->getSequence($i);
        
    if( $self->{_showHeaders} )
    {
        my $maxHeaderLen = $seqfile->maxHeaderLength();
        my $header = $seq{'header'};
        my $sizeDiff = $maxHeaderLen - length($header);
        
        for(my $j = 0; $j < $sizeDiff; ++$j)
        { $header .= " "; }
        
        $buffer->insert_with_tags_by_name($iter, $header, ('seqheader') );
        $buffer->insert($iter, " ");
    }
    
    my $offset = 0;
    $offset = $maxHeaderLen if $self->{_showHeaders};
    
    if( $self->{_showSequence} )
    {
        my $tmpIter = $iter;
        $buffer->insert($iter, $seq{'seq'});
    }
    
    $buffer->insert($iter, "\n");
    
    return $iter;
}

sub putSequenceSpacesOnBuffer
{
    my ($self, $seqfile, $i, $buffer, $iter) = @_;
    return if not $self->{_showAligned} or not $self->{_showSequence};
    
    my %seq = $seqfile->getSequence($i);

    my $offset = 0;
    $offset = $seqfile->maxHeaderLength() if $self->{_showHeaders};
    
    my $tmpIter = $buffer->get_iter_at_line($i);
    
    my $len = @{$seq{'spaces'}}-1;
    for $p (0..$len)
    {
        my $start = (@{$seq{'spaces'}}[$p])[0][0] + 1;
        my $count = (@{$seq{'spaces'}}[$p])[0][1];

        $tmpIter->set_line_offset($offset + $start);
        $buffer->insert($tmpIter, '-' x $count);
    }
}

sub showSequencesOnBuffer
{
    my ($self, $seqfile, $buffer) = @_;
    
    clearBuffer($buffer);
    
    my $maxHeaderLen = $seqfile->maxHeaderLength();
    my $numSeqs = $seqfile->numSequences();
    
    # Get start iterator of the text buffer
    my $startIter = $buffer->get_start_iter();
    
    for(my $i = 0; $i < $numSeqs; ++$i)
    {
        my %seq = $seqfile->getSequence($i);
        
        if( $self->{_showHeaders} )
        {
            my $header = $seq{'header'};
            my $sizeDiff = $maxHeaderLen - length($header);
            
            for(my $j = 0; $j < $sizeDiff; ++$j)
            { $header .= " "; }
            
            $buffer->insert_with_tags_by_name($startIter, $header, ('seqheader') );
            $buffer->insert($startIter, " ");
        }
        
        my $offset = 0;
        $offset = $maxHeaderLen if $self->{_showHeaders};
        
        if( $self->{_showSequence} )
        {
            my $tmpIter = $startIter;
            $buffer->insert($startIter, $seq{'seq'});
            
            if($self->{_showAligned})
            {
                my $len = @{$seq{'spaces'}}-1;
                for $p (0..$len)
                {
                    my $start = (@{$seq{'spaces'}}[$p])[0][0] + 1;
                    my $count = (@{$seq{'spaces'}}[$p])[0][1];
                    
                    my $whereIter = $tmpIter;
                    $tmpIter->set_line_offset($offset + $start);
                    $buffer->insert($tmpIter, '-' x $count);
                }
            }
        }
        
        $buffer->insert($startIter, "\n");    
    }
}

sub clearMatches
{
    my ($self) = @_;
    
    $self->{_bufferPos}->remove_tag_by_name('selectedseq', $self->{_bufferPos}->get_start_iter, $self->{_bufferPos}->get_end_iter);
    $self->{_bufferNeg}->remove_tag_by_name('selectedseq', $self->{_bufferNeg}->get_start_iter, $self->{_bufferNeg}->get_end_iter);
    
    my @markers = $self->{_bufferPos}->get_markers_in_region($self->{_bufferPos}->get_start_iter, $self->{_bufferPos}->get_end_iter);
    foreach $marker (@markers)
    {
        if( $marker->get_marker_type eq 'patternmatch' )
        { $self->{_bufferPos}->delete_marker($marker); }
    }
    
    @markers = $self->{_bufferNeg}->get_markers_in_region($self->{_bufferNeg}->get_start_iter, $self->{_bufferNeg}->get_end_iter);
    foreach $marker (@markers)
    {
        if( $marker->get_marker_type eq 'patternmatch' )
        { $self->{_bufferNeg}->delete_marker($marker); }
    }
}

sub addMatchMarker
{
    my ($self, $buffer, $seqPos, $startPosition, $endPosition) = @_;
    
    if( $buffer eq 'positive' )
    {
        my $lineIter = $self->{_bufferPos}->get_iter_at_line($seqPos);
        my $lineIterEnd = $self->{_bufferPos}->get_iter_at_line($seqPos);
        $lineIterEnd->forward_to_line_end;
        $self->{_bufferPos}->create_marker(undef, 'patternmatch', $lineIter);
    }else
    {
        my $lineIter = $self->{_bufferNeg}->get_iter_at_line($seqPos);
        $self->{_bufferNeg}->create_marker(undef, 'patternmatch', $lineIter);
        
        if(defined($startPosition) and defined($endPosition))
        {        
            my %seq = $self->{_negFile}->getSequence($seqPos);
            
            $lineIterEnd = $self->{_bufferNeg}->get_iter_at_line($line);
            $lineIterEnd->forward_to_line_end;
            $self->{_bufferNeg}->delete($lineIter, $lineIterEnd);
            
            $self->{_bufferNeg}->insert($lineIter, $seq{'seq'});
            
            

            
            $lineIter->set_line_offset($startPosition);
                        $lineIterEnd->set_line_offset($endPosition);            
            $self->{_bufferNeg}->apply_tag_by_name('patternmatch', $iterStart, $iterEnd);
        }
    }
    
    
}


#################### END OF METHODS ##################

############## ACCESSORS ####################

sub positiveSequences
{
    my ($self) = @_;
    return $self->{_posFile};
}

sub negativeSequences
{
    my ($self) = @_;
    return $self->{_negFile};
}

# Accessor positive file
sub positiveFile
{
    my ($self, $filename) = @_;
    
    if( defined($filename) )
    {
        $self->{_posFile} = new SequencesFile();
        $self->{_posFile}->load($filename);
        $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos});
    }
    
    return $self->{_posFile} ? $self->{_posFile}->fileName : "";
}

# Accessor negative file
sub negativeFile
{
    my ($self, $filename) = @_;
    
    if( defined($filename) )
    {
        $self->{_negFile} = new SequencesFile();
        $self->{_negFile}->load($filename);
        $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg});
    }
    
    return $self->{_negFile} ? $self->{_negFile}->fileName : "";
}

############## END OF ACCESSORS ####################

############# CALLBACKS ###############

# Called when a viewer is closed by the user
sub window_destroyed
{
    Gtk2->main_quit() if(--$viewerCounter == 0);
}

sub on_mnuExportToHTML_activate
{
    my ($mnu, $self) = @_;
}

# Called when the New Session menu item is clicked
sub on_mnuNewSession_activate
{
    my ($mnu, $self) = @_;
    my $diag = new NewSessionDialog();
    
    if($diag->run())
    {
        my $posFile = $diag->filePositive;
        my $negFile = $diag->fileNegative;
        
        unless($posFile && -e $posFile)
        {
            error("Invalid Positive File!");
            return;
        }
        
        unless($negFile && -e $negFile)
        {
            error("Invalid Negative File!");
            return;
        }
        
        $self->positiveFile($posFile);
        $self->negativeFile($negFile);
    }
}

sub on_mnuShowHeaders_toggled
{
    my ($mnu, $self) = @_;
    
    my $active = $mnu->get_active;
    
    $self->{_showHeaders} = $active;
    
    $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
    $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
}

sub on_mnuShowAligned_toggled
{
    my ($mnu, $self) = @_;
    
    my $active = $mnu->get_active;
    
    $self->{_showAligned} = $active;
    
    $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
    $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
}

sub on_mnuShowSequences_toggled
{
    my ($mnu, $self) = @_;
    
    my $active = $mnu->get_active;
    
    $self->{_showSequence} = $active;
    
    $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
    $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
}

sub on_mnuAlignSequences_activate
{
    my ($mnu, $self) = @_;
        
    if(not defined $self->{_posFile})
    {
        error("No positive file opened!");
        return;
    }
    
    if(not defined $self->{_negFile})
    {
        error("No negative file opened!");
        return;
    }
    
    my $numPosSeq = $self->{_posFile}->numSequences;
    my $numNegSeq = $self->{_negFile}->numSequences;
    
    if($numPosSeq < 2 or $numNegSeq < 2)
    {
        error("Each file must have at least 2 sequences!");
        return;
    }

    open my $outFile, ">out.fasta";
    
    for(my $i = 0; $i < $numPosSeq; ++$i)
    {
        my %seq = $self->{_posFile}->getSequence($i);
        print $outFile ">";
        print $outFile $seq{'header'};
        print $outFile "\n";
        print $outFile $seq{'seq'};
        print $outFile "\n";
    }
    
    for(my $i = 0; $i < $numNegSeq; ++$i)
    {
        my %seq = $self->{_negFile}->getSequence($i);
        print $outFile ">";
        print $outFile $seq{'header'};
        print $outFile "\n";
        print $outFile $seq{'seq'};
        print $outFile "\n";
    }
    
    close $outFile;    
    
    my $frmAlign = new TCoffee;
    $frmAlign->alignFile("out.fasta", $self->{_posFile}->fileName, $self->{_negFile}->fileName, $numPosSeq, $numNegSeq,
    sub
    {
        my ($posSeqs, $negSeqs) = @_;
        $posSeqs->fileName($self->{_posFile}->fileName);
        $negSeqs->fileName($self->{_negFile}->fileName);
        $self->{_posFile} = $posSeqs;
        $self->{_negFile} = $negSeqs;
        $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
        $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
    });
}

sub on_mnuShowSearchWindow_toggled
{
    my ($mnu, $self) = @_;
    if( $mnu->get_active )
    {
        $self->{_searchWindow}->show;
    }else
    {
        $self->{_searchWindow}->hide;
    }
}

sub on_mnuHorizontal_toggled
{
    my ($mnu, $self) = @_;
    if( $mnu->get_active )
    {
        $self->{_mainPan}->set_orientation('horizontal');
    }else
    {
        $self->{_mainPan}->set_orientation('vertical');    
    }
}

########## END OF CALLBACKS ###########

######### AUXILIARY FUNCTIONS ##########

# Add to a GtkTextBuffer all the tags are going to be used.
# One argument: the GtkTextBuffer
sub addStyleTags
{
    my ($buffer) = @_;
    my $tagTable = $buffer->get_tag_table();
    
    my %tags = ( 'patternmatch' => Gtk2::TextTag->new('patternmatch'),
                 'seqheader'    => Gtk2::TextTag->new('seqheader'),
                 'selectedseq'  => Gtk2::TextTag->new('selectedseq') );

    $tags{'patternmatch'}->set_property('weight', 4);
    $tags{'patternmatch'}->set_property('background-set', 1);
    $tags{'patternmatch'}->set_property('background-full-height', 1);
    $tags{'patternmatch'}->set_property('background-full-height-set', 1);
    $tags{'patternmatch'}->set_property('background', 'blue');
    
    $tags{'seqheader'}->set_property('background-set', 1);
    $tags{'seqheader'}->set_property('background-full-height', 1);
    $tags{'seqheader'}->set_property('background-full-height-set', 1);
    $tags{'seqheader'}->set_property('background', $headerbackcolor);
    $tags{'seqheader'}->set_property('foreground', $headerforecolor);
    $tags{'seqheader'}->set_property('foreground-set', 1);
    
    $tags{'selectedseq'}->set_property('background-set', 1);
    $tags{'selectedseq'}->set_property('background-full-height', 1);
    $tags{'selectedseq'}->set_property('background-full-height-set', 1);
    $tags{'selectedseq'}->set_property('background', '#DDDDDD');
    
    foreach $key (keys %tags)
    {
        $tagTable->add($tags{$key});
    }
}

sub clearBuffer
{
    my ($buffer) = @_;
    
    # Get start iterator of the text buffer
    my $startIter = $buffer->get_start_iter();
    # Get end iterator of the text buffer
    my $endIter = $buffer->get_end_iter();
    # Delete any existing text
    $buffer->delete($startIter, $endIter);
}

# Shows an error dialog. 
# One argument: message to show.
sub error($)
{
    $diag = Gtk2::MessageDialog::new(undef, $window, 'destroy-with-parent', 'error', 'ok', "%s", $_[0] );
    $diag->run;
    $diag->destroy;
}

# Shows an info dialog. 
# One argument: message to show.
sub info($)
{
    $diag = Gtk2::MessageDialog::new(undef, $window, 'destroy-with-parent', 'info', 'ok', "%s", $_[0] );
    $diag->run;
    $diag->destroy;
}

######### END OF AUXILIARY FUNCTIONS ##########

1;

