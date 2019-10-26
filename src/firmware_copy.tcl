#
# author: Golovachenko Victor
#

set curDir [pwd]
puts "current dir: $curDir"

if {![file exist $curDir/main.bit]} {
    puts "error can't find $curDir/main.bit"
    return
}
puts "run copy $curDir/main.bit to ../../../firmware/ and rename it to bfd_artix_firmware.bit"
file copy -force $curDir/main.bit ../../../firmware/bfd_artix_firmware.bit

#if {![file exist $curDir/main.hwdef]} {
#    puts "error can't find $curDir/main.hwdef"
#    return
#}
#puts "run create (system.hdf with main.bit into one file) ../../../firmware/system.hdf"
#write_sysdef -force -hwdef $curDir/main.hwdef -bitfile ./main.bit ../../../firmware/system.hdf
#
##puts "run create (system.hdf without main.bit into one file) ../../../firmware/system.hdf"
##write_hwdef -force  -file ../../../firmware/system.hdf
