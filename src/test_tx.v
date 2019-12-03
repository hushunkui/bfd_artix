//
// author: Golovachenko Viktor
//

module test_tx (
    output [7:0] mac_tx_data,
    output reg mac_tx_valid = 1'b0,
    output reg mac_tx_sof = 1'b0,
    output reg mac_tx_eof = 1'b0,

    input start,
    input [15:0] pkt_size,
    input [15:0] pause_size,

    input clk,
    input rst
);

wire [31:0] data;
reg [15:0] dcnt = 0;
reg srcambler_sof = 1'b0;

`ifdef SIM_FSM
    enum int unsigned {
        IDLE   ,
        TXSTART,
        TX     ,
        PAUSE
    } fsm_cs = IDLE;
`else
    localparam IDLE    = 2'd0;
    localparam TXSTART = 2'd1;
    localparam TX      = 2'd2;
    localparam PAUSE   = 2'd3;
    reg [1:0] fsm_cs = IDLE;
`endif

assign mac_tx_data = data[7:0];

sata_scrambler #(
    .G_INIT_VAL (16'h55AA)
) test_data (
    .p_in_SOF    (srcambler_sof),
    .p_in_en     (mac_tx_valid),
    .p_out_result(data),

    .p_in_clk(clk),
    .p_in_rst(rst)
);

always @(posedge clk) begin
    case (fsm_cs)
        IDLE: begin
            if (start) begin
                srcambler_sof <= 1'b1;
                fsm_cs <= TXSTART;
            end
        end

        TXSTART: begin
            srcambler_sof <= 1'b0;
            mac_tx_valid <= 1'b0;
            mac_tx_sof <= 1'b0;
            mac_tx_eof <= 1'b0;

            if (start) begin
                mac_tx_valid <= 1'b1;
                mac_tx_sof <= 1'b1;
                mac_tx_eof <= 1'b0;
                fsm_cs <= TX;
            end
        end

        TX: begin
            mac_tx_sof <= 1'b0;
            if (dcnt == (pkt_size - 2)) begin
                mac_tx_eof <= 1'b1;
            end else if (dcnt == (pkt_size - 1)) begin
                mac_tx_eof <= 1'b0;
                mac_tx_valid <= 1'b0;
            end

            if (dcnt == (pkt_size - 1)) begin
                dcnt <= 0;
                fsm_cs <= PAUSE;
            end else begin
                dcnt <= dcnt + 1;
            end
        end

        PAUSE: begin
            if (dcnt == (pause_size - 1)) begin
                dcnt <= 0;
                if (start) begin
                    fsm_cs <= TXSTART;
                end else begin
                    fsm_cs <= IDLE;
                end
            end else begin
                dcnt <= dcnt + 1;
            end
        end
    endcase
end



endmodule
