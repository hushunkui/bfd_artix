#
#author: Golovachenko Viktor
#

set bit_file ./firmware/bfd_artix_firmware.bit
set fpga_index 0

#jtag_cable params
set server localhost:3121
set jtag_cable_index 0

if {![file exist $bit_file]} {
    puts "error can't find [file normalize $bit_file]"
    return
}

#download firmware to flash
open_hw
connect_hw_server -url $server
set jtag_cabel_list [lindex [get_hw_targets]]
set jtag_cabel_cnt 0
foreach i $jtag_cabel_list {
    puts "jtag_cabel[$jtag_cabel_cnt] - $i";
    incr jtag_cabel_cnt
}
open_hw_target [lindex [get_hw_targets] $jtag_cable_index]
refresh_hw_device [lindex [get_hw_devices] $fpga_index]
current_hw_device [lindex [get_hw_devices] $fpga_index]
set_property PROGRAM.FILE $bit_file [current_hw_device]
# set_property PROBES.FILE {} [current_hw_device]
# set_property FULL_PROBES.FILE {} [current_hw_device]
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
close_hw_target [lindex [get_hw_targets] $jtag_cable_index]
disconnect_hw_server $server
close_hw