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
use Gtk2::Helper;
use Gtk2 '-init';
use Glib qw(TRUE FALSE);

my $strfrmRunCommand = "<?xml version=\"1.0\"?><interface>  <requires lib=\"gtk+\" version=\"2.16\"\/>  <!-- interface-naming-policy project-wide -->  <object class=\"GtkWindow\" id=\"frmRunCommand\">    <property name=\"title\" translatable=\"yes\">Running...<\/property>    <property name=\"window_position\">center<\/property>    <property name=\"default_width\">640<\/property>    <property name=\"default_height\">480<\/property>    <child>      <object class=\"GtkHBox\" id=\"hbox1\">        <property name=\"visible\">True<\/property>        <property name=\"spacing\">2<\/property>        <child>          <object class=\"GtkVBox\" id=\"vbox1\">            <property name=\"visible\">True<\/property>            <property name=\"orientation\">vertical<\/property>            <child>              <object class=\"GtkLabel\" id=\"label1\">                <property name=\"visible\">True<\/property>                <property name=\"xalign\">0<\/property>                <property name=\"label\" translatable=\"yes\">Output:<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"padding\">2<\/property>                <property name=\"position\">0<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkScrolledWindow\" id=\"scrolledwindow1\">                <property name=\"visible\">True<\/property>                <property name=\"can_focus\">True<\/property>                <property name=\"hscrollbar_policy\">automatic<\/property>                <property name=\"vscrollbar_policy\">automatic<\/property>                <child>                  <object class=\"GtkTextView\" id=\"txtOutput\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                  <\/object>                <\/child>              <\/object>              <packing>                <property name=\"position\">1<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkHButtonBox\" id=\"hbuttonbox1\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkButton\" id=\"btnCancel\">                    <property name=\"label\">gtk-cancel<\/property>                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"receives_default\">True<\/property>                    <property name=\"use_stock\">True<\/property>                  <\/object>                  <packing>                    <property name=\"expand\">False<\/property>                    <property name=\"fill\">False<\/property>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"padding\">5<\/property>                <property name=\"position\">2<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"padding\">5<\/property>            <property name=\"position\">0<\/property>          <\/packing>        <\/child>      <\/object>    <\/child>  <\/object><\/interface>";

sub new
{
    my ($class, $autohide) = @_;
    
    my $self = 
    {
        _builder => undef,
        _window => undef,
        command => "",
        buffer => undef,
        txtOutput => undef,
        autohide => 1,
        _canceled => 0
    };

    $self->{autohide} = $autohide if defined($autohide);
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
    $self->{_builder}->get_object("btnCancel")->signal_connect(clicked => \&on_btnCancel_clicked, $self);
    
    bless($self, $class);
    return $self;
}

sub destroy
{
    my ($self) = @_;
    $self->{_window}->destroy();
}

sub getOutput
{
    my ($self) = @_;
    if(defined($self->{buffer})) {
        return $self->{buffer}->get_text($self->{buffer}->get_start_iter, $self->{buffer}->get_end_iter, 0);
    }else{
        return "";
    }
}

sub runCommand
{
    my ($self, $cmd, $onDone) = @_;

    print (("-" x 80)."\n");
    print scalar localtime;
    print ("\n".("-" x 80)."\n");
    print "Running command: $cmd\n";
 
    $self->{command} = $cmd;
    $self->{_window}->show;
    $self->{_canceled} = 0;
    $self->{_builder}->get_object("btnCancel")->set_sensitive(1);
    
    my $pid = open my $pipe, "$cmd |";
    
    my $tag;

    my $buffer = $self->{buffer};
    my $win = $self->{_window};
    
    my $updater = Glib::Timeout->add(500, 
                  sub { 
                    if($self->{_canceled} == 1) {
                        kill 9, $pid+1;
                    }
                    Gtk2->main_iteration while Gtk2->events_pending;
                    return TRUE; 
                  });
                               
    $tag = Gtk2::Helper->add_watch( fileno( $pipe ),
    in => sub
    {
        if($self->{_canceled} == 1) {
            kill 9, $pid+1;
        }
        
        Gtk2->main_iteration while Gtk2->events_pending;
        if ( eof( $pipe ) ) {
            Glib::Source->remove($updater);
            Gtk2::Helper->remove_watch( $tag );
            close( $pipe );
            
            print "Output:\n";
            print $self->getOutput;
            print "\n".("-"x80)."\n\n";
    
            $win->destroy if $self->{autohide};
            
            if(defined($onDone))
            {
                &{$onDone}($self->{_canceled});
            }
        }
        else {
            my $line = <$pipe>;
            Gtk2->main_iteration while Gtk2->events_pending;
            $buffer->insert( $buffer->get_end_iter, $line );
            Gtk2->main_iteration while Gtk2->events_pending;
            $self->{txtOutput}->scroll_to_iter($buffer->get_end_iter, 0.0, TRUE, 0.0, 1.0);
        }

        return 1;
    } );
}

sub on_btnCancel_clicked
{
    my ($btn, $self) = @_;
    $self->{_canceled} = 1;
    $self->{_builder}->get_object("btnCancel")->set_sensitive(0);
}

1;

