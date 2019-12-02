
#set fpga_index 0
#
#open_hw
#connect_hw_server -url localhost:3121
#open_hw_target
#refresh_hw_device [lindex [get_hw_devices] $fpga_index]
#current_hw_device [lindex [get_hw_devices] $fpga_index]


proc sleep {time} {
    after $time set end 1
    vwait end
}

# jtag axi master interface hardware name, change as per your design.
set jtag_axi_master hw_axi_1
set ec 0

reset_hw_axi [get_hw_axis $jtag_axi_master]

# hw test script
# Delete all previous axis transactions
if { [llength [get_hw_axi_txns -quiet]] } {
	delete_hw_axi_txn [get_hw_axi_txns -quiet]
}

# Test all lite slaves.
set wdata_1 000055aa
set wdata_2 00003388

set UREG_FIRMWARE_DATE    0x00000000
set UREG_FIRMWARE_TIME    0x00000004
set UREG_CTRL             0x00000008
set UREG_TEST0            0x0000000C
set UREG_TEST1            0x00000010

set baseaddr 0x44A00000

# Test:
# Create a write transactions
create_hw_axi_txn reg_test0_wr [get_hw_axis $jtag_axi_master] -type write -address [format %08x [expr $baseaddr + $UREG_TEST0]] -data 00000001
create_hw_axi_txn reg_test1_wr [get_hw_axis $jtag_axi_master] -type write -address [format %08x [expr $baseaddr + $UREG_TEST1]] -data $wdata_2
create_hw_axi_txn reg_ctrl_wr [get_hw_axis $jtag_axi_master] -type write -address [format %08x [expr $baseaddr + $UREG_CTRL]] -data 00000000
# Create a read transactions
create_hw_axi_txn reg_test0_rd [get_hw_axis $jtag_axi_master] -type read -address [format %08x [expr $baseaddr + $UREG_TEST0]]
create_hw_axi_txn reg_test1_rd [get_hw_axis $jtag_axi_master] -type read -address [format %08x [expr $baseaddr + $UREG_TEST1]]
create_hw_axi_txn reg_ctrl_rd  [get_hw_axis $jtag_axi_master] -type read -address [format %08x [expr $baseaddr + $UREG_CTRL]]
create_hw_axi_txn reg_firmware_data_addr_rd [get_hw_axis $jtag_axi_master] -type read -address [format %08x [expr $baseaddr + $UREG_FIRMWARE_DATE]]
create_hw_axi_txn reg_firmware_time_addr_rd [get_hw_axis $jtag_axi_master] -type read -address [format %08x [expr $baseaddr + $UREG_FIRMWARE_TIME]]

# Initiate transactions
set_property DATA 00000001 [get_hw_axi_txn reg_ctrl_wr]
run_hw_axi reg_ctrl_wr -quiet


#close_hw
