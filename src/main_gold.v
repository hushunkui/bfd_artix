
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

module main_gold #(
    parameter ETHCOUNT = 4, //max 4
    parameter SIM = 0
) (
    // input [13:0] usr_lvds_p,
    // input [13:0] usr_lvds_n,

//    inout spi_clk ,
    inout spi_cs  ,
    inout spi_mosi,
    inout spi_miso,

    output mgt_pwr_en,
    output dbg_led,

    input sysclk25
);

assign mgt_pwr_en = 1'b0;

wire sysclk25_g;
BUFG sysclk25_bufg (
    .I(sysclk25), .O(sysclk25_g)
);

//----------------------------------
//DEBUG
//----------------------------------
wire led_blink;
fpga_test_01 #(
    .G_BLINK_T05(125),  // -- 1/2 ïåðèîäà ìèãàíèÿ ñâåòîäèîäà.(âðåìÿ â ms)
    .G_CLK_T05us(62) //(13) //-- êîë-âî ïåðèîäîâ ÷àñòîòû ïîðòà p_in_clk óêëàäûâàþùèåñÿ â 1/2 ïåðèîäà 1us
) test_led (
    .p_out_test_led (led_blink),
    .p_out_test_done(),

    .p_out_1us  (),
    .p_out_1ms  (),
    .p_out_1s   (),

    .p_in_clken (1'b1),
    .p_in_clk   (sysclk25_g),
    .p_in_rst   (1'b0)
);

assign dbg_led = led_blink;



endmodule
