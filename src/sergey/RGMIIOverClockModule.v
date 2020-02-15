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

    output [3:0] dbg_fi,
    output reg [9:0] dbg_fi_dcnt = 0,
    output [6:0] dbg_fi_wr_data_count,
    output [3:0] dbg_fo,
    output reg [9:0] dbg_fo_dcnt = 0,
    output [6:0] dbg_fo_rd_data_count,
    output [1:0] dbg_fi_wRGMII_Clk,
    output [4:0] dbg_fi_wDataDDRL,
    output [4:0] dbg_fi_wDataDDRH,
    output [3:0] dbg_fi_wCondition,
    output       dbg_fi_LoadDDREnaD0,

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

    .dbg_fi_wRGMII_Clk(dbg_fi_wRGMII_Clk),
    .dbg_fi_wDataDDRL(dbg_fi_wDataDDRL),
    .dbg_fi_wDataDDRH(dbg_fi_wDataDDRH),
    .dbg_fi_wCondition(dbg_fi_wCondition),
    .dbg_fi_LoadDDREnaD0(dbg_fi_LoadDDREnaD0),

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
reg [8:0]FIFOValidDelay;
always @ (posedge clk125) begin
    FIFOValidDelay<={wFIFOValid,FIFOValidDelay[8:1]};
end


axis_data_fifo_0 axis_data_fifo_0_inst (
    .axis_wr_data_count(dbg_fi_wr_data_count),  // output wire [6 : 0] axis_wr_data_count
    .axis_rd_data_count(dbg_fo_rd_data_count),  // output wire [6 : 0] axis_rd_data_count
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


reg pkt_detect = 1'b0;
reg bug_detect = 1'b0;
always @ (posedge clk125) begin
    if (SoF_Out) begin
        pkt_detect <= 1'b1;
    end else if (EoF_Out) begin
        pkt_detect <= 1'b0;
    end

    if (pkt_detect) begin
        if (!Val_Out) begin
            bug_detect <= 1'b1;
        end
    end else begin
        bug_detect <= 1'b0;
    end

    if (Val_Out) begin
        if (EoF_Out) begin
            dbg_fo_dcnt <= 0;
        end else begin
            dbg_fo_dcnt <= dbg_fo_dcnt + 1;
        end
    end
end


assign dbg_fo[0] = wFIFOValid;
assign dbg_fo[1] = FIFOValidDelay[0];
assign dbg_fo[2] = wFIFODat[8];
assign dbg_fo[3] = bug_detect;


reg bug_detect_s;
always @ (posedge clk375) begin
    bug_detect_s <= bug_detect;

    if (wRGMII_Val) begin
        if (wRGMII_EoF) begin
            dbg_fi_dcnt <= 0;
        end else begin
            dbg_fi_dcnt <= dbg_fi_dcnt + 1;
        end
    end
end
assign dbg_fi[0] = wRGMII_Val;
assign dbg_fi[1] = wRGMII_SoF;
assign dbg_fi[2] = wRGMII_EoF;
assign dbg_fi[3] = bug_detect_s;




endmodule
