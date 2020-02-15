module FrameL2_Out
(
    input Clk,
    input LINK_UP,

    input ValIn0,
    input SoFIn0,
    input EoFIn0,
    input ReqIn0,
    input [7:0] DataIn0,

    input ValIn1,
    input SoFIn1,
    input EoFIn1,
    input ReqIn1,
    input [7:0]DataIn1,

    // input ValIn2,
    // input SoFIn2,
    // input EoFIn2,
    // input ReqIn2,
    // input [7:0]DataIn2,

    // input ValIn3,
    // input SoFIn3,
    // input EoFIn3,
    // input ReqIn3,
    // input [7:0]DataIn3,

    output[3:0]ReqConfirm,

    input MODE,
    output [31:0] dbg_crc,
    output dbg_crc_rdy,
    output [7:0] dbg_wDataCRCOut,
    output dbg_wDataCRCVal,
    output dbg_wDataCRCSoF,
    output dbg_wDataCRCEoF,

    output ClkOut,
    output ValOut,
    output [3:0]DataOut
);

wire wValIn;
wire wSoFIn;
wire wEoFIn;
wire [7:0]wDataIn;


// assign wValIn  = ValIn1 ;
// assign wSoFIn  = SoFIn1 ;
// assign wEoFIn  = EoFIn1 ;
// assign wDataIn = DataIn1;

// assign ReqConfirm[0] = 0;
// assign ReqConfirm[1] = ReqIn1;


