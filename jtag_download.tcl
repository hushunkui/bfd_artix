#
#author: Golovachenko Viktor
#

set bit_file ./firmware/bfd_artix_firmware.bit
set fpga_index 0

if {![file exist $bit_file]} {
    puts "error can't find [file normalize $bit_file]"
    return
}

#download firmware to flash
open_hw
connect_hw_server -url localhost:3121
open_hw_target
refresh_hw_device [lindex [get_hw_devices] $fpga_index]
current_hw_device [lindex [get_hw_devices] $fpga_index]
set_property PROGRAM.FILE $bit_file [current_hw_device]
# set_property PROBES.FILE {} [current_hw_device]
# set_property FULL_PROBES.FILE {} [current_hw_device]
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]
close_hw