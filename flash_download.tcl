#
#author: Golovachenko Viktor
#

#Set flash param
set flash_name s25fl128sxxxxxx0-spi-x1_x2_x4
set flash_interface spix4
set flash_size 16
set flash_addr_firmware 0x0
set flash_index 0

#Set fpga param
set fpga_index 0

#Set file path
set bit_file ./firmware/bfd_artix_firmware_gold.bit
set mcs_file ./firmware/bfd_artix_firmware.mcs

#Set server path
set server localhost:3121

#Set unused pin termination - pull-none;pull-up;pull-down
set unused_pins pull-none

#check existing bit file for next working with it
if {![file exist $bit_file]} {
    puts "error can't find [file normalize $bit_file]"
    return
}

#convert bit file to mcs file
write_cfgmem -force -format mcs -size $flash_size -interface $flash_interface -verbose \
            -loadbit "up $flash_addr_firmware $bit_file" -file $mcs_file

#download firmware to flash
open_hw
connect_hw_server -url $server
open_hw_target
current_hw_device [lindex [get_hw_devices] $fpga_index]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] $fpga_index]

create_hw_cfgmem -hw_device [lindex [get_hw_devices] $fpga_index] -mem_device [lindex [get_cfgmem_parts $flash_name] $flash_index]
set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [current_hw_device]]
set_property PROGRAM.FILES [list "$mcs_file" ] [ get_property PROGRAM.HW_CFGMEM [current_hw_device]]
set_property PROGRAM.UNUSED_PIN_TERMINATION $unused_pins [ get_property PROGRAM.HW_CFGMEM [current_hw_device ]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [current_hw_device ]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device ]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device ]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device ]]

if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE [current_hw_device]] \
    [get_property MEM_TYPE [get_property CFGMEM_PART [get_property PROGRAM.HW_CFGMEM [current_hw_device ]]]]] } { \
        puts "download firmware for flash programming..."
        create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [ current_hw_device]];
        program_hw_devices [current_hw_device];
}

puts "flash programming..."
program_hw_cfgmem -hw_cfgmem [get_property PROGRAM.HW_CFGMEM [current_hw_device ]]
boot_hw_device  [current_hw_device]

close_hw_target
disconnect_hw_server $server
close_hw
