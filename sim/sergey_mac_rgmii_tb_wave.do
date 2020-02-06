onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_rgmii_tb/pll0_locked
add wave -noupdate /mac_rgmii_tb/clk200M
add wave -noupdate -divider RX
add wave -noupdate /mac_rgmii_tb/mac/RXC
add wave -noupdate /mac_rgmii_tb/mac/RXD
add wave -noupdate /mac_rgmii_tb/mac/RX_CTL
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_data
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_den
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_sof
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_eof
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/InnerMAC
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/ARPFrame
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/IP4Frame
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/DataIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/ValIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/EoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/SoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/WaitSync
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/Sync
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/DataOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/ValOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/SoFOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/EoFOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/ErrOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_inst/RemoteMACOut
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/IPD
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/TCP
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/UDP
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/DataIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/ValIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/SoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/EoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/ErrIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/PHeadOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/RemoteMACOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL3_inst/RemoteIPOut
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/IPD
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/PortD
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/DataIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/ValIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/SoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/EoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/ErrIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/FrameSize
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/RemoteMACOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/RemoteIPOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/RemotePortOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/CheckSumEna
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/CheckSum
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL4_inst/CheckCounter
add wave -noupdate /mac_rgmii_tb/mac/DATA_OUT
add wave -noupdate /mac_rgmii_tb/mac/ENA_OUT
add wave -noupdate /mac_rgmii_tb/mac/SOF_OUT
add wave -noupdate /mac_rgmii_tb/mac/EOF_OUT
add wave -noupdate /mac_rgmii_tb/mac/ERR_OUT
add wave -noupdate /mac_rgmii_tb/mac/CLK_OUT
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/InnerMAC
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/RemoteMAC
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/InnerIP
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/DataIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ValIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/SoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/EoFIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ErrIn
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/HeaderCorrect
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/IPCheck0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/IPCheck1
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/IPCheck2
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/IPCheck3
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/PackValid
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ValReg
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/EndValD0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/EoFReg
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ErrReg
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/OutRequest
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/Stop_Request
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/SyncOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ArpReq
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/DataOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/ValOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/SoFOut
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/ARP_L2_inst/EoFOut
add wave -noupdate -divider TX
add wave -noupdate /mac_rgmii_tb/mac/ReqIn0
add wave -noupdate /mac_rgmii_tb/mac/ReqConfirm
add wave -noupdate /mac_rgmii_tb/mac/DataIn0
add wave -noupdate /mac_rgmii_tb/mac/ValIn0
add wave -noupdate /mac_rgmii_tb/mac/SoFIn0
add wave -noupdate /mac_rgmii_tb/mac/EoFIn0
add wave -noupdate /mac_rgmii_tb/test_tx/start
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mac_rgmii_tb/test_tx/fsm_cs
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/MODE
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DataIn0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/ValIn0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/EoFIn0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/SoFIn0
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DataIn1
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/ValIn1
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/SoFIn1
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/EoFIn1
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/SyncRegL
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/OutValidReg
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DataReg8
add wave -noupdate {/mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/datain_h[5]}
add wave -noupdate {/mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/datain_l[5]}
add wave -noupdate {/mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/datain_h[4]}
add wave -noupdate {/mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/datain_l[4]}
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/phy_txc_obuf
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/phy_tx_ctl_obuf
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/FrameL2_Out_inst/DDR_OUT_inst/phy_txd_obuf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 462
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
WaveRestoreZoom {0 ps} {18900 ns}
