
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

`include "fpga_reg.v"

module main_gold (
    output qspi_cs  ,
    output qspi_mosi,
    input  qspi_miso,
    input  usr_spi_clk ,
    input [1:0] usr_spi_cs,
    input  usr_spi_mosi,
    output usr_spi_miso,

    output mgt_pwr_en,
    output dbg_led,
    output [1:0] dbg_out,

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
    .USRCCLKO(usr_spi_clk & !usr_spi_cs[0]), // 1-bit input: User CCLK input
                            // For Zynq-7000 devices, this input must be tied to GND
    .USRCCLKTS(1'b0),       // 1-bit input: User CCLK 3-state enable input
                            // For Zynq-7000 devices, this input must be tied to VCC
    .USRDONEO(1'b1),        // 1-bit input: User DONE pin output control
    .USRDONETS(1'b1)        // 1-bit input: User DONE 3-state enable output
);

wire usr_miso;

assign qspi_cs = usr_spi_cs[0];
assign qspi_mosi = usr_spi_mosi;
assign usr_spi_miso = (qspi_miso | usr_spi_cs[0]) && (usr_miso | usr_spi_cs[1]);

assign dbg_out[0] = usr_spi_miso;
assign dbg_out[1] = usr_spi_cs[1];


wire [(`FPGA_REG_DWIDTH * `FPGA_REG_COUNT)-1:0] reg_rd_data;
wire [7:0]  reg_wr_addr = 0;
wire [15:0] reg_wr_data = 0;
wire        reg_wr_en = 0;
wire        reg_clk;

wire [31:0] firmware_date;
wire [31:0] firmware_time;

reg [`FPGA_REG_DWIDTH-1:0] reg_test_array [0:`FPGA_REG_TEST_ARRAY_COUNT-1];

clk_wiz_gold pll0(
    .clk_out1(reg_clk),//clk125M
    .locked(),
    .clk_in1(sysclk25_g),
    .reset(1'b0)
);

firmware_gold_rev m_firmware_rev (
   .firmware_date (firmware_date),
   .firmware_time (firmware_time)
);

spi_slave #(
    .RD_OFFSET(`FPGA_RD_OFFSET),
    .REG_RD_DATA_WIDTH(`FPGA_REG_COUNT * `FPGA_REG_DWIDTH)
) usrspi (
    //SPI port
    .spi_cs_i  (usr_spi_cs[1]),
    .spi_clk_i (usr_spi_clk),
    .spi_mosi_i(usr_spi_mosi),
    .spi_miso_o(usr_miso),

    //User IF
    .reg_rd_data(reg_rd_data),
    .reg_wr_addr(reg_wr_addr),
    .reg_wr_data(reg_wr_data),
    .reg_wr_en  (reg_wr_en),
    .reg_clk    (reg_clk),
    .rst(1'b0)
);

//Read User resisters
assign reg_rd_data[`FPGA_RREG_FIRMWARE_DATE * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = firmware_date;
assign reg_rd_data[`FPGA_RREG_FIRMWARE_TIME * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = firmware_time;
assign reg_rd_data[`FPGA_RREG_FIRMWARE_TYPE * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = `FPGA_FIRMWARE_GOLDEN;

genvar a;
generate
    for (a = 0; a < `FPGA_REG_TEST_ARRAY_COUNT; a = a + 1) begin
        assign reg_rd_data[(`FPGA_RREG_TEST_ARRAY + a) * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_test_array[a];
    end
endgenerate

integer i;
//Write User resisters
always @ (posedge reg_clk) begin
    for (i = 0; i < `FPGA_REG_TEST_ARRAY_COUNT; i = i + 1) begin
        if (reg_wr_en && (reg_wr_addr == (`FPGA_WREG_TEST_ARRAY + i))) reg_test_array[i] <= reg_wr_data;
    end
end

endmodule
