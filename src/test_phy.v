//
// author: Golovachenko Viktor
//

module test_phy (
    output [7:0] mac_tx_data,
    output mac_tx_valid,
    output mac_tx_sof,
    output mac_tx_eof,

    input [7:0] mac_rx_data,
    input mac_rx_valid,
    input mac_rx_sof,
    input mac_rx_eof,
    input mac_rx_fr_good,
    input mac_rx_fr_err,

    input start,
    output err,
    output [7:0] test_data,

    input clk,
    input rst
);

test_tx test_tx (
    .mac_tx_data (mac_tx_data ),
    .mac_tx_valid(mac_tx_valid),
    .mac_tx_sof  (mac_tx_sof  ),
    .mac_tx_eof  (mac_tx_eof  ),

    .start(start),
    .pkt_size(16'd512),
    .pause_size(16'd64),

    .clk(clk),
    .rst(rst)
);

test_rx test_rx (
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
