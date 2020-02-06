`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2020 15:25:29
// Design Name: 
// Module Name: LinkStatus
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


module LinkStatus(
    input clk375,
    input RGMII_CLK_CHANGE,
    input ValIn,
    input [7:0]DataIn,

    output reg LINK_UP,
    output reg DUPLEX,
    output reg [1:0]SPEED
 );
 
 wire wCLKMode;
 
 RGMII_ClockSpeed_Test RGMII_ClockSpeed_Test_inst
(
    .clk375(clk375),
    .RGMII_CLK_CHANGE(RGMII_CLK_CHANGE),
	.RGMII_CLK_125_ON (wCLKMode)
);
 
 
reg [4:0] Counter=0;
reg [7:0] DataReg=0;

always @(posedge clk375)
begin
if (ValIn) Counter<=5'h1F;
	else Counter<=Counter-1;

if (Counter==4'h7) DataReg<=DataIn;

if (Counter==4'h0) LINK_UP <=DataReg[0]&DataReg[4];
if (Counter==4'h0) SPEED[0]<=DataReg[1]&DataReg[5];
if (Counter==4'h0) SPEED[1]<=DataReg[2]&DataReg[6]&&wCLKMode;
if (Counter==4'h0) DUPLEX  <=DataReg[3]&DataReg[7];

end

 
endmodule