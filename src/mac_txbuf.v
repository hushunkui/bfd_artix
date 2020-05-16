//
// author: Golovachenko Viktor
//

module mac_txbuf #(
    parameter SIM = 0
) (
    input        synch,

    output       axis_tready,
    input [31:0] axis_tdata ,
    input [3:0]  axis_tkeep ,
    input        axis_tvalid,
    input        axis_tlast ,

    output reg [7:0] mac_tx_data  = 8'd0,
    output reg       mac_tx_valid = 1'b0,
    output reg       mac_tx_sof   = 1'b0,
    output reg       mac_tx_eof   = 1'b0,
    output reg       mac_tx_rq    = 1'b0,
    input            mac_tx_ack,

    input rstn,
    input clk
);

`ifdef SIM_FSM
    enum int unsigned {
        S_IDLE,
        S_TXRQ,
        S_GET_TXD,
        S_TXD,
        S_TXD_LAST,
        S_TX_END
    } fsm_cs = S_IDLE;
`else
    localparam S_IDLE     = 0;
    localparam S_TXRQ     = 1;
    localparam S_GET_TXD  = 2;
    localparam S_TXD      = 3;
    localparam S_TXD_LAST = 4;
    localparam S_TX_END   = 5;
    reg [2:0] fsm_cs = S_IDLE;
`endif

reg [1:0] bcnt = 0;
reg [1:0] bcnt_last_count = 0;
wire [31:0] tdata;
wire [3:0]  tkeep;
wire        tvalid;
wire        tlast;
reg tready = 1'b1;

reg [31:0] s_tdata = 0;
reg [3:0]  s_tkeep = 0;
reg        s_tlast = 0;

always @(posedge clk) begin
    mac_tx_sof <= 1'b0;
    mac_tx_eof <= 1'b0;

    case (fsm_cs)
        S_IDLE : begin
            bcnt <= 0;
            bcnt_last_count <= 0;
            if (tvalid) begin
                tready <= 1'b0;
                mac_tx_rq <= 1'b1;
                s_tdata <= tdata;
                s_tkeep <= tkeep;
                s_tlast <= tlast;
                fsm_cs <= S_TXRQ;
            end else begin
                tready <= 1'b1;
            end
        end

        S_TXRQ : begin
            if (mac_tx_ack) begin
                mac_tx_data <= s_tdata[0  +: 8];
                mac_tx_valid <= 1'b1;
                mac_tx_sof <= 1'b1;
                bcnt <= bcnt + 1;
                if (s_tlast) begin
                    if (s_tkeep == 4'b0001) begin
                        mac_tx_eof <= 1'b1;
                        fsm_cs <= S_TX_END;
                    end else begin
                        case(s_tkeep)
                            4'b0011 : bcnt_last_count <= 2'd1;
                            4'b0111 : bcnt_last_count <= 2'd2;
                            4'b1111 : bcnt_last_count <= 2'd3;
                        endcase
                        fsm_cs <= S_TXD_LAST;
                    end
                end else begin
                    fsm_cs <= S_TXD;
                end
            end
        end

        S_GET_TXD : begin
            if (tvalid) begin
                bcnt <= bcnt + 1;
                tready <= 1'b0;
                s_tdata <= tdata;
                mac_tx_data <= tdata[0 +: 8];
                if (tlast) begin
                    if (tkeep == 4'b0001) begin
                        mac_tx_eof <= 1'b1;
                        fsm_cs <= S_TX_END;
                    end else begin
                        case(tkeep)
                            4'b0011 : bcnt_last_count <= 2'd1;
                            4'b0111 : bcnt_last_count <= 2'd2;
                            4'b1111 : bcnt_last_count <= 2'd3;
                        endcase
                        fsm_cs <= S_TXD_LAST;
                    end
                end else begin
                    fsm_cs <= S_TXD;
                end
            end
        end

        S_TXD : begin
            bcnt <= bcnt + 1;
            case (bcnt)
                2'd1 : mac_tx_data <= s_tdata[8  +: 8];
                2'd2 : mac_tx_data <= s_tdata[16 +: 8];
                2'd3 : mac_tx_data <= s_tdata[24 +: 8];
            endcase

            if (&bcnt) begin
                tready <= 1'b1;
                fsm_cs <= S_GET_TXD;
            end
        end

        S_TXD_LAST : begin
            if (bcnt == bcnt_last_count) begin
                bcnt <= 0;
                mac_tx_eof <= 1'b1;
                fsm_cs <= S_TX_END;
            end else begin
                bcnt <= bcnt + 1;
            end

            case (bcnt)
                2'd1 : mac_tx_data <= s_tdata[8  +: 8];
                2'd2 : mac_tx_data <= s_tdata[16 +: 8];
                2'd3 : mac_tx_data <= s_tdata[24 +: 8];
            endcase
        end

        S_TX_END : begin
            mac_tx_valid <= 1'b0;
            mac_tx_rq <= 1'b0;
            tready <= 1'b1;
            fsm_cs <= S_IDLE;
        end
    endcase
end

mac_txbuf_axis_fifo fifo (
    .s_axis_tready(axis_tready), // output
    .s_axis_tdata (axis_tdata ), // input [31 : 0]
    .s_axis_tkeep (axis_tkeep ), // input [3 : 0]
    .s_axis_tvalid(axis_tvalid), // input
    .s_axis_tlast (axis_tlast ), // input

    .m_axis_tready(tready), // input
    .m_axis_tvalid(tvalid), // output
    .m_axis_tdata (tdata ), // output [31 : 0]
    .m_axis_tkeep (tkeep ), // output [3 : 0]
    .m_axis_tlast (tlast ), // output

    .wr_rst_busy(),      // output
    .rd_rst_busy(),      // output

    .s_aclk(clk),
    .s_aresetn(rstn)
);


endmodule
