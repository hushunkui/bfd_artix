onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_phy_tb/clk
add wave -noupdate /test_phy_tb/start
add wave -noupdate /test_phy_tb/test_phy/err
add wave -noupdate /test_phy_tb/test_phy/test_tx/fsm_cs
add wave -noupdate /test_phy_tb/test_phy/test_tx/srcambler_sof
add wave -noupdate -radix unsigned /test_phy_tb/test_phy/test_tx/dcnt
add wave -noupdate /test_phy_tb/test_phy/test_tx/mac_tx_data
add wave -noupdate /test_phy_tb/test_phy/test_tx/mac_tx_valid
add wave -noupdate /test_phy_tb/test_phy/test_tx/mac_tx_sof
add wave -noupdate /test_phy_tb/test_phy/test_tx/mac_tx_eof
add wave -noupdate /test_phy_tb/test_phy/test_rx/fsm_cs
add wave -noupdate /test_phy_tb/test_phy/test_rx/srcambler_sof
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_tx_data
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_data
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_valid
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_sof
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_eof
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_fr_good
add wave -noupdate /test_phy_tb/test_phy/test_rx/mac_rx_fr_err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 332
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
WaveRestoreZoom {11142239 ps} {11697537 ps}
