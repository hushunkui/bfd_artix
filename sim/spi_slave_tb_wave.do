onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /spi_slave_tb/main/firmware_date
add wave -noupdate /spi_slave_tb/main/firmware_time
add wave -noupdate /spi_slave_tb/main/reg_test_array
add wave -noupdate /spi_slave_tb/main/reg_rd_data
add wave -noupdate /spi_slave_tb/main/reg_wr_addr
add wave -noupdate /spi_slave_tb/main/reg_wr_data
add wave -noupdate /spi_slave_tb/main/reg_wr_en
add wave -noupdate /spi_slave_tb/main/reg_clk
add wave -noupdate /spi_slave_tb/main/usr_spi_clk
add wave -noupdate /spi_slave_tb/main/usr_spi_cs
add wave -noupdate /spi_slave_tb/main/usr_spi_mosi
add wave -noupdate /spi_slave_tb/main/usr_spi_miso
add wave -noupdate -color {Slate Blue} -itemcolor Gold /spi_slave_tb/main/usrspi/fsm_cs
add wave -noupdate /spi_slave_tb/main/usrspi/cntb
add wave -noupdate /spi_slave_tb/main/usrspi/spi_cs
add wave -noupdate /spi_slave_tb/main/usrspi/spi_ck_rising_edge
add wave -noupdate /spi_slave_tb/main/usrspi/spi_ck_faling_edge
add wave -noupdate /spi_slave_tb/main/usrspi/spi_cs_rising_edge
add wave -noupdate /spi_slave_tb/main/usrspi/sr_mosi
add wave -noupdate /spi_slave_tb/main/usrspi/sr_miso
add wave -noupdate /spi_slave_tb/main/usrspi/read_en
add wave -noupdate -radix unsigned -childformat {{{/spi_slave_tb/main/usrspi/reg_wr_addr[7]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[6]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[5]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[4]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[3]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[2]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[1]} -radix unsigned} {{/spi_slave_tb/main/usrspi/reg_wr_addr[0]} -radix unsigned}} -subitemconfig {{/spi_slave_tb/main/usrspi/reg_wr_addr[7]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[6]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[5]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[4]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[3]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[2]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[1]} {-radix unsigned} {/spi_slave_tb/main/usrspi/reg_wr_addr[0]} {-radix unsigned}} /spi_slave_tb/main/usrspi/reg_wr_addr
add wave -noupdate /spi_slave_tb/main/usrspi/reg_wr_data
add wave -noupdate /spi_slave_tb/main/usrspi/reg_wr_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 174
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
configure wave -timelineunits us
update
WaveRestoreZoom {15012711 ps} {15341216 ps}
