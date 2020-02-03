onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_rgmii_tb/mac/RXC
add wave -noupdate /mac_rgmii_tb/mac/RXD
add wave -noupdate /mac_rgmii_tb/mac/RX_CTL
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_data
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_dv
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_err
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/dataout_h
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/dataout_l
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/LinkStatus_inst/LINK_UP
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_data
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_den
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_eof
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_sof
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 451
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
WaveRestoreZoom {2865509 ps} {3007079 ps}
