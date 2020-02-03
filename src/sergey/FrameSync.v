
module FrameSync
(
	input	Clk,
	input	SoFIn,
	input	EoFIn,
	input	ValIn,
	input	[7:0]DataIn,
	input	[47:0]InnerMAC ,

	output SoFOut,
	output EoFOut,
	output ValOut,
	output ErrOut,
	output FrameOut,
	output [7 :0] DataOut,
	output [47:0] RemoteMACOut,
	output reg ARPFrame = 0,
//	output reg JumFrame,
	output reg IP4Frame = 0


);

reg [7:0]DataReg = 0;
reg Pream0 = 0;
reg Pream1 = 0;
reg Pream2 = 0;
reg Pream3 = 0;
reg Sync = 0;
reg ValReg = 0;
reg ValReg0 = 0;
reg ValReg1 = 0;


reg EoFReg = 0;
reg EoFReg0 = 0;

reg Sync0 = 0;
reg Sync1 = 0;
reg Sync2 = 0;
reg Sync3 = 0;
reg Sync4 = 0;
reg Sync5 = 0;
reg Sync6 = 0;
reg Sync7 = 0;
reg Sync8 = 0;
reg Sync9 = 0;
reg Sync10 = 0;
reg Sync11 = 0;
reg Sync12 = 0;
reg Sync13 = 0;
reg Sync14 = 0;
reg Sync15 = 0;

reg Sync16 = 0;
reg Sync17 = 0;
reg Sync18 = 0;
reg Sync19 = 0;

//reg Sync15_D;

//wire wStartPayload;
//assign wStartPayload = Sync14;
//wire wSoFPayload;
//assign wSoFPayload =   Sync15;

wire wStartPayload;
assign wStartPayload = Sync18;
wire wSoFPayload;
assign wSoFPayload =   Sync19;

reg [7:0] DataReg0 = 0;
reg [7:0] DataReg1 = 0;
reg [7:0] DataReg2 = 0;
reg [7:0] DataReg3 = 0;
reg [7:0] DataReg4 = 0;
reg [7:0] DataReg5 = 0;
reg [7:0] DataReg6 = 0;

reg [7:0]SMACAdr0 = 0;
reg [7:0]SMACAdr1 = 0;
reg [7:0]SMACAdr2 = 0;
reg [7:0]SMACAdr3 = 0;
reg [7:0]SMACAdr4 = 0;
reg [7:0]SMACAdr5 = 0;
reg [7:0]DMACAdr0 = 0;
reg [7:0]DMACAdr1 = 0;
reg [7:0]DMACAdr2 = 0;
reg [7:0]DMACAdr3 = 0;
reg [7:0]DMACAdr4 = 0;
reg [7:0]DMACAdr5 = 0;

reg MacValid0 = 0;
reg MacValid1 = 0;
reg MacValid2 = 0;
reg MacValid3 = 0;
reg MacValid4 = 0;
reg MacValid5 = 0;
reg MacValid = 0;

reg PayloadReg=1'b0;

reg PackDecode=1'b0;
reg CRCVal0=1'b0;


   EthCRC32    RX_EthCRC32_inst0
    (

    . clk(Clk),
    . DataIn     (DataReg0 ),
    . DataValid  (CRCVal0),
    . EndOfPacket(EoFReg0),
    . StartOfPacket(Sync1),
	 . Sync(Sync0),
	 . CRCErr(ErrOut),

//    . DataOutSOF_R(),
//    . DataOutEOF_R(),
//    . DataOutCRC_OK_R(),
//    . DataOutValid_R(),
//    . DataOut_R(),


   	. DataOutValid(),
   	. DataOut(),
   	. crc32(),
   	. crc32_Ready()
//   	. crc32_ok2(),
//   	. crc32_ok()
);

reg WaitSync=1'b0;


always @(posedge Clk)
begin

if (wStartPayload&ValReg&MacValid) PayloadReg<=1'b1;
	else if (EoFReg0&ValReg0) PayloadReg<=1'b0;

if (SoFIn&ValIn)	PackDecode<=1'b0;
	else if (Sync) PackDecode<=1'b1;

if (SoFIn&ValIn)	WaitSync<=1'b1;
	else if (Sync) WaitSync<=1'b0;



CRCVal0<=	PackDecode&ValReg;


ValReg<=ValIn;
ValReg0<=ValReg;
ValReg1<=ValReg0;

EoFReg<=EoFIn;
EoFReg0<=EoFReg;

