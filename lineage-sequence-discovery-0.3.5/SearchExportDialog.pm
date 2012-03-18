#############################################################
#                                                           #
#   Class Name:  SearchExportDialog                         #
#   Description: Shows a dialog to save search results in   #
#                ARFF or CSV formats.                       #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package SearchExportDialog;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';

#my $strfrmSearchExport = "REPLACE_HERE";

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmSearchExport        => undef     
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmSearchExport))
    {
        $self->{_builder}->add_from_string($strfrmSearchExport);
    }else
    {
        $self->{_builder}->add_from_file("frmSearchExport.glade");
    }
    
    $self->{_frmSearchExport} = $self->{_builder}->get_object("frmSearchExport");
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

# Show the dialog and wait for answer ( 1 if open, 0 if cancel )
sub run
{
    my ($self) = @_;
    
    return 1;
    
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

1;

