#############################################################
#                                                           #
#   Class Name:  RunCommand                                 #
#   Description: Runs a command and shows it's output on a  #
#                textbox.                                   #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package RunCommand;

use Glib qw/TRUE FALSE/;
use Gtk2::SourceView;
use Gtk2::Helper;
use Gtk2 '-init';

#my $strfrmRunCommand = "REPLACE_HERE";

sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        _builder => undef,
        _window => undef,
        command => "",
        buffer => undef,
        txtOutput => undef
    };

    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmRunCommand))
    {
        $self->{_builder}->add_from_string($strfrmRunCommand);
    }else
    {
        $self->{_builder}->add_from_file("frmRunCommand.glade");
    }
    
    $self->{_builder}->connect_signals();
    
    $self->{_window} = $self->{_builder}->get_object("frmRunCommand");
    $self->{txtOutput} = $self->{_builder}->get_object("txtOutput");
    $self->{buffer} = $self->{txtOutput}->get_buffer;
    
    bless($self, $class);
    return $self;
}

sub runCommand
{
    my ($self, $cmd, $onDone) = @_;
 
    $self->{command} = $cmd;
    $self->{_window}->show();
    
    open my $pipe, "$cmd |";
    my $tag;

    my $buffer = $self->{buffer};
    my $win = $self->{_window};
    
    $tag = Gtk2::Helper->add_watch( fileno( $pipe ),
    in => sub
    {
        if ( eof( $pipe ) ) {
            Gtk2::Helper->remove_watch( $tag );
            close( $pipe );
            $win->destroy;
            
            if(defined($onDone))
            {
                &{$onDone}();
            }
        }
        else {
            my $line = <$pipe>;
            $buffer->insert( $buffer->get_end_iter, $line );
            $self->{txtOutput}->scroll_to_iter($buffer->get_end_iter, 0.0, TRUE, 0.0, 1.0);
        }

        return 1;
    } );
}

1;

