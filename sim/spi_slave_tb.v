//
//author: Golovachenko Viktor
//
`timescale 1ns / 1ps
module mdio_tb();

reg clk = 1;
always #20 clk = ~clk;

wire spi_cs  ;
wire spi_clk ;
wire spi_mosi;
wire spi_miso;

initial begin
    // $dumpfile("icarus/dump.fst");
    // $dumpvars;

    // $finish;
end

main_gold main (
    .qspi_cs  (),
    .qspi_mosi(),
    .qspi_miso(1'b1),
    .usr_spi_clk(spi_clk),
    .usr_spi_cs({spi_cs, 1'b1}),
    .usr_spi_mosi(spi_mosi),
    .usr_spi_miso(spi_miso),

    .mgt_pwr_en(),
    .dbg_led(),
    .dbg_out(),

    .sysclk25(clk)
);

spi_master  master (
    .spi_cs  (spi_cs  ),
    .spi_clk (spi_clk ),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso)
);

endmodule
