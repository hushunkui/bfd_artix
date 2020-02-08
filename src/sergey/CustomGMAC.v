module CustomGMAC
(
    input clk375,
    input clk125,

    input RXC,
    input RXC_DDR,
    input RX_CTL,
    input [3 :0]RXD,
    input [47:0]InnerMAC ,
    input [31:0]IPD ,
    input [15:0]PortD,

    input ValIn0,
    input SoFIn0,
    input EoFIn0,
    input ReqIn0,
    input [7:0]DataIn0,

    // input ValIn1,
    // input SoFIn1,
    // input EoFIn1,
    // input ReqIn1,
    // input [7:0]DataIn1,

    output [0:0] ReqConfirm,

    output CLK_TX,
    output TX_CTL,
    output [3:0]TXDATA,

    output MODE,
    output LINK_UP,
    output   [47:0] Remote_MACOut,
    output   [31:0] Remote_IP_Out,
    output   [15:0] RemotePortOut,
    output [7 :0] DATA_OUT,

    output reg [31 :0] InputCRC_ErrorCounter,
    output [7:0] dbg_rgmii_rx_data,
    output  dbg_rgmii_rx_den,
    output  dbg_rgmii_rx_sof,
    output  dbg_rgmii_rx_eof,
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

    output SOF_OUT,
    output EOF_OUT,
    output ENA_OUT,
    output ERR_OUT
);



wire wSOFRGMII;
wire wEOFRGMII;
wire wValRGMII;
wire [7:0]  wDATARGMII;




wire wLinkUP;
wire wDuplexMode;
wire [1:0]wSpeed;




//RGMII_rx RGMII_rx_inst (
//    .clk200  (CLK   ),
//    .RXC_DDR  (RXC_DDR     ),
//    .RXC      (clk125     ),
//    .RX_CTL   ( RX_CTL ),
//    .RXD      ( RXD    ),
//    .RX_ERR   (  ),
//    .RX_DV    (   ),
//    .ENA   ( wValRGMII  ),
//    .DATA_OUT ( wDATARGMII ),
//    .SOF   ( wSOFRGMII  ),
//    .EOF      ( wEOFRGMII  ),
//    .LINK_UP  ( wLinkUP),
//    .DUPLEX   ( wDuplexMode),
//    .SPEED    ( wSpeed)
//);



 RGMIIOverClockModule RGMIIOverClockModule_inst(
    . clk375(clk375),
    . clk125(clk125),
    . RGMII_Data(RXD),
    . RGMII_Ctrl(RX_CTL),
    . RGMII_Clk(RXC),


    . Data_Out(wDATARGMII),
    . Val_Out(wValRGMII),
    . Err_Out(),
    . SoF_Out(wSOFRGMII),
    . EoF_Out(wEOFRGMII),

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

    .  LINK_UP(wLinkUP),
    .  DUPLEX(wDuplexMode),
    .  SPEED(wSpeed)
    );


assign dbg_rgmii_rx_data = wDATARGMII;
assign dbg_rgmii_rx_den = wValRGMII;
assign dbg_rgmii_rx_sof = wSOFRGMII;
assign dbg_rgmii_rx_eof = wEOFRGMII;



// DDR_OUT DDR_OUT_inst (
//  .datain_l ( {1'b0,wValRGMII,wDATARGMII[7:4]}),
//  .datain_h ( {1'b1,wValRGMII,wDATARGMII[3:0]}),
//  .outclock ( RXC ),
//  .dataout  ( {CLK_TX,TX_CTL,TXDATA} )
//  );




wire wSOFL2;
wire wEOFL2;
wire wValL2;
wire wErrL2;
wire wIP4;
wire wARP;
wire [7:0]  wDATAL2;
wire [47:0] wRemoteMACL2;



