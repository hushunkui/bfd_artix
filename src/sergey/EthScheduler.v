
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

    output reg	[1:0]ReqConfirm = 0,

    output reg ValOut = 0,
    output reg SoFOut = 0,
    output reg EoFOut = 0,
    output reg [7:0]DataOut = 0

);

// reg  [3:0]ReqReg;
// reg  [3:0]ReqRegD;

// reg  BusyState=1'b0;
// reg  BusyStateD=1'b0;


// reg StopBusy;

reg VaitRequest = 0;


parameter  IDLE=0, ZERO=1, ONE=2;//, TWO=3, THREE=4;
reg [2:0] CurrentState=ZERO;

always @(posedge Clk )
begin
VaitRequest<=ReqIn0||ReqIn1;//||ReqIn2||ReqIn3;

case (CurrentState)
	  ZERO  : if (ReqIn0) 		CurrentState<= ZERO  ; else CurrentState<= ONE  ;
	  ONE   : if (ReqIn1) 		CurrentState<= ONE   ; else CurrentState<= IDLE ; //CurrentState<= TWO  ;
	//   TWO   : if (ReqIn2) 		CurrentState<= TWO   ; else CurrentState<= THREE;
	//   THREE : if (ReqIn3) 		CurrentState<= THREE ; else CurrentState<= IDLE ;
	  IDLE  : if (VaitRequest) CurrentState<= ZERO  ; else CurrentState<= IDLE ;
endcase
end



always @(posedge Clk)
begin
    case (CurrentState)
    ZERO : DataOut<=DataIn0;
    ONE  : DataOut<=DataIn1;
    // TWO  : DataOut<=DataIn2;
    // THREE: DataOut<=DataIn3;
    default : DataOut<=1'b0;
    endcase

    case (CurrentState)
    ZERO : EoFOut<=EoFIn0;
    ONE  : EoFOut<=EoFIn1;
    // TWO  : EoFOut<=EoFIn2;
    // THREE: EoFOut<=EoFIn3;
    default : EoFOut<=1'b0;
    endcase

    case (CurrentState)
    ZERO : SoFOut<=SoFIn0;
    ONE  : SoFOut<=SoFIn1;
    // TWO  : SoFOut<=SoFIn2;
    // THREE: SoFOut<=SoFIn3;
    default : SoFOut<=1'b0;
    endcase

    case (CurrentState)
    ZERO : ValOut<=ValIn0&LINK_UP;
    ONE  : ValOut<=ValIn1&LINK_UP;
    // TWO  : ValOut<=ValIn2&LINK_UP;
    // THREE: ValOut<=ValIn3&LINK_UP;
    default : ValOut<=1'b0;
    endcase

    case (CurrentState)
    ZERO : ReqConfirm[1:0]<={1'b0,ReqIn0};
    ONE  : ReqConfirm[1:0]<={ReqIn1,1'b0};
    // TWO  : ReqConfirm[3:0]<={1'b0,ReqIn2,1'b0,1'b0};
    // THREE: ReqConfirm[3:0]<={ReqIn3,1'b0,1'b0,1'b0};
    default : ReqConfirm[1:0]<=2'd0;
    endcase
end


endmodule
