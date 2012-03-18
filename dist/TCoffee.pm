#############################################################
#                                                           #
#   Class Name:  TCoffee                                    #
#   Description: Shows a dialog to configure a TCoffee      #
#                session. Allows the aligning of sequences  #
#                negative sequence files.                   #
#   Author:      Diogo Costa (costa.h4evr@gmail.com)        #
#                                                           #
#############################################################

package TCoffee;

use Glib qw/TRUE FALSE/;
use Gtk2::Helper;
use Gtk2 '-init';

use Settings;
use RunCommand;
use SequencesFile;
use File::HomeDir qw(home);

my $TCOFFEE_DEFAULTS = home() . '/.lineagesequencediscovery/tcoffee.defaults';

my $strfrmTCoffee = "<?xml version=\"1.0\"?><interface>  <requires lib=\"gtk+\" version=\"2.16\"\/>  <!-- interface-naming-policy project-wide -->  <object class=\"GtkWindow\" id=\"frmTCoffee\">    <property name=\"title\" translatable=\"yes\">TCoffee<\/property>    <property name=\"window_position\">center<\/property>    <property name=\"destroy_with_parent\">True<\/property>    <child>      <object class=\"GtkVBox\" id=\"vbox1\">        <property name=\"visible\">True<\/property>        <property name=\"orientation\">vertical<\/property>        <child>          <object class=\"GtkVBox\" id=\"vbox2\">            <property name=\"visible\">True<\/property>            <property name=\"orientation\">vertical<\/property>            <child>              <object class=\"GtkHBox\" id=\"hbox2\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkLabel\" id=\"label3\">                    <property name=\"visible\">True<\/property>                    <property name=\"xalign\">0<\/property>                    <property name=\"label\" translatable=\"yes\">Computation Mode:<\/property>                  <\/object>                  <packing>                    <property name=\"expand\">False<\/property>                    <property name=\"padding\">4<\/property>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkComboBox\" id=\"cmbComputationMode\">                    <property name=\"visible\">True<\/property>                    <property name=\"model\">liststore1<\/property>                    <property name=\"active\">0<\/property>                    <child>                      <object class=\"GtkCellRendererText\" id=\"cellrenderertext1\"\/>                      <attributes>                        <attribute name=\"text\">0<\/attribute>                      <\/attributes>                    <\/child>                  <\/object>                  <packing>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"fill\">False<\/property>                <property name=\"position\">0<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkHBox\" id=\"hbox3\">                <property name=\"visible\">True<\/property>                <property name=\"homogeneous\">True<\/property>                <child>                  <object class=\"GtkLabel\" id=\"label4\">                    <property name=\"visible\">True<\/property>                    <property name=\"xalign\">0<\/property>                    <property name=\"label\" translatable=\"yes\">Maximum number of sequences:<\/property>                  <\/object>                  <packing>                    <property name=\"padding\">4<\/property>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkSpinButton\" id=\"spinMaxNumSequences\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"invisible_char\">&#x25CF;<\/property>                    <property name=\"adjustment\">adjustment1<\/property>                    <property name=\"numeric\">True<\/property>                    <property name=\"update_policy\">if-valid<\/property>                  <\/object>                  <packing>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"position\">1<\/property>              <\/packing>            <\/child>            <child>              <object class=\"GtkHBox\" id=\"hbox4\">                <property name=\"visible\">True<\/property>                <property name=\"homogeneous\">True<\/property>                <child>                  <object class=\"GtkLabel\" id=\"label5\">                    <property name=\"visible\">True<\/property>                    <property name=\"xalign\">0<\/property>                    <property name=\"label\" translatable=\"yes\">Maximum length of sequences:<\/property>                  <\/object>                  <packing>                    <property name=\"padding\">4<\/property>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkSpinButton\" id=\"spinMaximumLengthSequences\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"invisible_char\">&#x25CF;<\/property>                    <property name=\"adjustment\">adjustment2<\/property>                    <property name=\"numeric\">True<\/property>                    <property name=\"update_policy\">if-valid<\/property>                  <\/object>                  <packing>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"position\">2<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"position\">0<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkCheckButton\" id=\"chkProfiles\">            <property name=\"label\" translatable=\"yes\">Use profiles for aligning<\/property>            <property name=\"visible\">True<\/property>            <property name=\"can_focus\">True<\/property>            <property name=\"receives_default\">False<\/property>            <property name=\"active\">True<\/property>            <property name=\"draw_indicator\">True<\/property>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"position\">1<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkExpander\" id=\"expAdvanced\">            <property name=\"visible\">True<\/property>            <property name=\"can_focus\">True<\/property>            <child>              <object class=\"GtkHBox\" id=\"hbox1\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkLabel\" id=\"label6\">                    <property name=\"visible\">True<\/property>                  <\/object>                  <packing>                    <property name=\"expand\">False<\/property>                    <property name=\"fill\">False<\/property>                    <property name=\"padding\">10<\/property>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>                <child>                  <object class=\"GtkVBox\" id=\"vbox3\">                    <property name=\"visible\">True<\/property>                    <property name=\"orientation\">vertical<\/property>                    <child>                      <object class=\"GtkExpander\" id=\"expander2\">                        <property name=\"visible\">True<\/property>                        <property name=\"can_focus\">True<\/property>                        <child>                          <object class=\"GtkTable\" id=\"table1\">                            <property name=\"visible\">True<\/property>                            <property name=\"n_rows\">2<\/property>                            <property name=\"n_columns\">3<\/property>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[0]\">                                <property name=\"label\" translatable=\"yes\">best_pair4prot<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[1]\">                                <property name=\"label\" translatable=\"yes\">fast_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">1<\/property>                                <property name=\"right_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[2]\">                                <property name=\"label\" translatable=\"yes\">clustalw_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">2<\/property>                                <property name=\"right_attach\">3<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[3]\">                                <property name=\"label\" translatable=\"yes\">lalign_id_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[4]\">                                <property name=\"label\" translatable=\"yes\">slow_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">1<\/property>                                <property name=\"right_attach\">2<\/property>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseMethods[5]\">                                <property name=\"label\" translatable=\"yes\">proba_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">2<\/property>                                <property name=\"right_attach\">3<\/property>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                          <\/object>                        <\/child>                        <child type=\"label\">                          <object class=\"GtkLabel\" id=\"label7\">                            <property name=\"visible\">True<\/property>                            <property name=\"label\" translatable=\"yes\">Pairwise Methods<\/property>                          <\/object>                        <\/child>                      <\/object>                      <packing>                        <property name=\"expand\">False<\/property>                        <property name=\"position\">0<\/property>                      <\/packing>                    <\/child>                    <child>                      <object class=\"GtkExpander\" id=\"expander3\">                        <property name=\"visible\">True<\/property>                        <property name=\"can_focus\">True<\/property>                        <child>                          <object class=\"GtkTable\" id=\"table2\">                            <property name=\"visible\">True<\/property>                            <property name=\"n_columns\">4<\/property>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseStructuralMethods[0]\">                                <property name=\"label\" translatable=\"yes\">sap_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseStructuralMethods[1]\">                                <property name=\"label\" translatable=\"yes\">fugue_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">1<\/property>                                <property name=\"right_attach\">2<\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseStructuralMethods[2]\">                                <property name=\"label\" translatable=\"yes\">TMalign_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">2<\/property>                                <property name=\"right_attach\">3<\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"PairwiseStructuralMethods[3]\">                                <property name=\"label\" translatable=\"yes\">mustang_pair<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">3<\/property>                                <property name=\"right_attach\">4<\/property>                              <\/packing>                            <\/child>                          <\/object>                        <\/child>                        <child type=\"label\">                          <object class=\"GtkLabel\" id=\"label8\">                            <property name=\"visible\">True<\/property>                            <property name=\"label\" translatable=\"yes\">Pairwise Structural Methods<\/property>                          <\/object>                        <\/child>                      <\/object>                      <packing>                        <property name=\"expand\">False<\/property>                        <property name=\"position\">1<\/property>                      <\/packing>                    <\/child>                    <child>                      <object class=\"GtkExpander\" id=\"expander4\">                        <property name=\"visible\">True<\/property>                        <property name=\"can_focus\">True<\/property>                        <child>                          <object class=\"GtkTable\" id=\"table3\">                            <property name=\"visible\">True<\/property>                            <property name=\"n_rows\">2<\/property>                            <property name=\"n_columns\">4<\/property>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[0]\">                                <property name=\"label\" translatable=\"yes\">pcma_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[1]\">                                <property name=\"label\" translatable=\"yes\">mafft_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">1<\/property>                                <property name=\"right_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[2]\">                                <property name=\"label\" translatable=\"yes\">clustalw_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">2<\/property>                                <property name=\"right_attach\">3<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[3]\">                                <property name=\"label\" translatable=\"yes\">dialigntx_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">3<\/property>                                <property name=\"right_attach\">4<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[4]\">                                <property name=\"label\" translatable=\"yes\">poa_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[5]\">                                <property name=\"label\" translatable=\"yes\">muscle_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">1<\/property>                                <property name=\"right_attach\">2<\/property>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[6]\">                                <property name=\"label\" translatable=\"yes\">probcons_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">2<\/property>                                <property name=\"right_attach\">3<\/property>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkCheckButton\" id=\"MultipleMethods[7]\">                                <property name=\"label\" translatable=\"yes\">t_coffee_msa<\/property>                                <property name=\"visible\">True<\/property>                                <property name=\"can_focus\">True<\/property>                                <property name=\"receives_default\">False<\/property>                                <property name=\"draw_indicator\">True<\/property>                              <\/object>                              <packing>                                <property name=\"left_attach\">3<\/property>                                <property name=\"right_attach\">4<\/property>                                <property name=\"top_attach\">1<\/property>                                <property name=\"bottom_attach\">2<\/property>                                <property name=\"y_options\"><\/property>                              <\/packing>                            <\/child>                          <\/object>                        <\/child>                        <child type=\"label\">                          <object class=\"GtkLabel\" id=\"label9\">                            <property name=\"visible\">True<\/property>                            <property name=\"label\" translatable=\"yes\">Multiple Methods<\/property>                          <\/object>                        <\/child>                      <\/object>                      <packing>                        <property name=\"expand\">False<\/property>                        <property name=\"position\">2<\/property>                      <\/packing>                    <\/child>                    <child>                      <object class=\"GtkExpander\" id=\"expander5\">                        <property name=\"visible\">True<\/property>                        <property name=\"can_focus\">True<\/property>                        <child>                          <object class=\"GtkVBox\" id=\"vbox4\">                            <property name=\"visible\">True<\/property>                            <property name=\"orientation\">vertical<\/property>                            <child>                              <object class=\"GtkHBox\" id=\"hbox6\">                                <property name=\"visible\">True<\/property>                                <child>                                  <object class=\"GtkLabel\" id=\"label11\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"xalign\">0<\/property>                                    <property name=\"yalign\">0<\/property>                                    <property name=\"label\" translatable=\"yes\">Alignment Format: <\/property>                                  <\/object>                                  <packing>                                    <property name=\"expand\">False<\/property>                                    <property name=\"fill\">False<\/property>                                    <property name=\"padding\">4<\/property>                                    <property name=\"position\">0<\/property>                                  <\/packing>                                <\/child>                                <child>                                  <object class=\"GtkTable\" id=\"table4\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"n_rows\">3<\/property>                                    <property name=\"n_columns\">4<\/property>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[0]\">                                        <property name=\"label\" translatable=\"yes\">clustalw_aln<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"active\">True<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[4]\">                                        <property name=\"label\" translatable=\"yes\">gcg<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"top_attach\">1<\/property>                                        <property name=\"bottom_attach\">2<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[8]\">                                        <property name=\"label\" translatable=\"yes\">msf_aln<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"top_attach\">2<\/property>                                        <property name=\"bottom_attach\">3<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[1]\">                                        <property name=\"label\" translatable=\"yes\">pir_aln<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">1<\/property>                                        <property name=\"right_attach\">2<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[2]\">                                        <property name=\"label\" translatable=\"yes\">pir_seq<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">2<\/property>                                        <property name=\"right_attach\">3<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[3]\">                                        <property name=\"label\" translatable=\"yes\">score_pdf<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"active\">True<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">3<\/property>                                        <property name=\"right_attach\">4<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[5]\">                                        <property name=\"label\" translatable=\"yes\">fasta_aln<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"active\">True<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">1<\/property>                                        <property name=\"right_attach\">2<\/property>                                        <property name=\"top_attach\">1<\/property>                                        <property name=\"bottom_attach\">2<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[6]\">                                        <property name=\"label\" translatable=\"yes\">fasta_seq<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">2<\/property>                                        <property name=\"right_attach\">3<\/property>                                        <property name=\"top_attach\">1<\/property>                                        <property name=\"bottom_attach\">2<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[7]\">                                        <property name=\"label\" translatable=\"yes\">score_ascii<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">3<\/property>                                        <property name=\"right_attach\">4<\/property>                                        <property name=\"top_attach\">1<\/property>                                        <property name=\"bottom_attach\">2<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[9]\">                                        <property name=\"label\" translatable=\"yes\">phylip<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"active\">True<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">1<\/property>                                        <property name=\"right_attach\">2<\/property>                                        <property name=\"top_attach\">2<\/property>                                        <property name=\"bottom_attach\">3<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkCheckButton\" id=\"AlignmentFormat[10]\">                                        <property name=\"label\" translatable=\"yes\">score_html<\/property>                                        <property name=\"visible\">True<\/property>                                        <property name=\"can_focus\">True<\/property>                                        <property name=\"receives_default\">False<\/property>                                        <property name=\"active\">True<\/property>                                        <property name=\"draw_indicator\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">2<\/property>                                        <property name=\"right_attach\">3<\/property>                                        <property name=\"top_attach\">2<\/property>                                        <property name=\"bottom_attach\">3<\/property>                                      <\/packing>                                    <\/child>                                    <child>                                      <object class=\"GtkLabel\" id=\"label15\">                                        <property name=\"visible\">True<\/property>                                      <\/object>                                      <packing>                                        <property name=\"left_attach\">3<\/property>                                        <property name=\"right_attach\">4<\/property>                                        <property name=\"top_attach\">2<\/property>                                        <property name=\"bottom_attach\">3<\/property>                                      <\/packing>                                    <\/child>                                  <\/object>                                  <packing>                                    <property name=\"position\">1<\/property>                                  <\/packing>                                <\/child>                              <\/object>                              <packing>                                <property name=\"expand\">False<\/property>                                <property name=\"position\">0<\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkHBox\" id=\"hbox7\">                                <property name=\"visible\">True<\/property>                                <property name=\"homogeneous\">True<\/property>                                <child>                                  <object class=\"GtkLabel\" id=\"label12\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"xalign\">0<\/property>                                    <property name=\"label\" translatable=\"yes\">Case:<\/property>                                  <\/object>                                  <packing>                                    <property name=\"padding\">4<\/property>                                    <property name=\"position\">0<\/property>                                  <\/packing>                                <\/child>                                <child>                                  <object class=\"GtkComboBox\" id=\"cmbAdvancedCase\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"model\">liststore2<\/property>                                    <property name=\"active\">0<\/property>                                    <child>                                      <object class=\"GtkCellRendererText\" id=\"cellrenderertext3\"\/>                                      <attributes>                                        <attribute name=\"text\">0<\/attribute>                                      <\/attributes>                                    <\/child>                                  <\/object>                                  <packing>                                    <property name=\"position\">1<\/property>                                  <\/packing>                                <\/child>                              <\/object>                              <packing>                                <property name=\"expand\">False<\/property>                                <property name=\"position\">1<\/property>                              <\/packing>                            <\/child>                            <child>                              <object class=\"GtkHBox\" id=\"hbox8\">                                <property name=\"visible\">True<\/property>                                <property name=\"homogeneous\">True<\/property>                                <child>                                  <object class=\"GtkLabel\" id=\"label13\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"xalign\">0<\/property>                                    <property name=\"label\" translatable=\"yes\">Residue Number: <\/property>                                  <\/object>                                  <packing>                                    <property name=\"padding\">4<\/property>                                    <property name=\"position\">0<\/property>                                  <\/packing>                                <\/child>                                <child>                                  <object class=\"GtkComboBox\" id=\"cmbAdvancedResidueNumber\">                                    <property name=\"visible\">True<\/property>                                    <property name=\"model\">liststore3<\/property>                                    <property name=\"active\">0<\/property>                                    <child>                                      <object class=\"GtkCellRendererText\" id=\"cellrenderertext4\"\/>                                      <attributes>                                        <attribute name=\"text\">0<\/attribute>                                      <\/attributes>                                    <\/child>                                  <\/object>                                  <packing>                                    <property name=\"position\">1<\/property>                                  <\/packing>                                <\/child>                              <\/object>                              <packing>                                <property name=\"expand\">False<\/property>                                <property name=\"position\">2<\/property>                              <\/packing>                            <\/child>                          <\/object>                        <\/child>                        <child type=\"label\">                          <object class=\"GtkLabel\" id=\"label10\">                            <property name=\"visible\">True<\/property>                            <property name=\"label\" translatable=\"yes\">Output<\/property>                          <\/object>                        <\/child>                      <\/object>                      <packing>                        <property name=\"position\">3<\/property>                      <\/packing>                    <\/child>                  <\/object>                  <packing>                    <property name=\"position\">1<\/property>                  <\/packing>                <\/child>              <\/object>            <\/child>            <child type=\"label\">              <object class=\"GtkLabel\" id=\"label1\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Advanced<\/property>              <\/object>            <\/child>          <\/object>          <packing>            <property name=\"position\">2<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkExpander\" id=\"expander1\">            <property name=\"visible\">True<\/property>            <property name=\"can_focus\">True<\/property>            <child>              <object class=\"GtkHBox\" id=\"hbox5\">                <property name=\"visible\">True<\/property>                <child>                  <object class=\"GtkEntry\" id=\"txtCommandLine\">                    <property name=\"visible\">True<\/property>                    <property name=\"can_focus\">True<\/property>                    <property name=\"invisible_char\">&#x25CF;<\/property>                  <\/object>                  <packing>                    <property name=\"position\">0<\/property>                  <\/packing>                <\/child>              <\/object>            <\/child>            <child type=\"label\">              <object class=\"GtkLabel\" id=\"label2\">                <property name=\"visible\">True<\/property>                <property name=\"label\" translatable=\"yes\">Command line<\/property>              <\/object>            <\/child>          <\/object>          <packing>            <property name=\"position\">3<\/property>          <\/packing>        <\/child>        <child>          <object class=\"GtkHButtonBox\" id=\"buttonlayout\">            <property name=\"visible\">True<\/property>            <child>              <object class=\"GtkButton\" id=\"btnExecute\">                <property name=\"label\">gtk-execute<\/property>                <property name=\"visible\">True<\/property>                <property name=\"can_focus\">True<\/property>                <property name=\"receives_default\">True<\/property>                <property name=\"use_stock\">True<\/property>              <\/object>              <packing>                <property name=\"expand\">False<\/property>                <property name=\"fill\">False<\/property>                <property name=\"position\">0<\/property>              <\/packing>            <\/child>          <\/object>          <packing>            <property name=\"expand\">False<\/property>            <property name=\"padding\">4<\/property>            <property name=\"position\">4<\/property>          <\/packing>        <\/child>      <\/object>    <\/child>  <\/object>  <object class=\"GtkListStore\" id=\"liststore1\">    <columns>      <!-- column-name ComputationMode -->      <column type=\"gchararray\"\/>    <\/columns>    <data>      <row>        <col id=\"0\" translatable=\"yes\">Regular<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">Expresso<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">rcoffee<\/col>      <\/row>    <\/data>  <\/object>  <object class=\"GtkAdjustment\" id=\"adjustment1\">    <property name=\"value\">1000.0000000002235<\/property>    <property name=\"upper\">5000<\/property>    <property name=\"step_increment\">1<\/property>    <property name=\"page_increment\">10<\/property>  <\/object>  <object class=\"GtkListStore\" id=\"liststore2\">    <columns>      <!-- column-name Case -->      <column type=\"gchararray\"\/>    <\/columns>    <data>      <row>        <col id=\"0\" translatable=\"yes\">upper<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">lower<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">keep<\/col>      <\/row>    <\/data>  <\/object>  <object class=\"GtkListStore\" id=\"liststore3\">    <columns>      <!-- column-name ResidueNumber -->      <column type=\"gchararray\"\/>    <\/columns>    <data>      <row>        <col id=\"0\" translatable=\"yes\">on<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">off<\/col>      <\/row>    <\/data>  <\/object>  <object class=\"GtkListStore\" id=\"liststore4\">    <columns>      <!-- column-name Order -->      <column type=\"gchararray\"\/>    <\/columns>    <data>      <row>        <col id=\"0\" translatable=\"yes\">input<\/col>      <\/row>      <row>        <col id=\"0\" translatable=\"yes\">aligned<\/col>      <\/row>    <\/data>  <\/object>  <object class=\"GtkAdjustment\" id=\"adjustment2\">    <property name=\"value\">-1<\/property>    <property name=\"lower\">-1<\/property>    <property name=\"upper\">5000<\/property>    <property name=\"step_increment\">1<\/property>    <property name=\"page_increment\">10<\/property>  <\/object>  <object class=\"GtkAdjustment\" id=\"adjustment3\">    <property name=\"value\">1000<\/property>    <property name=\"upper\">5000<\/property>    <property name=\"step_increment\">1<\/property>    <property name=\"page_increment\">10<\/property>  <\/object>  <object class=\"GtkAdjustment\" id=\"adjustment4\">    <property name=\"value\">-1<\/property>    <property name=\"lower\">-1<\/property>    <property name=\"upper\">5000<\/property>    <property name=\"step_increment\">1<\/property>    <property name=\"page_increment\">10<\/property>  <\/object><\/interface>";

