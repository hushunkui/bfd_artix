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

vlog -modelsimini $inifile ../src/core_gen/clk_wiz_gold/clk_wiz_gold.v
vlog -modelsimini $inifile ../src/core_gen/clk_wiz_gold/clk_wiz_gold_clk_wiz.v
vcom ../src/vicg_common_pkg.vhd
vcom ../src/time_gen.vhd
vcom ../src/fpga_test_01.vhd
#vlog ./fpga_test_01.v
vlog ../src/firmware_gold_rev.v
vlog ../src/spi_slave.v -sv +incdir+../src/ +define+SIM_FSM
vlog ../src/main_gold.v +incdir+../src/
vlog ./spi_master.sv -sv +incdir+../src/
vlog ./spi_slave_tb.v -sv

vsim -modelsimini $inifile -t 1ps -L unisims_ver -L unimacro_ver -novopt +notimingchecks -lib work spi_slave_tb work.glbl


#--------------------------
#View waveform
#--------------------------
do spi_slave_tb_wave.do

view wave
config wave -timelineunits us
view structure
view signals
run 3us

#quit -force
