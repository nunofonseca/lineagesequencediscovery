#############################################################
#                                                           #
#   Class Name:  SequencesViewer                            #
#   Description: Creates a window that allows to show two   #
#                SequencesFile's side by side.              #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SequencesViewer;

use Executable 'is_executable_available';
use SequencesFile;
use DoubleFileDialog;
use SearchWindow;
use SigDisDialog;
use MemeDialog;
use TCoffee;
use Glib qw/TRUE FALSE/;
use Gtk2::SourceView;
use Gtk2::Helper;
use Gtk2 '-init';
use Cwd qw(realpath);
use File::Basename;
use File::Copy;

my $strfrmSequencesViewer = "<?xml version=\"1.0\"?><interface>  <requires lib=\"gtk+\" version=\"2.16\"\/>  <!-- interface-naming-policy project-wide -->  <object class=\"GtkWindow\" id=\"frmSequencesViewer\">    <property name=\"title\" translatable=\"yes\">LSD - Lineage Sequence Discovery<\/property>    <property name=\"window_position\">center<\/property>    <property name=\"default_width\">640<\/property>    <property name=\"default_height\">480<\/property>    <signal name=\"destroy\" handler=\"window_destroyed\"\/>    <child>      <object class=\"GtkVBox\" id=\"vbox1\">        <property name=\"visible\">True<\/property>        <child>          <object class=\"GtkMenuBar\" id=\"menubar1\">            <property name=\"visible\">True<\/property>            <child>              <object class=\"GtkMenuItem\" id=\"menuitem1\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">_File<\/property>                <property name=\"use_underline\">True<\/property>                <child type=\"submenu\">                  <object class=\"GtkMenu\" id=\"menu1\">                    <property name=\"visible\">True<\/property>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuNewSession\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actNewSession<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuOpenSession\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actOpenSession<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkSeparatorMenuItem\" id=\"separatormenuitem1\">                        <property name=\"visible\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuSaveMatches\">                        <property name=\"label\" translatable=\"yes\">Export Sequences With Matches<\/property>                        <property name=\"visible\">True<\/property>                        <property name=\"image\">image2<\/property>                        <property name=\"use_stock\">False<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkSeparatorMenuItem\" id=\"separatormenuitem4\">                        <property name=\"visible\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuQuit1\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actQuit<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                  <\/object>                <\/child>              <\/object>            <\/child>            <child>              <object class=\"GtkMenuItem\" id=\"Search\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Search<\/property>                <property name=\"use_underline\">True<\/property>                <child type=\"submenu\">                  <object class=\"GtkMenu\" id=\"menu4\">                    <property name=\"visible\">True<\/property>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuShowSearchWindow\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actSearchPatterns<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                  <\/object>                <\/child>              <\/object>            <\/child>            <child>              <object class=\"GtkMenuItem\" id=\"mnuView\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">View<\/property>                <property name=\"use_underline\">True<\/property>                <child type=\"submenu\">                  <object class=\"GtkMenu\" id=\"menu3\">                    <property name=\"visible\">True<\/property>                    <child>                      <object class=\"GtkCheckMenuItem\" id=\"mnuShowHeaders\">                        <property name=\"visible\">True<\/property>                        <property name=\"label\" translatable=\"yes\">Show Headers<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"active\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkCheckMenuItem\" id=\"mnuShowSequences\">                        <property name=\"visible\">True<\/property>                        <property name=\"label\" translatable=\"yes\">Show Sequences<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"active\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkCheckMenuItem\" id=\"mnuShowAligned\">                        <property name=\"visible\">True<\/property>                        <property name=\"label\" translatable=\"yes\">Show Aligned<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"active\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkCheckMenuItem\" id=\"mnuSelectColumns\">                        <property name=\"visible\">True<\/property>                        <property name=\"label\" translatable=\"yes\">Select Columns<\/property>                        <property name=\"use_underline\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkCheckMenuItem\" id=\"mnuHorizontal\">                        <property name=\"visible\">True<\/property>                        <property name=\"label\" translatable=\"yes\">Horizontal Window Layout<\/property>                        <property name=\"use_underline\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkSeparatorMenuItem\" id=\"separatormenuitem3\">                        <property name=\"visible\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuClearSearchResults\">                        <property name=\"label\" translatable=\"yes\">Clear search results<\/property>                        <property name=\"visible\">True<\/property>                        <property name=\"image\">image1<\/property>                        <property name=\"use_stock\">False<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuClearSelectedColumns\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actClearSelectedColumns<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                  <\/object>                <\/child>              <\/object>            <\/child>            <child>              <object class=\"GtkMenuItem\" id=\"menuitem3\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Tools<\/property>                <property name=\"use_underline\">True<\/property>                <child type=\"submenu\">                  <object class=\"GtkMenu\" id=\"menu5\">                    <property name=\"visible\">True<\/property>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuShowSigDis\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actSigDis<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuAlignSequences\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actAlignSequences<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuShowMEME\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actMEME<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                  <\/object>                <\/child>              <\/object>            <\/child>            <child>              <object class=\"GtkMenuItem\" id=\"menuitem2\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Help<\/property>                <property name=\"use_underline\">True<\/property>                <child type=\"submenu\">                  <object class=\"GtkMenu\" id=\"menu2\">                    <property name=\"visible\">True<\/property>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"imagemenuitem1\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actHelp<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuViewLog\">                        <property name=\"visible\">True<\/property>                        <property name=\"related_action\">actViewLog<\/property>                        <property name=\"use_action_appearance\">True<\/property>                        <property name=\"use_underline\">True<\/property>                        <property name=\"use_stock\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkSeparatorMenuItem\" id=\"separatormenuitem2\">                        <property name=\"visible\">True<\/property>                      <\/object>                    <\/child>                    <child>                      <object class=\"GtkImageMenuItem\" id=\"mnuAbout\">                        <property name=\"label\" translatable=\"yes\">About<\/property>                        <property name=\"visible\">True<\/property>                        <property name=\"image\">image5<\/property>                        <property name=\"use_stock\">False<\/property>                      <\/object>                    <\/child>                  <\/object>                <\/child>              <\/object>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"position\">0<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkToolbar\" id=\"toolbar1\">            <property name=\"visible\">True<\/property>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton1\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actNewSession<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton1<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton7\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actOpenSession<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton7<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkSeparatorToolItem\" id=\"separatortoolitem1\">                <property name=\"visible\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton2\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actSearchPatterns<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton2<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkSeparatorToolItem\" id=\"separatortoolitem3\">                <property name=\"visible\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton3\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actSigDis<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton3<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton4\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actAlignSequences<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton4<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton6\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actMEME<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton6<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkSeparatorToolItem\" id=\"separatortoolitem2\">                <property name=\"visible\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkToolButton\" id=\"toolbutton5\">                <property name=\"visible\">True<\/property>                <property name=\"related_action\">actHelp<\/property>                <property name=\"use_action_appearance\">True<\/property>                <property name=\"label\" translatable=\"yes\">toolbutton5<\/property>                <property name=\"use_underline\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"homogeneous\">True<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"position\">1<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkVPaned\" id=\"mainPan\">            <property name=\"visible\">True<\/property>            <property name=\"can_focus\">True<\/property>            <child>              <object class=\"GtkVBox\" id=\"vbox2\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkScrolledWindow\" id=\"scrollPosFile\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"hscrollbar_policy\">automatic<\/property>                    <property name=\"vscrollbar_policy\">automatic<\/property>                    <child>                      <placeholder\/>                    <\/child>                  <\/object>                  <packing>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkLabel\" id=\"label1\">                    <property name=\"visible\">True<\/property>                    <property name=\"label\" translatable=\"yes\">Positive File<\/property>                  <\/object>                  <packing>                    <property name=\"expand\">False<\/property>                    <property name=\"padding\">4<\/property>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"resize\">False<\/property>                <property name=\"shrink\">True<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkVBox\" id=\"vbox3\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkScrolledWindow\" id=\"scrollNegFile\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"hscrollbar_policy\">automatic<\/property>                    <property name=\"vscrollbar_policy\">automatic<\/property>                    <child>                      <placeholder\/>                    <\/child>                  <\/object>                  <packing>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkLabel\" id=\"label2\">                    <property name=\"visible\">True<\/property>                    <property name=\"label\" translatable=\"yes\">Negative File<\/property>                  <\/object>                  <packing>                    <property name=\"expand\">False<\/property>                    <property name=\"padding\">4<\/property>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"resize\">True<\/property>                <property name=\"shrink\">True<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"position\">2<\/property>          <\/packing>        <\/child>      <\/object>    <\/child>  <\/object>  <object class=\"GtkImage\" id=\"image5\">    <property name=\"visible\">True<\/property>    <property name=\"stock\">gtk-about<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actNewSession\">    <property name=\"label\">New Session<\/property>    <property name=\"short_label\">Create a new session<\/property>    <property name=\"stock_id\">gtk-new<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actQuit\">    <property name=\"label\">Quit<\/property>    <property name=\"short_label\">Close the window<\/property>    <property name=\"stock_id\">gtk-quit<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actSearchPatterns\">    <property name=\"label\">Search for Patterns<\/property>    <property name=\"short_label\">Search for Patterns<\/property>    <property name=\"tooltip\">Open a search window<\/property>    <property name=\"stock_id\">gtk-find<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actSigDis\">    <property name=\"label\">Run SigDis<\/property>    <property name=\"short_label\">Run SigDis<\/property>    <property name=\"tooltip\">Show a dialog to configure and run SigDis<\/property>    <property name=\"stock_id\">gtk-execute<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actAlignSequences\">    <property name=\"label\">Align Sequences<\/property>    <property name=\"short_label\">Align Sequences<\/property>    <property name=\"tooltip\">Use tcoffee for sequences\\\' aligning<\/property>    <property name=\"stock_id\">gtk-justify-fill<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actHelp\">    <property name=\"label\">Help<\/property>    <property name=\"short_label\">Help<\/property>    <property name=\"tooltip\">Show the help manual<\/property>    <property name=\"stock_id\">gtk-help<\/property>  <\/object>  <object class=\"GtkImage\" id=\"image1\">    <property name=\"visible\">True<\/property>    <property name=\"stock\">gtk-clear<\/property>  <\/object>  <object class=\"GtkImage\" id=\"image2\">    <property name=\"visible\">True<\/property>    <property name=\"stock\">gtk-save-as<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actMEME\">    <property name=\"label\">Open MEME Tool<\/property>    <property name=\"short_label\">MEME<\/property>    <property name=\"tooltip\">Open MEME Tool<\/property>    <property name=\"stock_id\">gtk-select-font<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actViewLog\">    <property name=\"label\">View Execution Log<\/property>    <property name=\"short_label\">Execution Log<\/property>    <property name=\"tooltip\">Execution Log<\/property>    <property name=\"stock_id\">gtk-info<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actOpenSession\">    <property name=\"label\">Open Session<\/property>    <property name=\"short_label\">Open<\/property>    <property name=\"tooltip\">Open Session<\/property>    <property name=\"stock_id\">gtk-open<\/property>  <\/object>  <object class=\"GtkAction\" id=\"actClearSelectedColumns\">    <property name=\"label\">Clear selected columns<\/property>    <property name=\"short_label\">Clear selected columns<\/property>    <property name=\"tooltip\">Clear selected columns<\/property>    <property name=\"stock_id\">gtk-clear<\/property>  <\/object><\/interface>";

