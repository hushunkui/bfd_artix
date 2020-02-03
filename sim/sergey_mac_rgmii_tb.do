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

vlog -modelsimini $inifile ../src/core_gen/clk25_wiz0/clk25_wiz0.v
vlog -modelsimini $inifile ../src/core_gen/clk25_wiz0/clk25_wiz0_clk_wiz.v

vlog ../src/mac_crc.v
vlog -modelsimini $inifile ../src/mac_rgmii.v
vlog -modelsimini $inifile ../src/core_gen/clk25_wiz0/clk25_wiz0.v
vlog -modelsimini $inifile ../src/core_gen/clk25_wiz0/clk25_wiz0_clk_wiz.v
vlog -modelsimini $inifile ../src/mac_bram.v
vlog -modelsimini $inifile ../src/mac_fifo_sync_block.v
vlog -modelsimini $inifile ../src/mac_fifo_tx.v -sv +define+SIM_FSM
vlog -modelsimini $inifile ../src/mac_fifo_rx.v -sv +define+SIM_FSM
vlog -modelsimini $inifile ../src/mac_fifo.v

vlog -modelsimini $inifile ../src/sergey/CustomGMAC_Wrap.v
vlog -modelsimini $inifile ../src/sergey/CustomGMAC.v
vlog -modelsimini $inifile ../src/sergey/ARP_L2.v
vlog -modelsimini $inifile ../src/sergey/EthCRC32.v
vlog -modelsimini $inifile ../src/sergey/EthLinkAnalyser200.v
vlog -modelsimini $inifile ../src/sergey/EthScheduler.v
vlog -modelsimini $inifile ../src/sergey/FrameL2_Out.v
vlog -modelsimini $inifile ../src/sergey/FrameL3.v
vlog -modelsimini $inifile ../src/sergey/FrameL4.v
vlog -modelsimini $inifile ../src/sergey/FrameSync.v
vlog -modelsimini $inifile ../src/sergey/LinkStatus.v
vlog -modelsimini $inifile ../src/sergey/rgmii_rx.v
vlog -modelsimini $inifile ../src/sergey/RGMIIDDR_xil.v
vlog -modelsimini $inifile ../src/sergey/DDR_OUT_xil.v
vlog ./sergey_mac_rgmii_tb.v

vsim -modelsimini $inifile -t 1ps -novopt +notimingchecks -L unisims_ver -L secureip -lib work mac_rgmii_tb glbl


#--------------------------
#View waveform
#--------------------------
do sergey_mac_rgmii_tb_wave.do

view wave
config wave -timelineunits us
view structure
view signals
run 3us

#quit -force
