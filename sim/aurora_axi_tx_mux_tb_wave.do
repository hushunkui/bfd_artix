onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/trunc
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/eth_mask
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/mac_rx_data}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/mac_rx_valid}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/mac_rx_sof}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/mac_rx_eof}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/mac_rx_err}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tready}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tdata}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tkeep}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tvalid}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tlast}
add wave -noupdate {/aurora_axi_tx_mux_tb/eth[0]/mac1_rxbuf/axis_tuser}
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tready
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tvalid
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_s_tvalid_mask
add wave -noupdate -expand /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/tdata
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum10_Im
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum10_Re
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum32_Im
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum32_Re
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum3210_Im
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/sum3210_Re
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tready
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tdata
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tkeep
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tvalid
add wave -noupdate /aurora_axi_tx_mux_tb/aurora0_axi_tx_mux/axis_m_tlast
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 381
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {10500 ns}
