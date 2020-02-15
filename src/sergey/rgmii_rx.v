
module RGMII_rx
(
    input clk200,
    input RXC_DDR,
    input RXC,
    input RX_CTL,
    input [3:0]RXD,

    output reg RX_ERR = 0,
    output reg RX_DV = 0,
    output reg [7:0] DATA_OUT = 0,
    output reg ENA = 0,
    output reg SOF = 0,
    output reg EOF = 0,
    output    LINK_UP,
    output    DUPLEX,
    output    [1:0] SPEED
);

wire [4:0] wDataH;
wire [4:0] wDataL;
wire wLinkUP;
wire wDuplexMode;
wire [1:0]wSpeed;

RGMIIDDR RGMIIDDRRX_inst (
    .datain    ( {RX_CTL,RXD} ),
    .inclock   ( RXC ),
    .inclock2  ( RXC_DDR ),
    .dataout_h ( wDataL ),
    .dataout_l ( wDataH )
);

LinkStatus LinkStatus_inst
(
    .clk200(clk200),
    .clkRXC(RXC),
    .ValIn(wDataL[4]|wDataH[4]),
    .DataIn  ({wDataH[3:0],wDataL[3:0]}),

    .LINK_UP(wLinkUP),
    .DUPLEX (wDuplexMode),
    .SPEED  (wSpeed)
);

assign LINK_UP=wLinkUP;
assign DUPLEX =wDuplexMode;
assign SPEED  =wSpeed;

reg sr0_dv = 0;
reg sr0_err = 0;
reg [7:0] sr0_data = 0;
reg sr1_dv = 0;
reg sr1_err = 0;
reg [7:0] sr1_data = 0;
reg rgmii_dv = 0;
reg rgmii_err = 0;
reg [7:0] rgmii_data = 0;
reg rgmii_sof = 0;
reg rgmii_eof = 0;
always @(posedge RXC) begin
    sr0_dv <= wDataH[4];
    sr0_err <= wDataL[4];
    sr0_data <= {wDataH[3:0], wDataL[3:0]};

    sr1_dv <= sr0_dv;
    sr1_err <= sr0_err;
    sr1_data <= sr0_data;

    rgmii_data <= sr1_data;
    rgmii_dv <= sr1_dv;
    rgmii_err <= sr1_err;
    rgmii_sof <= sr1_dv & !rgmii_dv;
    rgmii_eof <= !sr0_dv & sr1_dv;

    DATA_OUT <= rgmii_data;
    ENA <= rgmii_dv;
    SOF <= rgmii_sof;
    EOF <= rgmii_eof;
    RX_DV <= rgmii_dv;
    RX_ERR <= rgmii_dv^rgmii_err;
end



// reg [4:0]DataL = 0;
// reg [4:0]DataH = 0;
// reg [7:0]Data = 0;
// reg  [4:0] rDataL = 0;

// reg SyncReg =1'b0;
// reg SyncReg0=1'b0;
// reg SyncReg1=1'b0;
// //reg SyncReg2=1'b0;
// reg RXDV_DEL0 = 0;
// reg RXDV_DEL1 = 0;

// reg SoFReg = 0;
// reg SoFReg0 = 0;
// reg SoFReg1 = 0;
// reg SoFReg2 = 0;

// reg EoFReg = 0;

// reg Busy=1'b0;
// reg BusyD=1'b0;

// always @(posedge RXC)
// begin
// rDataL<=wDataL;

// RXDV_DEL0<=wDataL[4];
// RXDV_DEL1<=RXDV_DEL0;

// 	if (wSpeed[1]==1'b0)
// 	begin
// 	if ({wDataL[4],RXDV_DEL0,RXDV_DEL1}==3'b100)
// 		begin
// 			SyncReg<=1'b1;
// 		end
// 		else
// 		begin
// 			SyncReg<=!SyncReg;
// 		end
// 	end else
// 	begin
// 		SyncReg<=1'b1;
// 	end

// 	if ({wDataL[4],RXDV_DEL0,RXDV_DEL1}==3'b100)
// 		begin
// 			SoFReg<=1'b1;
// 			Busy<=1'b1;
// 		end
// 		else
// 		begin
// 		   if ({wDataL[4],RXDV_DEL0,SyncReg}==3'b001)
// 			begin
// 				Busy<=1'b0;
// 				if (Busy) EoFReg<=1'b1; else EoFReg<=1'b0;
// 			end
// 			SoFReg<=1'b0;
// 		end

// //BusyD<=Busy;

// 	SoFReg0<=SoFReg;
// 	SoFReg1<=SoFReg0;
// 	if (wSpeed[1]==1'b0) SoFReg2<=SoFReg1;
// 		else SoFReg2<=SoFReg0;

// 	SyncReg0<=SyncReg;
// 	SyncReg1<=SyncReg0;
// //	SyncReg2<=SyncReg1;

// 	if( SyncReg )  DataL		<=	rDataL;
// 	if( SyncReg0)  DataH		<=	wDataH;

// end

// always @(posedge RXC) if( SyncReg1)   Data		<=	{DataH[3:0],DataL[3:0]};

// reg RXDV = 0;
// reg RXERR = 0;
// reg ENAReg = 0;


// always @(posedge RXC) if( SyncReg1) RXDV	<=	DataL[4];
// always @(posedge RXC) if( SyncReg1) RXERR	<=	DataH[4]^DataL[4];
// always @(posedge RXC) ENAReg	<=SyncReg1&DataL[4];

// assign DATA_OUT =Data;
// assign SOF  = SoFReg2;
// assign ENA  = ENAReg;//SyncReg2;

// assign EOF = EoFReg;

// assign RX_DV   = RXDV;
// assign RX_ERR  = RXERR;





endmodule
