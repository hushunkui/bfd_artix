


`timescale 1ns / 1ps

module main #(
    parameter ETHCOUNT = 2, //max 4
    parameter SIM = 0
) (
    output mgt_pwr_en,

    input [13:0] usr_lvds_p,
    input [13:0] usr_lvds_n,

    output [(ETHCOUNT*4)-1:0] rgmii_txd   ,
    output [ETHCOUNT-1:0]     rgmii_tx_ctl,
    output [ETHCOUNT-1:0]     rgmii_txc   ,
    input  [(ETHCOUNT*4)-1:0] rgmii_rxd   ,
    input  [ETHCOUNT-1:0]     rgmii_rx_ctl,
    input  [ETHCOUNT-1:0]     rgmii_rxc   ,

    output [ETHCOUNT-1:0]     eth_phy_rst ,

    inout                     eth_phy_mdio,
    output                    eth_phy_mdc ,

    input  uart_rx,
    output uart_tx,

//    inout spi_clk ,
    inout spi_cs  ,
    inout spi_mosi,
    inout spi_miso,

    output dbg_led,
    output [1:0] dbg_out,

//    input mgt_ext_clk125_p,
//    input mgt_ext_clk125_n,
//    input mgt_clk125_p,
//    input mgt_clk125_n,
    input clk20_p,
    input clk20_n,

    input sysclk25
);

wire [63:0] probe;

wire [ETHCOUNT-1:0] mac_rx_axis_fr_good;
wire [ETHCOUNT-1:0] mac_rx_axis_fr_err;

wire [(ETHCOUNT*8)-1:0] mac_rx_axis_tdata ;
wire [ETHCOUNT-1:0]     mac_rx_axis_tvalid;
wire [ETHCOUNT-1:0]     mac_rx_axis_tlast ;
wire [ETHCOUNT-1:0]     mac_rx_axis_tuser ;
wire [ETHCOUNT-1:0]     mac_rx_aclk;
wire [ETHCOUNT-1:0]     mac_rx_reset;
wire [79:0]             mac_rx_cfg_vector;

wire [(ETHCOUNT*8)-1:0] mac_tx_axis_tdata ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_axis_tvalid;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_axis_tlast ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_axis_tuser ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_axis_tready;
wire [ETHCOUNT-1:0]     mac_tx_aclk;
wire [ETHCOUNT-1:0]     mac_tx_reset;
wire [79:0]             mac_tx_cfg_vector;

wire mac_gtx_clk;
wire mac_gtx_clk90;

wire sysrst;

assign sysrst = 1'b0;

assign eth_phy_mdio = 1'bz;
assign eth_phy_mdc = 1'b0;

wire [31:0] firmware_date;
wire [31:0] firmware_time;

firmware_rev revision (
   .firmware_date(firmware_date),
   .firmware_time(firmware_time)
);


wire [13:0] usr_lvds_i;
genvar i;
generate
    for (i=0; i < 14; i=i+1) begin
        IBUFDS usr_lvds_ibuf_diff (
            .I (usr_lvds_p[i]), .IB(usr_lvds_n[i]), .O(usr_lvds_i[i])
        );
    end
endgenerate


wire clk20_i;
wire clk20_g;
IBUFDS clk20_ibuf_diff (
    .I (clk20_p), .IB(clk20_n), .O(clk20_i)
);
BUFG clk20_bufg (
    .I(clk20_i), .O(clk20_g)
);


wire sysclk25_g;
BUFG sysclk25_bufg (
    .I(sysclk25), .O(sysclk25_g)
);

wire pll0_locked;
wire clk200M;
clk25_wiz0 pll0(
    .clk_out1(mac_gtx_clk),
    .clk_out2(mac_gtx_clk90),
    .clk_out3(),
    .clk_out4(clk200M),
    .locked(pll0_locked),
    .clk_in1(sysclk25_g),
    .reset(sysrst)
);



assign mgt_pwr_en = 1'b1;

assign uart_tx = uart_rx;

//assign  spi_clk  = 1'bz;
assign  spi_cs   = 1'bz;
assign  spi_mosi = 1'bz;
assign  spi_miso = 1'bz;

IDELAYCTRL idelayctrl (
    .RDY(),
    .REFCLK(clk200M),
    .RST(pll0_locked)
);

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = pll0_locked;
    end
endgenerate

wire dbg_mac0_rx_fr_good;
wire dbg_mac1_rx_fr_good;
mac_rgmii rgmii_0 (
    .status_o(),
    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(0*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[0]         ),
    .phy_rxc   (rgmii_rxc   [0]         ),
    .phy_txd   (rgmii_txd   [(0*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[0]         ),
    .phy_txc   (rgmii_txc   [0]         ),

    // logic side
    .mac_rx_data_o (mac_rx_axis_tdata [(0*8) +: 8]),
    .mac_rx_valid_o(mac_rx_axis_tvalid[0]         ),
    .mac_rx_sof_o  (mac_rx_axis_tuser [0]         ),
    .mac_rx_eof_o  (mac_rx_axis_tlast [0]         ),
    .mac_rx_fr_good_o(mac_rx_axis_fr_good[0]),
    .mac_rx_fr_err_o(mac_rx_axis_fr_err[0]),
    .mac_rx_clk_o  (),
    .dbg_mac_rx_fr_good(dbg_mac0_rx_fr_good),

    .mac_tx_data  (mac_rx_axis_tdata [(1*8) +: 8]),
    .mac_tx_valid (mac_rx_axis_tvalid[1]         ),
    .mac_tx_sof   (mac_rx_axis_tuser [1]         ),
    .mac_tx_eof   (mac_rx_axis_tlast [1]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~pll0_locked)
);

mac_rgmii rgmii_1 (
    .status_o(),
    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(1*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[1]         ),
    .phy_rxc   (rgmii_rxc   [1]         ),
    .phy_txd   (rgmii_txd   [(1*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[1]         ),
    .phy_txc   (rgmii_txc   [1]         ),

    // logic side
    .mac_rx_data_o (mac_rx_axis_tdata [(1*8) +: 8]),
    .mac_rx_valid_o(mac_rx_axis_tvalid[1]         ),
    .mac_rx_sof_o  (mac_rx_axis_tuser [1]         ),
    .mac_rx_eof_o  (mac_rx_axis_tlast [1]         ),
    .mac_rx_fr_good_o(mac_rx_axis_fr_good[1]),
    .mac_rx_fr_err_o(mac_rx_axis_fr_err[1]),
    .mac_rx_clk_o  (),
    .dbg_mac_rx_fr_good(dbg_mac1_rx_fr_good),

    .mac_tx_data  (mac_rx_axis_tdata [(0*8) +: 8]),
    .mac_tx_valid (mac_rx_axis_tvalid[0]         ),
    .mac_tx_sof   (mac_rx_axis_tuser [0]         ),
    .mac_tx_eof   (mac_rx_axis_tlast [0]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~pll0_locked)
);



//----------------------------------
//DEBUG
//----------------------------------
reg clk20_div = 1'b0;
always @(posedge clk20_g) begin
    clk20_div <= ~clk20_div;
end

reg sysclk25_div = 1'b0;
always @(posedge sysclk25_g) begin
    sysclk25_div <= ~sysclk25_div;
end

assign dbg_out[0] = |usr_lvds_i;
assign dbg_out[1] = |firmware_date &
                    |firmware_time &
                    clk20_div | sysclk25_div &
                    |mac_rx_axis_tdata &
                    |mac_rx_axis_tvalid &
                    |mac_rx_axis_tlast &
                    |mac_rx_axis_tuser &
                    |mac_rx_reset &
                    |mac_tx_axis_tready &
                    |mac_tx_aclk &
                    |mac_tx_reset
                    ;

// assign dbg_led = 1'b0;

fpga_test_01 #(
    .G_BLINK_T05(125),  // -- 1/2 ïåðèîäà ìèãàíèÿ ñâåòîäèîäà.(âðåìÿ â ms)
    .G_CLK_T05us(62) //(13) //-- êîë-âî ïåðèîäîâ ÷àñòîòû ïîðòà p_in_clk óêëàäûâàþùèåñÿ â 1/2 ïåðèîäà 1us
) test_led (
    .p_out_test_led (dbg_led),
    .p_out_test_done(),

    .p_out_1us  (),
    .p_out_1ms  (),
    .p_out_1s   (),

    .p_in_clken (1'b1),
    .p_in_clk   (mac_rx_aclk[0]), //(mac_gtx_clk),//(sysclk25),
    .p_in_rst   (~pll0_locked)
);




assign mac_tx_axis_tdata  = 0;
assign mac_tx_axis_tvalid = 0;
assign mac_tx_axis_tlast  = 0;
assign mac_tx_axis_tuser  = 0;

// assign probe[0] = mac_rx_axis_tdata [0];
// assign probe[1] = mac_rx_axis_tdata [1];
// assign probe[2] = mac_rx_axis_tdata [2];
// assign probe[3] = mac_rx_axis_tdata [3];
// assign probe[4] = mac_rx_axis_tdata [4];
// assign probe[5] = mac_rx_axis_tdata [5];
// assign probe[6] = mac_rx_axis_tdata [6];
// assign probe[7] = mac_rx_axis_tdata [7];
// assign probe[8] = mac_rx_axis_tvalid [0];
// assign probe[9] = mac_rx_axis_tuser [0];
// assign probe[10] = mac_rx_axis_tlast [0];
// assign probe[11] = mac_rx_axis_fr_good[0];
// assign probe[12] = mac_rx_axis_fr_err[0];
// assign probe[31:1] = 0;
// assign probe[63:32] = 0;

wire [7:0] mac0_rx_axis_tdata ;
wire       mac0_rx_axis_tvalid;
wire       mac0_rx_axis_tlast ;
wire       mac0_rx_axis_tuser ;
wire       mac0_rx_axis_fr_good;
wire       mac0_rx_axis_fr_err;

wire [7:0] mac1_rx_axis_tdata ;
wire       mac1_rx_axis_tvalid;
wire       mac1_rx_axis_tlast ;
wire       mac1_rx_axis_tuser ;
wire       mac1_rx_axis_fr_good;
wire       mac1_rx_axis_fr_err;

wire [7:0] mac2_rx_axis_tdata ;
wire       mac2_rx_axis_tvalid;
wire       mac2_rx_axis_tlast ;
wire       mac2_rx_axis_tuser ;
wire       mac2_rx_axis_fr_good;
wire       mac2_rx_axis_fr_err;

wire [7:0] mac3_rx_axis_tdata ;
wire       mac3_rx_axis_tvalid;
wire       mac3_rx_axis_tlast ;
wire       mac3_rx_axis_tuser ;
wire       mac3_rx_axis_fr_good;
wire       mac3_rx_axis_fr_err;

assign mac0_rx_axis_tdata   = mac_rx_axis_tdata[7:0];
assign mac0_rx_axis_tvalid  = mac_rx_axis_tvalid[0];
assign mac0_rx_axis_tuser   = mac_rx_axis_tuser[0];
assign mac0_rx_axis_tlast   = mac_rx_axis_tlast[0];
assign mac0_rx_axis_fr_good = mac_rx_axis_fr_good[0];
assign mac0_rx_axis_fr_err  = mac_rx_axis_fr_err[0];

assign mac1_rx_axis_tdata   = mac_rx_axis_tdata[15:8];
assign mac1_rx_axis_tvalid  = mac_rx_axis_tvalid[1];
assign mac1_rx_axis_tuser   = mac_rx_axis_tuser[1];
assign mac1_rx_axis_tlast   = mac_rx_axis_tlast[1];
assign mac1_rx_axis_fr_good = mac_rx_axis_fr_good[1];
assign mac1_rx_axis_fr_err  = mac_rx_axis_fr_err[1];

reg err_det = 1'b0;
reg mac0_rx_err_0 = 1'b0;
reg mac1_rx_err_0 = 1'b0;
reg mac0_rx_err = 1'b0;
reg mac1_rx_err = 1'b0;
always @(posedge mac_gtx_clk) begin
    mac0_rx_err_0 <= 1'b0;
    if (mac0_rx_axis_tlast & mac0_rx_axis_tvalid) begin
        mac0_rx_err_0 <= ~mac0_rx_axis_fr_good;
    end
    mac0_rx_err <= mac0_rx_err_0 | mac0_rx_axis_fr_err;

    mac1_rx_err_0 <= 1'b0;
    if (mac1_rx_axis_tlast & mac1_rx_axis_tvalid) begin
        mac1_rx_err_0 <= ~mac1_rx_axis_fr_good;
    end
    mac1_rx_err <= mac1_rx_err_0 | mac1_rx_axis_fr_err;

    err_det = mac0_rx_err | mac1_rx_err;
end

ila_0 dbg_ila (
    .probe0({
        mac0_rx_err_0,
        mac0_rx_err,
        mac1_rx_err_0,
        mac1_rx_err,
        err_det,

        dbg_mac1_rx_fr_good,
        mac_rx_axis_tdata[15:8],
        mac_rx_axis_tvalid[1],
        mac_rx_axis_tuser[1],
        mac_rx_axis_tlast[1],
        mac_rx_axis_fr_good[1],
        mac_rx_axis_fr_err[1],

        dbg_mac0_rx_fr_good,
        mac_rx_axis_tdata[7:0],
        mac_rx_axis_tvalid[0],
        mac_rx_axis_tuser[0],
        mac_rx_axis_tlast[0],
        mac_rx_axis_fr_good[0],
        mac_rx_axis_fr_err[0]
    }),
    .clk(mac_gtx_clk) //(mac_rx_aclk[0]) //
);

    // .probe0({
    //     mac1_rx_axis_tdata,
    //     mac1_rx_axis_tvalid,
    //     mac1_rx_axis_tuser,
    //     mac1_rx_axis_tlast,
    //     mac1_rx_axis_fr_good,
    //     mac1_rx_axis_fr_err,

    //     mac0_rx_axis_tdata,
    //     mac0_rx_axis_tvalid,
    //     mac0_rx_axis_tuser,
    //     mac0_rx_axis_tlast,
    //     mac0_rx_axis_fr_good,
    //     mac0_rx_axis_fr_err
    // }),\


endmodule

