`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2020 15:16:04
// Design Name: 
// Module Name: RGMII_ClockSpeed_Test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module RGMII_ClockSpeed_Test
(
	input clk375,
	input RGMII_CLK_CHANGE,
	output RGMII_CLK_125_ON
);

	reg [4:0] State=1'b0;
	reg Start=1'b0;
	reg ACLR=1'b0;
	reg Compare=1'b0;
	reg CompareD=1'b0;
	reg [4:0] REG_LCLK=1'b0;
	reg [4:0] REGRXC=1'b0;
	reg [5:0] Result=1'b0;
	reg CLK_125_ON=1'b0;
	
always @ (posedge clk375)
begin

State<=State+1'b1;
if (State >5'b11010)Start<=1'b0; else Start<=1'b1;
if (State==5'b11101)Compare<=1'b1; else Compare<=1'b0;
if (State==5'b11110)ACLR <=1'b1; else ACLR <=1'b0;
CompareD<=Compare;
if (Compare)Result<=REG_LCLK-REGRXC;
if (CompareD)
	begin
		if((Result<=6'd22))CLK_125_ON<=1'b1; else CLK_125_ON<=1'b0;
	end
end

always @ (posedge clk375 )
begin
if (ACLR) REG_LCLK<=1'b0;
	else if (Start) REG_LCLK<=REG_LCLK+1'b1;
end


always @ (posedge clk375 )
begin
if (ACLR) REGRXC<=1'b0;
	else if (Start&&RGMII_CLK_CHANGE) REGRXC<=REGRXC+1'b1;
end

	assign RGMII_CLK_125_ON = CLK_125_ON;

endmodule

