onerror {resume}
quietly virtual function -install /udp_extracter_tb/ip_sg -env /udp_extracter_tb { &{/udp_extracter_tb/ip_sg/headers[5][28], /udp_extracter_tb/ip_sg/headers[5][27], /udp_extracter_tb/ip_sg/headers[5][26], /udp_extracter_tb/ip_sg/headers[5][25], /udp_extracter_tb/ip_sg/headers[5][24], /udp_extracter_tb/ip_sg/headers[5][23], /udp_extracter_tb/ip_sg/headers[5][22], /udp_extracter_tb/ip_sg/headers[5][21], /udp_extracter_tb/ip_sg/headers[5][20], /udp_extracter_tb/ip_sg/headers[5][19], /udp_extracter_tb/ip_sg/headers[5][18], /udp_extracter_tb/ip_sg/headers[5][17], /udp_extracter_tb/ip_sg/headers[5][16] }} ip_frament_offset
quietly virtual function -install /udp_extracter_tb/ip_sg -env /udp_extracter_tb { &{/udp_extracter_tb/ip_sg/headers[4][31], /udp_extracter_tb/ip_sg/headers[4][30], /udp_extracter_tb/ip_sg/headers[4][29], /udp_extracter_tb/ip_sg/headers[4][28], /udp_extracter_tb/ip_sg/headers[4][27], /udp_extracter_tb/ip_sg/headers[4][26], /udp_extracter_tb/ip_sg/headers[4][25], /udp_extracter_tb/ip_sg/headers[4][24], /udp_extracter_tb/ip_sg/headers[4][23], /udp_extracter_tb/ip_sg/headers[4][22], /udp_extracter_tb/ip_sg/headers[4][21], /udp_extracter_tb/ip_sg/headers[4][20], /udp_extracter_tb/ip_sg/headers[4][19], /udp_extracter_tb/ip_sg/headers[4][18], /udp_extracter_tb/ip_sg/headers[4][17], /udp_extracter_tb/ip_sg/headers[4][16] }} ip_total_len
quietly WaveActivateNextPane {} 0
add wave -noupdate /udp_extracter_tb/avmm_address
add wave -noupdate /udp_extracter_tb/avmm_writedata
add wave -noupdate /udp_extracter_tb/avmm_byteenable
add wave -noupdate /udp_extracter_tb/avmm_write
add wave -noupdate /udp_extracter_tb/avmm_readdata
add wave -noupdate /udp_extracter_tb/avmm_read
add wave -noupdate -divider TEST_DATA_GEN
add wave -noupdate /udp_extracter_tb/nxt_test_pkt
add wave -noupdate /udp_extracter_tb/datagen/go_bit
add wave -noupdate -radix unsigned /udp_extracter_tb/datagen/payload_prbs_byte_count
add wave -noupdate -color {Slate Blue} -itemcolor Gold /udp_extracter_tb/datagen/state
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_ready
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_data
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_valid
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_startofpacket
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_endofpacket
add wave -noupdate /udp_extracter_tb/datagen/aso_src0_empty
add wave -noupdate -divider UDP_INS
add wave -noupdate /udp_extracter_tb/udp_ins/cfg
add wave -noupdate -radix unsigned /udp_extracter_tb/udp_ins/udp_length
add wave -noupdate -radix unsigned /udp_extracter_tb/udp_ins/ip_total_length
add wave -noupdate /udp_extracter_tb/udp_ins/ip_identification
add wave -noupdate /udp_extracter_tb/udp_ins/go_bit
add wave -noupdate -radix unsigned /udp_extracter_tb/udp_ins/cnt
add wave -noupdate -color {Slate Blue} -itemcolor Gold /udp_extracter_tb/udp_ins/state
add wave -noupdate /udp_extracter_tb/udp_ins/busy
add wave -noupdate /udp_extracter_tb/udp_ins/ip_header_crc
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_ready
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_data
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_valid
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_startofpacket
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_endofpacket
add wave -noupdate /udp_extracter_tb/udp_ins/aso_src0_empty
add wave -noupdate -divider IP_SEGMENTATION
add wave -noupdate /udp_extracter_tb/ip_sg/asi_snk0_data
add wave -noupdate /udp_extracter_tb/ip_sg/headers
add wave -noupdate -radix unsigned /udp_extracter_tb/ip_sg/info.udp_len
add wave -noupdate -childformat {{/udp_extracter_tb/ip_sg/info.udp_len -radix unsigned} {/udp_extracter_tb/ip_sg/info.payload_len -radix unsigned} {/udp_extracter_tb/ip_sg/info.ip_total_len -radix unsigned} {/udp_extracter_tb/ip_sg/info.fragment_offset -radix unsigned}} -expand -subitemconfig {/udp_extracter_tb/ip_sg/info.udp_len {-height 15 -radix unsigned} /udp_extracter_tb/ip_sg/info.payload_len {-height 15 -radix unsigned} /udp_extracter_tb/ip_sg/info.ip_total_len {-height 15 -radix unsigned} /udp_extracter_tb/ip_sg/info.fragment_offset {-height 15 -radix unsigned}} /udp_extracter_tb/ip_sg/info
add wave -noupdate -radix unsigned /udp_extracter_tb/ip_sg/udp_pd
add wave -noupdate -radix unsigned /udp_extracter_tb/ip_sg/ip_fg_pd_size
add wave -noupdate -radix unsigned /udp_extracter_tb/ip_sg/ip_fg_pd_cnt
add wave -noupdate /udp_extracter_tb/ip_sg/first_data
add wave -noupdate -color {Slate Blue} -itemcolor Gold /udp_extracter_tb/ip_sg/fsm_state
add wave -noupdate /udp_extracter_tb/ip_sg/busy
add wave -noupdate /udp_extracter_tb/ip_sg/sv_snk0_data
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_ready
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_data
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_valid
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_startofpacket
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_endofpacket
add wave -noupdate /udp_extracter_tb/ip_sg/aso_src0_empty
add wave -noupdate -divider UDP_EXT
add wave -noupdate -color {Slate Blue} -itemcolor Gold /udp_extracter_tb/udp_ext/fsm_state
add wave -noupdate /udp_extracter_tb/udp_ext/ip_fg
add wave -noupdate /udp_extracter_tb/udp_ext/snk0_data
add wave -noupdate /udp_extracter_tb/udp_ext/pkt_valid
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_ready
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_data
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_valid
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_startofpacket
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_endofpacket
add wave -noupdate /udp_extracter_tb/udp_ext/aso_src0_empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 169
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
WaveRestoreZoom {0 ps} {19467352 ps}
