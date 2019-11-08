#
#author: Golovachenko Viktor
#

set usr_firmware            ./firmware/bfd_artix_firmware.bit

if {![file exist $usr_firmware]} {
    puts "error can't find [file normalize $usr_firmware]"
    return
}

open_hw
connect_hw_server -url localhost:3121
open_hw_target
refresh_hw_device [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {./firmware/bfd_artix_firmware.bit} [current_hw_device]
close_hw
