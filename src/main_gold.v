
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

module main_gold (
    output qspi_cs  ,
    output qspi_mosi,
    input  qspi_miso,
    input  usr_spi_clk ,
    input  usr_spi_cs  ,
    input  usr_spi_mosi,
    output usr_spi_miso,

    output mgt_pwr_en,
    output dbg_led,

    input sysclk25
);

assign mgt_pwr_en = 1'b0;

wire sysclk25_g;
BUFG sysclk25_bufg (
    .I(sysclk25), .O(sysclk25_g)
);

fpga_test_01 #(
    .G_BLINK_T05(125),
    .G_CLK_T05us(62)
) test_led (
    .p_out_test_led (dbg_led),
    .p_out_test_done(),

    .p_out_1us  (),
    .p_out_1ms  (),
    .p_out_1s   (),

    .p_in_clken (1'b1),
    .p_in_clk   (sysclk25_g),
    .p_in_rst   (1'b0)
);

STARTUPE2 #(
    .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
    .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
) STARTUPE2_inst (
    .CFGCLK(),              // 1-bit output: Configuration main clock output
    .CFGMCLK(),             // 1-bit output: Configuration internal oscillator clock output
    .EOS(),                 // 1-bit output: Active high output signal indicating the End Of Startup.
    .PREQ(),                // 1-bit output: PROGRAM request to fabric output
    .CLK(1'b0),             // 1-bit input: User start-up clock input
    .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
    .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
    .KEYCLEARB(1'b0),       // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
    .PACK(1'b0),            // 1-bit input: PROGRAM acknowledge input
    .USRCCLKO(usr_spi_clk), // 1-bit input: User CCLK input
                            // For Zynq-7000 devices, this input must be tied to GND
    .USRCCLKTS(1'b0),       // 1-bit input: User CCLK 3-state enable input
                            // For Zynq-7000 devices, this input must be tied to VCC
    .USRDONEO(1'b1),        // 1-bit input: User DONE pin output control
    .USRDONETS(1'b1)        // 1-bit input: User DONE 3-state enable output
);

assign qspi_cs = usr_spi_cs;
assign qspi_mosi = usr_spi_mosi;
assign usr_spi_miso = qspi_miso;

endmodule
