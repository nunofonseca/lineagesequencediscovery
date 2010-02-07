#############################################################
#                                                           #
#   Class Name:  NewSessionDialog                           #
#   Description: Shows a dialog to open a positive and a    #
#                negative sequence files.                   #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package NewSessionDialog;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';

#my $strfrmNewSession = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmNewSession        => undef,
        _txtPercTraining      => undef,
        _txtEstimatedHomology => undef,
        _txtOutputFilePrefix  => undef,
        _filePositive         => undef,
        _fileNegative         => undef        
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmNewSession))
    {
        $self->{_builder}->add_from_string($strfrmNewSession);
    }else
    {
        $self->{_builder}->add_from_file("frmNewSession.glade");
    }
    
    $self->{_frmNewSession}        = $self->{_builder}->get_object("frmNewSession");
    $self->{_txtPercTraining}      = $self->{_builder}->get_object("txtPercTraining");
    $self->{_txtEstimatedHomology} = $self->{_builder}->get_object("txtEstimatedHomology");
    $self->{_txtOutputFilePrefix}  = $self->{_builder}->get_object("txtOutputFilePrefix");
    $self->{_filePositive}         = $self->{_builder}->get_object("filePositive");
    $self->{_fileNegative}         = $self->{_builder}->get_object("fileNegative");
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

sub percentageTraining
{
    my ($self) = @_;
    my $res = $self->{_txtPercTraining}->get_text() + 0.0;
    return $res;
}

sub estimatedHomology
{
    my ($self) = @_;
    my $res = $self->{_txtEstimatedHomology}->get_text() + 0.0;
    return $res;
}

sub outputFilePrefix
{
    my ($self) = @_;
    return $self->{_txtEstimatedHomology}->get_text();
}

sub filePositive
{
    my ($self) = @_;
    #return "/home/h4evr/IBMC/Refactored/proteins2000.fasta";
    #return "/home/h4evr/IBMC/Refactored/pos_file_test.fasta";
    return $self->{_filePositive}->get_filename();
}

sub fileNegative
{
    my ($self) = @_;
    #return "/home/h4evr/IBMC/Refactored/retrovirus5000.fasta";
    #return "/home/h4evr/IBMC/Refactored/neg_file_test.fasta";
    return $self->{_fileNegative}->get_filename();
}

# Show the dialog and wait for answer ( 1 if open, 0 if cancel )
sub run
{
    my ($self) = @_;
    
    #return 1;
    
    if( 'ok' eq $self->{_frmNewSession}->run() )
    {
        $self->{_frmNewSession}->hide;
        return 1 ;    
    }else
    {
        $self->{_frmNewSession}->hide;
        return 0;    
    }
}

sub on_btnCancel_clicked
{
    my($button, $dialog) = @_;
    $dialog->response('cancel');
}

sub on_btnOpen_clicked
{
    my($button, $dialog) = @_;
    $dialog->response('ok');
}

1;

