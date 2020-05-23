//
// author: Golovachenko Viktor
//
module aurora_axi_tx_mux #(
    parameter ETHCOUNT = 0,
    parameter SIM = 0
) (
    input [2:0]  axis_s_sel,

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

always @(posedge clk) begin
    case (axis_s_sel[1:0])
        2'd0 : begin
            axis_m_tdata  <= axis_s_tdata[(0*32) +: 32];
            axis_m_tkeep  <= axis_s_tkeep[(0*4) +: 4];
            axis_m_tvalid <= axis_s_tvalid[0];
            axis_m_tlast  <= axis_s_tlast [0];
        end
        2'd1 : begin
            axis_m_tdata  <= axis_s_tdata[(1*32) +: 32];
            axis_m_tkeep  <= axis_s_tkeep[(1*4) +: 4];
            axis_m_tvalid <= axis_s_tvalid[1];
            axis_m_tlast  <= axis_s_tlast [1];
        end
        2'd2 : begin
            axis_m_tdata  <= axis_s_tdata[(2*32) +: 32];
            axis_m_tkeep  <= axis_s_tkeep[(2*4) +: 4];
            axis_m_tvalid <= axis_s_tvalid[2];
            axis_m_tlast  <= axis_s_tlast [2];
        end
        2'd3 : begin
            axis_m_tdata  <= axis_s_tdata[(3*32) +: 32];
            axis_m_tkeep  <= axis_s_tkeep[(3*4) +: 4];
            axis_m_tvalid <= axis_s_tvalid[3];
            axis_m_tlast  <= axis_s_tlast [3];
        end
    endcase
end

endmodule
