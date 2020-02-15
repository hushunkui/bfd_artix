module ARP_L2
(
	input	Clk,
	input	SoFIn,
	input	EoFIn,
	input	ValIn,
	input	ErrIn,
	input	[7:0]DataIn,

	input	[47:0]InnerMAC ,
	input	[47:0]RemoteMAC ,

	input	[31:0]InnerIP ,


	input	ReqConfirm,
	input	MODE,


	output ArpReq,
	output reg FrameOut = 0,
	output reg ValOut = 0,
	output reg SyncOut = 0,
	output reg SoFOut = 0,
	output reg EoFOut = 0,
	output [7:0]DataOut

);

reg EoFOutD = 0;


reg [7:0]DataReg = 0;
reg ValReg = 0;
reg ValRegD = 0;
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


reg OutTxSync=1'b0;

reg Sync = 0;
reg Sync0 = 0;

reg Stop_Request=1'b0;
reg Stop_RequestD=1'b0;
reg [4:0]Stop_RequestCounter=1'b0;



always @(posedge Clk)
begin

DataReg<=DataIn;
ValReg <=ValIn;
EoFReg <=EoFIn;
ErrReg <=ErrIn;

ValRegD <=  ValReg;


end







reg [3:0] HeaderCheck = 0;
reg HeaderCorrect = 0;

reg PackRecciveState=1'b0;

//reg [4:0] ArpCounter;

reg [7:0] ArpCounter = 0;
reg [7:0] MACRem0 = 0;
reg [7:0] MACRem1 = 0;
reg [7:0] MACRem2 = 0;
reg [7:0] MACRem3 = 0;
reg [7:0] MACRem4 = 0;
reg [7:0] MACRem5 = 0;

reg [7:0] IPRem0 = 0;
reg [7:0] IPRem1 = 0;
reg [7:0] IPRem2 = 0;
reg [7:0] IPRem3 = 0;

reg IPCheck0 = 0;
reg IPCheck1 = 0;
reg IPCheck2 = 0;
reg IPCheck3 = 0;
reg IPCheck = 0;


//reg MACCheck0 = 0;
//reg MACCheck1 = 0;
//reg MACCheck2 = 0;
//reg MACCheck3 = 0;
//reg MACCheck4 = 0;
//reg MACCheck5 = 0;
//reg MACCheck = 0;



reg PackValid = 0;

reg OutRequest =1'b0;
reg ReqConfirmD =1'b0;
reg StartPulse =1'b0;

reg [6:0] OutReadCounter=0;// reg unsigned [6:0] OutReadCounter=0;
reg OutReadState=1'b0;
reg EndValD0 = 0;
reg EndValD1 = 0;
reg EndValD2 = 0;
reg EndValD3 = 0;
reg EndValD4 = 0;


reg [7:0] MACDataReg0=0;
reg [7:0] MACDataReg1=0;
reg [7:0] MACDataReg2=0;

reg [7:0] OutDataReg0=0;
reg [7:0] OutDataReg1=0;
reg [7:0] OutDataReg2=0;
reg [7:0] OutDataReg3=0;



reg [7:0] DataReg0 = 0;








always @(posedge Clk)
begin





if (ValReg) DataReg0<=DataReg;




Sync<=SoFIn&&ValIn;
if (ValReg) Sync0<=Sync ;



