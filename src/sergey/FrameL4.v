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
	output reg FrameOut,
	output [7:0]DataOut,
	output reg [47:0] RemoteMACOut,
	output reg [31:0] RemoteIPOut,
	output reg [15:0] RemotePortOut


	
);


reg [5:0 ]HeadCounter=1'b0; 
reg [15:0]PackCounter=1'b0; 
reg [15:0]FrameSize=1'b0; 

reg [7:0]DataReg; 
reg ValReg;
reg EoFReg;
reg ErrReg;

reg [7:0]DataRegD0; 
reg ValRegD0;
reg EoFRegD0;
reg ErrRegD0;
reg SoFRegD0;
reg PackStateD0;

reg [7:0]DataRegD1; 
reg ValRegD1;
reg EoFRegD1;
reg ErrRegD1;
reg SoFRegD1;
reg PackStateD1;

reg HeaderState=1'b0; 
reg PackState=1'b0; 
reg WordCnt=1'b0; 

reg PortValid0;
reg PortValid1;
reg PortValid;



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



reg Sync;
reg Sync0;
reg Sync1;
reg Sync2;
reg Sync3;
reg Sync4;
reg Sync5;
reg Sync6;
reg Sync7; 
reg Sync8;
reg Sync9;
reg Sync10;
reg Sync11;
reg Sync12;
reg Sync13;
reg Sync14;
reg Sync15;
reg Sync16;
//reg Sync17;



reg [7:0] DataReg0; 
reg [7:0] DataReg1; 
reg [7:0] DataReg2; 

//reg [7:0] DataReg4; 


reg  CheckSumEna; 


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

reg SoFOutReg;
reg EoFOutReg;
reg ValOutReg;
reg ErrOutReg;
reg [7:0]DataOutReg;
reg SoFPulse;

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
