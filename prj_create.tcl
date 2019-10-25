
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

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project -force artix_base $script_folder/vv -part xc7a35tcsg325-2
   set origin_dir "."
   set obj [get_projects artix_base]
#   set_property "ip_repo_paths" "[file normalize "$origin_dir/src/vv_ip_repo"]" $obj
#   # Rebuild user ip_repo's index before adding any source files
#   update_ip_catalog -rebuild
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\
xilinx.com:ip:tri_mode_ethernet_mac:*\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set eth0_m_axis_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 eth0_m_axis_rx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $eth0_m_axis_rx
  set eth0_rgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 eth0_rgmii ]
  set eth0_rgmii_status [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_tri_mode_ethernet_mac:rgmii_status_rtl:1.0 eth0_rgmii_status ]
  set eth0_s_axis_pause [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 eth0_s_axis_pause ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {2} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $eth0_s_axis_pause
  set eth0_s_axis_tx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 eth0_s_axis_tx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $eth0_s_axis_tx
  set eth0_statistics_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_tri_mode_ethernet_mac:statistics_rtl:1.0 eth0_statistics_rx ]
  set eth0_statistics_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_tri_mode_ethernet_mac:statistics_rtl:1.0 eth0_statistics_tx ]

  # Create ports
  set eth0_cfg_vector_rx [ create_bd_port -dir I -from 79 -to 0 eth0_cfg_vector_rx ]
  set eth0_cfg_vector_tx [ create_bd_port -dir I -from 79 -to 0 eth0_cfg_vector_tx ]
  set eth0_glbl_rstn [ create_bd_port -dir I -type rst eth0_glbl_rstn ]
  set eth0_gtx_clk [ create_bd_port -dir I -type clk eth0_gtx_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PHASE {0} \
 ] $eth0_gtx_clk
  set eth0_rx_mac_aclk [ create_bd_port -dir O -type clk eth0_rx_mac_aclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $eth0_rx_mac_aclk
  set eth0_tx_ifg_delay [ create_bd_port -dir I -from 7 -to 0 eth0_tx_ifg_delay ]
  set eth0_tx_mac_aclk [ create_bd_port -dir O -type clk eth0_tx_mac_aclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $eth0_tx_mac_aclk

  # Create instance: tri_mode_ethernet_mac_0, and set properties
  set tri_mode_ethernet_mac_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:tri_mode_ethernet_mac tri_mode_ethernet_mac_0 ]
  set_property -dict [ list \
   CONFIG.Enable_MDIO {false} \
   CONFIG.MAC_Speed {1000_Mbps} \
   CONFIG.Make_MDIO_External {false} \
   CONFIG.Management_Interface {false} \
   CONFIG.Number_of_Table_Entries {0} \
   CONFIG.Physical_Interface {RGMII} \
   CONFIG.Statistics_Counters {false} \
 ] $tri_mode_ethernet_mac_0

  # Create interface connections
  connect_bd_intf_net -intf_net s_axis_pause_0_1 [get_bd_intf_ports eth0_s_axis_pause] [get_bd_intf_pins tri_mode_ethernet_mac_0/s_axis_pause]
  connect_bd_intf_net -intf_net s_axis_tx_0_1 [get_bd_intf_ports eth0_s_axis_tx] [get_bd_intf_pins tri_mode_ethernet_mac_0/s_axis_tx]
  connect_bd_intf_net -intf_net tri_mode_ethernet_mac_0_m_axis_rx [get_bd_intf_ports eth0_m_axis_rx] [get_bd_intf_pins tri_mode_ethernet_mac_0/m_axis_rx]
  connect_bd_intf_net -intf_net tri_mode_ethernet_mac_0_rgmii [get_bd_intf_ports eth0_rgmii] [get_bd_intf_pins tri_mode_ethernet_mac_0/rgmii]
  connect_bd_intf_net -intf_net tri_mode_ethernet_mac_0_rgmii_status [get_bd_intf_ports eth0_rgmii_status] [get_bd_intf_pins tri_mode_ethernet_mac_0/rgmii_status]
  connect_bd_intf_net -intf_net tri_mode_ethernet_mac_0_rx_statistics [get_bd_intf_ports eth0_statistics_rx] [get_bd_intf_pins tri_mode_ethernet_mac_0/rx_statistics]
  connect_bd_intf_net -intf_net tri_mode_ethernet_mac_0_tx_statistics [get_bd_intf_ports eth0_statistics_tx] [get_bd_intf_pins tri_mode_ethernet_mac_0/tx_statistics]

  # Create port connections
  connect_bd_net -net glbl_rstn_0_1 [get_bd_ports eth0_glbl_rstn] [get_bd_pins tri_mode_ethernet_mac_0/glbl_rstn]
  connect_bd_net -net gtx_clk_0_1 [get_bd_ports eth0_gtx_clk] [get_bd_pins tri_mode_ethernet_mac_0/gtx_clk] [get_bd_pins tri_mode_ethernet_mac_0/gtx_clk90]
  connect_bd_net -net rx_configuration_vector_0_1 [get_bd_ports eth0_cfg_vector_rx] [get_bd_pins tri_mode_ethernet_mac_0/rx_configuration_vector]
  connect_bd_net -net tri_mode_ethernet_mac_0_rx_mac_aclk [get_bd_ports eth0_rx_mac_aclk] [get_bd_pins tri_mode_ethernet_mac_0/rx_mac_aclk]
  connect_bd_net -net tri_mode_ethernet_mac_0_rx_reset [get_bd_pins tri_mode_ethernet_mac_0/rx_axi_rstn] [get_bd_pins tri_mode_ethernet_mac_0/rx_reset]
  connect_bd_net -net tri_mode_ethernet_mac_0_tx_mac_aclk [get_bd_ports eth0_tx_mac_aclk] [get_bd_pins tri_mode_ethernet_mac_0/tx_mac_aclk]
  connect_bd_net -net tri_mode_ethernet_mac_0_tx_reset [get_bd_pins tri_mode_ethernet_mac_0/tx_axi_rstn] [get_bd_pins tri_mode_ethernet_mac_0/tx_reset]
  connect_bd_net -net tx_configuration_vector_0_1 [get_bd_ports eth0_cfg_vector_tx] [get_bd_pins tri_mode_ethernet_mac_0/tx_configuration_vector]
  connect_bd_net -net tx_ifg_delay_0_1 [get_bd_ports eth0_tx_ifg_delay] [get_bd_pins tri_mode_ethernet_mac_0/tx_ifg_delay]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

set_property -name "target_language" -value "Verilog" -objects $obj
set_property default_lib work [current_project]
set_property target_simulator ModelSim [current_project]
set_property compxlib.modelsim_compiled_library_dir $script_folder/sim/compile_simlib [current_project]

add_files -fileset constrs_1 -norecurse $script_folder/src/main.xdc

add_files -norecurse $script_folder/src/main.v
add_files -norecurse $script_folder/src/firmware_rev.v
set_property include_dirs $script_folder/src [current_fileset]

#add_files -fileset sim_1 -norecurse $script_folder/sim/main_tb.v
#set_property include_dirs $script_folder/src/ [get_filesets sim_1]
#set_property -name {modelsim.simulate.custom_wave_do} -value $script_folder/sim/main_wave.do -objects [get_filesets sim_1]
#set_property -name {modelsim.simulate.runtime} -value {5us} -objects [get_filesets sim_1]
#
#set obj [get_runs synth_1]
#set_property steps.synth_design.tcl.pre [file normalize "$script_folder/src/firmware_rev.tcl"] $obj
##-include_dirs is path at dir ./vv/<name>.runs/synth_1
##set_property -name {steps.synth_design.args.more options} -value {-include_dirs ../../../src} -objects $obj
#
#set obj [get_runs impl_1]
#set_property steps.write_bitstream.tcl.post [file normalize "$script_folder/src/firmware_copy.tcl"] $obj