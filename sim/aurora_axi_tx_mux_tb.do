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

vlog -modelsimini $inifile ../src/core_gen/mac_rxbuf_axis_fifo/sim/mac_rxbuf_axis_fifo.v
vlog ../src/mac_rxbuf.v
vlog ../src/aurora_axi_tx_mux.v
vlog ./aurora_axi_tx_mux_tb.v -sv

vsim -modelsimini $inifile -t 1ps -L fifo_generator_v13_2_2 -L unisims_ver -L unimacro_ver -novopt +notimingchecks -lib work aurora_axi_tx_mux_tb work.glbl


#--------------------------
#View waveform
#--------------------------
do aurora_axi_tx_mux_tb_wave.do

view wave
config wave -timelineunits us
view structure
view signals
run 3us

#quit -force
