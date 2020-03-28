module UDPFormer
(
	input	Clk20,
	input	[31:0]DataIn ,
	input	DataInVal,
	input	SoF 	,
	input	EoF 	,
	input	SoSubF,
	input	EoSubF,
	
	input	[31:0]Status0 ,
	input	[31:0]Status1 ,
	input	[31:0]Status2 ,
	input	[31:0]Status3 ,
	input	[31:0]Status4 ,
	input	[31:0]Status5 ,
	input	[31:0]Status6 ,
	input	[31:0]Status7 ,
	
	
	input	[15:0]MTU ,
	input	[15:0]NPoints ,
	
	
	
	input	[47:0]InnerMAC ,
	input	[47:0]RemoteMAC ,
	
	input	[31:0]InnerIP ,	
	input	[31:0]RemoteIP ,
	
	input	[15:0] InnerPort,
	input	[15:0] RemotePort,
	
	input	Clk,
	output reg UdpReq,
	input	ReqConfirm,
	output reg FrameOut,
	output reg ValOut,
	output reg SyncOut,
	output reg SoFOut,
	output reg EoFOut,
	output reg [7:0]DataOut
	
);

localparam MACHedear= 14;
localparam IP_Hedear= 20;	
localparam UDPHedear=  8;	
localparam user_Info= 44;

localparam MACFullSize= user_Info+UDPHedear+IP_Hedear+MACHedear;
localparam IP_FullSize= user_Info+UDPHedear+IP_Hedear;
localparam UDPFullSize= user_Info+UDPHedear;


wire [35:0]wFIFOData;
wire wFIFOempty;


reg  [31:0]FIFOData;

parameter DONE_STATE=0,  DATA_STATE=1, HEADER_STATE=2, IDLE_STATE=3;
reg [1:0] UDPCurrentState	=IDLE_STATE;
reg [1:0] UDPCurrentStateD =IDLE_STATE;


// чтение FIFO только в режимах DATA_STATE и IDLE_STATE
EthernetFIFO	EthernetFIFO_inst (
	.data ( {SoF,SoSubF,EoF,EoSubF,DataIn} ),
	.rdclk ( Clk ),
	.rdreq ( UDPCurrentState[0]),
	.wrclk ( Clk20 ),
	.wrreq ( DataInVal ),
	.q ( wFIFOData ),
	.rdempty (wFIFOempty  )
	);


reg [4:0]InsertHeaderCnt=1'b0;

reg FIFOData_Val =1'b0;
reg FIFOData_ValD=1'b0;

reg unsigned [15:0] DataCount=1'b0;
reg unsigned [15:0] DataAddress=1'b0;



