//
// author: Golovachenko Viktor
//

module aurora_axi_tx_mux #(
    parameter ETHCOUNT = 0,
    parameter SIM = 0
) (
    input [2:0]  axis_m_sel,

    output       axis_s_tready,
    input [31:0] axis_s_tdata ,
    input [3:0]  axis_s_tkeep ,
    input        axis_s_tvalid,
    input        axis_s_tlast ,

    input [ETHCOUNT-1:0]           axis_m_tready,
    output reg [(ETHCOUNT*32)-1:0] axis_m_tdata  = 0,
    output reg [(ETHCOUNT*4-1):0]  axis_m_tkeep  = 0,
    output reg [ETHCOUNT-1:0]      axis_m_tvalid = 0,
    output reg [ETHCOUNT-1:0]      axis_m_tlast  = 0,

    input rstn,
    input clk
);

reg pkt_en = 1'b0;
reg [2:0] m_sel = 0;

integer i;
always @(posedge clk) begin
    if (axis_s_tvalid) begin
        pkt_en <= 1'b0;
    end else if (axis_s_tvalid) begin
        pkt_en <= 1'b1;
    end

    if (axis_s_tvalid && !pkt_en) begin
        m_sel <= axis_s_tdata[2:0];
    end

    for (i=0;i<ETHCOUNT;i=i+1) begin
        axis_m_tdata [(i*32) +: 32] <= axis_s_tdata;
        axis_m_tkeep [(i*4) +: 4] <= axis_s_tkeep;
        axis_m_tvalid[i] <= (m_sel == i) & axis_s_tvalid;
        axis_m_tlast [i] <= (m_sel == i) & axis_s_tlast ;
    end
end


endmodule
