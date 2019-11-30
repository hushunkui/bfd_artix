//
// author: Golovachenko Viktor
//

module test_rx (
    input [7:0] mac_rx_data,
    input mac_rx_valid,
    input mac_rx_sof,
    input mac_rx_eof,
    input mac_rx_fr_good,
    input mac_rx_fr_err,

    input start,
    output reg err = 1'b0,

    input clk,
    input rst
);

localparam IDLE  = 2'd0;
localparam RX    = 2'd1;
localparam ERR   = 2'd2;
reg [1:0] fsm_cs = IDLE;

wire [31:0] mac_tx_data;
reg err_crc   = 1'b0;
reg err_fr_rx = 1'b0;
reg err_cmp   = 1'b0;

sata_scrambler #(
    .G_INIT_VAL (16'h55AA)
) test_data (
    .p_in_SOF    (1'b0),
    .p_in_en     (mac_rx_valid),
    .p_out_result(mac_tx_data),

    .p_in_clk(clk),
    .p_in_rst(rst)
);

always @(posedge clk) begin
    case (fsm_cs)
        IDLE: begin
            err_crc   = 1'b0;
            err_fr_rx = 1'b0;
            err_cmp   = 1'b0;
            if (start) begin
                fsm_cs <= RX;
            end
        end

        RX: begin
            if (mac_rx_valid) begin
                if ((mac_tx_data[7:0] != mac_rx_data) || (mac_rx_eof) || (mac_rx_fr_err)) begin
                    if (mac_rx_eof && mac_rx_fr_good) begin
                        fsm_cs <= IDLE;
                    end else begin
                        err_cmp <= 1'b1;
                        fsm_cs <= ERR;
                    end
                end

                err_crc <= (mac_rx_eof && !mac_rx_fr_good);
                err_fr_rx <= mac_rx_fr_err;
            end

        end

        ERR: begin
            err <= err_cmp || err_fr_rx || err_crc;
        end
    endcase
end


endmodule