// Если есть данные в FIFO устанавливаем запрос на запись
wire wDataStReq;
assign wDataStReq = ((wFIFOData[35:34]!=2'b00)&&FIFOData_Val);
// Если обноружен конец фрэйма - устанавливаем запрос на заполнение заголовка
wire wHeaderStReq;
assign wHeaderStReq  = ((wFIFOData[33:32]!=2'b00)&& FIFOData_Val);

wire wDoneStReq;
assign wDoneStReq   = (InsertHeaderCnt==1'b0);

reg DoneStReq;

wire wMuxDir;

assign wMuxDir = (UDPCurrentState==DATA_STATE)||(UDPCurrentStateD==DATA_STATE);


always @(posedge Clk)
begin
if(wHeaderStReq&&(UDPCurrentState==DATA_STATE)) InsertHeaderCnt<=5'd23;
	else if (InsertHeaderCnt!=5'd31) InsertHeaderCnt<=InsertHeaderCnt-1'b1;
	
if (UDPCurrentState[0]) FIFOData		<= wFIFOData[31:0];
if (UDPCurrentState[0]) FIFOData_Val<=!wFIFOempty&&UDPCurrentState[0];


if(wDataStReq&&(UDPCurrentState==IDLE_STATE)) DataCount<=16'd1;
	else if ((UDPCurrentState==DATA_STATE)&&FIFOData_Val) DataCount<=DataCount+1'b1;

if(wDataStReq&&(UDPCurrentState==IDLE_STATE)) DataAddress<=16'd23;
	else if (((UDPCurrentState==DATA_STATE)&&FIFOData_Val)) DataAddress<=DataAddress+1'b1;	
	
	


UDPCurrentStateD<=UDPCurrentState;	

DoneStReq<=wDoneStReq;
end



always @(posedge Clk )
begin
case (UDPCurrentState)
	  IDLE_STATE	: FIFOData_ValD<=FIFOData_Val;
	  DATA_STATE 	: FIFOData_ValD<=FIFOData_Val;	  
	  HEADER_STATE : FIFOData_ValD<=1'b0;
	  DONE_STATE   : FIFOData_ValD<=1'b0;			
endcase
end



always @(posedge Clk )
begin
case (UDPCurrentState)
	  DONE_STATE  	 : UDPCurrentState<= IDLE_STATE		;		 
	  IDLE_STATE    : if (wDataStReq  )	UDPCurrentState<= DATA_STATE		; else if (wHeaderStReq || wDoneStReq   )	UDPCurrentState<= IDLE_STATE	;	
	  DATA_STATE    : if (wHeaderStReq) UDPCurrentState<= HEADER_STATE	; else if (wDataStReq   || wDoneStReq   )	UDPCurrentState<= IDLE_STATE	;	
	  HEADER_STATE  : if (wDoneStReq  ) UDPCurrentState<= DONE_STATE		; else if (					   wHeaderStReq )	UDPCurrentState<= IDLE_STATE 	;			
endcase
end



reg [15:0] IPIdentification=16'h3333;
reg [15:0] IPNBytes=1'b0;
reg unsigned [23:0] IPCheckSum0=1'b0;
reg unsigned [23:0] IPCheckSum1=1'b0;
reg unsigned [23:0] IPCheckSum2=1'b0;
reg unsigned [23:0] IPCheckSum3=1'b0;
reg unsigned [16:0] IPCheckSum4=1'b0;
reg unsigned [15:0] IPCheckSum=1'b0;
reg [15:0] UDPNBytes;



reg [4:0]HeaderPointer0=5'd30;
reg [4:0]HeaderPointer1=1'b0;
reg [4:0]HeaderPointer2=1'b0;

reg [4:0]HeaderPointer=1'b0;

//reg WrSt=1'b0;

always @(posedge Clk)
begin


if(wHeaderStReq&&(UDPCurrentState==DATA_STATE)) IPIdentification<=IPIdentification +1'b1;
if(wHeaderStReq&&(UDPCurrentState==DATA_STATE)) HeaderPointer0<= 1'b0;
	else if (HeaderPointer0!=5'd31) HeaderPointer0<=HeaderPointer0+1'b1;
HeaderPointer1<=HeaderPointer0+5'd2;
HeaderPointer2<=HeaderPointer1+5'd2;

HeaderPointer<=HeaderPointer0;

//if(wHeaderStReq&&(UDPCurrentState==IDLE_STATE)) WrSt<=1'b1;
//	else if (HeaderPointer0==5'd31) WrSt<=1'b0;


IPNBytes <=(DataCount<<2)+IP_FullSize;
	
IPCheckSum0<=RemoteIP[31:16]+RemoteIP[15: 0];
IPCheckSum1<=IPIdentification + IPNBytes ;
IPCheckSum2<=IPCheckSum0 +IPCheckSum1 ;

/// InnerIP -> const, after 
IPCheckSum3<=InnerIP[31:16] +InnerIP[15: 0] + 16'h4500 + 16'h8011 + IPCheckSum2;

IPCheckSum4<=  (IPCheckSum3[15:0]+{8'h00,IPCheckSum3[23:16]});

IPCheckSum <= ~(IPCheckSum4[15:0]+{15'h00,IPCheckSum4[16]});

UDPNBytes <= (DataCount<<2)+16'd52;

end	

reg WrEna0=1'b0;
reg WrEna1=1'b0;
reg WrEna2=1'b0;


reg [31:0]RAMDataReg0=1'b0;
reg [31:0]RAMDataReg1=1'b0;
reg [31:0]RAMDataReg2=1'b0;

reg WrEna=1'b0;
reg [31:0]RAMDataReg =1'b0;
reg [15:0]RAMAddress=1'b0;

reg [15:0]PackPointer=1'b0;
reg [15:0]LastDataPointer=1'b0;




reg [31:0]MagicConstant=32'h00000000;
reg [31:0]Pack_ID		  =32'h12345678;

reg NextPackReq;

reg BV0;
reg BV1;
reg BV2;
reg BV3;



always @(posedge Clk)
begin
case (HeaderPointer0)
  5'd00   : {WrEna0,RAMDataReg0}<={1'b1,8'h00,8'h00,8'h00,8'h00};
  5'd01   : {WrEna0,RAMDataReg0}<={1'b1,8'h00  ,8'h00  ,RemoteMAC[47:40],RemoteMAC[39:32]};
  5'd02   : {WrEna0,RAMDataReg0}<={1'b1,RemoteMAC[31:24],RemoteMAC[23:16],RemoteMAC[15: 8],RemoteMAC[ 7: 0]};
  5'd03   : {WrEna0,RAMDataReg0}<={1'b1,InnerMAC[47:40],InnerMAC[39:32],InnerMAC[31:24],InnerMAC[23:16]};
  5'd04   : {WrEna0,RAMDataReg0}<={1'b1,InnerMAC[15: 8],InnerMAC[ 7: 0],8'h08,8'h00};
  5'd05   : {WrEna0,RAMDataReg0}<={1'b1,8'h45,8'h00,IPNBytes[15:8],IPNBytes[7:0]};
  5'd06   : {WrEna0,RAMDataReg0}<={1'b1,IPIdentification[15:8],IPIdentification[ 7:0],8'h00,8'h00};
  5'd07   : {WrEna0,RAMDataReg0}<={1'b1,8'h80,8'h11,IPCheckSum[15:8],IPCheckSum[7:0]};
  default : {WrEna0,RAMDataReg0}<={WrEna1,RAMDataReg1};		
endcase

case (HeaderPointer1)
  5'd08   : {WrEna1,RAMDataReg1}<={1'b1,InnerIP};
  5'd09   : {WrEna1,RAMDataReg1}<={1'b1,RemoteIP};
  5'd10   : {WrEna1,RAMDataReg1}<={1'b1,InnerPort, RemotePort};
  5'd11   : {WrEna1,RAMDataReg1}<={1'b1,UDPNBytes,16'h0};
  5'd12   : {WrEna1,RAMDataReg1}<={1'b1,MagicConstant};
  5'd13   : {WrEna1,RAMDataReg1}<={1'b1,Pack_ID};
  5'd14   : {WrEna1,RAMDataReg1}<={1'b1,Pack_ID};
  5'd15   : {WrEna1,RAMDataReg1}<={1'b1,Status0};
  default : {WrEna1,RAMDataReg1}<={WrEna2,RAMDataReg2};		