FrameSync  FrameL2_inst
(
    .Clk       ( clk125        ),
    .SoFIn     ( wSOFRGMII  ),
    .EoFIn     ( wEOFRGMII  ),
    .ValIn     ( wValRGMII  ),
    .DataIn    ( wDATARGMII ),
    .InnerMAC  ( InnerMAC  ),
    .IP4Frame  ( wIP4     ),
    .ARPFrame  ( wARP   ),
    .RemoteMACOut  ( wRemoteMACL2 ),
    .SoFOut    ( wSOFL2     ),
    .EoFOut    ( wEOFL2     ),
    .ValOut    ( wValL2     ),
    .ErrOut    ( wErrL2     ),
    .DataOut   ( wDATAL2    )
);


reg [7:0]DATAL2 = 0;
reg SOFL2 = 0;
reg EOFL2 = 0;
reg ValL2 = 0;
reg ErrL2 = 0;


always @(posedge clk125)
begin
if (wEOFL2&&wErrL2) InputCRC_ErrorCounter<=InputCRC_ErrorCounter+1'b1;

if (wIP4) DATAL2 <=wDATAL2; else DATAL2 <=1'b0;
if (wIP4) SOFL2  <=wSOFL2;  else SOFL2  <=1'b0;
if (wIP4) EOFL2  <=wEOFL2;  else EOFL2  <=1'b0;
if (wIP4) ValL2  <=wValL2;  else ValL2  <=1'b0;
if (wIP4) ErrL2  <=wErrL2;  else ErrL2  <=1'b0;
end





wire wSOFL3;
wire wEOFL3;
wire wValL3;
wire wErrL3;
wire wUDPL3;
wire [7:0]  wDATAL3;
wire [23:0] wPHeadL3;
wire [31:0] wRemoteIPL3;
wire [47:0] wRemoteMACL3;


FrameL3  FrameL3_inst
(
    .Clk    ( clk125    ),
    .SoFIn  ( SOFL2 ),
    .EoFIn  ( EOFL2 ),
    .ValIn  ( ValL2 ),
    .ErrIn  ( ErrL2 ),
    .DataIn ( DATAL2),
    .RemoteMACIn (wRemoteMACL2),
    .RemoteMACOut(wRemoteMACL3),
    .RemoteIPOut ( wRemoteIPL3 ),

    .IPD   ( IPD     ),
    .UDP    ( wUDPL3 ),
    .SoFOut ( wSOFL3  ),
    .EoFOut ( wEOFL3  ),
    .ValOut ( wValL3  ),
    .ErrOut ( wErrL3 ),
    .FrameOut(),
    .PHeadOut(wPHeadL3),
    .DataOut( wDATAL3 )
);


reg [7:0]DATAL3 = 0;
reg [31:0]IPSL3 = 0;
reg SOFL3 = 0;
reg EOFL3 = 0;
reg ValL3 = 0;
reg ErrL3 = 0;

wire [47:0] wRemoteMACL4;


always @(posedge clk125)
begin
if (wUDPL3) DATAL3 <=wDATAL3; else DATAL3 <=1'b0;
if (wUDPL3) SOFL3  <=wSOFL3;  else SOFL3  <=1'b0;
if (wUDPL3) EOFL3  <=wEOFL3;  else EOFL3  <=1'b0;
if (wUDPL3) ValL3  <=wValL3;  else ValL3  <=1'b0;
if (wUDPL3) ErrL3  <=wErrL3;  else ErrL3  <=1'b0;
//if (wUDPL3) IPSL3  <=wRemoteIPL3;  else IPSL3  <=1'b0;
end


