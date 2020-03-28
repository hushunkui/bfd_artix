//
// author: Golovachenko Viktor
//

module test_rx #(
    parameter TEST_DATA_WIDTH = 32
)(
    input [TEST_DATA_WIDTH-1:0] mac_rx_data,
    input mac_rx_valid,
    input mac_rx_sof,
    input mac_rx_eof,
    input mac_rx_fr_good,
    input mac_rx_fr_err,

    input start,
    output reg err = 1'b0,
    output [TEST_DATA_WIDTH-1:0] test_data,

    input clk,
    input rst
);

`ifdef SIM_FSM
    enum int unsigned {
        IDLE   ,
        RXSTART,
        RX     ,
        WAIT_EOF
    } fsm_cs = IDLE;
`else
    localparam IDLE    = 2'd0;
    localparam RXSTART = 2'd1;
    localparam RX      = 2'd2;
    localparam WAIT_EOF= 2'd3;
    reg [1:0] fsm_cs = IDLE;
`endif

wire [31:0] data;
reg err_crc   = 1'b0;
reg err_fr_rx = 1'b0;
reg err_cmp   = 1'b0;
reg srcambler_sof = 1'b0;

sata_scrambler #(
    .G_INIT_VAL (16'h55AA)
) scrambler (
    .p_in_SOF    (srcambler_sof),
    .p_in_en     (mac_rx_valid),
    .p_out_result(data),

    .p_in_clk(clk),
    .p_in_rst(rst)
);

assign test_data[TEST_DATA_WIDTH-1:0] = data[TEST_DATA_WIDTH-1:0];

always @(posedge clk) begin
    srcambler_sof <= 1'b0;
    case (fsm_cs)
        IDLE: begin //Initialization scrambler. Do it once.
            if (start) begin
                srcambler_sof <= 1'b1;
                fsm_cs <= RXSTART;
            end
        end

        RXSTART: begin
            if (start) begin
                err_cmp <= 1'b0;
                err_fr_rx <= 1'b0;
                err_crc <= 1'b0;
                fsm_cs <= RX;
            end else begin
                fsm_cs <= IDLE;
            end
        end

        RX: begin
            if (mac_rx_valid) begin
                if (test_data != mac_rx_data) begin
                    err_cmp <= 1'b1;
                    if (mac_rx_eof) begin
                        if (start) begin
                            fsm_cs <= RXSTART;
                        end else begin
                            fsm_cs <= IDLE;
                        end
                    end else begin
                        fsm_cs <= WAIT_EOF;
                    end

                end else if (mac_rx_fr_err) begin
                    err_fr_rx <= 1'b1;
                    if (mac_rx_eof) begin
                        if (start) begin
                            fsm_cs <= RXSTART;
                        end else begin
                            fsm_cs <= IDLE;
                        end
                    end else begin
                        fsm_cs <= WAIT_EOF;
                    end

                end else if (mac_rx_eof) begin
                    if (!mac_rx_fr_good) begin
                        err_crc <= 1'b1;
                    end
                    if (start) begin
                        fsm_cs <= RXSTART;
                    end else begin
                        fsm_cs <= IDLE;
                    end
                end
            end
        end

        WAIT_EOF: begin
            if (mac_rx_valid & mac_rx_eof) begin
                if (start) begin
                    fsm_cs <= RXSTART;
                end else begin
                    fsm_cs <= IDLE;
                end
            end
        end
    endcase
end

always @(posedge clk) begin
    err <= err_cmp | err_fr_rx | err_crc;
end

endmodule
