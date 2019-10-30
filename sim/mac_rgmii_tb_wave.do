onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_rgmii_tb/mac/phy_rxd
add wave -noupdate /mac_rgmii_tb/mac/phy_rx_ctrl
add wave -noupdate /mac_rgmii_tb/mac/phy_rx_clk
add wave -noupdate /mac_rgmii_tb/mac/mac_rx_data_o
add wave -noupdate /mac_rgmii_tb/mac/mac_rx_valid_o
add wave -noupdate /mac_rgmii_tb/mac/mac_rx_sof_o
add wave -noupdate /mac_rgmii_tb/mac/mac_rx_eof_o
add wave -noupdate /mac_rgmii_tb/mac/mac_rx_clk_o
add wave -noupdate /mac_rgmii_tb/mac/mac_tx_data
add wave -noupdate /mac_rgmii_tb/mac/mac_tx_valid
add wave -noupdate /mac_rgmii_tb/mac/mac_tx_eof
add wave -noupdate /mac_rgmii_tb/mac/mac_tx_sof
add wave -noupdate /mac_rgmii_tb/mac/mac_tx_clk
add wave -noupdate /mac_rgmii_tb/mac/phy_txd
add wave -noupdate /mac_rgmii_tb/mac/phy_tx_ctrl
add wave -noupdate /mac_rgmii_tb/mac/phy_tx_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 141
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
WaveRestoreZoom {0 ps} {82387200 ps}
