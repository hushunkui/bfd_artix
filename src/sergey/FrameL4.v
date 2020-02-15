module FrameL4
(
	input	Clk,
	input	SoFIn,
	input	EoFIn,
	input	ValIn,
	input	ErrIn,
	input	[7 :0]DataIn,
	input [23:0]PHeadIn,
	input	[15:0]PortD ,
	input	[31:0]IPD ,
	input	[31:0]RemoteIPIn ,
	input	[47:0]RemoteMACIn ,

	output SoFOut,
	output EoFOut,
	output ValOut,
	output ErrOut,
	output reg FrameOut = 0,
	output [7:0]DataOut,
	output reg [47:0] RemoteMACOut = 0,
	output reg [31:0] RemoteIPOut = 0,
	output reg [15:0] RemotePortOut = 0



);


reg [5:0 ]HeadCounter=1'b0;
reg [15:0]PackCounter=1'b0;
reg [15:0]FrameSize=1'b0;

reg [7:0]DataReg = 0;
reg ValReg = 0;
reg EoFReg = 0;
reg ErrReg = 0;

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

reg HeaderState=1'b0;
reg PackState=1'b0;
reg WordCnt=1'b0;

reg PortValid0 = 0;
reg PortValid1 = 0;
reg PortValid = 0;



always @(posedge Clk)
begin


if (SoFIn&&ValIn) WordCnt<=1'b0;
	else if (ValIn) WordCnt<=!WordCnt;


if (SoFIn&&ValIn) HeadCounter<=(6'b001000);
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

/*



*/

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
//reg Sync17 = 0;



reg [7:0] DataReg0 = 0;
reg [7:0] DataReg1 = 0;
reg [7:0] DataReg2 = 0;

//reg [7:0] DataReg4 = 0;


reg  CheckSumEna = 0;


reg [23:0]CheckCounter=1'b0;
reg [15:0] CheckSum=1'b0;
//reg CheckSumFlag=1'b0;


always @(posedge Clk)
begin
if (SoFIn&&ValIn) CheckCounter<=PHeadIn;
	else if (ValReg&&WordCnt) CheckCounter<=CheckCounter+{DataReg0,DataReg};
CheckSum<=CheckCounter[15:0]+CheckCounter[23:16];

// CheckSumFlag<=(CheckSum[15:0]==16'hFFFF);

if (ValReg) DataReg0<=DataReg;
if (ValReg) DataReg1<=DataReg0;
if (ValReg) DataReg2<=DataReg1;

//if (ValReg) DataReg4<=DataReg3;

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
//if (ValReg) Sync17<=Sync16;


if (Sync5) FrameSize <= {DataReg1,DataReg0};
if (Sync1) RemotePortOut<= {DataReg1,DataReg0};
if (Sync0) RemoteIPOut  <= RemoteIPIn;
if (Sync3) PortValid0<=(DataReg0==PortD[ 7: 0]);
if (Sync3) PortValid1<=(DataReg1==PortD[15: 8]);

if (Sync7)  CheckSumEna<=|(DataReg1|DataReg0);


PortValid<=PortValid0&&PortValid1;
//IPValid<=1'b1;



end

reg SoFOutReg = 0;
reg EoFOutReg = 0;
reg ValOutReg = 0;
reg ErrOutReg = 0;
reg [7:0]DataOutReg = 0;
reg SoFPulse = 0;

always @(posedge Clk)
begin
if (ValIn) SoFPulse<= ((HeadCounter==1'b1)&&HeaderState);

SoFRegD0 <=SoFPulse;
DataRegD0<=DataReg;
ValRegD0 <=ValReg&&PackState;
EoFRegD0 <=EoFReg&&PackState;
ErrRegD0 <=ErrReg||(PackCounter!=FrameSize);//||(!CheckSumFlag);
PackStateD0 <=PackState;


SoFRegD1 <=SoFRegD0;
DataRegD1<=DataRegD0;
ValRegD1 <=ValRegD0;
EoFRegD1 <=EoFRegD0;
ErrRegD1 <=ErrRegD0;
PackStateD1 <=PackStateD0;



SoFOutReg <= SoFRegD1&&PortValid;
ValOutReg <= ValRegD1&&PortValid;
DataOutReg<= DataRegD1;
EoFOutReg <= EoFRegD1&&PortValid;
ErrOutReg <= ErrRegD1||((CheckSum[15:0]!=16'hFFFF)&&CheckSumEna);
FrameOut  <= PackStateD1&&PortValid;
end

assign DataOut= DataOutReg;
assign ValOut = ValOutReg;
assign EoFOut = EoFOutReg;
assign SoFOut = SoFOutReg;
assign ErrOut = ErrOutReg;



endmodule
