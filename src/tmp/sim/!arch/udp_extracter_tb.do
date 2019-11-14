#-----------------------------------------------------------------------
# Engineer    : Golovachenko Victor
#
# Create Date : 19.12.2017 10:54:46
#
#------------------------------------------------------------------------
file delete -force -- work

vlib work

vlog ./data_packet_generator.sv -sv
vlog ../udp_payload_inserter/udp_payload_inserter.sv -sv
vlog ../ip_segmentation/ip_segmentation.sv -sv
vlog ../udp_payload_extracter/udp_extracter.sv -sv
vlog ./udp_extracter_tb.sv -sv


vsim -t 1ps  -novopt -lib  work udp_extracter_tb


do udp_extracter_tb_wave.do
view wave
view structure
view signals
run 1000000ns

#quit -force