endcase

case (HeaderPointer2)
  5'd16   : {WrEna2,RAMDataReg2}<={1'b1,Status1};	
  5'd17   : {WrEna2,RAMDataReg2}<={1'b1,Status2};	
  5'd18   : {WrEna2,RAMDataReg2}<={1'b1,Status3};	
  5'd19   : {WrEna2,RAMDataReg2}<={1'b1,Status4};	
  5'd20   : {WrEna2,RAMDataReg2}<={1'b1,Status5};	
  5'd21   : {WrEna2,RAMDataReg2}<={1'b1,Status6};	
  5'd22   : {WrEna2,RAMDataReg2}<={1'b1,Status7};	
 // 6'd23   : {WrEna2,RAMDataReg}2<={WrSt,Status2};
  // Last element zeroing
  5'd23   : {WrEna2,RAMDataReg2}<={1'b1,32'b0};	 
  default : {WrEna2,RAMDataReg2}<={1'b0,32'b0};		
endcase



if (wMuxDir) RAMDataReg<= FIFOData;  else RAMDataReg<= {RAMDataReg0[7:0],RAMDataReg0[15:8],RAMDataReg0[23:16],RAMDataReg0[31:24]}; 
if (wMuxDir) WrEna<= FIFOData_ValD;  else WrEna<= WrEna0; 

if (DoneStReq) RAMAddress<=LastDataPointer;
	else if (wMuxDir) RAMAddress<=DataAddress+PackPointer; else RAMAddress<= HeaderPointer+PackPointer; 

NextPackReq<= (UDPCurrentState==HEADER_STATE)&&(UDPCurrentStateD==DATA_STATE);