EthScheduler EthScheduler_Inst
(
    .Clk(Clk),
    .LINK_UP(LINK_UP),

    .ValIn0 (ValIn0 ),
    .SoFIn0 (SoFIn0 ),
    .EoFIn0 (EoFIn0 ),
    .ReqIn0 (1'b0),//(ReqIn0 ),
    .DataIn0(DataIn0),

    .ValIn1 (ValIn1 ),
    .SoFIn1 (SoFIn1 ),
    .EoFIn1 (EoFIn1 ),
    .ReqIn1 (ReqIn1 ),
    .DataIn1(DataIn1),

    .ValIn2 (1'b0),//(ValIn2),
    .SoFIn2 (1'b0),//(SoFIn2),
    .EoFIn2 (1'b0),//(EoFIn2),
    .ReqIn2 (1'b0),//(ReqIn2),
    .DataIn2(8'd0),//(DataIn2),

    .ValIn3 (1'b0),//(ValIn3),
    .SoFIn3 (1'b0),//(SoFIn3),
    .EoFIn3 (1'b0),//(EoFIn3),
    .ReqIn3 (1'b0),//(ReqIn3),
    .DataIn3(8'd0),//(DataIn3),

    .ReqConfirm(ReqConfirm),

    .ValOut (wValIn),
    .SoFOut (wSoFIn),
    .EoFOut (wEoFIn),
    .DataOut(wDataIn)
);


reg Val_D = 0;
reg SyncRegH =1'b0;
reg SyncRegL=1'b0;

reg [7:0]DataReg = 0;
reg ValReg = 0;
reg EoFReg = 0;
reg SoFReg = 0;
reg ErrReg = 0;

wire wSync;

wire [7:0]wDataCRCOut;
wire wDataCRCVal;
wire wDataCRCSoF;
wire wDataCRCEoF;
wire wDataCRCReady;
wire [7:0]wCRCOut0;
wire [7:0]wCRCOut1;
wire [7:0]wCRCOut2;
wire [7:0]wCRCOut3;

assign wSync = wSoFIn&!SoFReg;

EthCRC32  TX_EthCRC32_inst0(
    . clk(Clk),
    . DataIn     (DataReg ),
    . DataValid  (ValReg),
    . EndOfPacket(EoFReg),
    . StartOfPacket(SoFReg),
    . Sync(wSync),
    . CRCErr(),

    . DataOutValid(wDataCRCVal),
    . DataOut(wDataCRCOut),
    . DataOutSoF(wDataCRCSoF),
    . DataOutEoF(wDataCRCEoF),

    .dbg_crc_(dbg_crc),

    . crc32({wCRCOut3,wCRCOut2,wCRCOut1,wCRCOut0}),
    . crc32_Ready(wDataCRCReady)
);

//
reg [7:0]DataReg0 = 0;
reg [7:0]DataReg1 = 0;
reg [7:0]DataReg2 = 0;
reg [7:0]DataReg3 = 0;
reg [7:0]DataReg4 = 0;
reg [7:0]DataReg5 = 0;
reg [7:0]DataReg6 = 0;
reg [7:0]DataReg7 = 0;
reg [7:0]DataReg8 = 0;

reg [7:0]OutValid = 0;

reg OutValidReg = 0;

reg [3:0]DataL = 0;
reg [3:0]DataH = 0;

reg [7:0]CRC0 = 0;
reg [7:0]CRC1 = 0;
reg [7:0]CRC2 = 0;
reg [7:0]CRC3 = 0;

reg Busy=1'b0;
reg BusyStopD0=1'b0;

reg BusyStopD1=1'b0;
reg BusyStopD2=1'b0;
reg BusyStopD3=1'b0;
reg BusyStopD4=1'b0;

reg LinkUpReg = 0;

// assign dbg_crc = {wCRCOut3, wCRCOut2, wCRCOut1, wCRCOut0};
assign dbg_crc_rdy = wDataCRCReady;

assign dbg_wDataCRCOut = wDataCRCOut;
assign dbg_wDataCRCVal = wDataCRCVal;
assign dbg_wDataCRCSoF = wDataCRCSoF;
assign dbg_wDataCRCEoF = wDataCRCEoF;

always @(posedge Clk)
begin
    DataReg<=wDataIn;
    ValReg <=wValIn;
    SoFReg <=wSoFIn;
    EoFReg <=wEoFIn;

    if (wDataCRCReady) begin
        CRC3<=wCRCOut3;
        CRC2<=wCRCOut2;
        CRC1<=wCRCOut1;
        CRC0<=wCRCOut0;
    end

    if (wDataCRCEoF && wDataCRCVal)
        BusyStopD0<=1'b1;
    else if (SyncRegL)
        BusyStopD0<=1'b0;

    if (SyncRegL)  BusyStopD1<=BusyStopD0;
    if (SyncRegL)  BusyStopD2<=BusyStopD1;
    if (SyncRegL)  BusyStopD3<=BusyStopD2;
    if (SyncRegL)  BusyStopD4<=BusyStopD3;

    LinkUpReg<=LINK_UP;

    if (wDataCRCSoF && wDataCRCVal && LinkUpReg) begin
        Busy<=1'b1;
    end else if (BusyStopD4 && SyncRegL) begin
        Busy<=1'b0;
    end

    if (wDataCRCSoF && wDataCRCVal) begin
        DataReg0<=wDataCRCOut;
        DataReg1<=8'hD5;
        DataReg2<=8'h55;
        DataReg3<=8'h55;
        DataReg4<=8'h55;
        DataReg5<=8'h55;
        DataReg6<=8'h55;
        DataReg7<=8'h55;
        DataReg8<=8'h55;
        OutValid<=8'b11111111;

    end else if (SyncRegL) begin
        OutValid<={OutValid[6:0],Busy};

        if (BusyStopD3) DataReg0<= CRC3;
            else DataReg0<=wDataCRCOut;
        if (BusyStopD3) DataReg1<= CRC2;
            else DataReg1<=DataReg0;
        if (BusyStopD3) DataReg2<= CRC1;
            else DataReg2<=DataReg1;
        if (BusyStopD3) DataReg3<= CRC0;
            else DataReg3<=DataReg2;

        DataReg4<=DataReg3;
        DataReg5<=DataReg4;
        DataReg6<=DataReg5;
        DataReg7<=DataReg6;
        DataReg8<=DataReg7;
    end

    if (MODE==1'b0) begin
        if (wValIn && !ValReg) begin
            SyncRegL<=1'b1;
            SyncRegH<=1'b1;
        end else begin
            SyncRegL<=!SyncRegL;
            SyncRegH<=!SyncRegH;
        end
    end else begin
        SyncRegL<=1'b1;
        SyncRegH<=1'b0;
    end

    OutValidReg<=OutValid[7];

    //--------------------------------------------------
    if ( SyncRegL ) DataL<= DataReg8[7:4];
        else DataL<= DataReg8[3:0];
    //--------------------------------------------------
    if ( SyncRegH ) DataH<= DataReg8[7:4];
        else DataH<= DataReg8[3:0];
    //--------------------------------------------------
end


DDR_OUT	DDR_OUT_inst (
    .datain_l ( {1'b0,OutValidReg,DataL}),
    .datain_h ( {1'b1,OutValidReg,DataH}),
    .outclock ( Clk ),
    .dataout  ( {ClkOut,ValOut,DataOut} )
);

endmodule



