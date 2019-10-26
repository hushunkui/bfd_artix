//---------------------------------------------------------------------------
// Testbench
//---------------------------------------------------------------------------
`timescale 1ns / 1ps

module tb;

initial
begin
    tb_ACLK = 1'b0;
end

//------------------------------------------------------------------------
// Simple Clock Generator
//------------------------------------------------------------------------

always #10 tb_ACLK = !tb_ACLK;


//main # (
//    .SIM(1)
//) main (
//    .usr_led(),
//    .eth_phy_npwr_dwn(),
//    .MDIO_0_mdc(),
//    .MDIO_0_mdio_io(),
//    .MII_0_col(1'b0),
//    .MII_0_crs(1'b0),
//    .MII_0_rst_n(),
//    .MII_0_rx_clk(1'b0),
//    .MII_0_rx_dv(1'b0),
//    .MII_0_rx_er(1'b0),
//    .MII_0_rxd(3'h0),
//    .MII_0_tx_clk(1'b0),
//    .MII_0_tx_en(),
//    .MII_0_txd(),
//    .DDR_addr   (),
//    .DDR_ba     (),
//    .DDR_cas_n  (),
//    .DDR_ck_n   (),
//    .DDR_ck_p   (),
//    .DDR_cke    (),
//    .DDR_cs_n   (),
//    .DDR_dm     (),
//    .DDR_dq     (),
//    .DDR_dqs_n  (),
//    .DDR_dqs_p  (),
//    .DDR_odt    (),
//    .DDR_ras_n  (),
//    .DDR_reset_n(),
//    .DDR_we_n   (),
//    .FIXED_IO_ddr_vrn(),
//    .FIXED_IO_ddr_vrp(),
//    .FIXED_IO_mio(),
//    .FIXED_IO_ps_clk  (temp_clk ),
//    .FIXED_IO_ps_porb (temp_rstn),
//    .FIXED_IO_ps_srstb(temp_rstn)
//);


endmodule

