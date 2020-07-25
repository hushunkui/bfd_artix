//
// author: Golovachenko Viktor
//
module aurora_axi_tx_mux #(
    parameter ETHCOUNT = 0,
    parameter SIM = 0
) (
    input [1:0] trunc,
    input [ETHCOUNT-1:0] eth_mask, //1-mask, 0-normal work

    output [ETHCOUNT-1:0]      axis_s_tready,
    input  [(ETHCOUNT*32)-1:0] axis_s_tdata ,
    input  [(ETHCOUNT*4-1):0]  axis_s_tkeep ,
    input  [ETHCOUNT-1:0]      axis_s_tvalid,
    input  [ETHCOUNT-1:0]      axis_s_tlast ,
    input  [ETHCOUNT-1:0]      axis_s_tuser , //err

    input             axis_m_tready,
    output reg [31:0] axis_m_tdata  = 32'd0,
    output reg [3:0]  axis_m_tkeep  = 4'd0,
    output reg        axis_m_tvalid = 1'b0,
    output reg        axis_m_tlast  = 1'b0,

    input rstn,
    input clk
);

integer x;
reg [31:0] tdata [ETHCOUNT-1:0];
reg signed [16:0] sum10_Im;
reg signed [16:0] sum10_Re;
reg signed [16:0] sum32_Im;
reg signed [16:0] sum32_Re;
reg signed [17:0] sum3210_Im;
reg signed [17:0] sum3210_Re;
reg [2:0] sr_axis_s_tvalid;
reg [2:0] sr_axis_s_tlast;
wire [ETHCOUNT-1:0] axis_s_tvalid_mask;
wire [ETHCOUNT-1:0] axis_s_tlast_mask;

genvar x1;
generate
    for (x1=0; x1 < ETHCOUNT; x1=x1+1)  begin : eth
        assign axis_s_tready[x1] = axis_m_tready | eth_mask[x1];
        assign axis_s_tvalid_mask[x1] = axis_s_tvalid[x1] | eth_mask[x1];
        assign axis_s_tlast_mask[x1] = axis_s_tlast[x1] | eth_mask[x1];
    end
endgenerate

always @(posedge clk) begin
    //satge 0
    for (x=0; x < ETHCOUNT; x=x+1) begin
        if (!eth_mask[x]) begin
            tdata[x] <= axis_s_tdata[(x*32) +: 32];
        end else begin
            tdata[x] <= 0;
        end
    end
    sr_axis_s_tvalid[0] <= &axis_s_tvalid_mask;
    sr_axis_s_tlast[0] <= &axis_s_tlast_mask;

    //satge 1
    sum10_Im[16:0] <= $signed(tdata[0][15: 0]) + $signed(tdata[1][15: 0]);
    sum10_Re[16:0] <= $signed(tdata[0][31:16]) + $signed(tdata[1][31:16]);

    sum32_Im[16:0] <= $signed(tdata[2][15: 0]) + $signed(tdata[3][15: 0]);
    sum32_Re[16:0] <= $signed(tdata[2][31:16]) + $signed(tdata[3][31:16]);

    sr_axis_s_tvalid[1] <= sr_axis_s_tvalid[0];
    sr_axis_s_tlast[1] <= sr_axis_s_tlast[0];

    //satge 2
    sum3210_Im[17:0] <= sum10_Im[16:0] + sum32_Im[16:0];
    sum3210_Re[17:0] <= sum10_Re[16:0] + sum32_Re[16:0];

    sr_axis_s_tvalid[2] <= sr_axis_s_tvalid[1];
    sr_axis_s_tlast[2] <= sr_axis_s_tlast[1];

    //satge 3
    if (trunc == 2'd2) begin
        axis_m_tdata[15: 0] <= sum3210_Im[17:2];
        axis_m_tdata[31:16] <= sum3210_Re[17:2];
    end else if (trunc == 2'd1) begin
        axis_m_tdata[15: 0] <= sum3210_Im[16:1];
        axis_m_tdata[31:16] <= sum3210_Re[16:1];
    end else begin
        axis_m_tdata[15: 0] <= sum3210_Im[15:0];
        axis_m_tdata[31:16] <= sum3210_Re[15:0];
    end
    axis_m_tkeep <= 4'hF;
    axis_m_tvalid <= sr_axis_s_tvalid[2];
    axis_m_tlast <= sr_axis_s_tlast[2];

end

endmodule