my $basePath = dirname(realpath(__FILE__));

my $patternPixBufFile  = "$basePath/arrow-right.png";
my $defaultfont = "mono 10";
my $font = undef;
my $headerbackcolor = "#7B68EE";
my $headerforecolor = "#FFFFFF";

my $viewerCounter = 0;

sub log_to_file
{
  my $logfile = shift;
  open STDOUT, ">>", $logfile or die "cannot append to '$logfile': $!\n";
  open STDERR, ">&STDOUT" or die "cannot dup STDERR to STDOUT: $!\n";
  select STDERR; $| = 1;
  open LOG, ">&STDOUT" or die "cannot dup LOG to STDOUT: $!\n";
  select LOG; $| = 1;
  select STDOUT; $| = 1;
}

sub check_for_available_apps
{
  my ($self) = @_;
  
  my %apps = (
    "t_coffee" => Executable::is_executable_available("t_coffee"),
    "meme" => Executable::is_executable_available("meme"),
    "sigdis" => Executable::is_executable_available("sigdis.pl")
  );
  
  print (("-" x 80) . "\n");
  print ("Program availability\n" . ("-" x 80) . "\n");

  my @not_available;
  foreach $k (keys %apps) {
    print "$k: " . ( ($apps{$k} == 1) ? "available" : "not available" ) . "\n";
    push @not_available, $k if $apps{$k} == 0;
  }
  
  print (("-" x 80) . "\n");
  
  if(scalar @not_available > 0) {
    my $msg = "Some programs that LSD uses internally are not available.\n".
              "While this might not be critical, you'll be unable to access some of the features of LSD.\n".
              "\nPlease consider installing the following programs to enjoy full functionality:\n\n";
    foreach $p (@not_available) {
      $msg .= "- $p\n";
    }
    
    $msg .= "\nGo to LSD's homepage to find out how to install the applications:\n\n".
            "http://code.google.com/p/lineagesequencediscovery/";
    
    SequencesViewer::info($msg);
    
    $self->{_builder}->get_object("actSigDis")->set_sensitive(0) if $apps{'sigdis'} == 0;
    $self->{_builder}->get_object("actMEME")->set_sensitive(0) if $apps{'meme'} == 0; 
    $self->{_builder}->get_object("actAlignSequences")->set_sensitive(0) if $apps{'t_coffee'} == 0;
  }
}

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # The file where the application log is
        _logFile => "/tmp/LSD_$$.txt",

        _projectDir => "",
        
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
        
        # Change the display orientation
        _mainPan => undef,
        
        # Flags
        _showHeaders  => 1,
        _showSequence => 1,
        _showAligned  => 1,
        _selectColumns => 0,
        
        # Selected columns
        _selPosStart => -1,
        _selPosEnd => -1,
        _selNegStart => -1,
        _selNegEnd => -1,
        
        # Indexes of sequences with matches
        _posMatches => (),
        _negMatches => ()
    };
    
    bless $self, $class;
    
    log_to_file($self->{_logFile});
    
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
    $self->{_txtPosFile}->set_editable(0);
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
    $self->{_txtNegFile}->set_editable(0);
    $self->{_txtNegFile}->modify_font($font);
    $self->{_txtNegFile}->show();
    
    $self->{_builder}->connect_signals();
    
    # Connect signals
    $self->{_builder}->get_object("actQuit")->signal_connect( activate => \&close_window, $self);
    $self->{_builder}->get_object("actViewLog")->signal_connect( activate => \&view_log, $self);
    $self->{_builder}->get_object("actSigDis")->signal_connect( activate => \&on_mnuShowSigDis_activate, $self);
    $self->{_builder}->get_object("actHelp")->signal_connect( activate => \&on_mnuShowHelp_activate, $self);
    $self->{_builder}->get_object("mnuAbout")->signal_connect( activate => \&on_mnuShowAbout_activate, $self);
    $self->{_builder}->get_object("actNewSession")->signal_connect( activate => \&on_mnuNewSession_activate, $self);
    $self->{_builder}->get_object("actOpenSession")->signal_connect( activate => \&on_mnuOpenSession_activate, $self);
    $self->{_builder}->get_object("mnuShowHeaders")->signal_connect( toggled => \&on_mnuShowHeaders_toggled, $self);
    $self->{_builder}->get_object("mnuShowSequences")->signal_connect( toggled => \&on_mnuShowSequences_toggled, $self);
    $self->{_builder}->get_object("mnuShowAligned")->signal_connect( toggled => \&on_mnuShowAligned_toggled, $self);
    $self->{_builder}->get_object("mnuSelectColumns")->signal_connect( toggled => \&on_mnuSelectColumns_toggled, $self);
    $self->{_builder}->get_object("mnuSaveMatches")->signal_connect( activate => \&on_mnuSaveMatches_activate, $self);
    $self->{_builder}->get_object("actMEME")->signal_connect( activate => \&on_mnuShowMEME_activate, $self);
    $self->{_builder}->get_object("actAlignSequences")->signal_connect( activate => \&on_mnuAlignSequences_activate, $self);
    $self->{_builder}->get_object("actSearchPatterns")->signal_connect( activate => \&on_mnuShowSearchWindow_toggled, $self);
    $self->{_builder}->get_object("mnuHorizontal")->signal_connect( toggled => \&on_mnuHorizontal_toggled, $self);
    $self->{_builder}->get_object("mnuClearSearchResults")->signal_connect( activate => \&on_mnuClearSearchResults_activate, $self);
    $self->{_builder}->get_object("actClearSelectedColumns")->signal_connect( activate => \&on_actClearSelectedColumns_activate, $self);
    $self->{_bufferPos}->signal_connect( 'mark-set' => \&on_bufferPos_markset, $self );
    $self->{_bufferNeg}->signal_connect( 'mark-set' => \&on_bufferNeg_markset, $self );
    
    $self->{_mainPan} = $self->{_builder}->get_object("mainPan");
    
    ++$viewerCounter;
}

