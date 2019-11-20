//
//author: Golovachenko Viktor
//
`timescale 1ns / 1ps
module mdio_tb();

reg clk = 1;
always #2.5 clk = ~clk;

reg rst = 1'b0;
reg mdio_start = 0;
reg mdio_dir = 0;
reg [4:0] mdio_aphy = 0;
reg [4:0] mdio_areg = 0;
reg [15:0] mdio_txd = 0;
wire [15:0] mdio_rxd;

initial begin
    // $dumpfile("icarus/dump.fst");
    // $dumpvars;

    mdio_start = 1'b0;
    mdio_aphy = 0;
    mdio_areg = 0;
    mdio_txd = 0;

    rst = 1'b0;
    #500;
    rst = 1'b1;
    #100;
    rst = 1'b0;

    #500;
    mdio_start = 1'b1;
    mdio_aphy <= 5'h06;
    mdio_areg <= 5'h0B;
    mdio_txd  <= 16'h8FFA;
    mdio_dir  <= 1'b1; //1 -tx; 0 -rx
    @(posedge clk);

    #100;
    mdio_start = 1'b0;
    @(posedge clk);

    // $display("\007");
    // $finish;
end

eth_mdio #(
    .G_DIV(2)
) mdio_m (
    //--------------------------------------
    .usr_start(mdio_start),
    .usr_dir(mdio_dir),
    .usr_aphy(mdio_aphy),
    .usr_areg(mdio_areg),
    .usr_txd(mdio_txd),
    .usr_rxd(mdio_rxd),
    .usr_done(),
    .usr_busy(),

    .p_out_mdio_t(),
    .p_out_mdio(),
    .p_in_mdio(1'b1),
    .p_out_mdc(),

    //--------------------------------------------------
    .dbg_o(),

    //--------------------------------------
    .clk (clk),
    .rst (rst)
);


endmodule