if (Sync) PackRecciveState<=1'b1;
	else if ((ArpCounter==8'hFE) && ValReg) PackRecciveState<=1'b0;

if (Sync)ArpCounter<=1'b0;
	else if (ValReg&&PackRecciveState) ArpCounter<=ArpCounter+1'b1;

if (Sync) HeaderCheck<=1'b0;
	else if ((ArpCounter==8'h00) && ValRegD&&(DataReg0==8'h00)) HeaderCheck<=HeaderCheck+1'b1;
		else if ((ArpCounter==8'h01) && ValRegD&&(DataReg0==8'h01)) HeaderCheck<=HeaderCheck+1'b1;
			else if ((ArpCounter==8'h02) && ValRegD&&(DataReg0==8'h08)) HeaderCheck<=HeaderCheck+1'b1;
				else if ((ArpCounter==8'h03) && ValRegD&&(DataReg0==8'h00)) HeaderCheck<=HeaderCheck+1'b1;
					else if ((ArpCounter==8'h04) && ValRegD&&(DataReg0==8'h06)) HeaderCheck<=HeaderCheck+1'b1;
						else if ((ArpCounter==8'h05) && ValRegD&&(DataReg0==8'h04)) HeaderCheck<=HeaderCheck+1'b1;
							else if ((ArpCounter==8'h06) && ValRegD&&(DataReg0==8'h00)) HeaderCheck<=HeaderCheck+1'b1;
								else if ((ArpCounter==8'h07) && ValRegD&&(DataReg0==8'h01)) HeaderCheck<=HeaderCheck+1'b1;

if (Sync0) HeaderCorrect<=1'b0;
	else if ((ArpCounter==8'h08) &&(HeaderCheck==4'h8)) HeaderCorrect<=1'b1;

if (Sync0) MACRem5<=1'b0;
	else if ((ArpCounter==8'h08)&& ValRegD ) MACRem5<=DataReg0;
if (Sync0) MACRem4<=1'b0;
	else if ((ArpCounter==8'h09)&& ValRegD ) MACRem4<=DataReg0;
if (Sync0) MACRem3<=1'b0;
	else if ((ArpCounter==8'h0A)&& ValRegD ) MACRem3<=DataReg0;
if (Sync0) MACRem2<=1'b0;
	else if ((ArpCounter==8'h0B)&& ValRegD ) MACRem2<=DataReg0;
if (Sync0) MACRem1<=1'b0;
	else if ((ArpCounter==8'h0C)&& ValRegD ) MACRem1<=DataReg0;
if (Sync0) MACRem0<=1'b0;
	else if ((ArpCounter==8'h0D)&& ValRegD ) MACRem0<=DataReg0;
if (Sync0) IPRem3<=1'b0;
	else if ((ArpCounter==8'h0E)&& ValRegD ) IPRem3<=DataReg0;
if (Sync0) IPRem2<=1'b0;
	else if ((ArpCounter==8'h0F)&& ValRegD ) IPRem2<=DataReg0;
if (Sync0) IPRem1<=1'b0;
	else if ((ArpCounter==8'h10)&& ValRegD ) IPRem1<=DataReg0;
if (Sync0) IPRem0<=1'b0;
	else if ((ArpCounter==8'h11)&& ValRegD ) IPRem0<=DataReg0;



if (Sync0) IPCheck3<=1'b0;
	else if ((ArpCounter==8'h18)&& ValRegD ) IPCheck3<=(DataReg0==InnerIP[31:24]);
if (Sync0) IPCheck2<=1'b0;
	else if ((ArpCounter==8'h19)&& ValRegD ) IPCheck2<=(DataReg0==InnerIP[23:16]);
if (Sync0) IPCheck1<=1'b0;
	else if ((ArpCounter==8'h1A)&& ValRegD ) IPCheck1<=(DataReg0==InnerIP[15: 8]);
if (Sync0) IPCheck0<=1'b0;
	else if ((ArpCounter==8'h1B)&& ValRegD ) IPCheck0<=(DataReg0==InnerIP[ 7: 0]);







//IPCheck0<=(IPRem0==IP[ 7: 0]);
//IPCheck1<=(IPRem1==IP[15: 8]);
//IPCheck2<=(IPRem2==IP[23:16]);
//IPCheck3<=(IPRem3==IP[31:24]);
//IPCheck<=IPCheck0&IPCheck1&IPCheck2&IPCheck3;

//IPCheck<=1'b1;

PackValid<=IPCheck0&IPCheck1&IPCheck2&IPCheck3&HeaderCorrect;


//MACCheck0;
//MACCheck1;
//MACCheck2;
//MACCheck3;
//MACCheck4;
//MACCheck5;
//MACCheck;


//// ????????????????????????????????????

EndValD0<=ValReg&&EoFReg&&!ErrReg;
EndValD1<=EndValD0;
EndValD2<=EndValD1;
EndValD3<=EndValD2;
EndValD4<=EndValD3;




ReqConfirmD<=ReqConfirm;

StartPulse<=!ReqConfirmD&ReqConfirm;





	if (MODE==1'b0)
	begin
	if (StartPulse)
		begin
			OutTxSync<=1'b0;

		end
		else
		begin
			OutTxSync<=!OutTxSync;
		end
	end else
	begin
		OutTxSync<=1'b1;
	end




if (OutTxSync ) EoFOut<=(OutReadCounter==7'd67)&&OutReadState;

//EoFOut<=EoFOutD;


if (OutTxSync &&EoFOut ) Stop_RequestCounter<=5'h1A;
	else if (OutTxSync) Stop_RequestCounter<=Stop_RequestCounter-1'b1;

if (OutTxSync &&EoFOut ) Stop_Request<=1'b1;
	else if (OutTxSync&&(Stop_RequestCounter==1'b0)) Stop_Request<=1'b0;

Stop_RequestD<=Stop_Request;

if (PackValid&&EndValD4&&!Stop_Request)	OutRequest<=1'b1;
	else if (!Stop_Request&&Stop_RequestD) OutRequest<=1'b0;





//if (StartPulse) OutReadCounter<=6'd0;
if (StartPulse) OutReadCounter<=7'd8;
	else if (OutReadState&&OutTxSync) OutReadCounter<=OutReadCounter+1;

//if (StartPulse) OutReadState<=1'b1;
//	else if ((OutReadCounter==6'd49)&&OutTxSync)OutReadState<=1'b0;

	if (StartPulse) OutReadState<=1'b1;
	else if ((OutReadCounter==7'd67)&&OutTxSync)OutReadState<=1'b0;


ValOut<=OutTxSync&&OutReadState;
SyncOut<=OutTxSync;

if (OutTxSync) begin


if (OutReadCounter<7'd07) MACDataReg0<=8'h55;
	else if (OutReadCounter==7'd07) MACDataReg0<=8'hD5;
		else if (OutReadCounter==7'd08) MACDataReg0<=MACRem5;
			else if (OutReadCounter==7'd09) MACDataReg0<=MACRem4;
				else if (OutReadCounter==7'd10) MACDataReg0<=MACRem3;
					else if (OutReadCounter==7'd11) MACDataReg0<=MACRem2;
						else if (OutReadCounter==7'd12) MACDataReg0<=MACRem1;
							else if (OutReadCounter==7'd13) MACDataReg0<=MACRem0;
								else MACDataReg0<=MACDataReg1;


if (OutReadCounter==7'd13) MACDataReg1<=InnerMAC[47:40];
else if (OutReadCounter==7'd14) MACDataReg1<=InnerMAC[39:32];
	else if (OutReadCounter==7'd15) MACDataReg1<=InnerMAC[31:24];
		else if (OutReadCounter==7'd16) MACDataReg1<=InnerMAC[23:16];
			else if (OutReadCounter==7'd17) MACDataReg1<=InnerMAC[15:8];
				else if (OutReadCounter==7'd18) MACDataReg1<=InnerMAC[7:0];
					else if (OutReadCounter==7'd19) MACDataReg1<=8'h08;
						else if (OutReadCounter==7'd20) MACDataReg1<=8'h06;
								else MACDataReg1<=OutDataReg0;


////////////////////////////////////////////////////////////////////////////////////

if (OutReadCounter==7'h14) OutDataReg0<=8'h00;
	else if (OutReadCounter==7'h15) OutDataReg0<=8'h01;
		else if (OutReadCounter==7'h16) OutDataReg0<=8'h08;
			else if (OutReadCounter==7'h17) OutDataReg0<=8'h00;
				else if (OutReadCounter==7'h18) OutDataReg0<=8'h06;
					else if (OutReadCounter==7'h19) OutDataReg0<=8'h04;
						else if (OutReadCounter==7'h1A) OutDataReg0<=8'h00;
							else if (OutReadCounter==7'h1B) OutDataReg0<=8'h02;
								else OutDataReg0<=OutDataReg1;


if (OutReadCounter==7'h1B) OutDataReg1<=InnerMAC[47:40];
	else if (OutReadCounter==7'h1C) OutDataReg1<=InnerMAC[39:32];
		else if (OutReadCounter==7'h1D) OutDataReg1<=InnerMAC[31:24];
			else if (OutReadCounter==7'h1E) OutDataReg1<=InnerMAC[23:16];
				else if (OutReadCounter==7'h1F) OutDataReg1<=InnerMAC[15:8];
					else if (OutReadCounter==7'h20) OutDataReg1<=InnerMAC[7:0];
						else OutDataReg1<=OutDataReg2;

if (OutReadCounter==7'h20) OutDataReg2<=InnerIP[31:24];
	else if (OutReadCounter==7'h21) OutDataReg2<=InnerIP[23:16];
		else if (OutReadCounter==7'h22) OutDataReg2<=InnerIP[15:8];
			else if (OutReadCounter==7'h23) OutDataReg2<=InnerIP[7:0];
				else if (OutReadCounter==7'h24) OutDataReg2<=MACRem5;
					else if (OutReadCounter==7'h25) OutDataReg2<=MACRem4;
						else OutDataReg2<=OutDataReg3;

if (OutReadCounter==7'h25) OutDataReg3<=MACRem3;
	else if (OutReadCounter==7'h26) OutDataReg3<=MACRem2;
		else if (OutReadCounter==7'h27) OutDataReg3<=MACRem1;
			else if (OutReadCounter==7'h28) OutDataReg3<=MACRem0;
				else if (OutReadCounter==7'h29) OutDataReg3<=IPRem3;
					else if (OutReadCounter==7'h2A) OutDataReg3<=IPRem2;
						else if (OutReadCounter==7'h2B) OutDataReg3<=IPRem1;
							else if (OutReadCounter==7'h2C) OutDataReg3<=IPRem0;
								else OutDataReg3<=8'h00;
end



if (OutTxSync) FrameOut <= OutReadState;

//if (OutTxSync) SoFOut <= (OutReadCounter==6'd0)&&OutReadState;


if (OutTxSync) SoFOut <= (OutReadCounter==6'd8)&&OutReadState;

end


assign DataOut= MACDataReg0;
//assign ValOut = OutReadState;
assign ArpReq = OutRequest;



endmodule
