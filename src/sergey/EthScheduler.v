
module EthScheduler
(		

   input	Clk,
	input LINK_UP,
	
	input	ValIn0,
	input	SoFIn0,
	input	EoFIn0,
	input	ReqIn0,
	input	[7:0]DataIn0,
	
	input	ValIn1,
	input	SoFIn1,
	input	EoFIn1,
	input	ReqIn1,
	input	[7:0]DataIn1,

	input	ValIn2,
	input	SoFIn2,
	input	EoFIn2,
	input	ReqIn2,
	input	[7:0]DataIn2,

	input	ValIn3,
	input	SoFIn3,
	input	EoFIn3,
	input	ReqIn3,
	input	[7:0]DataIn3,

	output reg	[3:0]ReqConfirm,
	
	output reg ValOut,
	output reg SoFOut,
	output reg EoFOut,
	output reg [7:0]DataOut
	
);

reg  [3:0]ReqReg; 
reg  [3:0]ReqRegD; 

reg  BusyState=1'b0; 
reg  BusyStateD=1'b0; 


reg StopBusy;

reg [2:0] CurrentState=1'b0;

reg VaitRequest;


parameter  ZERO=0, ONE=1, TWO=2, THREE=3, IDLE =4;


always @(posedge Clk )
begin
VaitRequest<=ReqIn3||ReqIn2||ReqIn1||ReqIn0;	

case (CurrentState)
	  ZERO  : if (ReqIn0) 		CurrentState<= ZERO  ; else CurrentState<= ONE  ;			 
	  ONE   : if (ReqIn1) 		CurrentState<= ONE   ; else CurrentState<= TWO  ;	
	  TWO   : if (ReqIn2) 		CurrentState<= TWO   ; else CurrentState<= THREE;	
	  THREE : if (ReqIn3) 		CurrentState<= THREE ; else CurrentState<= IDLE ;
	  IDLE  : if (VaitRequest) CurrentState<= ZERO  ; else CurrentState<= IDLE ;			
endcase
end



always @(posedge Clk)
begin

	


case (CurrentState)
  3'b000 : DataOut<=DataIn0;
  3'b001 : DataOut<=DataIn1;
  3'b010 : DataOut<=DataIn2;
  3'b011 : DataOut<=DataIn3;
 default : DataOut<=1'b0;
endcase

case (CurrentState)
  3'b000 : EoFOut<=EoFIn0;
  3'b001 : EoFOut<=EoFIn1;
  3'b010 : EoFOut<=EoFIn2;
  3'b011 : EoFOut<=EoFIn3;
 default : EoFOut<=1'b0;
endcase

case (CurrentState)
  3'b000 : SoFOut<=SoFIn0;
  3'b001 : SoFOut<=SoFIn1;
  3'b010 : SoFOut<=SoFIn2;
  3'b011 : SoFOut<=SoFIn3;
 default : SoFOut<=1'b0;
endcase

case (CurrentState)
  3'b000 : ValOut<=ValIn0&LINK_UP;
  3'b001 : ValOut<=ValIn1&LINK_UP;
  3'b010 : ValOut<=ValIn2&LINK_UP;
  3'b011 : ValOut<=ValIn3&LINK_UP;
 default : ValOut<=1'b0;
endcase

case (CurrentState)
  3'b000 : ReqConfirm[3:0]<={1'b0,1'b0,1'b0,ReqIn0};
  3'b001 : ReqConfirm[3:0]<={1'b0,1'b0,ReqIn1,1'b0};
  3'b010 : ReqConfirm[3:0]<={1'b0,ReqIn2,1'b0,1'b0};
  3'b011 : ReqConfirm[3:0]<={ReqIn3,1'b0,1'b0,1'b0};
 default : ReqConfirm[3:0]<=4'b0000;
endcase

	
				
end



endmodule
