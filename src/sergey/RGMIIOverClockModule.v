`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06.02.2020 11:55:48
// Design Name:
// Module Name: RGMIIOverClockModule
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


module RGMIIOverClockModule(
    input clk375,
    input clk125,
    input [3:0] RGMII_Data,
    input RGMII_Ctrl,
    input RGMII_Clk,


    output [7:0] Data_Out,
    output Val_Out,
    output Err_Out,
    output SoF_Out,
    output EoF_Out,

    output  LINK_UP,
    output  DUPLEX,
    output  [1:0]SPEED
    );

wire [7:0] wRGMII_Data;
wire wRGMII_SoF;
wire wRGMII_Val;
wire wRGMII_EoF;
wire wRGMII_Err;

wire wRGMII_LinkUp;
wire wRGMII_Duplex;
wire [1:0]wRGMII_Speed;

RGMIIOverClockSampler RGMIIOverClockSampler_inst(
    . clk375(clk375),
    . RGMII_Data(RGMII_Data),
    . RGMII_Ctrl(RGMII_Ctrl),
    . RGMII_Clk(RGMII_Clk),

    . Data_Out(wRGMII_Data),
    . Val_Out(wRGMII_Val),
    . Err_Out(wRGMII_Err),
    . SoF_Out(wRGMII_SoF),
    . EoF_Out(wRGMII_EoF),
    .LINK_UP(wRGMII_LinkUp),
    .DUPLEX (wRGMII_Duplex),
    .SPEED  (wRGMII_Speed)
    );

 wire wFIFOValid;
 wire [15:0]wFIFODat;
 reg [2:0]FIFOValidDelay;
 always @ (posedge clk125)
begin
FIFOValidDelay<={wFIFOValid,FIFOValidDelay[2:1]};
end
 axis_data_fifo_0 axis_data_fifo_0_inst (
  .s_aresetn(1'b1),          // input wire s_aresetn
  .s_aclk(clk375),                // input wire s_aclk
  .s_axis_tvalid(wRGMII_Val),  // input wire s_axis_tvalid
  .s_axis_tready(),  // output wire s_axis_tready
  .s_axis_tdata({4'b0000,wRGMII_SoF,wRGMII_EoF,wRGMII_Err,wRGMII_Val,wRGMII_Data}),    // input wire [15 : 0] s_axis_tdata
  .m_aclk(clk125),                // input wire m_aclk
  .m_axis_tvalid(wFIFOValid),  // output wire m_axis_tvalid
  .m_axis_tready(FIFOValidDelay[0]),  // input wire m_axis_tready
  .m_axis_tdata(wFIFODat)    // output wire [15 : 0] m_axis_tdata
);

    assign Data_Out= wFIFODat[7:0];
    assign Val_Out = wFIFODat[8 ]&&wFIFOValid&&FIFOValidDelay[0];
    assign Err_Out = wFIFODat[9 ]&&wFIFOValid&&FIFOValidDelay[0];
    assign EoF_Out = wFIFODat[10]&&wFIFOValid&&FIFOValidDelay[0];
    assign SoF_Out = wFIFODat[11]&&wFIFOValid&&FIFOValidDelay[0];

    assign  LINK_UP = wRGMII_LinkUp;
    assign  DUPLEX  = wRGMII_Duplex;
    assign  SPEED   = wRGMII_Speed;

endmodule
