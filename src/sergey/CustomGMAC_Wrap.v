module CustomGMAC_Wrap
#( parameter InnerMAC=48'hC0A805050505 )
(

    input clk375,
    input clk125,

    input   RXC,
    input   RX_CTL,
    input   [3:0]RXD,

    output CLK_TX,
    output TX_CTL,
    output [3:0]TXDATA,

    output 	MODE,
    output  LINK_UP,

    input   ValIn0,
    input   SoFIn0,
    input   EoFIn0,
    input   ReqIn0,
    input   [7:0]DataIn0,

    output [0:0] ReqConfirm,

    output [7:0] dbg_rgmii_rx_data,
    output dbg_rgmii_rx_den,
    output dbg_rgmii_rx_sof,
    output dbg_rgmii_rx_eof,
    output [3:0] dbg_fi,
    output [9:0] dbg_fi_dcnt,
    output [6:0] dbg_fi_wr_data_count,
    output [3:0] dbg_fo,
    output [9:0] dbg_fo_dcnt,
    output [6:0] dbg_fo_rd_data_count,
    output [1:0] dbg_fi_wRGMII_Clk,
    output [4:0] dbg_fi_wDataDDRL,
    output [4:0] dbg_fi_wDataDDRH,
    output [3:0] dbg_fi_wCondition,
    output       dbg_fi_LoadDDREnaD0,
    output [31:0] dbg_crc,
    output dbg_crc_rdy,
    output [7:0] dbg_wDataCRCOut,
    output dbg_wDataCRCVal,
    output dbg_wDataCRCSoF,
    output dbg_wDataCRCEoF,

    output [47:0] Remote_MACOut,
    output [31:0] Remote_IP_Out,
    output [15:0] RemotePortOut,
    output SOF_OUT,
    output EOF_OUT,
    output ENA_OUT,
    output ERR_OUT,
    output [7 :0] DATA_OUT,
    output [31 :0] InputCRC_ErrorCounter

);


CustomGMAC  CustomGMAC_Inst
(
    . clk375(clk375),
    . clk125(clk125),

    .RXC(RXC),
    .RX_CTL(RX_CTL),
    .RXD(RXD),
    .InnerMAC (48'hC0A805050505 ),
    .IPD (32'hC0A80507),
    .PortD (16'h04D2),
    .MODE(MODE),
    .LINK_UP(LINK_UP),
    .CLK_TX(CLK_TX),
    .TX_CTL(TX_CTL),
    .TXDATA(TXDATA),

    .ValIn0 (ValIn0 ),
    .SoFIn0 (SoFIn0 ),
    .EoFIn0 (EoFIn0 ),
    .ReqIn0 (ReqIn0 ),
    .DataIn0(DataIn0),

    // .ValIn1 (ValIn1),
    // .SoFIn1 (SoFIn1),
    // .EoFIn1 (EoFIn1),
    // .ReqIn1 (ReqIn1),
    // .DataIn1(DataIn1),

    .ReqConfirm(ReqConfirm),

    .dbg_rgmii_rx_data(dbg_rgmii_rx_data),
    .dbg_rgmii_rx_den(dbg_rgmii_rx_den),
    .dbg_rgmii_rx_sof(dbg_rgmii_rx_sof),
    .dbg_rgmii_rx_eof(dbg_rgmii_rx_eof),
    .dbg_fi(dbg_fi),
    .dbg_fi_dcnt(dbg_fi_dcnt),
    .dbg_fi_wr_data_count(dbg_fi_wr_data_count),
    .dbg_fo(dbg_fo),
    .dbg_fo_dcnt(dbg_fo_dcnt),
    .dbg_fo_rd_data_count(dbg_fo_rd_data_count),
    .dbg_fi_wRGMII_Clk(dbg_fi_wRGMII_Clk),
    .dbg_fi_wDataDDRL(dbg_fi_wDataDDRL),
    .dbg_fi_wDataDDRH(dbg_fi_wDataDDRH),
    .dbg_fi_wCondition(dbg_fi_wCondition),
    .dbg_fi_LoadDDREnaD0(dbg_fi_LoadDDREnaD0),
    .dbg_crc(dbg_crc),
    .dbg_crc_rdy(dbg_crc_rdy),
    .dbg_wDataCRCOut(dbg_wDataCRCOut),
    .dbg_wDataCRCVal(dbg_wDataCRCVal),
    .dbg_wDataCRCSoF(dbg_wDataCRCSoF),
    .dbg_wDataCRCEoF(dbg_wDataCRCEoF),

    .Remote_MACOut(Remote_MACOut),
    .Remote_IP_Out(Remote_IP_Out),
    .RemotePortOut(RemotePortOut),
    .InputCRC_ErrorCounter(InputCRC_ErrorCounter),
    .DATA_OUT(DATA_OUT),
    .SOF_OUT (SOF_OUT ),
    .EOF_OUT (EOF_OUT ),
    .ENA_OUT (ENA_OUT ),
    .ERR_OUT (ERR_OUT )
);


endmodule