FrameL4  FrameL4_inst
(
    .Clk    ( clk125    ),
    .SoFIn  ( SOFL3 ) ,
    .EoFIn  ( EOFL3 ) ,
    .ValIn  ( ValL3 ) ,
    .ErrIn  ( ErrL3 ) ,
    .DataIn ( DATAL3) ,
    .PHeadIn(wPHeadL3),
    // .PortD  (16'h2323) ,
    .PortD  (PortD) ,

    .RemoteMACIn  (wRemoteMACL3 ),
    .RemoteIPIn   ( wRemoteIPL3 ),

    .RemoteMACOut (Remote_MACOut ),
    .RemoteIPOut  (Remote_IP_Out ),
    .RemotePortOut(RemotePortOut ),

    // .IPD   ( 32'hC0A80505      ),
    .IPD   ( IPD   ) ,

    .SoFOut (SOF_OUT),
    .EoFOut (EOF_OUT),
    .ValOut (ENA_OUT),
    .ErrOut ( ERR_OUT),
    .FrameOut(),
    .DataOut( DATA_OUT  )
);



reg [7:0]DATA_ARP_L2 = 0;
reg   SOF_ARP_L2 = 0;
reg   EOF_ARP_L2 = 0;
reg   Val_ARP_L2 = 0;
reg   Err_ARP_L2 = 0;


always @(posedge clk125)
begin
if (wARP) DATA_ARP_L2 <=wDATAL2; else DATA_ARP_L2 <=1'b0;
if (wARP) SOF_ARP_L2  <=wSOFL2;  else SOF_ARP_L2  <=1'b0;
if (wARP) EOF_ARP_L2  <=wEOFL2;  else EOF_ARP_L2  <=1'b0;
if (wARP) Val_ARP_L2  <=wValL2;  else Val_ARP_L2  <=1'b0;
if (wARP) Err_ARP_L2  <=wErrL2;  else Err_ARP_L2  <=1'b0;
end



wire wArpReq;
wire wArpEoF;
wire wArpSoF;
wire wArpVal;
wire wArpSync;
wire wArpFrame;
wire [7:0] wArpData;

//////////////////////////////////////////////

wire [1:0] wReqConfirm;

ARP_L2  ARP_L2_inst
(
    . Clk  (clk125),
    . SoFIn  (SOF_ARP_L2),
    . EoFIn  (EOF_ARP_L2),
    . ValIn  (Val_ARP_L2),
    . ErrIn  (Err_ARP_L2),
    . DataIn  (DATA_ARP_L2),
    . InnerMAC (InnerMAC),
    . RemoteMAC(wRemoteMACL2),
    . InnerIP  ( IPD ),
    . ReqConfirm(wReqConfirm[0]),
    . MODE     (wSpeed[1]),
    . ArpReq   (wArpReq  ),
    . ValOut   (wArpVal  ),
    . FrameOut (wArpFrame),
    . SyncOut  (wArpSync ),
    . SoFOut (wArpSoF  ),
    . EoFOut   (wArpEoF  ),
    . DataOut (wArpData )
);

FrameL2_Out  FrameL2_Out_inst
(
    .Clk ( clk125      ),
    .MODE( wSpeed[1]),

    .LINK_UP (wLinkUP),

    .ValIn0 (wArpVal ),
    .SoFIn0 (wArpSoF ),
    .EoFIn0 (wArpEoF ),
    .ReqIn0 (1'b0),//(wArpReq ),
    .DataIn0(wArpData),

    .ValIn1 (ValIn0 ),
    .SoFIn1 (SoFIn0 ),
    .EoFIn1 (EoFIn0 ),
    .ReqIn1 (ReqIn0 ),
    .DataIn1(DataIn0),

    // .ValIn1 (ValIn1),
    // .SoFIn1 (SoFIn1),
    // .EoFIn1 (EoFIn1),
    // .ReqIn1 (ReqIn1),
    // .DataIn1(DataIn1),

    // .ValIn2 (ValIn2),
    // .SoFIn2 (SoFIn2),
    // .EoFIn2 (EoFIn2),
    // .ReqIn2 (ReqIn2),
    // .DataIn2(DataIn2),

    .ReqConfirm(wReqConfirm),

    .ClkOut  ( CLK_TX ),
    .ValOut  ( TX_CTL ),
    .DataOut ( TXDATA )
);


assign ReqConfirm = wReqConfirm[1:1];


endmodule