# Constructor
sub new
{
    my ($class) = @_;
    
    my $self = 
    {
        # GTK libbuilder stuff
        _builder              => undef,
        _frmTCoffee           => undef,
        _chkProfiles          => undef,
        _expAdvanced          => undef,
        baseDir               => "",
        fileToAlign           => "",
        posFile               => "",
        negFile               => "",
        cntPos                => 0,
        cntNeg                => 0,
        callback              => undef,
        _settings             => undef
    };
    
    bless $self, $class;
    
    $self->{_builder} = Gtk2::Builder->new;
    
    if(defined($strfrmTCoffee))
    {
        $self->{_builder}->add_from_string($strfrmTCoffee);
    }else
    {
        $self->{_builder}->add_from_file("frmTCoffee.glade");
    }
    
    $self->{_frmTCoffee} = $self->{_builder}->get_object("frmTCoffee");
    $self->{_chkProfiles} = $self->{_builder}->get_object("chkProfiles");
    $self->{_expAdvanced} = $self->{_builder}->get_object("expAdvanced");
    
    $self->{_builder}->get_object("btnExecute")->signal_connect(clicked => \&on_btnExecute_clicked, $self);
    
    $self->{_builder}->get_object("cmbComputationMode")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("spinMaxNumSequences")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("spinMaximumLengthSequences")->signal_connect(changed => \&updateCommandLine, $self);

    for(my $i = 0; $i < 6; ++$i)
    {
        $self->{_builder}->get_object("PairwiseMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);
    }    

    for(my $i = 0; $i < 4; ++$i)
    {
        $self->{_builder}->get_object("PairwiseStructuralMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    for(my $i = 0; $i < 8; ++$i)
    {
        my $obj = $self->{_builder}->get_object("MultipleMethods[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    for(my $i = 0; $i < 11; ++$i)
    {
        my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]")->signal_connect(toggled => \&updateCommandLine, $self);;
    }
    
    $self->{_builder}->get_object("cmbAdvancedCase")->signal_connect(changed => \&updateCommandLine, $self);
    $self->{_builder}->get_object("cmbAdvancedResidueNumber")->signal_connect(changed => \&updateCommandLine, $self);
    
    $self->{_expAdvanced}->signal_connect(activate => \&updateCommandLine, $self);
    
    $self->{_builder}->connect_signals();
    
    $self->{_settings} = new Settings($TCOFFEE_DEFAULTS, 
      {
        'ComputationMode' => 0,
        'MaxNumSequences' => 2000,
        'MaximumLengthSequences' => -1,
        'Profiles' => 1,
        
        # PairwiseMethods
        'PairwiseMethods[0]' => 0, 'PairwiseMethods[1]' => 0, 'PairwiseMethods[2]' => 0,
        'PairwiseMethods[3]' => 0, 'PairwiseMethods[4]' => 0, 'PairwiseMethods[5]' => 0,
        
        # PairwiseStructuralMethods
        'PairwiseStructuralMethods[0]' => 0, 'PairwiseStructuralMethods[1]' => 0,
        'PairwiseStructuralMethods[2]' => 0, 'PairwiseStructuralMethods[3]' => 0,
        
        # MultipleMethods
        'MultipleMethods[0]' => 0, 'MultipleMethods[1]' => 0, 'MultipleMethods[2]' => 0, 'MultipleMethods[3]' => 0,
        'MultipleMethods[4]' => 0, 'MultipleMethods[5]' => 0, 'MultipleMethods[6]' => 0, 'MultipleMethods[7]' => 0,
        
        # AlignmentFormat
        'AlignmentFormat[0]' => 1, 'AlignmentFormat[1]' => 0, 'AlignmentFormat[2]' => 0, 'AlignmentFormat[3]' => 1,
        'AlignmentFormat[4]' => 0, 'AlignmentFormat[5]' => 1, 'AlignmentFormat[6]' => 0, 'AlignmentFormat[7]' => 0,
        'AlignmentFormat[8]' => 0, 'AlignmentFormat[9]' => 1, 'AlignmentFormat[10]' => 1,
        
        # Case
        'Case' => 2,
        
        # ResidueNumber
        'ResidueNumber' => 1
      }
    );
    
    $self->{_settings}->save($TCOFFEE_DEFAULTS) unless(-e $TCOFFEE_DEFAULTS);
    
    return $self;
}

sub alignFile
{
    my ($self, $basedir, $file, $posFile, $negFile, $cntPos, $cntNeg, $onDone) = @_;
    $self->{baseDir} = $basedir;
    $self->{fileToAlign} = $file;
    $self->{posFile} = $posFile;
    $self->{negFile} = $negFile;
    $self->{cntPos} = $cntPos;
    $self->{cntNeg} = $cntNeg;
    $self->{callback} = $onDone;
    $self->{_frmTCoffee}->show();
    
    $self->{_builder}->get_object("spinMaxNumSequences")->set_value($self->{_settings}->get('MaxNumSequences'));
    $self->{_builder}->get_object("spinMaximumLengthSequences")->set_value($self->{_settings}->get('MaximumLengthSequences'));
    $self->{_builder}->get_object("cmbComputationMode")->set_active($self->{_settings}->get('ComputationMode'));
    $self->{_builder}->get_object("chkProfiles")->set_active($self->{_settings}->get('Profiles'));
    
    for(my $i = 0; $i < 6; ++$i)
    {
        $self->{_builder}->get_object("PairwiseMethods[$i]")->set_active($self->{_settings}->get("PairwiseMethods[$i]"));
    }    

    for(my $i = 0; $i < 4; ++$i)
    {
        $self->{_builder}->get_object("PairwiseStructuralMethods[$i]")->set_active($self->{_settings}->get("PairwiseStructuralMethods[$i]"));
    }
    
    for(my $i = 0; $i < 8; ++$i)
    {
        my $obj = $self->{_builder}->get_object("MultipleMethods[$i]")->set_active($self->{_settings}->get("MultipleMethods[$i]"));
    }
    
    for(my $i = 0; $i < 11; ++$i)
    {
        my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]")->set_active($self->{_settings}->get("AlignmentFormat[$i]"));
    }
    
    $self->{_builder}->get_object("cmbAdvancedCase")->set_active($self->{_settings}->get('Case'));
    $self->{_builder}->get_object("cmbAdvancedResidueNumber")->set_active($self->{_settings}->get('ResidueNumber'));
}

sub do_it
{
    my ($self, $useProfiles) = @_;
    
    if($useProfiles)                     
    {
        my $cmd = 't_coffee ';
        my $outfile = '"' . $self->{negFile} . '"';        
        $cmd .= $outfile;
        #for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }        
        $cmd .= $self->{_builder}->get_object("txtCommandLine")->get_text;
        $cmd .= ' -outfile=\''.$self->{baseDir}.'/negfile.aln\' 2>&1';
        
        #print("Running: $cmd\n");
        
        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd,
        sub {
            my $canceled = shift;
            if($canceled == 1) {
                $self->{_frmTCoffee}->destroy(); 
                return;
            }
            
            $cmd = 't_coffee ';
            $outfile = '"'. $self->{posFile} . '"';   
            $cmd .= $outfile;
            $cmd .= ' -profile \''.$self->{baseDir}.'/negfile.aln\' -outfile=\''.$self->{baseDir}.'/out.aln\' 2>&1';
            print("Running: $cmd\n");
            $runcmd = new RunCommand;
            $runcmd->runCommand($cmd,
                sub { 
                    my $canceled = shift;
                    $self->{_frmTCoffee}->destroy(); 
                    return if($canceled == 1);
                    process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); 
                    });
        });
        
    }else
    {
        my $cmd = 't_coffee ';
        my $outfile = '"'.$self->{baseDir}. '/'. $self->{fileToAlign} . '"';

        $cmd .= $outfile;

        #for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }        
        $cmd .= $self->{_builder}->get_object("txtCommandLine")->get_text;
        
        $cmd .= ' 2>&1';

        my $runcmd = new RunCommand;
        $runcmd->runCommand($cmd, 
        sub { 
            my $canceled = shift;
            $self->{_frmTCoffee}->destroy(); 
            return if($canceled == 1);
            process_out_file($self->{callback}, "out.aln", $self->{posFile}, $self->{negFile}, $self->{cntPos}, $self->{cntNeg}, $self); });
    }
}

sub updateCommandLine
{
    my ($btn, $self) = @_;
    
    my $useAdvanced = $self->{_expAdvanced}->get_expanded;
    $useAdvanced = !$useAdvanced if($btn == $self->{_expAdvanced});
    my %params = ();
    
    $params{'mode'} = lc($self->{_builder}->get_object("cmbComputationMode")->get_active_text);
    $params{'-maxnseq'} = $self->{_builder}->get_object("spinMaxNumSequences")->get_value;
    $params{'-maxlen'}  = $self->{_builder}->get_object("spinMaximumLengthSequences")->get_value;
    
    if($useAdvanced)
    {
        my $modeStr = "";
        for(my $i = 0; $i < 6; ++$i)
        {
            my $obj = $self->{_builder}->get_object("PairwiseMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }    

        for(my $i = 0; $i < 4; ++$i)
        {
            my $obj = $self->{_builder}->get_object("PairwiseStructuralMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-in'} = $modeStr if(length($modeStr) > 0);
        
        $modeStr = "";
        for(my $i = 0; $i < 8; ++$i)
        {
            my $obj = $self->{_builder}->get_object("MultipleMethods[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-method'} = $modeStr if(length($modeStr) > 0);

        $modeStr = "";
        for(my $i = 0; $i < 11; ++$i)
        {
            my $obj = $self->{_builder}->get_object("AlignmentFormat[$i]");
            
            if($obj->get_active)
            {
                $modeStr .= "," if length($modeStr) > 0;
                $modeStr .= $obj->get_label;
            }
        }
        
        $params{'-output'} = $modeStr if(length($modeStr) > 0);
        
        $params{'-case'} = lc($self->{_builder}->get_object("cmbAdvancedCase")->get_active_text);
        $params{'-seqnos'} = lc($self->{_builder}->get_object("cmbAdvancedResidueNumber")->get_active_text);
    }
    
    my $cmd = "";
    for my $k (keys %params) { $cmd .= ' ' . $k . ' ' . $params{$k}; }
    
    $self->{_builder}->get_object("txtCommandLine")->set_text($cmd);
}

sub on_btnExecute_clicked
{
    my ($btn, $self) = @_;
    my $useProfiles = $self->{_chkProfiles}->get_active;    
    updateCommandLine($btn, $self);
    $self->do_it($useProfiles);
}

sub process_out_file
{
    my ($callback, $outfile, $posFile, $negFile, $cntPos, $cntNeg, $self) = @_;
    
    my $outSeqs = new SequencesFile();
    $outSeqs->load($self->{baseDir}.'/'.$outfile);
    
    if( $outSeqs->numSequences > $cntPos + $cntNeg )
    {
        print("WARNING: Number of sequences on out file is greater than the sum of sequences from the positive and negatives files! Continuing...\n");
    }elsif ($outSeqs->numSequences < $cntPos + $cntNeg)
    {
        print("ERROR: Number of sequences on out file is lower than the sum of sequences from the positive and negatives files! Exiting!\n");
        return;
    }
    
    my $posSeqs = new SequencesFile();
    my $negSeqs = new SequencesFile();
    
    my $totSeqs = $cntPos + $cntNeg;
    
    for(my $i = 0; $i < $cntPos; ++$i)
    {
        my %seq = $outSeqs->getSequence($i);
        $posSeqs->addSequence($seq{'header'}, $seq{'seq'}, $seq{'spaces'});
    }
    
    for(my $i = $cntPos; $i < $totSeqs; ++$i)
    {
        my %seq = $outSeqs->getSequence($i);
        $negSeqs->addSequence($seq{'header'}, $seq{'seq'}, $seq{'spaces'});
    }
    
    &{$callback}($posSeqs, $negSeqs);
}

1;

