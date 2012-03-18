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

my $strfrmNewSession = "<?xml version=\"1.0\"?>\n<interface>\n  <requires lib=\"gtk+\" version=\"2.16\"\/>\n  <!-- interface-naming-policy project-wide -->\n  <object class=\"GtkDialog\" id=\"frmNewSession\">\n    <property name=\"border_width\">5<\/property>\n    <property name=\"title\" translatable=\"yes\">New Session<\/property>\n    <property name=\"type_hint\">normal<\/property>\n    <property name=\"has_separator\">False<\/property>\n    <child internal-child=\"vbox\">\n      <object class=\"GtkVBox\" id=\"dialog-vbox1\">\n        <property name=\"visible\">True<\/property>\n        <property name=\"orientation\">vertical<\/property>\n        <property name=\"spacing\">2<\/property>\n        <child>\n          <object class=\"GtkTable\" id=\"table1\">\n            <property name=\"visible\">True<\/property>\n            <property name=\"n_rows\">2<\/property>\n            <property name=\"n_columns\">2<\/property>\n            <child>\n              <object class=\"GtkLabel\" id=\"label4\">\n                <property name=\"visible\">True<\/property>\n                <property name=\"xalign\">1<\/property>\n                <property name=\"label\" translatable=\"yes\">Positive file<\/property>\n              <\/object>\n              <packing>\n                <property name=\"x_padding\">5<\/property>\n              <\/packing>\n            <\/child>\n            <child>\n              <object class=\"GtkLabel\" id=\"label5\">\n                <property name=\"visible\">True<\/property>\n                <property name=\"xalign\">1<\/property>\n                <property name=\"label\" translatable=\"yes\">Negative\/Control file<\/property>\n              <\/object>\n              <packing>\n                <property name=\"top_attach\">1<\/property>\n                <property name=\"bottom_attach\">2<\/property>\n                <property name=\"x_padding\">5<\/property>\n              <\/packing>\n            <\/child>\n            <child>\n              <object class=\"GtkFileChooserButton\" id=\"filePositive\">\n                <property name=\"visible\">True<\/property>\n                <property name=\"create_folders\">False<\/property>\n                <property name=\"use_preview_label\">False<\/property>\n                <property name=\"preview_widget_active\">False<\/property>\n                <property name=\"title\" translatable=\"yes\">Select a file<\/property>\n              <\/object>\n              <packing>\n                <property name=\"left_attach\">1<\/property>\n                <property name=\"right_attach\">2<\/property>\n              <\/packing>\n            <\/child>\n            <child>\n              <object class=\"GtkFileChooserButton\" id=\"fileNegative\">\n                <property name=\"visible\">True<\/property>\n                <property name=\"create_folders\">False<\/property>\n                <property name=\"use_preview_label\">False<\/property>\n                <property name=\"title\" translatable=\"yes\">Select a file<\/property>\n              <\/object>\n              <packing>\n                <property name=\"left_attach\">1<\/property>\n                <property name=\"right_attach\">2<\/property>\n                <property name=\"top_attach\">1<\/property>\n                <property name=\"bottom_attach\">2<\/property>\n              <\/packing>\n            <\/child>\n          <\/object>\n          <packing>\n            <property name=\"position\">1<\/property>\n          <\/packing>\n        <\/child>\n        <child internal-child=\"action_area\">\n          <object class=\"GtkHButtonBox\" id=\"dialog-action_area1\">\n            <property name=\"visible\">True<\/property>\n            <property name=\"layout_style\">end<\/property>\n            <child>\n              <object class=\"GtkButton\" id=\"btnCancel\">\n                <property name=\"label\">gtk-cancel<\/property>\n                <property name=\"visible\">True<\/property>\n                <property name=\"can_focus\">True<\/property>\n                <property name=\"receives_default\">True<\/property>\n                <property name=\"use_stock\">True<\/property>\n                <signal name=\"clicked\" handler=\"on_btnCancel_clicked\" object=\"frmNewSession\"\/>\n              <\/object>\n              <packing>\n                <property name=\"expand\">False<\/property>\n                <property name=\"fill\">False<\/property>\n                <property name=\"position\">0<\/property>\n              <\/packing>\n            <\/child>\n            <child>\n              <object class=\"GtkButton\" id=\"btnOpen\">\n                <property name=\"label\">gtk-open<\/property>\n                <property name=\"visible\">True<\/property>\n                <property name=\"can_focus\">True<\/property>\n                <property name=\"receives_default\">True<\/property>\n                <property name=\"use_stock\">True<\/property>\n                <signal name=\"clicked\" handler=\"on_btnOpen_clicked\" object=\"frmNewSession\"\/>\n              <\/object>\n              <packing>\n                <property name=\"expand\">False<\/property>\n                <property name=\"fill\">False<\/property>\n                <property name=\"position\">1<\/property>\n              <\/packing>\n            <\/child>\n          <\/object>\n          <packing>\n            <property name=\"expand\">False<\/property>\n            <property name=\"pack_type\">end<\/property>\n            <property name=\"position\">0<\/property>\n          <\/packing>\n        <\/child>\n      <\/object>\n    <\/child>\n    <action-widgets>\n      <action-widget response=\"0\">btnCancel<\/action-widget>\n      <action-widget response=\"0\">btnOpen<\/action-widget>\n    <\/action-widgets>\n  <\/object>\n<\/interface>\n";

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmNewSession        => undef,
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
    $self->{_filePositive}         = $self->{_builder}->get_object("filePositive");
    $self->{_fileNegative}         = $self->{_builder}->get_object("fileNegative");
    
    
    
    $self->{_builder}->connect_signals();
    
    return $self;
}

sub filePositive
{
    my ($self) = @_;
    #return "/home/h4evr/IBMC/Refactored/proteins2000.fasta";
    return "/home/h4evr/IBMC/Refactored/pos_file_test.fasta";
    #return $self->{_filePositive}->get_filename();
}

sub fileNegative
{
    my ($self) = @_;
    #return "/home/h4evr/IBMC/Refactored/retrovirus5000.fasta";
    return "/home/h4evr/IBMC/Refactored/neg_file_test.fasta";
    #return $self->{_fileNegative}->get_filename();
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