# Show the viewer
sub show
{
    my ($self) = @_;
    $self->{_frmSequencesViewer}->show();
    $self->check_for_available_apps if($viewerCounter == 1);
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
    
    if( $self->{_showSequence} )
    {
        my $tmpIter = $iter;
        $buffer->insert($iter, $seq{'seq'});
    }
        
    return $iter;
}

sub putSequenceSpacesOnBuffer
{
    my ($self, $seqfile, $i, $buffer) = @_;
    return if not $self->{_showAligned} or not $self->{_showSequence};
    
    my %seq = $seqfile->getSequence($i);

    my $offset = 0;
    $offset = $seqfile->maxHeaderLength() +1 if $self->{_showHeaders};
    
    my $tmpIter = $buffer->get_iter_at_line($i);
    
    my $len = @{$seq{'spaces'}}-1;
    for $p (0..$len)
    {
        my $start = (@{$seq{'spaces'}}[$p])[0][0];
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
        $startIter = $self->putSequenceOnBuffer($seqfile, $i, $buffer, $startIter);  
        $buffer->insert($startIter, "\n") unless($i == $numSeqs - 1);
        $self->putSequenceSpacesOnBuffer($seqfile, $i, $buffer);
        $startIter = $buffer->get_iter_at_line($i+1);
    }
}

