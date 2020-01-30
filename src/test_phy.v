//
// author: Golovachenko Viktor
//

module test_phy #(
    parameter TEST_DATA_WIDTH = 8
)(
    output [TEST_DATA_WIDTH-1:0] mac_tx_data,
    output mac_tx_valid,
    output mac_tx_sof,
    output mac_tx_eof,
    input  mac_tx_rdy,

    input [TEST_DATA_WIDTH-1:0] mac_rx_data,
    input mac_rx_valid,
    input mac_rx_sof,
    input mac_rx_eof,
    input mac_rx_fr_good,
    input mac_rx_fr_err,

    input [15:0] pkt_size,
    input [15:0] pause_size,
    input start,
    output err,
    output [TEST_DATA_WIDTH-1:0] test_data,

    input clk,
    input rst
);

test_tx #(
    .TEST_DATA_WIDTH(TEST_DATA_WIDTH)
) test_tx (
    .mac_tx_data (mac_tx_data ),
    .mac_tx_valid(mac_tx_valid),
    .mac_tx_sof  (mac_tx_sof  ),
    .mac_tx_eof  (mac_tx_eof  ),
    .mac_tx_rdy  (mac_tx_rdy  ),

    .start(start),
    .pkt_size(pkt_size),
    .pause_size(pause_size),

    .clk(clk),
    .rst(rst)
);

test_rx #(
    .TEST_DATA_WIDTH(TEST_DATA_WIDTH)
)  test_rx (
    .mac_rx_data   (mac_rx_data   ),
    .mac_rx_valid  (mac_rx_valid  ),
    .mac_rx_sof    (mac_rx_sof    ),
    .mac_rx_eof    (mac_rx_eof    ),
    .mac_rx_fr_good(mac_rx_fr_good),
    .mac_rx_fr_err (mac_rx_fr_err ),

    .start(start),
    .err(err),
    .test_data(test_data),

    .clk(clk),
    .rst(rst)
);


endmodule
