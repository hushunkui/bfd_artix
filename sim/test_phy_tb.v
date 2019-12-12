//---------------------------------------------------------------------------
// Testbench
//---------------------------------------------------------------------------
`timescale 1ns / 1ps

module test_phy_tb ();

localparam  TEST_DATA_WIDTH = 32;

reg clk = 0;
reg start = 0;
wire [TEST_DATA_WIDTH-1:0] mac_tx_data;
wire mac_tx_valid;
wire mac_tx_sof  ;
wire mac_tx_eof  ;

reg [TEST_DATA_WIDTH-1:0] mac_rx_data = 0;
reg mac_rx_valid = 1'b0;
reg mac_rx_sof = 1'b0;
reg mac_rx_eof = 1'b0;

wire [TEST_DATA_WIDTH-1:0] test_data;

initial
begin
    clk = 1'b0;
    #1000
    start = 1'b1;
end

//------------------------------------------------------------------------
// Simple Clock Generator
//------------------------------------------------------------------------

always #10 clk = !clk;

test_phy #(
    .TEST_DATA_WIDTH(TEST_DATA_WIDTH)
) test_phy (
    .mac_tx_data (mac_tx_data ),
    .mac_tx_valid(mac_tx_valid),
    .mac_tx_sof  (mac_tx_sof  ),
    .mac_tx_eof  (mac_tx_eof  ),

    .mac_rx_data (mac_rx_data ),
    .mac_rx_valid(mac_rx_valid),
    .mac_rx_sof  (mac_rx_sof  ),
    .mac_rx_eof  (mac_rx_eof  ),
    .mac_rx_fr_good(mac_rx_eof),
    .mac_rx_fr_err(1'b0),

    .start(start),
    .err(),
    .test_data(test_data),

    .clk(clk),
    .rst(1'b0)
);

always @(posedge clk) begin
    mac_rx_data  <= mac_tx_data ;
    mac_rx_valid <= mac_tx_valid;
    mac_rx_sof   <= mac_tx_sof  ;
    mac_rx_eof   <= mac_tx_eof  ;
end

endmodule

