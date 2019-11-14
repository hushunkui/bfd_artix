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
vlog ./arp_sender.sv -sv
vlog ../ethernet_packet_multiplexer3/ethernet_packet_multiplexer3.sv -sv
vlog ../filter_eth_pkt/filter_eth_pkt.sv -sv
vlog  ./filter_eth_pkt_tb.sv -sv


vsim -t 1ps -novopt -lib  work filter_eth_pkt_tb


do filter_eth_pkt_tb_wave.do
view wave
view structure
view signals
run 1000000ns

#quit -force
