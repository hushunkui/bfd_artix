
module RGMII_rx

(	
	input	clk200,
	input	RXC,
	input	RX_CTL,	
	input	[3:0]RXD,
	
	output	RX_ERR,
	output	RX_DV,
	output	[7:0] DATA_OUT,
	output	 ENA,
	output	 SOF,
	output	 EOF,
	output    LINK_UP,
	output    DUPLEX,
	output    [1:0] SPEED
);



reg [4:0]DataL;
reg [4:0]DataH;
reg [7:0]Data;

wire [4:0] wDataH;
wire [4:0] wDataL;
reg  [4:0] rDataL;


RGMIIDDR	RGMIIDDRRX_inst (
	.datain    ( {RX_CTL,RXD} ),
	.inclock   ( RXC ),
	.dataout_h ( wDataL ),
	.dataout_l ( wDataH )
	);

reg SyncReg =1'b0;
reg SyncReg0=1'b0;
reg SyncReg1=1'b0;
//reg SyncReg2=1'b0;
reg RXDV_DEL0;
reg RXDV_DEL1;

reg SoFReg;
reg SoFReg0;
reg SoFReg1;
reg SoFReg2;

reg EoFReg;

reg Busy=1'b0;
reg BusyD=1'b0;
/////////////////////////////////////////////////////

	wire wLinkUP;
	wire wDuplexMode;
	wire [1:0]wSpeed;

LinkStatus LinkStatus_inst
(
	. clk200(clk200),
	. clkRXC(RXC),
	. ValIn(wDataL[4]|wDataH[4]),
	. DataIn  ({wDataH[3:0],wDataL[3:0]}),
	
	. LINK_UP(wLinkUP),
	. DUPLEX (wDuplexMode),
	. SPEED  (wSpeed)
);	


assign LINK_UP=wLinkUP;
assign DUPLEX =wDuplexMode;
assign SPEED  =wSpeed;


always @(posedge RXC)
begin
rDataL<=wDataL;

RXDV_DEL0<=wDataL[4];
RXDV_DEL1<=RXDV_DEL0;
	
	if (wSpeed[1]==1'b0)
	begin
	if ({wDataL[4],RXDV_DEL0,RXDV_DEL1}==3'b100)	
		begin
			SyncReg<=1'b1;
		end
		else
		begin
			SyncReg<=!SyncReg;
		end	
	end else
	begin
		SyncReg<=1'b1;	
	end  
	
	

	if ({wDataL[4],RXDV_DEL0,RXDV_DEL1}==3'b100)	
		begin
			SoFReg<=1'b1;
			Busy<=1'b1;
		end
		else
		begin
		   if ({wDataL[4],RXDV_DEL0,SyncReg}==3'b001)	
			begin 
				Busy<=1'b0;
				if (Busy) EoFReg<=1'b1; else EoFReg<=1'b0;
			end
			SoFReg<=1'b0;
		end	

//BusyD<=Busy;
	
	SoFReg0<=SoFReg;
	SoFReg1<=SoFReg0;
	if (wSpeed[1]==1'b0) SoFReg2<=SoFReg1;
		else SoFReg2<=SoFReg0;

	
	SyncReg0<=SyncReg;
	SyncReg1<=SyncReg0;
//	SyncReg2<=SyncReg1;
	
	

	if( SyncReg )  DataL		<=	rDataL; 
	if( SyncReg0)  DataH		<=	wDataH;

end 


always @(posedge RXC) if( SyncReg1)   Data		<=	{DataH[3:0],DataL[3:0]};




reg RXDV;
reg RXERR;
reg ENAReg;


always @(posedge RXC) if( SyncReg1) RXDV	<=	DataL[4];
always @(posedge RXC) if( SyncReg1) RXERR	<=	DataH[4]^DataL[4];
always @(posedge RXC) ENAReg	<=SyncReg1&DataL[4];






assign DATA_OUT =Data;
assign SOF  = SoFReg2;
assign ENA  = ENAReg;//SyncReg2;

assign EOF = EoFReg;

assign RX_DV   = RXDV;
assign RX_ERR  = RXERR;


endmodule
