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

#my $strfrmDoubleFileDialog = "REPLACE_HERE";

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

