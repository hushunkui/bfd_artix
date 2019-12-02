//---------------------------------------------------------------------------
// Testbench
//---------------------------------------------------------------------------
`timescale 1ns / 1ps

module test_phy_tb ();

reg clk = 0;
reg start = 0;
wire [7:0] mac_tx_data ;
wire mac_tx_valid;
wire mac_tx_sof  ;
wire mac_tx_eof  ;

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


test_phy test_phy (
    .mac_tx_data (mac_tx_data ),
    .mac_tx_valid(mac_tx_valid),
    .mac_tx_sof  (mac_tx_sof  ),
    .mac_tx_eof  (mac_tx_eof  ),

    .mac_rx_data (mac_tx_data ),
    .mac_rx_valid(mac_tx_valid),
    .mac_rx_sof  (mac_tx_sof  ),
    .mac_rx_eof  (mac_tx_eof  ),
    .mac_rx_fr_good(),
    .mac_rx_fr_err(),

    .start(start),
    .err(),

    .clk(clk),
    .rst(1'b0)
);


endmodule

