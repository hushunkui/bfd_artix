onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider GEN_ARP_PKT
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/go_bit
add wave -noupdate -color {Slate Blue} -itemcolor Gold /filter_eth_pkt_tb/gen_arp_pkt/state
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_ready
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_valid
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_data
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_startofpacket
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_endofpacket
add wave -noupdate /filter_eth_pkt_tb/gen_arp_pkt/aso_src0_empty
add wave -noupdate -divider GEN_UDP_PKT
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/go_bit
add wave -noupdate -color {Slate Blue} -itemcolor Gold /filter_eth_pkt_tb/gen_udp_pkt/state
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_ready
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_data
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_valid
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_startofpacket
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_endofpacket
add wave -noupdate /filter_eth_pkt_tb/gen_udp_pkt/aso_src0_empty
add wave -noupdate -divider PKT_MUX
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_ready
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_data
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_valid
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_startofpacket
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_endofpacket
add wave -noupdate /filter_eth_pkt_tb/pkt_mux/aso_out_empty
add wave -noupdate -divider FILTER_ETH_PKT
add wave -noupdate /filter_eth_pkt_tb/eth_filter/go_bit
add wave -noupdate /filter_eth_pkt_tb/eth_filter/en_arp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/en_udp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/en_icmp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/dev_ip
add wave -noupdate /filter_eth_pkt_tb/eth_filter/dev_udp_port
add wave -noupdate -color {Slate Blue} -itemcolor Gold /filter_eth_pkt_tb/eth_filter/state
add wave -noupdate /filter_eth_pkt_tb/eth_filter/detect_arp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/detect_icmp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/detect_ipv4
add wave -noupdate /filter_eth_pkt_tb/eth_filter/detect_udp
add wave -noupdate /filter_eth_pkt_tb/eth_filter/check
add wave -noupdate /filter_eth_pkt_tb/eth_filter/pkt_valid
add wave -noupdate /filter_eth_pkt_tb/aso_src0_ready
add wave -noupdate /filter_eth_pkt_tb/aso_src0_data
add wave -noupdate /filter_eth_pkt_tb/aso_src0_valid
add wave -noupdate /filter_eth_pkt_tb/aso_src0_startofpacket
add wave -noupdate /filter_eth_pkt_tb/aso_src0_endofpacket
add wave -noupdate /filter_eth_pkt_tb/aso_src0_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 344
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {25036631 ps} {26071491 ps}
