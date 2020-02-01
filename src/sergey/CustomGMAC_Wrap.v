module CustomGMAC_Wrap
#( parameter InnerMAC=48'hC0A805050505 )
(	input	RXC,
	input	CLK,
	input	RX_CTL,
	input	[3:0]RXD,

  	output CLK_TX,
	output TX_CTL,
	output [3:0]TXDATA,

	output 	MODE,
	output	LINK_UP,

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

	output [2:0]ReqConfirm,


	output   [47:0] Remote_MACOut,
	output   [31:0] Remote_IP_Out,
	output   [15:0] RemotePortOut,
	output	CLK_OUT,
	output	SOF_OUT,
	output	EOF_OUT,
	output	ENA_OUT,
	output	ERR_OUT,
	output	[7 :0] DATA_OUT

);

assign CLK_OUT=RXC;

CustomGMAC  CustomGMAC_Inst
	(

	.	RXC(RXC),
	.	CLK(CLK),
	.	RX_CTL(RX_CTL),
	.	RXD(RXD),
	.	InnerMAC (48'hC0A805050505 ),
	.	IPD (32'hC0A80507),
	.	PortD (16'h04D2),
	.	MODE(MODE),
	.  LINK_UP(LINK_UP),
  	.  CLK_TX(CLK_TX),
	.  TX_CTL(TX_CTL),
	.  TXDATA(TXDATA),

	.	ValIn0 (ValIn0 ),
	.	SoFIn0 (SoFIn0 ),
	.	EoFIn0 (EoFIn0 ),
	.	ReqIn0 (ReqIn0 ),
	.	DataIn0(DataIn0),

	.	ValIn1 (ValIn1),
	.	SoFIn1 (SoFIn1),
	.	EoFIn1 (EoFIn1),
	.	ReqIn1 (ReqIn1),
	.	DataIn1(DataIn1),

	.	ValIn2 (ValIn2),
	.	SoFIn2 (SoFIn2),
	.	EoFIn2 (EoFIn2),
	.	ReqIn2 (ReqIn2),
	.	DataIn2(DataIn2),

	.  ReqConfirm(ReqConfirm),

	.  Remote_MACOut(Remote_MACOut),
	.  Remote_IP_Out(Remote_IP_Out),
	.  RemotePortOut(RemotePortOut),
	.  DATA_OUT(DATA_OUT),
	.  SOF_OUT (SOF_OUT ),
	.  EOF_OUT (EOF_OUT ),
	.  ENA_OUT (ENA_OUT ),
	.  ERR_OUT (ERR_OUT )

	);






endmodule