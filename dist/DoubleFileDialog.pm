#############################################################
#                                                           #
#   Class Name:  DoubleFileDialog                           #
#   Description: Shows a dialog to open a positive and a    #
#                negative files.                            #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package DoubleFileDialog;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';
use File::Basename;

my $strfrmDoubleFileDialog = "<?xml version=\"1.0\"?><interface>  <requires lib=\"gtk+\" version=\"2.16\"\/>  <!-- interface-naming-policy project-wide -->  <object class=\"GtkDialog\" id=\"frmDoubleFileDialog\">    <property name=\"width_request\">320<\/property>    <property name=\"border_width\">5<\/property>    <property name=\"title\" translatable=\"yes\">Create new session<\/property>    <property name=\"resizable\">False<\/property>    <property name=\"modal\">True<\/property>    <property name=\"window_position\">center<\/property>    <property name=\"destroy_with_parent\">True<\/property>    <property name=\"type_hint\">normal<\/property>    <property name=\"has_separator\">False<\/property>    <child internal-child=\"vbox\">      <object class=\"GtkVBox\" id=\"dialog-vbox1\">        <property name=\"visible\">True<\/property>        <property name=\"spacing\">2<\/property>        <child>          <object class=\"GtkVBox\" id=\"vbox1\">            <property name=\"visible\">True<\/property>            <child>              <object class=\"GtkTable\" id=\"table1\">                <property name=\"visible\">True<\/property>                <property name=\"n_rows\">2<\/property>                <property name=\"n_columns\">3<\/property>                <child>                  <object class=\"GtkButton\" id=\"btnPositiveFile\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"receives_default\">True<\/property>                    <property name=\"image_position\">right<\/property>                  <\/object>                  <packing>                    <property name=\"left_attach\">2<\/property>                    <property name=\"right_attach\">3<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkLabel\" id=\"label1\">                    <property name=\"visible\">True<\/property>                    <property name=\"label\" translatable=\"yes\">Positive file:<\/property>                  <\/object>                  <packing>                    <property name=\"left_attach\">1<\/property>                    <property name=\"right_attach\">2<\/property>                    <property name=\"x_options\"><\/property>                    <property name=\"x_padding\">5<\/property>                    <property name=\"y_padding\">5<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkLabel\" id=\"label2\">                    <property name=\"visible\">True<\/property>                    <property name=\"label\" translatable=\"yes\">Negative file:<\/property>                  <\/object>                  <packing>                    <property name=\"left_attach\">1<\/property>                    <property name=\"right_attach\">2<\/property>                    <property name=\"top_attach\">1<\/property>                    <property name=\"bottom_attach\">2<\/property>                    <property name=\"x_options\"><\/property>                    <property name=\"x_padding\">5<\/property>                    <property name=\"y_padding\">5<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkButton\" id=\"btnNegativeFile\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"receives_default\">True<\/property>                  <\/object>                  <packing>                    <property name=\"left_attach\">2<\/property>                    <property name=\"right_attach\">3<\/property>                    <property name=\"top_attach\">1<\/property>                    <property name=\"bottom_attach\">2<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkImage\" id=\"image1\">                    <property name=\"visible\">True<\/property>                    <property name=\"stock\">gtk-file<\/property>                    <property name=\"icon-size\">5<\/property>                  <\/object>                  <packing>                    <property name=\"x_options\"><\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkImage\" id=\"image2\">                    <property name=\"visible\">True<\/property>                    <property name=\"stock\">gtk-file<\/property>                    <property name=\"icon-size\">5<\/property>                  <\/object>                  <packing>                    <property name=\"top_attach\">1<\/property>                    <property name=\"bottom_attach\">2<\/property>                    <property name=\"x_options\"><\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"position\">0<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"position\">1<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkTable\" id=\"table2\">            <property name=\"visible\">True<\/property>            <property name=\"n_rows\">2<\/property>            <property name=\"n_columns\">2<\/property>            <child>              <object class=\"GtkLabel\" id=\"label3\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Project Title:<\/property>              <\/object>            <\/child>            <child>              <object class=\"GtkEntry\" id=\"txtProjectName\">                <property name=\"visible\">True<\/property>                <property name=\"can_focus\">True<\/property>                <property name=\"invisible_char\">&#x25CF;<\/property>              <\/object>              <packing>                <property name=\"left_attach\">1<\/property>                <property name=\"right_attach\">2<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkLabel\" id=\"label5\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Folder to Create Project in:<\/property>              <\/object>              <packing>                <property name=\"top_attach\">1<\/property>                <property name=\"bottom_attach\">2<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkFileChooserButton\" id=\"dirProject\">                <property name=\"visible\">True<\/property>                <property name=\"action\">select-folder<\/property>              <\/object>              <packing>                <property name=\"left_attach\">1<\/property>                <property name=\"right_attach\">2<\/property>                <property name=\"top_attach\">1<\/property>                <property name=\"bottom_attach\">2<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"fill\">False<\/property>            <property name=\"position\">2<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkProgressBar\" id=\"pb\">            <property name=\"activity_mode\">True<\/property>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"position\">3<\/property>          <\/packing>        <\/child>        <child internal-child=\"action_area\">          <object class=\"GtkHButtonBox\" id=\"dialog-action_area1\">            <property name=\"visible\">True<\/property>            <property name=\"layout_style\">end<\/property>            <child>              <object class=\"GtkButton\" id=\"btnCancel\">                <property name=\"label\">gtk-cancel<\/property>                <property name=\"visible\">True<\/property>                <property name=\"can_focus\">True<\/property>                <property name=\"receives_default\">True<\/property>                <property name=\"use_stock\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"fill\">False<\/property>                <property name=\"position\">0<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkButton\" id=\"btnOK\">                <property name=\"label\">gtk-ok<\/property>                <property name=\"visible\">True<\/property>                <property name=\"sensitive\">False<\/property>                <property name=\"can_focus\">True<\/property>                <property name=\"receives_default\">True<\/property>                <property name=\"use_stock\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"fill\">False<\/property>                <property name=\"position\">1<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"pack_type\">end<\/property>            <property name=\"position\">0<\/property>          <\/packing>        <\/child>      <\/object>    <\/child>    <action-widgets>      <action-widget response=\"0\">btnCancel<\/action-widget>      <action-widget response=\"0\">btnOK<\/action-widget>    <\/action-widgets>  <\/object><\/interface>";

