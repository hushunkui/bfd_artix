module FrameL2_Out
(
	input	Clk,
	input LINK_UP,

	input	ValIn0,
	input	SoFIn0,
	input	EoFIn0,
	input	ReqIn0,
	input	[7:0] DataIn0,

	input	ValIn1,
	input	SoFIn1,
	input	EoFIn1,
	input	ReqIn1,
	input	[7:0]DataIn1,

	// input	ValIn2,
	// input	SoFIn2,
	// input	EoFIn2,
	// input	ReqIn2,
	// input	[7:0]DataIn2,

	// input	ValIn3,
	// input	SoFIn3,
	// input	EoFIn3,
	// input	ReqIn3,
	// input	[7:0]DataIn3,

	output[1:0]ReqConfirm,

	input	MODE,

	output ClkOut,
	output ValOut,
	output [3:0]DataOut
);

wire	wValIn;
wire	wSoFIn;
wire	wEoFIn;
wire	[7:0]wDataIn;



EthScheduler EthScheduler_Inst
(
   .	Clk	 (Clk),
	.  LINK_UP(LINK_UP),
	.	ValIn0 (ValIn0 ),
	.	SoFIn0 (SoFIn0 ),
	.	EoFIn0 (EoFIn0 ),
	.	ReqIn0 (ReqIn0 ),
	.	DataIn0(DataIn0),

	.	ValIn1 (ValIn1 ),
	.	SoFIn1 (SoFIn1 ),
	.	EoFIn1 (EoFIn1 ),
	.	ReqIn1 (ReqIn1 ),
	.	DataIn1(DataIn1),

	// .	ValIn2 (ValIn2),
	// .	SoFIn2 (SoFIn2),
	// .	EoFIn2 (EoFIn2),
	// .	ReqIn2 (ReqIn2),
	// .	DataIn2(DataIn2),

	// .	ValIn3 (ValIn3),
	// .	SoFIn3 (SoFIn3),
	// .	EoFIn3 (EoFIn3),
	// .	ReqIn3 (ReqIn3),
	// .	DataIn3(DataIn3),

	.  ReqConfirm(ReqConfirm),

	.  ValOut (wValIn),
	.  SoFOut (wSoFIn),
	.  EoFOut (wEoFIn),
	.  DataOut(wDataIn)

);






reg Val_D;
reg SyncRegH =1'b0;
reg SyncRegL=1'b0;

reg [7:0]DataReg;
reg ValReg;
reg EoFReg;
reg SoFReg;
reg ErrReg;

wire wSync;

assign wSync = wSoFIn&!SoFReg;

wire [7:0]wDataCRCOut;
wire wDataCRCVal;
wire wDataCRCSoF;
wire wDataCRCEoF;
wire wDataCRCReady;
wire [7:0]wCRCOut0;
wire [7:0]wCRCOut1;
wire [7:0]wCRCOut2;
wire [7:0]wCRCOut3;


   EthCRC32    TX_EthCRC32_inst0
    (
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

   	. crc32({wCRCOut3,wCRCOut2,wCRCOut1,wCRCOut0}),
   	. crc32_Ready(wDataCRCReady)

);

//
reg [7:0]DataReg0;
reg [7:0]DataReg1;
reg [7:0]DataReg2;
reg [7:0]DataReg3;
reg [7:0]DataReg4;
reg [7:0]DataReg5;
reg [7:0]DataReg6;
reg [7:0]DataReg7;
reg [7:0]DataReg8;

reg [7:0]OutValid;

reg OutValidReg;


reg [3:0]DataL;
reg [3:0]DataH;

reg [7:0]CRC0;
reg [7:0]CRC1;
reg [7:0]CRC2;
reg [7:0]CRC3;

reg Busy=1'b0;
reg BusyStopD0=1'b0;

reg BusyStopD1=1'b0;
reg BusyStopD2=1'b0;
reg BusyStopD3=1'b0;
reg BusyStopD4=1'b0;

reg LinkUpReg;

always @(posedge Clk)
begin
DataReg<=wDataIn;
ValReg <=wValIn;
SoFReg <=wSoFIn;
EoFReg <=wEoFIn;


if (wDataCRCReady)
begin
CRC3<=wCRCOut3;
CRC2<=wCRCOut2;
CRC1<=wCRCOut1;
CRC0<=wCRCOut0;
end



if (wDataCRCEoF&&wDataCRCVal) BusyStopD0<=1'b1;
	else if (SyncRegL)  BusyStopD0<=1'b0;

if (SyncRegL)  BusyStopD1<=BusyStopD0;
if (SyncRegL)  BusyStopD2<=BusyStopD1;
if (SyncRegL)  BusyStopD3<=BusyStopD2;
if (SyncRegL)  BusyStopD4<=BusyStopD3;


LinkUpReg<=LINK_UP;


if (wDataCRCSoF&&wDataCRCVal&&LinkUpReg)
	begin
		Busy<=1'b1;
	end
	else if (BusyStopD4&&SyncRegL)
	begin
		Busy<=1'b0;
	end


if (wDataCRCSoF&&wDataCRCVal)
	begin
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
	end
	else if (SyncRegL)
	begin
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





if (MODE==1'b0)
	begin
	if (wValIn&&!ValReg)
		begin
			SyncRegL<=1'b1;
			SyncRegH<=1'b1;
		end
		else
		begin
			SyncRegL<=!SyncRegL;
			SyncRegH<=!SyncRegH;
		end
	end else
	begin
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



