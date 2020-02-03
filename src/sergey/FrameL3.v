module FrameL3
(
	input	Clk,
	input	SoFIn,
	input	EoFIn,
	input	ValIn,
	input	ErrIn,
	input	[7:0]DataIn,
	input	[31:0]IPD ,
	input	[47:0]RemoteMACIn ,

	output SoFOut,
	output EoFOut,
	output ValOut,
	output ErrOut,
	output reg FrameOut,
	output [7:0]DataOut,
	output reg [47:0] RemoteMACOut = 0,
	output reg [31:0] RemoteIPOut = 0,
	output reg [23:0] PHeadOut = 0,
	output reg UDP,
	output reg TCP


);


reg [5:0]HeadCounter=1'b0;
reg [15:0]PackCounter=1'b0;
reg [15:0]FrameSize=1'b0;
//reg VersFlag=1'b0;

reg [7:0]DataReg = 0;
reg ValReg = 0;
reg EoFReg = 0;
reg ErrReg = 0;

reg HeaderState=1'b0;
reg PackState=1'b0;
reg WordCnt=1'b0;

reg [23:0] PHead0=1'b0;

reg IPValid0 = 0;
reg IPValid1 = 0;
reg IPValid2 = 0;
reg IPValid3 = 0;
reg IPValid = 0;


always @(posedge Clk)
begin
if (SoFIn&&ValIn) WordCnt<=1'b0;
	else if (ValIn) WordCnt<=!WordCnt;

//if (SoFIn&&ValIn) VersFlag<=(DataIn[7:4]==4'h4);

if (SoFIn&&ValIn) HeadCounter<=({DataIn[3:0],2'b00});
	else if (ValIn) HeadCounter<= HeadCounter-1'b1;

if (SoFIn&&ValIn) PackCounter<=1'b1;
	else if (ValIn) PackCounter<= PackCounter+1'b1;




DataReg<=DataIn;
ValReg <=ValIn;
EoFReg <=EoFIn;
ErrReg <=ErrIn;

if (SoFIn&ValIn)	HeaderState<=1'b1;
	else if ((HeadCounter==4'h1)&&ValIn) HeaderState<=1'b0;

if (HeaderState&&ValIn&&(HeadCounter==4'h1))	PackState<=1'b1;
	else if (EoFReg&&ValReg) PackState<=1'b0;



end

reg Sync = 0;
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
reg Sync20 = 0;

reg [7:0] DataReg0 = 0;
reg [7:0] DataReg1 = 0;
reg [7:0] DataReg2 = 0;
reg [7:0] DataReg3 = 0;
reg [7:0] DataReg4 = 0;
reg [7:0] DataReg5 = 0;
//reg [7:0] DataReg6;



reg [23:0]CheckCounter=1'b0;
reg [15:0] CheckSum=1'b0;
reg CheckSumFlag=1'b0;



always @(posedge Clk)
begin
if (SoFIn&&ValIn) CheckCounter<=1'b0;
	else if (ValReg&&WordCnt) CheckCounter<=CheckCounter+{DataReg0,DataReg};
CheckSum<=CheckCounter[15:0]+CheckCounter[23:16];

if (Sync20) CheckSumFlag<=(CheckSum[15:0]==16'hFFFF);

if (ValReg) DataReg0<=DataReg;
if (ValReg) DataReg1<=DataReg0;
if (ValReg) DataReg2<=DataReg1;
if (ValReg) DataReg3<=DataReg2;
if (ValReg) DataReg4<=DataReg3;
if (ValReg) DataReg5<=DataReg4;
//if (ValReg) DataReg6<=DataReg5;

Sync<=SoFIn&&ValIn;

if (Sync) RemoteMACOut<=RemoteMACIn;

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
if (ValReg) Sync20<=Sync19;


if (Sync0&&ValReg) PHead0<=((~{18'h0,DataReg0[3:0],2'b00})+1'b1);
	else if (ValReg&&Sync3) PHead0<=PHead0+{DataReg1,DataReg0};
			else if (ValReg&&Sync9) PHead0<=PHead0+{16'h0,DataReg0};


if (Sync10) PHeadOut <= PHead0;
	 else if (ValReg&&(Sync13||Sync15||Sync17||Sync19))  PHeadOut <= PHeadOut + {DataReg1,DataReg0};




if (Sync3) FrameSize <= {DataReg1,DataReg0};


if (Sync15) RemoteIPOut<= {DataReg3,DataReg2,DataReg1,DataReg0};




if (Sync19) IPValid0<=(DataReg0==IPD[ 7: 0])||(DataReg0==8'hFF);
if (Sync19) IPValid1<=(DataReg1==IPD[15: 8]);
if (Sync19) IPValid2<=(DataReg2==IPD[23:16]);
if (Sync19) IPValid3<=(DataReg3==IPD[31:24]);

IPValid<=IPValid0&&IPValid1&&IPValid2&&IPValid3;

if (Sync9) UDP<= {DataReg0==8'd17};
if (Sync9) TCP<= {DataReg0==8'd6};


end


reg [7:0]DataRegD0 = 0;
reg ValRegD0 = 0;
reg EoFRegD0 = 0;
reg ErrRegD0 = 0;
reg SoFRegD0 = 0;
reg PackStateD0 = 0;

reg [7:0]DataRegD1 = 0;
reg ValRegD1 = 0;
reg EoFRegD1 = 0;
reg ErrRegD1 = 0;
reg SoFRegD1 = 0;
reg PackStateD1 = 0;




reg SoFOutReg = 0;
reg EoFOutReg = 0;
reg ValOutReg = 0;
reg ErrOutReg = 0;
reg [7:0]DataOutReg = 0;
reg SoFPulse = 0;

always @(posedge Clk)
begin
//if (ValIn) SoFPulse<= ((HeadCounter==1'b1)&&HeaderState);
//
//SoFOutReg <= SoFPulse&&IPValid;
//ValOutReg <= ValReg&&PackState&&IPValid;
//DataOutReg<= DataReg&&IPValid;
//EoFOutReg <= EoFReg&&IPValid;
//ErrOutReg <= ErrReg||(PackCounter!=FrameSize)||(!CheckSumFlag)&&IPValid;
//FrameOut  <= PackState&&IPValid;


if (ValIn) SoFPulse<= ((HeadCounter==1'b1)&&HeaderState);

SoFRegD0 <= SoFPulse;
ValRegD0 <= ValReg&&PackState;
DataRegD0<= DataReg;
EoFRegD0 <= EoFReg;
ErrRegD0 <= ErrReg||(PackCounter!=FrameSize)||(!CheckSumFlag);
PackStateD0  <= PackState;

SoFRegD1 <=SoFRegD0;
DataRegD1<=DataRegD0;
ValRegD1 <=ValRegD0;
EoFRegD1 <=EoFRegD0;
ErrRegD1 <=ErrRegD0;
PackStateD1 <=PackStateD0;

SoFOutReg <= SoFRegD1&&IPValid;
ValOutReg <= ValRegD1&&IPValid;
DataOutReg<= DataRegD1;
EoFOutReg <= EoFRegD1&&IPValid;
ErrOutReg <= ErrRegD1&&IPValid;
FrameOut  <= PackStateD1&&IPValid;



end

assign DataOut= DataOutReg;
assign ValOut = ValOutReg;
assign EoFOut = EoFOutReg;
assign SoFOut = SoFOutReg;
assign ErrOut = ErrOutReg;

endmodule