# Constructor
sub new
{
    my ($class, $title, $chooseProject) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmDoubleFileDialog  => undef,
        _filePositive         => "",
        _fileNegative         => "",
        _txtProjectName       => undef,
        _dirProject           => undef,
        _btnOK                => undef
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmDoubleFileDialog))
    {
        $self->{_builder}->add_from_string($strfrmDoubleFileDialog);
    }else
    {
        $self->{_builder}->add_from_file("frmDoubleFileDialog.glade");
    }
    
    $self->{_frmDoubleFileDialog}  = $self->{_builder}->get_object("frmDoubleFileDialog");
    $self->{_txtProjectName}  = $self->{_builder}->get_object("txtProjectName");
    $self->{_dirProject}  = $self->{_builder}->get_object("dirProject");
    $self->{_btnOK}  = $self->{_builder}->get_object("btnOK");
    
    if($chooseProject) {
        $self->{_txtProjectName}->signal_connect( changed => \&on_txtProjectName_changed, $self);    
    } else {
        $self->{_builder}->get_object("table2")->hide;
        $self->{_btnOK}->set_sensitive(1);
    }
        
    $self->{_frmDoubleFileDialog}->set_title($title) if defined($title);
    
    $self->{_builder}->get_object("btnPositiveFile")->signal_connect( clicked => \&on_btnPositiveFile_clicked, $self );
    $self->{_builder}->get_object("btnNegativeFile")->signal_connect( clicked => \&on_btnNegativeFile_clicked, $self );
    $self->{_builder}->get_object("btnOK")->signal_connect( clicked => \&on_btnOK_clicked, $self );
    $self->{_builder}->get_object("btnCancel")->signal_connect( clicked => \&on_btnCancel_clicked, $self );
    $self->{_pb} = $self->{_builder}->get_object("pb");

    $self->{_builder}->connect_signals();
    
    return $self;
}

sub filePositive
{
    my ($self) = @_;
    return $self->{_filePositive};
}

sub fileNegative
{
    my ($self) = @_;
    return $self->{_fileNegative};
}

sub projectName
{
    my ($self) = @_;
    return $self->{_txtProjectName}->get_text;
}

sub projectDir
{
    my ($self) = @_;
    return $self->{_dirProject}->get_filename;
}

# Show the dialog and wait for answer ( 1 if open, 0 if cancel )
sub run
{
    my ($self) = @_;
    my $retval = $self->{_frmDoubleFileDialog}->run();
    return $retval;
}

sub pulse
{
  my ($self) = @_;
  $self->{_pb}->show;
  $self->{_pb}->pulse;
}

sub destroy
{
    my $self = shift;
    $self->{_frmDoubleFileDialog}->destroy;
}

sub on_btnCancel_clicked
{
    my($button, $self) = @_;
    $self->{_frmDoubleFileDialog}->response('cancel');
}

sub on_btnOK_clicked
{
    my($button, $self) = @_;
    $self->{_frmDoubleFileDialog}->response('ok');
}

sub add_filters
{
    my ($diag) = @_;
    
    my $filter = new Gtk2::FileFilter();
    $filter->set_name("FASTA Files");
    $filter->add_pattern("*.fasta");
    $diag->add_filter($filter);

    $filter = new Gtk2::FileFilter();
    $filter->set_name("All Files");
    $filter->add_pattern("*");
    $diag->add_filter($filter);
}

sub on_btnPositiveFile_clicked
{
    my ($button, $self) = @_;
    
    my $diag = new Gtk2::FileChooserDialog("Choose positive file..", $self->{_frmDoubleFileDialog}, 'open', 'gtk-cancel' => 'cancel', 'gtk-open' => 'ok');
    
    add_filters($diag);
    
    if('ok' eq $diag->run)
    {
        my $filename = $diag->get_filename;
        $self->{_filePositive} = $filename;
        $self->{_builder}->get_object("btnPositiveFile")->set_label(basename($filename));
    }
    $diag->destroy;
}

sub on_btnNegativeFile_clicked
{
    my ($button, $self) = @_;
    my $diag = new Gtk2::FileChooserDialog("Choose negative file..", $self->{_frmDoubleFileDialog}, 'open', 'gtk-cancel' => 'cancel', 'gtk-open' => 'ok');
    
    add_filters($diag);
    
    if('ok' eq $diag->run)
    {
        my $filename = $diag->get_filename;
        $self->{_fileNegative} = $filename;
        $self->{_builder}->get_object("btnNegativeFile")->set_label(basename($filename));
    }
    $diag->destroy;
}

sub on_txtProjectName_changed
{
    my ($txt, $self) = @_;
    
    my $projectName = $txt->get_text;
    my $projectDir = $self->{_dirProject}->get_filename;
    
    if(-d "$projectDir/$projectName") {
        $self->{_btnOK}->set_sensitive(0);
    } else {
        $self->{_btnOK}->set_sensitive(1);
    }
}

1;

