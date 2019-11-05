#
#author: Golovachenko Viktor
#

file delete -force -- work

#--------------------------
#Xilinx
#--------------------------
set inifile "./compile_simlib/modelsim.ini"
if { [ file exists $inifile ] != 1 } {
    puts "No found modelsim.ini. Run script prj_simlib.bat"
    return
}

vlib work

#Compile files in sim folder (excluding model parameter file)#
#$XILINX variable must be set
vlog  $env(XILINX)/verilog/src/glbl.v

vlog                        ../src/mac_crc.v
vlog  -modelsimini $inifile ../src/mac_rgmii.v
vlog                         ./mac_rgmii_tb.v

vsim  -modelsimini $inifile -t 1ps -novopt +notimingchecks -L unisims_ver -L secureip  -lib work mac_rgmii_tb glbl


#--------------------------
#View waveform
#--------------------------
do mac_rgmii_tb_wave.do

view wave
config wave -timelineunits us
view structure
view signals
run 3us

#quit -force
