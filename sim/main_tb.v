//---------------------------------------------------------------------------
// Testbench
//---------------------------------------------------------------------------
`timescale 1ns / 1ps

`include "fpga_reg.v"

module tb;

    reg tb_ACLK;
    reg tb_ARESETn;

    wire temp_clk;
    wire temp_rstn;

    reg [31:0] addr;
    reg [31:0] write_data;
    reg [31:0] read_data;
    reg resp;

    reg [31:0] usr_base;

    initial
    begin
        tb_ACLK = 1'b0;
    end

    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------

    always #10 tb_ACLK = !tb_ACLK;

    initial
    begin

        $display ("running the tb");

        addr = 0;
        write_data = 0;
        read_data = 0;
        resp = 0;

        usr_base = 32'h43C0_0000;

        tb_ARESETn = 1'b0;
        repeat(20)@(posedge tb_ACLK);
        tb_ARESETn = 1'b1;
        @(posedge tb_ACLK);

        repeat(5) @(posedge tb_ACLK);

        //Reset the PL
        tb.main.system.processing_system7_0.inst.fpga_soft_reset(32'h1);
        tb.main.system.processing_system7_0.inst.fpga_soft_reset(32'h0);

        repeat(5) @(posedge tb_ACLK);

        repeat(50) @(posedge tb_ACLK);

        //UREG_FIRMWARE_DATE
        addr = usr_base + `UREG_FIRMWARE_DATE;
        tb.main.system.processing_system7_0.inst.read_data(addr, 4, read_data, resp);
        $display ("%t, rd UREG_FIRMWARE_DATE(32'h%x): 32'h%x",$time, addr, read_data);

        //UREG_FIRMWARE_TIME
        addr = usr_base + `UREG_FIRMWARE_TIME;
        tb.main.system.processing_system7_0.inst.read_data(addr, 4, read_data, resp);
        $display ("%t, rd UREG_FIRMWARE_DATE(32'h%x): 32'h%x",$time, addr, read_data);

        //UREG_TEST0
        addr = usr_base + `UREG_TEST0;
        write_data = 32'hDEADBEAF;
        $display ("%t, wr UREG_TEST0(32'h%x): 32'h%x",$time, addr, write_data);
        tb.main.system.processing_system7_0.inst.write_data(addr, 4, write_data, resp);

        //UREG_TEST1
        addr = usr_base + `UREG_TEST1;
        write_data = 32'hA5A5A5;
        $display ("%t, wr UREG_TEST1(32'h%x): 32'h%x",$time, addr, write_data);
        tb.main.system.processing_system7_0.inst.write_data(addr, 4, write_data, resp);

        //UREG_TEST0
        addr = usr_base + `UREG_TEST0;
        tb.main.system.processing_system7_0.inst.read_data(addr, 4, read_data, resp);
        $display ("%t, rd UREG_TEST0(32'h%x): 32'h%x",$time, addr, read_data);

        //UREG_TEST1
        addr = usr_base + `UREG_TEST1;
        tb.main.system.processing_system7_0.inst.read_data(addr, 4, read_data, resp);
        $display ("%t, rd UREG_TEST1(32'h%x): 32'h%x",$time, addr, read_data);

        $display ("Simulation completed");
        $stop;
    end

    assign temp_clk = tb_ACLK;
    assign temp_rstn = tb_ARESETn;

main # (
    .SIM(1)
) main (
    .usr_led(),
    .eth_phy_npwr_dwn(),
    .MDIO_0_mdc(),
    .MDIO_0_mdio_io(),
    .MII_0_col(1'b0),
    .MII_0_crs(1'b0),
    .MII_0_rst_n(),
    .MII_0_rx_clk(1'b0),
    .MII_0_rx_dv(1'b0),
    .MII_0_rx_er(1'b0),
    .MII_0_rxd(3'h0),
    .MII_0_tx_clk(1'b0),
    .MII_0_tx_en(),
    .MII_0_txd(),
    .DDR_addr   (),
    .DDR_ba     (),
    .DDR_cas_n  (),
    .DDR_ck_n   (),
    .DDR_ck_p   (),
    .DDR_cke    (),
    .DDR_cs_n   (),
    .DDR_dm     (),
    .DDR_dq     (),
    .DDR_dqs_n  (),
    .DDR_dqs_p  (),
    .DDR_odt    (),
    .DDR_ras_n  (),
    .DDR_reset_n(),
    .DDR_we_n   (),
    .FIXED_IO_ddr_vrn(),
    .FIXED_IO_ddr_vrp(),
    .FIXED_IO_mio(),
    .FIXED_IO_ps_clk  (temp_clk ),
    .FIXED_IO_ps_porb (temp_rstn),
    .FIXED_IO_ps_srstb(temp_rstn)
);


endmodule

