
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_msg_id "BD_TCL-1002" "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set vv_path $::env(XILINX_VV)
if {![file exist $vv_path/data/boards/board_files/TE0714_35_2I/1.0]} {
    file copy -force $script_folder/board/TE0714_35_2I $vv_path/data/boards/board_files
}

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project -force artix_base $script_folder/vv_gold -part xc7a35tcsg325-2
   set_property BOARD_PART trenz.biz:te0714_35_2i:part0:1.0 [current_project]
   set origin_dir "."
   set obj [get_projects artix_base]
}

set_property -name "target_language" -value "Verilog" -objects $obj
set_property default_lib work [current_project]
set_property target_simulator ModelSim [current_project]
set_property compxlib.modelsim_compiled_library_dir $script_folder/sim/compile_simlib [current_project]

add_files -fileset constrs_1 -norecurse $script_folder/src/main_gold.xdc

add_files -norecurse $script_folder/src/main_gold.v
add_files -norecurse $script_folder/src/vicg_common_pkg.vhd
add_files -norecurse $script_folder/src/time_gen.vhd
add_files -norecurse $script_folder/src/fpga_test_01.vhd
set_property include_dirs $script_folder/src [current_fileset]

#add_files -fileset sim_1 -norecurse $script_folder/sim/main_tb.v
#set_property include_dirs $script_folder/src/ [get_filesets sim_1]
#set_property -name {modelsim.simulate.custom_wave_do} -value $script_folder/sim/main_wave.do -objects [get_filesets sim_1]
#set_property -name {modelsim.simulate.runtime} -value {5us} -objects [get_filesets sim_1]

#set obj [get_runs synth_1]
#set_property steps.synth_design.tcl.pre [file normalize "$script_folder/src/firmware_gold_rev.tcl"] $obj
##-include_dirs is path at dir ./vv/<name>.runs/synth_1
#set_property -name {steps.synth_design.args.more options} -value {-include_dirs ../../../src} -objects $obj

set obj [get_runs impl_1]
set_property steps.write_bitstream.tcl.post [file normalize "$script_folder/src/firmware_gold_copy.tcl"] $obj