sub clearMatches
{
    my ($self) = @_;
    
    $self->{_bufferPos}->remove_tag_by_name('patternmatch', $self->{_bufferPos}->get_start_iter, $self->{_bufferPos}->get_end_iter);
    $self->{_bufferNeg}->remove_tag_by_name('patternmatch', $self->{_bufferNeg}->get_start_iter, $self->{_bufferNeg}->get_end_iter);
    
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
    
    $self->{_posMatches} = ();
    $self->{_negMatches} = ();
}

sub addMatchMarker
{
    my ($self, $buf, $seqPos, @matchesPositions) = @_;
    
    my $buffer = undef;
    my $seqfile = undef;
    my @matches = ();
    my $selection = 0;
    my $selStart = -1;
    my $selEnd = -1;
    
    if($buf eq 'positive')
    {
        $buffer = $self->{_bufferPos} ;
        $seqfile = \$self->{_posFile};
        push @{ $self->{_posMatches} }, $seqPos;
        
        if($self->{_selPosStart} != -1 and $self->{_selPosEnd} != -1) {
            $selection = 1;
            $selStart = $self->{_selPosStart};
            $selEnd = $self->{_selPosEnd};
        }
    }elsif($buf eq 'negative')
    {
        $buffer = $self->{_bufferNeg} ;
        $seqfile = \$self->{_negFile};
        push @{ $self->{_negMatches} }, $seqPos;
        
        if($self->{_selNegStart} != -1 and $self->{_selNegEnd} != -1) {
            $selection = 1;
            $selStart = $self->{_selNegStart};
            $selEnd = $self->{_selNegEnd};
        }
    }

    return if not defined($buffer) or not defined($seqfile);
    
    if(@matchesPositions)
    {        
        my %seq = $$seqfile->getSequence($seqPos);

        my $offset = 0;
        $offset = $$seqfile->maxHeaderLength() + 1 if $self->{_showHeaders};

        # Delete the current line
        my $lineIter = $buffer->get_iter_at_line($seqPos);
        $lineIterEnd = $buffer->get_iter_at_line($seqPos);
        $lineIterEnd->forward_to_line_end;
        
        if($selection == 1) {
            my $tmpIter = $lineIter->copy;
            my $tmpIterEnd = $lineIter->copy;
            $tmpIter->forward_chars($offset) if $self->{_showHeaders};
            $tmpIterEnd->forward_chars($selStart);
            my $beforeSeqExt = $buffer->get_text($tmpIter, $tmpIterEnd, 0);
            $tmpIterEnd->forward_chars($selEnd - $selStart);
            my $seqTxt = $buffer->get_text($tmpIter, $tmpIterEnd, 0);
            $beforeSeqExt =~ s/-//g;
            $seqTxt =~ s/-//g;
            $selStart = length($beforeSeqExt);
            $selEnd = length($seqTxt);
        }
        
        $buffer->delete($lineIter, $lineIterEnd);
        
        # Insert unaligned sequence
        $self->putSequenceOnBuffer($$seqfile, $seqPos, $buffer, $lineIter);  
            
        # Select columns!
        if($selection == 1) {
            my $startIter = $buffer->get_iter_at_line($seqPos);
            $startIter->set_line_offset($offset + $selStart);
            
            my $endIter = $buffer->get_iter_at_line($seqPos);
            $endIter->set_line_offset($offset + $selEnd);
            
            $buffer->apply_tag_by_name('selectedseq', $startIter, $endIter);
        }
        
        # Mark found pattern matches
        foreach $a (@matchesPositions)
        {
            my ($startPosition, $endPosition) = @$a;
            
            $lineIter = $buffer->get_iter_at_line($seqPos);
            $lineIterEnd = $buffer->get_iter_at_line($seqPos);
            $lineIter->set_line_offset($offset + $startPosition);
            $lineIterEnd->set_line_offset($offset + $endPosition);            
            $buffer->apply_tag_by_name('patternmatch', $lineIter, $lineIterEnd);
        }
                
        # Insert spaces!
        $self->putSequenceSpacesOnBuffer($$seqfile, $seqPos, $buffer);
    }
    
    $lineIter = $buffer->get_iter_at_line($seqPos);
    $buffer->create_marker(undef, 'patternmatch', $lineIter);       
}

