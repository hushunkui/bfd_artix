//
// author: Golovachenko Viktor
//

module mac_rxbuf #(
    parameter SIM = 0
) (
    input         axis_tready,
    output [31:0] axis_tdata,
    output [3:0]  axis_tkeep,
    output        axis_tvalid,
    output        axis_tlast,
    output        axis_tuser,

    input [7:0] mac_rx_data ,
    input       mac_rx_valid,
    input       mac_rx_sof  ,
    input       mac_rx_eof  ,
    input       mac_rx_err  ,
    input       mac_rx_clk  ,

    input rstn,
    input clk
);

reg [1:0] bcnt = 0;
reg [31:0] tdata = 0;
reg [3:0]  tkeep = 0;
reg tvalid = 1'b0;
reg tlast   = 1'b0;
reg sof_detect = 1'b0;

always @(posedge clk) begin
    if (mac_rx_valid) begin
        if (!sof_detect) begin
            if (mac_rx_sof & !mac_rx_eof) begin
                sof_detect <= 1'b1;
            end
            bcnt <= bcnt + 1;
            case (bcnt)
                2'd0 : tdata[0  +: 8] <= mac_rx_data;
                2'd1 : tdata[8  +: 8] <= mac_rx_data;
                2'd2 : tdata[16 +: 8] <= mac_rx_data;
                2'd3 : tdata[24 +: 8] <= mac_rx_data;
            endcase

            if (mac_rx_eof) begin
                case (bcnt)
                    2'd0 : tkeep <= 4'b0001;
                    2'd1 : tkeep <= 4'b0011;
                    2'd2 : tkeep <= 4'b0111;
                    2'd3 : tkeep <= 4'b1111;
                endcase
            end else begin
                tkeep <= 4'b1111;
            end
        end else begin
            bcnt <= bcnt + 1;
            case (bcnt)
                2'd0 : tdata[0  +: 8] <= mac_rx_data;
                2'd1 : tdata[8  +: 8] <= mac_rx_data;
                2'd2 : tdata[16 +: 8] <= mac_rx_data;
                2'd3 : tdata[24 +: 8] <= mac_rx_data;
            endcase

            if (mac_rx_eof) begin
                sof_detect <= 1'b0;
                case (bcnt)
                    2'd0 : tkeep <= 4'b0001;
                    2'd1 : tkeep <= 4'b0011;
                    2'd2 : tkeep <= 4'b0111;
                    2'd3 : tkeep <= 4'b1111;
                endcase
            end else begin
                tkeep <= 4'b1111;
            end
        end
    end else begin
        bcnt <= 2'd0;
        tkeep <= 4'b1111;
    end

    tvalid <= ((&bcnt) & mac_rx_valid) | mac_rx_eof;
    tlast <= mac_rx_eof;
end


mac_rxbuf_axis_fifo fifo (
    .s_axis_tready(),       // output
    .s_axis_tdata (tdata ), // input [31 : 0]
    .s_axis_tkeep (tkeep ), // input [3 : 0]
    .s_axis_tvalid(tvalid), // input
    .s_axis_tlast (tlast ), // input
    .s_axis_tuser (mac_rx_err), // input [0 : 0]

    .m_axis_tready(axis_tready), // input
    .m_axis_tvalid(axis_tvalid), // output
    .m_axis_tdata (axis_tdata ), // output [31 : 0]
    .m_axis_tkeep (axis_tkeep ), // output [3 : 0]
    .m_axis_tlast (axis_tlast ), // output
    .m_axis_tuser (axis_tuser ), // output [0 : 0]

    .wr_rst_busy(),      // output
    .rd_rst_busy(),      // output

    .s_aclk(clk),
    .s_aresetn(rstn)
);


endmodule
