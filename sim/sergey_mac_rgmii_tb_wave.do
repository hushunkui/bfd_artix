onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_rgmii_tb/clk200M
add wave -noupdate /mac_rgmii_tb/clk125M
add wave -noupdate /mac_rgmii_tb/pll0_locked
add wave -noupdate -divider RX
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_data_i
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_eof_i
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_sof_i
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_valid_i
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_data_o
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_eof_o
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_sof_o
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf_cut/mac_rx_valid_o
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/mac_rx_data
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/mac_rx_valid
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/mac_rx_sof
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/mac_rx_eof
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/axis_tready
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/axis_tdata
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/axis_tvalid
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/axis_tkeep
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/axis_tlast
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/clk
add wave -noupdate /mac_rgmii_tb/mac0_rxbuf/rstn
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/axis_tready
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/axis_tdata
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/axis_tvalid
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/axis_tkeep
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/axis_tlast
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_data
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_valid
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_sof
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_eof
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_rq
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/mac_tx_ack
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/clk
add wave -noupdate /mac_rgmii_tb/mac0_txbuf/rstn
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/DataIn0
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/ValIn0
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/SoFIn0
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EoFIn0
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/ReqIn0
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/DataIn1
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/ValIn1
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/SoFIn1
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EoFIn1
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/ReqIn1
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/ReqConfirm
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/CurrentState
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/DataOut
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/ValOut
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/SoFOut
add wave -noupdate /mac_rgmii_tb/mac0/CustomGMAC_Inst/FrameL2_Out_inst/EthScheduler_Inst/EoFOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 541
configure wave -valuecolwidth 70
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
WaveRestoreZoom {7957818 ps} {15081786 ps}