sub getSequenceSelectedColumns
{
    my ($self, $buf, $i) = @_;
    
    my $buffer = undef;
    my $seqfile = undef;
    my $selstart = 0;
    my $selend = 0;
    my $offset = 0;
    
    if($buf eq 'pos')
    {
        $buffer = $self->{_bufferPos} ;
        $seqfile = \$self->{_posFile};
        $selstart = $self->{_selPosStart};
        $selend = $self->{_selPosEnd};
        $offset = $self->{_posFile}->maxHeaderLength()+1 if $self->{_showHeaders};
    }elsif($buf eq 'neg')
    {
        $buffer = $self->{_bufferNeg} ;
        $seqfile = \$self->{_negFile};
        $selstart = $self->{_selNegStart};
        $selend = $self->{_selNegEnd};
        $offset = $self->{_negFile}->maxHeaderLength()+1 if $self->{_showHeaders};
    }else
    {
        return "";
    }

    my $iterStartOfSeq = $buffer->get_iter_at_line($i);
    my $iterStart = $buffer->get_iter_at_line($i);
    my $iterEnd = $buffer->get_iter_at_line($i);
    
    $iterStartOfSeq->forward_chars($offset);
    $iterStart->forward_chars($selstart);
    $iterEnd->forward_chars($selend);
    
    my $startSeq = $buffer->get_text($iterStartOfSeq, $iterStart, 0);
    $startSeq =~ s/-//g;
    my $txt = $buffer->get_text($iterStart, $iterEnd, 0);
    $txt =~ s/-//g;
    
    my @res = ($txt, length($startSeq));
    return @res;
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
    my ($self, $filename, $handler) = @_;
    
    if( defined($filename) )
    {
        $self->{_posFile} = new SequencesFile();
        $self->{_posFile}->load($filename, $handler);
        $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos});
    }
    
    return $self->{_posFile} ? $self->{_posFile}->fileName : "";
}

# Accessor negative file
sub negativeFile
{
    my ($self, $filename, $handler) = @_;
    
    if( defined($filename) )
    {
        $self->{_negFile} = new SequencesFile();
        $self->{_negFile}->load($filename, $handler);
        $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg});
    }
    
    return $self->{_negFile} ? $self->{_negFile}->fileName : "";
}

sub projectDir
{
    my ($self) = @_;
    return $self->{_projectDir};
}

