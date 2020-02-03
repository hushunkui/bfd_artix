module LinkStatus
(
	input clk200,
	input	clkRXC,
	input	ValIn,
	input	[7:0]DataIn,

	output reg LINK_UP,
	output reg DUPLEX,
	output reg [1:0] SPEED

);

wire wCLKMode;

EthLinkAnalyser200 Mode_inst
(
	. clk200 (clk200),
	. clkRXC (clkRXC),
	. LINK_UP (wCLKMode)
);



reg [3:0] Counter=0;

reg [7:0] DataReg=0;

always @(posedge clkRXC)
begin
if (ValIn) Counter<=4'hF;
	else Counter<=Counter-1;

if (Counter==4'h7) DataReg<=DataIn;

if (Counter==4'h0) LINK_UP <=DataReg[0]&DataReg[4];
if (Counter==4'h0) SPEED[0]<=DataReg[1]&DataReg[5];
if (Counter==4'h0) SPEED[1]<=DataReg[2]&DataReg[6]&&wCLKMode;
if (Counter==4'h0) DUPLEX  <=DataReg[3]&DataReg[7];

end


endmodule
