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
reg signed [16:0] sum01_a;
reg signed [16:0] sum01_b;
reg signed [16:0] sum23_a;
reg signed [16:0] sum23_b;
reg signed [17:0] sum0123_a;
reg signed [17:0] sum0123_b;
reg [2:0] sr_axis_s_tvalid;
reg [2:0] sr_axis_s_tlast;
wire [ETHCOUNT-1:0] axis_s_tvalid_mask;
wire [ETHCOUNT-1:0] axis_s_tlast_mask;

assign axis_s_tvalid_mask = axis_s_tvalid | eth_mask;
assign axis_s_tlast_mask = axis_s_tlast | eth_mask;

assign axis_s_tready[0] = axis_m_tready & &axis_s_tvalid_mask;
assign axis_s_tready[1] = axis_m_tready & &axis_s_tvalid_mask;
assign axis_s_tready[2] = axis_m_tready & &axis_s_tvalid_mask;
assign axis_s_tready[3] = axis_m_tready & &axis_s_tvalid_mask;

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
    sum01_a[16:0] <= $signed(tdata[0][15: 0]) + $signed(tdata[1][15: 0]);
    sum01_b[16:0] <= $signed(tdata[0][31:16]) + $signed(tdata[1][31:16]);

    sum23_a[16:0] <= $signed(tdata[2][15: 0]) + $signed(tdata[3][15: 0]);
    sum23_b[16:0] <= $signed(tdata[2][31:16]) + $signed(tdata[3][31:16]);

    sr_axis_s_tvalid[1] <= sr_axis_s_tvalid[0];
    sr_axis_s_tlast[1] <= sr_axis_s_tlast[0];

    //satge 2
    sum0123_a[17:0] <= sum01_a[16:0] + sum01_a[16:0];
    sum0123_b[17:0] <= sum01_b[16:0] + sum01_b[16:0];

    sr_axis_s_tvalid[2] <= sr_axis_s_tvalid[1];
    sr_axis_s_tlast[2] <= sr_axis_s_tlast[1];

    //satge 3
    if (trunc == 2'd2) begin
        axis_m_tdata[15: 0] <= sum0123_a[17:2];
        axis_m_tdata[31:16] <= sum0123_b[17:2];
    end else if (trunc == 2'd1) begin
        axis_m_tdata[15: 0] <= sum0123_a[16:1];
        axis_m_tdata[31:16] <= sum0123_b[16:1];
    end else begin
        axis_m_tdata[15: 0] <= sum0123_a[15:0];
        axis_m_tdata[31:16] <= sum0123_b[15:0];
    end
    axis_m_tkeep <= 4'hF;
    axis_m_tvalid <= sr_axis_s_tvalid[2];
    axis_m_tlast <= sr_axis_s_tlast[2];

end

endmodule
