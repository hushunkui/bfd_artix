`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2020 17:58:16
// Design Name: 
// Module Name: RGMIIOverClock
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


module RGMIIOverClockSampler(
    input clk375,
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
// output from DDR Primitive    
wire [1:0]wRGMII_Clk; 
// output from DDR Primitive of previous clock
reg  [1:0]RGMII_Clk_reg;     
    
IDDR #( .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED") )
CLK_Reader (

.R  ( 1'b0 ),
.S  ( 1'b0 ),
.CE ( 1'b1 ),
.C  ( clk375 ),
.D  ( RGMII_Clk ),
.Q1 ( wRGMII_Clk[0] ),
.Q2 ( wRGMII_Clk[1] ) ); 

// RGMII DDR Sampled Data 
 reg [4:0] DataRegH;
 reg [4:0] DataRegL;
 
 // LoadDDREnaD0 - Load Enabled to 8 bit Register, appears when RXC fall is detected
 reg LoadDDREnaD0;
 // LoadDDREna  - Pipelined function of LoadDDREnaD0
 reg LoadDDREna;
 
 // wires to connect IDDR primitive
 wire [4:0] wDataDDRIn;
 wire [4:0] wDataDDRL;
 wire [4:0] wDataDDRH;
 
 assign  wDataDDRIn ={RGMII_Ctrl,RGMII_Data};
 
 genvar i;
   generate 
    for (i = 0; i < 5; i = i + 1) 
    begin
    IDDR #( .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED") )
    Data_DDRReader (
    .R  ( 1'b0 ),
    .S  ( 1'b0 ),
    .CE ( 1'b1 ),
    .C  ( clk375 ),
    .D  ( wDataDDRIn[i] ),
    .Q1 ( wDataDDRL [i] ),
    .Q2 ( wDataDDRH [i] ) 
    ); 
    end
  endgenerate
 
// registers of Avalon stream interface
reg [7:0] DataRegD0;
reg ValRegD0;
reg ErrRegD0;
reg SoFRegD0;

// registers of Avalon stream interface (pipelined)  
reg [7:0] DataReg;
reg ValReg;
reg ErrReg;
reg SoFReg;
reg EoFReg;

// plase all RXC samples in order. Main task to find front all fall
wire [3:0] wCondition;
assign wCondition = {RGMII_Clk_reg[0],RGMII_Clk_reg[1],wRGMII_Clk[0],wRGMII_Clk[1]};
    
always @ (posedge clk375) 
begin
RGMII_Clk_reg<=wRGMII_Clk;
// if RXC fall detected LoadDDREnaD0 is set to load DDR data to 8 bit register
LoadDDREnaD0<=(wCondition==4'b1100)||(wCondition==4'b1000);
case (wCondition)
  4'b0111: DataRegL <= wDataDDRL;
  4'b0011: DataRegL <= wDataDDRH;
  4'b1100: DataRegH <= wDataDDRH;
  4'b1000: DataRegH <= wDataDDRL;
endcase

if (LoadDDREnaD0)DataRegD0<={DataRegH[3:0],DataRegL[3:0]};
if (LoadDDREnaD0)ValRegD0 <= DataRegL[4];
if (LoadDDREnaD0)ErrRegD0 <= (DataRegL[4]^DataRegH[4]);
if (LoadDDREnaD0)SoFRegD0 <= (DataRegL[4]&!ValRegD0);

// output pipelining for correct EoFReg setting
LoadDDREna<=LoadDDREnaD0;
if (LoadDDREnaD0)DataReg<=DataRegD0;
ValReg <= ValRegD0&&LoadDDREnaD0;
ErrReg <= ErrRegD0&&LoadDDREnaD0;
SoFReg <= SoFRegD0&&LoadDDREnaD0;
EoFReg <= (!DataRegL[4]&ValRegD0)&&LoadDDREnaD0;
end
    
    
assign    Data_Out =DataReg;
assign    Val_Out  = ValReg;
assign    Err_Out  = ErrReg;
assign    SoF_Out  = SoFReg;
assign    EoF_Out  = EoFReg;   



LinkStatus LinkStatus_inst
(
    .clk375(clk375),
    .RGMII_CLK_CHANGE(LoadDDREna),
    .ValIn( ValReg),
    .DataIn  (DataReg),

    .LINK_UP(LINK_UP),
    .DUPLEX (DUPLEX),
    .SPEED  (SPEED)
);
    
    
endmodule
