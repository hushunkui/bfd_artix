onerror {resume}
quietly virtual function -install /ip_segmetation_tb/ip_sg -env /ip_segmetation_tb { &{/ip_segmetation_tb/ip_sg/headers[5][28], /ip_segmetation_tb/ip_sg/headers[5][27], /ip_segmetation_tb/ip_sg/headers[5][26], /ip_segmetation_tb/ip_sg/headers[5][25], /ip_segmetation_tb/ip_sg/headers[5][24], /ip_segmetation_tb/ip_sg/headers[5][23], /ip_segmetation_tb/ip_sg/headers[5][22], /ip_segmetation_tb/ip_sg/headers[5][21], /ip_segmetation_tb/ip_sg/headers[5][20], /ip_segmetation_tb/ip_sg/headers[5][19], /ip_segmetation_tb/ip_sg/headers[5][18], /ip_segmetation_tb/ip_sg/headers[5][17], /ip_segmetation_tb/ip_sg/headers[5][16] }} ip_frament_offset
quietly virtual function -install /ip_segmetation_tb/ip_sg -env /ip_segmetation_tb { &{/ip_segmetation_tb/ip_sg/headers[4][31], /ip_segmetation_tb/ip_sg/headers[4][30], /ip_segmetation_tb/ip_sg/headers[4][29], /ip_segmetation_tb/ip_sg/headers[4][28], /ip_segmetation_tb/ip_sg/headers[4][27], /ip_segmetation_tb/ip_sg/headers[4][26], /ip_segmetation_tb/ip_sg/headers[4][25], /ip_segmetation_tb/ip_sg/headers[4][24], /ip_segmetation_tb/ip_sg/headers[4][23], /ip_segmetation_tb/ip_sg/headers[4][22], /ip_segmetation_tb/ip_sg/headers[4][21], /ip_segmetation_tb/ip_sg/headers[4][20], /ip_segmetation_tb/ip_sg/headers[4][19], /ip_segmetation_tb/ip_sg/headers[4][18], /ip_segmetation_tb/ip_sg/headers[4][17], /ip_segmetation_tb/ip_sg/headers[4][16] }} ip_total_len
quietly WaveActivateNextPane {} 0
add wave -noupdate /ip_segmetation_tb/avmm_address
add wave -noupdate /ip_segmetation_tb/avmm_writedata
add wave -noupdate /ip_segmetation_tb/avmm_byteenable
add wave -noupdate /ip_segmetation_tb/avmm_write
add wave -noupdate /ip_segmetation_tb/avmm_readdata
add wave -noupdate /ip_segmetation_tb/avmm_read
add wave -noupdate -divider TEST_DATA_GEN
add wave -noupdate /ip_segmetation_tb/nxt_test_pkt
add wave -noupdate /ip_segmetation_tb/datagen/go_bit
add wave -noupdate -radix unsigned /ip_segmetation_tb/datagen/payload_prbs_byte_count
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ip_segmetation_tb/datagen/state
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_ready
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_data
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_valid
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_startofpacket
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_endofpacket
add wave -noupdate /ip_segmetation_tb/datagen/aso_src0_empty
add wave -noupdate -divider UDP_INS
add wave -noupdate /ip_segmetation_tb/udp_ins/cfg
add wave -noupdate -radix unsigned /ip_segmetation_tb/udp_ins/udp_length
add wave -noupdate -radix unsigned /ip_segmetation_tb/udp_ins/ip_total_length
add wave -noupdate /ip_segmetation_tb/udp_ins/ip_identification
add wave -noupdate /ip_segmetation_tb/udp_ins/go_bit
add wave -noupdate -radix unsigned /ip_segmetation_tb/udp_ins/cnt
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ip_segmetation_tb/udp_ins/state
add wave -noupdate /ip_segmetation_tb/udp_ins/busy
add wave -noupdate /ip_segmetation_tb/udp_ins/ip_header_crc
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_ready
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_data
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_valid
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_startofpacket
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_endofpacket
add wave -noupdate /ip_segmetation_tb/udp_ins/aso_src0_empty
add wave -noupdate -divider IP_SEGMENTATION
add wave -noupdate /ip_segmetation_tb/ip_sg/asi_snk0_data
add wave -noupdate /ip_segmetation_tb/ip_sg/headers
add wave -noupdate -radix unsigned /ip_segmetation_tb/ip_sg/info.udp_len
add wave -noupdate -childformat {{/ip_segmetation_tb/ip_sg/info.udp_len -radix unsigned} {/ip_segmetation_tb/ip_sg/info.payload_len -radix unsigned} {/ip_segmetation_tb/ip_sg/info.ip_total_len -radix unsigned} {/ip_segmetation_tb/ip_sg/info.fragment_offset -radix unsigned}} -expand -subitemconfig {/ip_segmetation_tb/ip_sg/info.udp_len {-height 15 -radix unsigned} /ip_segmetation_tb/ip_sg/info.payload_len {-height 15 -radix unsigned} /ip_segmetation_tb/ip_sg/info.ip_total_len {-height 15 -radix unsigned} /ip_segmetation_tb/ip_sg/info.fragment_offset {-height 15 -radix unsigned}} /ip_segmetation_tb/ip_sg/info
add wave -noupdate -radix unsigned /ip_segmetation_tb/ip_sg/udp_pd
add wave -noupdate -radix unsigned /ip_segmetation_tb/ip_sg/ip_fg_pd_size
add wave -noupdate -radix unsigned /ip_segmetation_tb/ip_sg/ip_fg_pd_cnt
add wave -noupdate /ip_segmetation_tb/ip_sg/first_data
add wave -noupdate -color {Slate Blue} -itemcolor Gold /ip_segmetation_tb/ip_sg/fsm_state
add wave -noupdate /ip_segmetation_tb/ip_sg/busy
add wave -noupdate /ip_segmetation_tb/ip_sg/sv_snk0_data
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_ready
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_data
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_valid
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_startofpacket
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_endofpacket
add wave -noupdate /ip_segmetation_tb/ip_sg/aso_src0_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 205
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
WaveRestoreZoom {6051025 ps} {12345297 ps}
