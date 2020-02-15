
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
   create_project -force artix_base $script_folder/vv -part xc7a35tcsg325-2
   set_property BOARD_PART trenz.biz:te0714_35_2i:part0:1.0 [current_project]
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
xilinx.com:ip:aurora_8b10b:*\
xilinx.com:ip:axi_protocol_converter:*\
xilinx.com:ip:jtag_axi:*\
xilinx.com:ip:proc_sys_reset:*\
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
  set M_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $M_AXI_0
  set aurora_axi_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 aurora_axi_rx ]
  set aurora_axi_tx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 aurora_axi_tx ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $aurora_axi_tx
  set aurora_control [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:core_control_in_rtl:1.0 aurora_control ]
  set aurora_gt_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 aurora_gt_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $aurora_gt_refclk
  set aurora_gt_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 aurora_gt_rx ]
  set aurora_gt_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 aurora_gt_tx ]
  set aurora_status [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:core_status_out_rtl:1.0 aurora_status ]

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXI_0} \
   CONFIG.ASSOCIATED_RESET {areset_n} \
   CONFIG.FREQ_HZ {125000000} \
 ] $aclk
  set areset_n [ create_bd_port -dir I -type rst areset_n ]
  set aurora_gt_rst [ create_bd_port -dir I -type rst aurora_gt_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $aurora_gt_rst
  set aurora_init_clk [ create_bd_port -dir I -type clk aurora_init_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {aurora_rst:aurora_gt_rst} \
   CONFIG.FREQ_HZ {125000000} \
 ] $aurora_init_clk
  set aurora_rst [ create_bd_port -dir I -type rst aurora_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $aurora_rst
  set aurora_usr_clk [ create_bd_port -dir O -type clk aurora_usr_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {aurora_axi_tx:aurora_axi_rx} \
   CONFIG.ASSOCIATED_RESET {aurora_sysrst} \
 ] $aurora_usr_clk

  # Create instance: aurora_8b10b_0, and set properties
  set aurora_8b10b_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_8b10b aurora_8b10b_0 ]
  set_property -dict [ list \
   CONFIG.C_AURORA_LANES {1} \
   CONFIG.C_DRP_IF {false} \
   CONFIG.C_GT_CLOCK_1 {GTPQ0} \
   CONFIG.C_GT_LOC_1 {1} \
   CONFIG.C_GT_LOC_2 {X} \
   CONFIG.C_GT_LOC_3 {X} \
   CONFIG.C_LANE_WIDTH {4} \
   CONFIG.C_LINE_RATE {3.125} \
   CONFIG.C_USE_BYTESWAP {true} \
   CONFIG.Interface_Mode {Framing} \
   CONFIG.SINGLEEND_GTREFCLK {false} \
   CONFIG.SINGLEEND_INITCLK {true} \
   CONFIG.SupportLevel {1} \
 ] $aurora_8b10b_0

  # Create instance: axi_protocol_convert_0, and set properties
  set axi_protocol_convert_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter axi_protocol_convert_0 ]
  set_property -dict [ list \
   CONFIG.TRANSLATION_MODE {2} \
 ] $axi_protocol_convert_0

  # Create instance: jtag_axi_0, and set properties
  set jtag_axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi jtag_axi_0 ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net CORE_CONTROL_0_1 [get_bd_intf_ports aurora_control] [get_bd_intf_pins aurora_8b10b_0/CORE_CONTROL]
  connect_bd_intf_net -intf_net GT_DIFF_REFCLK1_0_1 [get_bd_intf_ports aurora_gt_refclk] [get_bd_intf_pins aurora_8b10b_0/GT_DIFF_REFCLK1]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_0_1 [get_bd_intf_ports aurora_gt_rx] [get_bd_intf_pins aurora_8b10b_0/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net USER_DATA_S_AXI_TX_0_1 [get_bd_intf_ports aurora_axi_tx] [get_bd_intf_pins aurora_8b10b_0/USER_DATA_S_AXI_TX]
  connect_bd_intf_net -intf_net aurora_8b10b_0_CORE_STATUS [get_bd_intf_ports aurora_status] [get_bd_intf_pins aurora_8b10b_0/CORE_STATUS]
  connect_bd_intf_net -intf_net aurora_8b10b_0_GT_SERIAL_TX [get_bd_intf_ports aurora_gt_tx] [get_bd_intf_pins aurora_8b10b_0/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net aurora_8b10b_0_USER_DATA_M_AXI_RX [get_bd_intf_ports aurora_axi_rx] [get_bd_intf_pins aurora_8b10b_0/USER_DATA_M_AXI_RX]
  connect_bd_intf_net -intf_net axi_protocol_convert_0_M_AXI [get_bd_intf_ports M_AXI_0] [get_bd_intf_pins axi_protocol_convert_0/M_AXI]
  connect_bd_intf_net -intf_net jtag_axi_0_M_AXI [get_bd_intf_pins axi_protocol_convert_0/S_AXI] [get_bd_intf_pins jtag_axi_0/M_AXI]

  # Create port connections
  connect_bd_net -net aclk_0_1 [get_bd_ports aclk] [get_bd_pins axi_protocol_convert_0/aclk] [get_bd_pins jtag_axi_0/aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net aurora_8b10b_0_user_clk_out [get_bd_ports aurora_usr_clk] [get_bd_pins aurora_8b10b_0/user_clk_out]
  connect_bd_net -net ext_reset_in_0_1 [get_bd_ports areset_n] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net gt_reset_0_1 [get_bd_ports aurora_gt_rst] [get_bd_pins aurora_8b10b_0/gt_reset]
  connect_bd_net -net init_clk_in_0_1 [get_bd_ports aurora_init_clk] [get_bd_pins aurora_8b10b_0/drpclk_in] [get_bd_pins aurora_8b10b_0/init_clk_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_protocol_convert_0/aresetn] [get_bd_pins jtag_axi_0/aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net reset_0_1 [get_bd_ports aurora_rst] [get_bd_pins aurora_8b10b_0/reset]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces jtag_axi_0/Data] [get_bd_addr_segs M_AXI_0/Reg] SEG_M_AXI_0_Reg


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
add_files -norecurse $script_folder/src/axi4lite_ctrl.v
add_files -norecurse $script_folder/src/usr_logic.v
add_files -norecurse $script_folder/src/firmware_rev.v
add_files -norecurse $script_folder/src/mac_rgmii.v
add_files -norecurse $script_folder/src/mac_crc.v
add_files -norecurse $script_folder/src/vicg_common_pkg.vhd
add_files -norecurse $script_folder/src/time_gen.vhd
add_files -norecurse $script_folder/src/fpga_test_01.vhd
add_files -norecurse $script_folder/src/sata_scrambler.vhd
add_files -norecurse $script_folder/src/test_rx.v
add_files -norecurse $script_folder/src/test_tx.v
add_files -norecurse $script_folder/src/test_phy.v
add_files -norecurse $script_folder/src/mac_bram.v
add_files -norecurse $script_folder/src/mac_fifo_sync_block.v
add_files -norecurse $script_folder/src/mac_fifo_rx.v
add_files -norecurse $script_folder/src/mac_fifo_tx.v
add_files -norecurse $script_folder/src/mac_fifo.v
add_files -norecurse $script_folder/src/sergey/ARP_L2.v
add_files -norecurse $script_folder/src/sergey/CustomGMAC.v
add_files -norecurse $script_folder/src/sergey/CustomGMAC_Wrap.v
add_files -norecurse $script_folder/src/sergey/DDR_OUT_xil.v
add_files -norecurse $script_folder/src/sergey/EthCRC32.v
add_files -norecurse $script_folder/src/sergey/EthScheduler.v
add_files -norecurse $script_folder/src/sergey/FrameL2_Out.v
add_files -norecurse $script_folder/src/sergey/FrameL3.v
add_files -norecurse $script_folder/src/sergey/FrameL4.v
add_files -norecurse $script_folder/src/sergey/FrameSync.v
add_files -norecurse $script_folder/src/sergey/Link_Status.v
add_files -norecurse $script_folder/src/sergey/RGMIIOverClockModule.v
add_files -norecurse $script_folder/src/sergey/RGMIIOverClock.v
add_files -norecurse $script_folder/src/sergey/RGMII_ClockSpeed_Test.v
add_files -norecurse $script_folder/src/core_gen/axis_data_fifo_0/axis_data_fifo_0.xci
add_files -norecurse $script_folder/src/core_gen/clk25_wiz0/clk25_wiz0.xci
add_files -norecurse $script_folder/src/core_gen/ila_0/ila_0.xci
add_files -norecurse $script_folder/src/core_gen/ila_1/ila_1.xci
add_files -norecurse $script_folder/src/core_gen/aurora_rx_fifo/aurora_rx_fifo.xci
add_files -norecurse $script_folder/src/core_gen/aurora_tx_fifo/aurora_tx_fifo.xci
set_property include_dirs $script_folder/src [current_fileset]

add_files -fileset sim_1 -norecurse $script_folder/sim/main_tb.v
set_property include_dirs $script_folder/src/ [get_filesets sim_1]
set_property -name {modelsim.simulate.custom_wave_do} -value $script_folder/sim/main_wave.do -objects [get_filesets sim_1]
set_property -name {modelsim.simulate.runtime} -value {5us} -objects [get_filesets sim_1]

set obj [get_runs synth_1]
set_property steps.synth_design.tcl.pre [file normalize "$script_folder/src/firmware_rev.tcl"] $obj
#-include_dirs is path at dir ./vv/<name>.runs/synth_1
set_property -name {steps.synth_design.args.more options} -value {-include_dirs ../../../src} -objects $obj

set obj [get_runs impl_1]
set_property steps.write_bitstream.tcl.post [file normalize "$script_folder/src/firmware_copy.tcl"] $obj
