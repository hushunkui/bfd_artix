#-----------------------------------------------------------------------
# Engineer    : Golovachenko Victor
#
# Create Date : 10.10.2017 10:26:46
#
#------------------------------------------------------------------------
file delete -force -- work

vlib work

vlog ./data_packet_generator.sv -sv
vlog ../udp_payload_inserter/udp_payload_inserter.sv -sv
vlog ../ip_segmentation/ip_segmentation.sv -sv
vlog  ./ip_segmetation_tb.sv -sv


vsim -t 1ps  -novopt -lib  work ip_segmetation_tb


do ip_segmetation_tb_wave.do
view wave
view structure
view signals
run 1000000ns

#quit -force
