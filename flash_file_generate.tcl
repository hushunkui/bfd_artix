#
#author: Golovachenko Viktor
#

#Set flash param
set flash_name s25fl128sxxxxxx0-spi-x1_x2_x4
set flash_interface spix4
set flash_size 16
set flash_addr_firmware 0x0
# set flash_addr_usr_data 0x00800000

#Set file path
set bit_file ./firmware/bfd_artix_firmware.bit
set mcs_file ./firmware/bfd_artix_firmware.mcs

#check existing bit file for next working with it
if {![file exist $bit_file]} {
    puts "error can't find [file normalize $bit_file]"
    return
}

#convert bit file to mcs file
write_cfgmem -force -format mcs -size $flash_size -interface $flash_interface -verbose \
             -loadbit "up $flash_addr_firmware $bit_file" -file $mcs_file
