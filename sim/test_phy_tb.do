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
vlog  $env(XILINX_VV)/data/verilog/src/glbl.v

vcom ../src/vicg_common_pkg.vhd
vcom ../src/sata_scrambler.vhd
vlog ../src/test_tx.v
vlog ../src/test_rx.v
vlog ../src/test_phy.v
vlog ./test_phy_tb.v -sv

vsim -modelsimini $inifile -t 1ps -novopt +notimingchecks -lib work test_phy_tb


#--------------------------
#View waveform
#--------------------------
do test_phy_tb_wave.do

view wave
config wave -timelineunits us
view structure
view signals
run 3us

#quit -force
