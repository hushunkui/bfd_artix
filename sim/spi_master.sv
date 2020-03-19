//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 14.06.2018 15:38:21
// Module Name : spi_master
//
// Description :
//
//------------------------------------------------------------------------
`timescale 1ns / 1ps

`include "fpga_regs.v"

module spi_master #(
    parameter BAYER_PATTERN = 0,
)(
    output   spi_cs  ,
    output   spi_clk ,
    output   spi_mosi,
    input    spi_miso
);


logic  cs;
logic  clk;
logic  mosi;
logic  miso;
logic [(`FPGA_REG_AWIDTH + `FPGA_REG_DWIDTH - 1):0] spi_rxdata;
logic [`FPGA_REG_DWIDTH-1:0] spi_wrdata [7:0];
logic [31:0] rd_build_data;

logic [29:0] mem_adr = 0;
logic [31:0] mem_wdata = 0;
logic [31:0] mem_rdata = 0;
logic [31:0] usr_data32b;
logic [15:0] usr_data16b;



assign spi_cs = cs;
assign spi_clk = clk;
assign spi_mosi = mosi;
assign miso = spi_miso;


localparam SPI_DELAY = 100;
task SPI_Write(input [`FPGA_REG_AWIDTH-1:0] addr, input [`FPGA_REG_DWIDTH-1:0] data);
begin
    int i;
    logic [($size(addr) + $size(data) - 1):0] txdata;

//     //SPI MODE = 3
//     txdata = {addr, data};
//     #SPI_DELAY;
//     cs = 0;
//     mosi = txdata[$size(txdata)-1];
//     #SPI_DELAY;
//     for (i = $size(txdata)-1; i >= 0; i--) begin
//         mosi = txdata[i];
//         clk = 0;
//         #SPI_DELAY;
//         clk = 1;
//         #SPI_DELAY;
//     end
//     cs = 1;
// //    $display("\t\tSPI_WR: REG_ADR %h(hex),%03d(dec); WDATA %h(hex)", addr, addr, data);
//     mosi = 1'bz;
//     #SPI_DELAY;

   //SPI MODE = 0
       txdata = {addr, data};
       #SPI_DELAY;
       cs = 0;
       mosi = txdata[$size(txdata)-1];
       #SPI_DELAY;
       for (i = $size(txdata)-1; i >= 0; i--) begin
           mosi = txdata[i];
           clk = 0;
           #SPI_DELAY;
           clk = 1;
           #SPI_DELAY;
       end
       clk = 0;
       #SPI_DELAY;
       cs = 1;
   //    $display("\t\tSPI_WR: REG_ADR %h(hex),%03d(dec); WDATA %h(hex)", addr, addr, data);
       mosi = 1'bz;
       #SPI_DELAY;
end
endtask : SPI_Write


task SPI_Read (input [`FPGA_REG_AWIDTH-1:0] addr, input [`FPGA_REG_DWIDTH-1:0] data);
begin
    int i;
    logic [($size(addr) + $size(data) - 1):0] txdata;
    logic [($size(addr) + $size(data) - 1):0] rxdata;

//     txdata = {addr, data};
//     #SPI_DELAY;
//     cs = 0;
//     mosi = txdata[$size(txdata)-1];
//     #SPI_DELAY;
//     for (i = $size(txdata)-1; i >= 0; i--) begin
//         mosi = txdata[i];
//         clk = 0;
//         #SPI_DELAY;
//         clk = 1;
//         #SPI_DELAY;
//         rxdata[i] = miso;
//     end
//     spi_rxdata = rxdata;
// //    $display("\t\tSPI_RD: REG_ADR %h(hex),%03d(dec); RDATA %h(hex)", addr, addr, spi_rxdata[`FPGA_REG_DWIDTH-1:0]);
//     cs = 1;
//     mosi = 1'bz;
//     #SPI_DELAY;

   //SPI MODE = 0
   txdata = {addr, data};
   #SPI_DELAY;
   cs = 0;
   mosi = txdata[$size(txdata)-1];
   #SPI_DELAY;
   for (i = $size(txdata)-1; i >= 0; i--) begin
       mosi = txdata[i];
       clk = 0;
       #SPI_DELAY;
       clk = 1;
       #SPI_DELAY;
       rxdata[i] = miso;
   end
   spi_rxdata = rxdata;
//    $display("\t\tSPI_RD: REG_ADR %h(hex),%03d(dec); RDATA %h(hex)", addr, addr, spi_rxdata[`FPGA_REG_DWIDTH-1:0]);
   cs = 1;
   mosi = 1'bz;
   clk = 0;
   #SPI_DELAY;
end
endtask : SPI_Read


initial begin : sim_main
    int i;

    usr_data16b = 0;

    cs = 1;
    // //SPI MODE = 3
    // clk = 1;
   //SPI MODE = 0
   clk = 0;
    mosi = 0;

    #10000;

    SPI_Read((`FPGA_RD_FIRMWARE_REV), 0);
    #300;

    usr_data16b = 32'hAA;
    SPI_Write(`FPGA_REG_TEST_ARRAY + 0, usr_data16b); $display("\usr_data16b = %04d", usr_data16b);
    #300;
    usr_data16b = 32'hBB;
    SPI_Write(`FPGA_REG_TEST_ARRAY + 1, usr_data16b); $display("\usr_data16b = %04d", usr_data16b);
    #300;
    usr_data16b = 32'hCC;
    SPI_Write(`FPGA_REG_TEST_ARRAY + 2, usr_data16b); $display("\usr_data16b = %04d", usr_data16b);
    #300;
    usr_data16b = 32'hDD;
    SPI_Write(`FPGA_REG_TEST_ARRAY + 3, usr_data16b); $display("\usr_data16b = %04d", usr_data16b);
    #300;

    #500;
    SPI_Read(`FPGA_REG_TEST_ARRAY + 0, 0);
    SPI_Read(`FPGA_REG_TEST_ARRAY + 1, 0);
    SPI_Read(`FPGA_REG_TEST_ARRAY + 2, 0);
    SPI_Read(`FPGA_REG_TEST_ARRAY + 3, 0);

    // do begin
    //     SPI_Read(`FPGA_REG_TEST_ARRAY + 0, 0);
    // end while (spi_rxdata[`FPGA_RD_REG_MEMTEST_STATUS_CALIB_DONE_BIT] != 1'b1);
    // $display("Wait memctrl colibration complete - Done");

    #500;


end : sim_main



endmodule : spi_master
