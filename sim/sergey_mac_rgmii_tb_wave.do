onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_rgmii_tb/pll0_locked
add wave -noupdate /mac_rgmii_tb/clk200M
add wave -noupdate /mac_rgmii_tb/mac/RXC
add wave -noupdate /mac_rgmii_tb/mac/RXD
add wave -noupdate /mac_rgmii_tb/mac/RX_CTL
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/wSpeed
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/LinkStatus_inst/LINK_UP
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rst
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_data
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_dv
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/rx_err
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/dataout_h
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/RGMIIDDRRX_inst/dataout_l
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/wDataH
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/wDataL
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/sr0_data
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/sr0_dv
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/sr1_data
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/sr1_dv
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/rgmii_sof
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/rgmii_eof
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/rgmii_data
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/rgmii_dv
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/DATA_OUT
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/ENA
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/SOF
add wave -noupdate /mac_rgmii_tb/mac/CustomGMAC_Inst/RGMII_rx_inst/EOF
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_data
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_den
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_eof
add wave -noupdate /mac_rgmii_tb/mac/dbg_rgmii_rx_sof
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7037576 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 412
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
WaveRestoreZoom {0 ps} {25178144 ps}
