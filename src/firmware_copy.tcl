#
#author: Golovachenko Viktor
#

set curDir [pwd]
puts "current dir: $curDir"
# result of compilation xilinx IDE
set prj_firmware_name            main.bit
# set prj_dbg_name                 main.ltx
# user name of fpga firmware
set usr_firmware_name            bfd_artix_firmware.bit
# user directory for fpga firmware
set usr_firmware_dir            ../../../firmware
# set usr_dbg_dir                 ../../../dbg

if {![file exist $curDir/$prj_firmware_name]} {
    puts "error can't find $curDir/$prj_firmware_name"
    return
}
if {![file exist $usr_firmware_dir]} {
    puts "warning can't find [file normalize $usr_firmware_dir]. Make directory [file normalize $usr_firmware_dir]"
    file mkdir $usr_firmware_dir
}
puts "$curDir/$prj_firmware_name to [file normalize $usr_firmware_dir] and rename it to $usr_firmware_name"
file copy -force $curDir/$prj_firmware_name $usr_firmware_dir/$usr_firmware_name

# if {[file exist $usr_dbg_dir]} {
#     puts "-----[file normalize $usr_dbg_dir]"
#     if {[file exist $curDir/$prj_dbg_name]} {
#         # puts "-----[file normalize $curDir/$prj_dbg_name]"
#         puts "$curDir/$prj_dbg_name to [file normalize $usr_dbg_dir]"
#         file copy -force $curDir/$prj_dbg_name $usr_dbg_dir
#     } else {
#         puts "!!!![file normalize $curDir/$prj_dbg_name]"
#     }
# } else {
#     puts "!!!!!!![file normalize $usr_dbg_dir]"
# }