############## END OF ACCESSORS ####################

############# CALLBACKS ###############

sub view_log
{
    my ($mnu, $self) = @_;
    system("xdg-open '" . $self->{_logFile} . "'");
}

sub close_window
{
    my ($mnu, $self) = @_;
    $self->{_frmSequencesViewer}->destroy;
}

# Called when a viewer is closed by the user
sub window_destroyed
{
    Gtk2->main_quit() if(--$viewerCounter == 0);
}

sub on_mnuShowHelp_activate
{
    my ($mnu, $self) = @_;
    info("LSD - Lineage Sequence Discovery\n\nHelp not yet available!\n\nCheck the website:\nhttp://code.google.com/p/lineagesequencediscovery/");
}

sub on_mnuShowAbout_activate
{
    my ($mnu, $self) = @_;
    info("LSD - Lineage Sequence Discovery\n\nAuthor: Diogo Costa (costa.h4evr\@gmail.com)\n\nWebsite:\nhttp://code.google.com/p/lineagesequencediscovery/");
}

sub on_mnuClearSearchResults_activate
{
    my ($mnu, $self) = @_;
    $self->clearMatches;
}

sub on_mnuShowSigDis_activate
{
    my ($mnu, $self) = @_;
    
    if(not defined $self->{_posFile})
    {
        error("No positive file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    if(not defined $self->{_negFile})
    {
        error("No negative file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    my $sigdis = new SigDisDialog($self);
    $sigdis->show;
}

sub on_mnuShowMEME_activate
{
    my ($mnu, $self) = @_;
    
    if(not defined $self->{_posFile})
    {
        error("No positive file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    my $meme = new MemeDialog($self);
    $meme->show;
}

# Called when the New Session menu item is clicked
sub on_mnuNewSession_activate
{
    my ($mnu, $self) = @_;
    my $diag = new DoubleFileDialog(undef, 1);
    
    if($diag->run() eq 'ok')
    #if(1)
    {
        my $posFile = $diag->filePositive;
        my $negFile = $diag->fileNegative;
        my $projectName = $diag->projectName;
        my $projectDir = $diag->projectDir;
        
        #my $posFile = "/home/h4evr/IBMC/Refactored/pos_file_test.fasta";
        #my $negFile = "/home/h4evr/IBMC/Refactored/neg_file_test.fasta";
        
        unless($posFile && -e $posFile)
        {
            error("Invalid Positive File!");
            return;
        }
        
        if($negFile) {
            unless(-e $negFile)
            {
                error("Invalid Negative File!");
                return;
            }
        }
        
        # Create Project Folder and move files in!
        mkdir("$projectDir/$projectName");
        copy($posFile, "$projectDir/$projectName/positive.fasta");
        if($negFile) {
            copy($negFile, "$projectDir/$projectName/negative.fasta");
        } else {
            open $fh, ">$projectDir/$projectName/negative.fasta";
            close $fh;
        }
        
        # Move the log file!
        mkdir("$projectDir/$projectName/LSD");
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
        my $newLogFile = "$projectDir/$projectName/LSD/log_".($year+1900)."-$mon-$mday-$hour-$min.txt";
        copy($self->{_logFile}, $newLogFile);
        log_to_file($newLogFile);
        $self->{_logFile} = $newLogFile;
        
        $posFile = "$projectDir/$projectName/positive.fasta";
        $negFile = "$projectDir/$projectName/negative.fasta";
        
        $self->{_projectDir} = "$projectDir/$projectName/";
        
        Gtk2->main_iteration_do(1);
        
        $self->positiveFile($posFile, sub{
          $diag->pulse;
          Gtk2->main_iteration_do(1);
        });
        
        Gtk2->main_iteration_do(1);
        
        $self->negativeFile($negFile, sub{
          $diag->pulse;
          Gtk2->main_iteration_do(1);
        });
    }
    
    $diag->destroy();
}

sub on_mnuSaveMatches_activate
{
    my ($mnu, $self) = @_;

    if(not defined $self->{_posFile})
    {
        error("No positive file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    if(not defined $self->{_negFile})
    {
        error("No negative file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    my $diag = new DoubleFileDialog("Export matches to FASTA");
    $resp = $diag->run();

    if($resp eq 'ok')
    {
        my $posFile = $diag->filePositive;
        my $negFile = $diag->fileNegative;

        if(length($posFile) == 0 || length($negFile) == 0) {
            error("You must select two output files!");
        } else {
            my $numPosSeq = $self->{_posFile}->numSequences;
            my $numNegSeq = $self->{_negFile}->numSequences;
            
            if($numPosSeq < 2 or $numNegSeq < 2)
            {
                error("Each file must have at least 2 sequences!");
                return;
            }

            open my $outFile, ">$posFile";
            
            for my $i (@{ $self->{_posMatches} })
            #for(my $i = 0; $i < $numPosSeq; ++$i)
            {
                my %seq = $self->{_posFile}->getSequence($i);
                print $outFile ">";
                print $outFile $seq{'header'};
                print $outFile " " . $seq{'desc'};
                print $outFile "\n";
                print $outFile $seq{'seq'};
                print $outFile "\n";
            }
            
            close $outFile;
            
            open $outFile, ">$negFile";

            for my $i (@{ $self->{_negMatches} })        
            #for(my $i = 0; $i < $numNegSeq; ++$i)
            {
                my %seq = $self->{_negFile}->getSequence($i);
                print $outFile ">";
                print $outFile $seq{'header'};
                print $outFile " " . $seq{'desc'};
                print $outFile "\n";
                print $outFile $seq{'seq'};
                print $outFile "\n";
            }
            
            close $outFile;    
            
            info("Exported successfully!");
        }
    }
    
    $diag->destroy();
}

sub on_mnuShowHeaders_toggled
{
    my ($mnu, $self) = @_;
    
    my $active = $mnu->get_active;
    
    if($self->{_selPosStart} != -1 and $self->{_selPosEnd} != -1) {
        my $diff = $self->{_posFile}->maxHeaderLength + 1;
        $diff = -$diff unless($active);
        $self->{_selPosStart} += $diff;
        $self->{_selPosEnd} += $diff;
    }

    if($self->{_selNegStart} != -1 and $self->{_selNegEnd} != -1) {
        my $diff = $self->{_negFile}->maxHeaderLength + 1;
        $diff = -$diff unless($active);
        $self->{_selNegStart} += $diff;
        $self->{_selNegEnd} += $diff;
    }

    $self->{_showHeaders} = $active;
    
    $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
    $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
    
    $self->update_column_selection;
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

sub on_mnuSelectColumns_toggled
{
    my ($mnu, $self) = @_;
    
    my $active = $mnu->get_active;
    
    $self->{_selectColumns} = $active;
}

sub on_mnuAlignSequences_activate
{
    my ($mnu, $self) = @_;
        
    if(not defined $self->{_posFile})
    {
        error("No positive file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    if(not defined $self->{_negFile})
    {
        error("No negative file opened!");
        on_mnuNewSession_activate(undef, $self);
        return;
    }
    
    my $numPosSeq = $self->{_posFile}->numSequences;
    my $numNegSeq = $self->{_negFile}->numSequences;
    
    if($numPosSeq < 2 or $numNegSeq < 2)
    {
        error("Each file must have at least 2 sequences!");
        return;
    }

    my $outDir = $self->{_projectDir} . "tcoffee/";
    mkdir($outDir) unless(-d $outDir);
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    $outDir .= ($year+1900)."-$mon-$mday-$hour-$min/";
    mkdir($outDir) unless(-d $outDir);
    
    open my $outFile, ">$outDir/out.fasta";
    
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
    $frmAlign->alignFile($outDir, "$outDir/out.fasta", $self->{_posFile}->fileName, $self->{_negFile}->fileName, $numPosSeq, $numNegSeq,
    sub
    {
        my ($posSeqs, $negSeqs) = @_;
        $posSeqs->fileName($self->{_posFile}->fileName);
        $negSeqs->fileName($self->{_negFile}->fileName);
        $self->{_posFile} = $posSeqs;
        $self->{_negFile} = $negSeqs;
        $self->{_posFile}->save($self->projectDir . "/positive_aln.fasta");
        $self->{_negFile}->save($self->projectDir . "/negative_aln.fasta");
        $self->showSequencesOnBuffer($self->{_posFile}, $self->{_bufferPos}) if (defined($self->{_posFile} && (length($self->{_posFile}->fileName) > 0)));
        $self->showSequencesOnBuffer($self->{_negFile}, $self->{_bufferNeg}) if (defined($self->{_negFile} && (length($self->{_negFile}->fileName) > 0)));
    });
}

sub on_mnuShowSearchWindow_toggled
{
    my ($mnu, $self) = @_;
    my $swin = new SearchWindow($self);
    $swin->show;
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

sub on_actClearSelectedColumns_activate
{
    my ($mnu, $self) = @_;
    
    $self->{_bufferPos}->remove_tag_by_name('selectedseq', $self->{_bufferPos}->get_start_iter, $self->{_bufferPos}->get_end_iter);
    $self->{_bufferNeg}->remove_tag_by_name('selectedseq', $self->{_bufferNeg}->get_start_iter, $self->{_bufferNeg}->get_end_iter);
    
    $self->{_selPosStart} = -1;
    $self->{_selPosEnd} = -1;
    $self->{_selNegStart} = -1;
    $self->{_selNegEnd} = -1;
}

sub update_column_selection
{
    my ($self) = @_;
    
    $self->{_bufferPos}->remove_tag_by_name('selectedseq', $self->{_bufferPos}->get_start_iter, $self->{_bufferPos}->get_end_iter);
    $self->{_bufferNeg}->remove_tag_by_name('selectedseq', $self->{_bufferNeg}->get_start_iter, $self->{_bufferNeg}->get_end_iter);
    
    if($self->{_selPosStart} != -1 and $self->{_selPosEnd} != -1)
    {
        my $iter = $self->{_bufferPos}->get_start_iter;
        
        do
        {
            my $startIter = $iter->copy;
            my $endIter = $iter->copy;
            
            $startIter->set_line_offset($self->{_selPosStart});
            $endIter->set_line_offset($self->{_selPosEnd});
                        
            $self->{_bufferPos}->apply_tag_by_name('selectedseq', $startIter, $endIter);
        }while($iter->forward_line);    
    }
    
    if($self->{_selNegStart} != -1 and $self->{_selNegEnd} != -1)
    {
        my $iter = $self->{_bufferNeg}->get_start_iter;
        
        do
        {
            my $startIter = $iter->copy;
            my $endIter = $iter->copy;
            
            $startIter->set_line_offset($self->{_selNegStart});
            $endIter->set_line_offset($self->{_selNegEnd});
                        
            $self->{_bufferNeg}->apply_tag_by_name('selectedseq', $startIter, $endIter);
        }while($iter->forward_line);    
    }
}

sub on_bufferPos_markset
{
    my ($buffer, $iter, $mark, $self) = @_;

    if($self->{_selectColumns})
    {
        if($buffer->get_has_selection)
        {
            my ($iter_start, $iter_end) = $buffer->get_selection_bounds;
            
            if(defined($iter_start) and defined($iter_end))
            {
                $self->{_selPosStart} = $iter_start->get_line_offset;
                $self->{_selPosEnd} = $iter_end->get_line_offset;
                $self->update_column_selection;
                return;
            }
        }
    }
}

sub on_bufferNeg_markset
{
    my ($buffer, $iter, $mark, $self) = @_;

    if($self->{_selectColumns})
    {
        if($buffer->get_has_selection)
        {
            my ($iter_start, $iter_end) = $buffer->get_selection_bounds;
            
            if(defined($iter_start) and defined($iter_end))
            {
                $self->{_selNegStart} = $iter_start->get_line_offset;
                $self->{_selNegEnd} = $iter_end->get_line_offset;
                $self->update_column_selection;
                return;
            }
        }      
    }
}

sub on_mnuOpenSession_activate
{
    my ($mnu, $self) = @_;
    my $diag = Gtk2::FileChooserDialog->new("Choose session folder",
                                            $self->{_frmSequencesViewer},
                                            'select-folder',
                                            "Cancel" => 'cancel',
                                            "Open" => 'accept');
    if($diag->run() eq 'accept') {
        my $sessionFolder = $diag->get_filename;
        
        if(-e "$sessionFolder/positive.fasta" && -e "$sessionFolder/negative.fasta" ) {
            print $sessionFolder . "\n";
        } else {
            error("Invalid session folder!");
        }
        
        my $posFile = "$sessionFolder/positive.fasta";
        my $negFile = "$sessionFolder/negative.fasta";
        
        $posFile = "$sessionFolder/positive_aln.fasta" if(-e "$sessionFolder/positive_aln.fasta");
        $negFile = "$sessionFolder/negative_aln.fasta" if(-e "$sessionFolder/negative_aln.fasta");
        
        $self->positiveFile($posFile);
        $self->negativeFile($negFile);
        
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
        my $newLogFile = "$sessionFolder/LSD/log_".($year+1900)."-$mon-$mday-$hour-$min.txt";
        copy($self->{_logFile}, $newLogFile);
        log_to_file($newLogFile);
        $self->{_logFile} = $newLogFile;
        
        $self->{_projectDir} = "$sessionFolder/";
    }

    $diag->destroy();
}

########## END OF CALLBACKS ###########

######### AUXILIARY FUNCTIONS ##########

# Add to a GtkTextBuffer all the tags are going to be used.
# One argument: the GtkTextBuffer
sub addStyleTags
{
    my ($buffer) = @_;
    my $tagTable = $buffer->get_tag_table();
    
    my %tags = ( 'seqheader'    => Gtk2::TextTag->new('seqheader'),
                 'selectedseq'  => Gtk2::TextTag->new('selectedseq'),
                 'patternmatch' => Gtk2::TextTag->new('patternmatch') );

    $tags{'seqheader'}->set_property('background-set', 1);
    $tags{'seqheader'}->set_property('background-full-height', 1);
    $tags{'seqheader'}->set_property('background-full-height-set', 1);
    $tags{'seqheader'}->set_property('background', $headerbackcolor);
    $tags{'seqheader'}->set_property('foreground', $headerforecolor);
    $tags{'seqheader'}->set_property('foreground-set', 1);
    
    $tags{'selectedseq'}->set_property('background-set', 1);
    $tags{'selectedseq'}->set_property('background-full-height', 1);
    $tags{'selectedseq'}->set_property('background-full-height-set', 1);
    $tags{'selectedseq'}->set_property('background', '#AAAAAA');
    
    $tags{'patternmatch'}->set_property('weight', 4);
    $tags{'patternmatch'}->set_property('background-set', 1);
    $tags{'patternmatch'}->set_property('background-full-height', 1);
    $tags{'patternmatch'}->set_property('background-full-height-set', 1);
    $tags{'patternmatch'}->set_property('background', '#00ba00');
    
    $tagTable->add($tags{'seqheader'});
    $tagTable->add($tags{'selectedseq'});
    $tagTable->add($tags{'patternmatch'});
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