if (ValIn) DataReg<=DataIn;
if (ValIn) Pream0<=(DataIn==8'h55);
if (ValIn) Pream1<=Pream0;
if (ValIn) Pream2<=Pream1;
if (ValIn) Pream3<=Pream2;
if (ValIn) Sync<=(DataIn==8'hD5)&Pream0&Pream1&Pream2&Pream3&WaitSync;

if (ValReg) Sync0<=Sync ;
if (ValReg) Sync1<=Sync0;
if (ValReg) Sync2<=Sync1;
if (ValReg) Sync3<=Sync2;
if (ValReg) Sync4<=Sync3;
if (ValReg) Sync5<=Sync4;
if (ValReg) Sync6<=Sync5;
if (ValReg) Sync7<=Sync6;
if (ValReg) Sync8<=Sync7;
if (ValReg) Sync9<=Sync8;
if (ValReg) Sync10<=Sync9;
if (ValReg) Sync11<=Sync10;
if (ValReg) Sync12<=Sync11;
if (ValReg) Sync13<=Sync12;
if (ValReg) Sync14<=Sync13;
if (ValReg) Sync15<=Sync14;
if (ValReg) Sync16<=Sync15;
if (ValReg) Sync17<=Sync16;
if (ValReg) Sync18<=Sync17;
if (ValReg) Sync19<=Sync18;



if (ValReg) DataReg0<=DataReg;
if (ValReg) DataReg1<=DataReg0;
if (ValReg) DataReg2<=DataReg1;
if (ValReg) DataReg3<=DataReg2;
if (ValReg) DataReg4<=DataReg3;
if (ValReg) DataReg5<=DataReg4;
if (ValReg) DataReg6<=DataReg5;

if (Sync6) DMACAdr0<=DataReg0 ;
if (Sync6) DMACAdr1<=DataReg1 ;
if (Sync6) DMACAdr2<=DataReg2 ;
if (Sync6) DMACAdr3<=DataReg3 ;
if (Sync6) DMACAdr4<=DataReg4 ;
if (Sync6) DMACAdr5<=DataReg5 ;

if (Sync12) SMACAdr0<=DataReg0 ;
if (Sync12) SMACAdr1<=DataReg1 ;
if (Sync12) SMACAdr2<=DataReg2 ;
if (Sync12) SMACAdr3<=DataReg3 ;
if (Sync12) SMACAdr4<=DataReg4 ;
if (Sync12) SMACAdr5<=DataReg5 ;

if (Sync13) IP4Frame<=(DataReg0==8'h08)&&(DataReg==8'h00);
if (Sync13) ARPFrame<=(DataReg0==8'h08)&&(DataReg==8'h06);



//MacValid0<=(DMACAdr0==InnerMAC[ 7: 0])||(DMACAdr0==8'hFF);
//MacValid1<=(DMACAdr1==InnerMAC[15: 8])||(DMACAdr1==8'hFF);
//MacValid2<=(DMACAdr2==InnerMAC[23:16])||(DMACAdr2==8'hFF);
//MacValid3<=(DMACAdr3==InnerMAC[31:24])||(DMACAdr3==8'hFF);
//MacValid4<=(DMACAdr4==InnerMAC[39:32])||(DMACAdr4==8'hFF);
//MacValid5<=(DMACAdr5==InnerMAC[47:40])||(DMACAdr5==8'hFF);

if (Sync6) MacValid0<=(DataReg0==InnerMAC[ 7: 0])||(DataReg0==8'hFF);
if (Sync6) MacValid1<=(DataReg1==InnerMAC[15: 8])||(DataReg1==8'hFF);
if (Sync6) MacValid2<=(DataReg2==InnerMAC[23:16])||(DataReg2==8'hFF);
if (Sync6) MacValid3<=(DataReg3==InnerMAC[31:24])||(DataReg3==8'hFF);
if (Sync6) MacValid4<=(DataReg4==InnerMAC[39:32])||(DataReg4==8'hFF);
if (Sync6) MacValid5<=(DataReg5==InnerMAC[47:40])||(DataReg5==8'hFF);

MacValid<=MacValid0&&MacValid1&&MacValid2&&MacValid3&&MacValid4&&MacValid5;

//SoFOut<=Sync14;
//ValOut<=ValReg&&PayloadReg;
//EoFOut<=EoFIn&&PayloadReg;
end

reg [7:0]DataOutRegD0 = 0;
reg [7:0]DataOutRegD1 = 0;
reg ValOutRegD0 = 0;
reg ValOutRegD1 = 0;
reg SoFOutRegD0 = 0;
reg SoFOutRegD1 = 0;
reg EoFOutRegD0 = 0;
reg EoFOutRegD1 = 0;


//assign DataOut=DataReg4;
//assign ValOut=ValReg0&&PayloadReg;
//assign EoFOut=EoFReg0&&PayloadReg;
//assign SoFOut=wSoFPayload &&PayloadReg;

always @(posedge Clk)
begin
DataOutRegD0<=DataReg4;
DataOutRegD1<=DataOutRegD0;

ValOutRegD0<=ValReg0&&PayloadReg;
ValOutRegD1<=ValOutRegD0;

EoFOutRegD0<=EoFReg0&&PayloadReg;
EoFOutRegD1<=EoFOutRegD0;

SoFOutRegD0<=wSoFPayload &&PayloadReg;
SoFOutRegD1<=SoFOutRegD0;
end

assign DataOut=DataOutRegD1;
assign ValOut = ValOutRegD1;
assign EoFOut = EoFOutRegD1;
assign SoFOut = SoFOutRegD1;
assign RemoteMACOut = {SMACAdr5,SMACAdr4,SMACAdr3,SMACAdr2,SMACAdr1,SMACAdr0};

endmodule