//if (NextPackReq) LastDataPointer<=RAMAddress; 
//LastDataPointer указывает на следующий за последним элементом который будет обнулен
if (NextPackReq) LastDataPointer<=RAMAddress+1'b1; 
if ( UDPCurrentState==DONE_STATE) PackPointer<=LastDataPointer+1'b1; 

if (NextPackReq||DoneStReq) 
	begin
	BV0<=1'b0;
	BV1<=1'b0;
	BV2<=1'b0;
	BV3<=1'b0;
	end 
	else begin
	BV3<=1'b1;
	BV2<=1'b1;
	BV1<=BV3;
	BV0<=BV2;
	end 
end


wire wDV;
wire [7:0]wData;


////////////////////////////////////////////////////////////////////////////////////


reg [12:0] ReadSide_ReadAdrress=1'b0;
reg [12:0] ReadSideWriteAdrress=1'b0;

reg UdpReadEna;
reg UdpOutState;

wire wReadDoneCondition;
assign wReadDoneCondition = (ReadSideWriteAdrress!=ReadSide_ReadAdrress);

reg DV_Reg;

wire wReadPackDoneCondition;
assign wReadPackDoneCondition = DV_Reg&!wDV;


reg ReadOutState=1'b0;
reg ReadOutStateD=1'b0;
reg ReadOutStateDD=1'b0;
reg [5:0]GapOutCounter=1'b0;

reg Val_D0;
reg Sync_D0;
reg SoF_D0;
wire wEoF_D0;
reg [7:0]Data_D0;


reg OutTxSync=1'b0;


always @(posedge Clk)
begin
if (MODE==1'b0)
		begin
			OutTxSync<=!OutTxSync;
		end else
	begin
		OutTxSync<=1'b1;	
	end  

end


always @(posedge Clk)
begin

if ( UDPCurrentState==DONE_STATE) ReadSideWriteAdrress<={LastDataPointer[10:0],2'b11}; 

	if (OutTxSync)
		begin 
		
		DV_Reg <= wDV;
		ReadOutStateD<=ReadOutState;
		ReadOutStateDD <= ReadOutStateD;
		
		UdpReq<=(ReadSideWriteAdrress!=ReadSide_ReadAdrress);
		
		if ((DV_Reg&~wDV)||(ReadOutStateD&~ReadOutState)) GapOutCounter<=6'b111111;
			else if (GapOutCounter!=1'b0) GapOutCounter<=GapOutCounter-1'b1;
		
		if ((ReadSideWriteAdrress==ReadSide_ReadAdrress)||(DV_Reg&~wDV))  ReadOutState<=1'b0;
			else  if (((ReadSideWriteAdrress!=ReadSide_ReadAdrress)&&(GapOutCounter==1'b0))&&ReqConfirm) ReadOutState<=1'b1;
			
		
		
		
		
		if ((ReadSideWriteAdrress!=ReadSide_ReadAdrress)&&ReadOutState) ReadSide_ReadAdrress<=ReadSide_ReadAdrress+1'b1; 
		
		

		
		
		 Val_D0  <= wDV && ReadOutStateDD;
		 SoF_D0  <= wDV && (!DV_Reg) && ReadOutStateDD;
		 //EoF_D0  <= DV_Reg && (!wDV) &&!Val_D0; 
		 Data_D0 <= wData ;
		
		
		
		if (Val_D0) DataOut<= Data_D0; else DataOut<= 1'd0;
		
		SoFOut <= SoF_D0;
		//EoFOut <= wEoF_D0;
		
		EoFOut <= Val_D0&&!(wDV && ReadOutStateDD);
		
		end 
		ValOut <= Val_D0&&OutTxSync;

end

assign wEoF_D0  = DV_Reg && (!wDV) && Val_D0; 



EthBuffRAM	EthBuffRAM_inst (
	.data (  {BV3,RAMDataReg[31:24],BV2,RAMDataReg[23:16],BV1,RAMDataReg[15:8],BV0,RAMDataReg[7:0]} ),
	.rdaddress ( ReadSide_ReadAdrress ),
	.rdclock ( Clk ),
	.rdclocken ( OutTxSync ),
	.wraddress (  RAMAddress[10:0] ),
	.wrclock ( Clk ),
	.wrclocken ( 1'b1 ),
	.wren ( WrEna ),
	.q (  {wDV,wData}  )
	);







endmodule

