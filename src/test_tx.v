//
// author: Golovachenko Viktor
//

module test_tx #(
    parameter SIM = 0
) (
    output [7:0] mac_tx_data,
    output       mac_tx_valid,
    output       mac_tx_sof,
    output       mac_tx_eof,

    input start,
    input clk,
    input rst
);

wire [31:0] test_data;

assign mac_tx_data = test_data[7:0];

sata_scrambler #(
    .G_INIT_VAL (16'h55AA)
) test_data (
    .p_in_SOF    (1'b0),
    .p_in_en     (),
    .p_out_result(test_data),

    .p_in_clk(clk),
    .p_in_rst(rst)
);



endmodule
