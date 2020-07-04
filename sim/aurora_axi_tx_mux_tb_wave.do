onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aurora_axi_tx_mux_tb/mac_rx_data
add wave -noupdate /aurora_axi_tx_mux_tb/mac_rx_valid
add wave -noupdate /aurora_axi_tx_mux_tb/mac_rx_sof
add wave -noupdate /aurora_axi_tx_mux_tb/mac_rx_eof
add wave -noupdate /aurora_axi_tx_mux_tb/mac_rx_err
add wave -noupdate /aurora_axi_tx_mux_tb/axis_tready
add wave -noupdate -expand /aurora_axi_tx_mux_tb/axis_tdata
add wave -noupdate /aurora_axi_tx_mux_tb/axis_tkeep
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tvalid
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tlast
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tready
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tvalid_mask
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/tdata
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tdata
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tkeep
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tlast
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tready
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tvalid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 149
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
WaveRestoreZoom {0 ps} {15750 ns}
