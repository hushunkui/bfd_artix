


`timescale 1ns / 1ps

module main #(
    parameter ETHCOUNT = 4, //max 4
    parameter SIM = 0
) (
    output mgt_pwr_en,

    output [13:0] usr_lvds_p,
    output [13:0] usr_lvds_n,

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

wire [ETHCOUNT-1:0] mac_rx_fr_good;
wire [ETHCOUNT-1:0] mac_rx_fr_err;
wire [ETHCOUNT-1:0] mac_rx_fr_good_dbg;
wire [ETHCOUNT-1:0] mac_rx_fr_bad;

wire [(ETHCOUNT*8)-1:0] mac_rx_tdata ;
wire [ETHCOUNT-1:0]     mac_rx_tvalid;
wire [ETHCOUNT-1:0]     mac_rx_tlast ;
wire [ETHCOUNT-1:0]     mac_rx_tuser ;
wire [ETHCOUNT-1:0]     mac_rx_clk;
wire [ETHCOUNT-1:0]     mac_rx_reset;

wire [(ETHCOUNT*8)-1:0] mac_tx_tdata ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tvalid;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tlast ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tuser ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tready;
wire [ETHCOUNT-1:0]     mac_tx_clk;
wire [ETHCOUNT-1:0]     mac_tx_reset;

wire [(ETHCOUNT*4)-1:0] mac_fifo_status;
wire [(ETHCOUNT*4)-1:0] mac_status;

wire mac_gtx_clk;
wire mac_gtx_clk90;


// wire [31:0] firmware_date;
// wire [31:0] firmware_time;

wire [31:0] M_AXI_0_awaddr ;
wire [2:0]  M_AXI_0_awprot ;
wire        M_AXI_0_awready;
wire        M_AXI_0_awvalid;
wire [31:0] M_AXI_0_wdata  ;
wire [3:0]  M_AXI_0_wstrb  ;
wire        M_AXI_0_wvalid ;
wire        M_AXI_0_wready ;
wire [1:0]  M_AXI_0_bresp  ;
wire        M_AXI_0_bvalid ;
wire        M_AXI_0_bready ;

wire [31:0] M_AXI_0_araddr ;
wire [2:0]  M_AXI_0_arprot ;
wire        M_AXI_0_arready;
wire        M_AXI_0_arvalid;
wire [31:0] M_AXI_0_rdata  ;
wire        M_AXI_0_rvalid ;
wire [1:0]  M_AXI_0_rresp  ;
wire        M_AXI_0_rready ;

wire [0:0] test_gpio;
wire [31:0] reg_ctrl;
wire test_err;




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

wire sysrst;
assign sysrst = 1'b0;

wire mac_pll_locked;
wire clk200M;
clk25_wiz0 pll0(
    .clk_out1(mac_gtx_clk),
    .clk_out2(mac_gtx_clk90),
    .clk_out3(),
    .clk_out4(clk200M),
    .locked(mac_pll_locked),
    .clk_in1(sysclk25_g),
    .reset(sysrst)
);

system system_i(
    .M_AXI_0_awaddr  (M_AXI_0_awaddr ),
    .M_AXI_0_awprot  (M_AXI_0_awprot ),
    .M_AXI_0_awready (M_AXI_0_awready),
    .M_AXI_0_awvalid (M_AXI_0_awvalid),
    .M_AXI_0_wdata   (M_AXI_0_wdata  ),
    .M_AXI_0_wstrb   (M_AXI_0_wstrb  ),
    .M_AXI_0_wvalid  (M_AXI_0_wvalid ),
    .M_AXI_0_wready  (M_AXI_0_wready ),
    .M_AXI_0_bresp   (M_AXI_0_bresp  ),
    .M_AXI_0_bvalid  (M_AXI_0_bvalid ),
    .M_AXI_0_bready  (M_AXI_0_bready ),

    .M_AXI_0_araddr  (M_AXI_0_araddr ),
    .M_AXI_0_arprot  (M_AXI_0_arprot ),
    .M_AXI_0_arready (M_AXI_0_arready),
    .M_AXI_0_arvalid (M_AXI_0_arvalid),
    .M_AXI_0_rdata   (M_AXI_0_rdata  ),
    .M_AXI_0_rvalid  (M_AXI_0_rvalid ),
    .M_AXI_0_rresp   (M_AXI_0_rresp  ),
    .M_AXI_0_rready  (M_AXI_0_rready ),

    .aclk(mac_gtx_clk),
    .areset_n(mac_pll_locked)
);

usr_logic #(
    .SIM (SIM)
) m_usr (
//user part
    .test_gpio (test_gpio),
    .reg_ctrl (reg_ctrl),

//AXI interface
    .s_axi_awaddr  (M_AXI_0_awaddr ),
    .s_axi_awprot  (M_AXI_0_awprot ),
    .s_axi_awready (M_AXI_0_awready),
    .s_axi_awvalid (M_AXI_0_awvalid),
    .s_axi_wdata   (M_AXI_0_wdata  ),
    .s_axi_wstrb   (M_AXI_0_wstrb  ),
    .s_axi_wvalid  (M_AXI_0_wvalid ),
    .s_axi_wready  (M_AXI_0_wready ),
    .s_axi_bresp   (M_AXI_0_bresp  ),
    .s_axi_bvalid  (M_AXI_0_bvalid ),
    .s_axi_bready  (M_AXI_0_bready ),

    .s_axi_araddr  (M_AXI_0_araddr ),
    .s_axi_arprot  (M_AXI_0_arprot ),
    .s_axi_arready (M_AXI_0_arready),
    .s_axi_arvalid (M_AXI_0_arvalid),
    .s_axi_rdata   (M_AXI_0_rdata  ),
    .s_axi_rvalid  (M_AXI_0_rvalid ),
    .s_axi_rresp   (M_AXI_0_rresp  ),
    .s_axi_rready  (M_AXI_0_rready ),

    .s_axi_resetn (mac_pll_locked),
    .s_axi_clk (mac_gtx_clk)
);

assign mgt_pwr_en = 1'b1;

assign uart_tx = uart_rx;

//assign  spi_clk  = 1'bz;
assign  spi_cs   = 1'bz;
assign  spi_mosi = 1'bz;
assign  spi_miso = 1'bz;

assign eth_phy_mdio = 1'bz;
assign eth_phy_mdc = 1'b0;

wire [13:0] usr_lvds_io;
genvar i;
generate
    for (i=0; i < 14; i=i+1) begin
        // IBUFDS usr_lvds_ibuf_diff (
        //     .I (usr_lvds_p[i]), .IB(usr_lvds_n[i]), .O(usr_lvds_io[i])
        // );
        OBUFDS usr_lvds_obuf_diff (
            .O (usr_lvds_p[i]), .OB(usr_lvds_n[i]), .I(usr_lvds_io[i])
        );
    end
endgenerate

wire [13:0] usr_lvds;
assign usr_lvds_io = usr_lvds;
assign usr_lvds = 14'h2AAA;
// always @(posedge mac_gtx_clk) begin
//     usr_lvds_io <= usr_lvds_io + 1;
// end


IDELAYCTRL idelayctrl (
    .RDY(),
    .REFCLK(clk200M),
    .RST(mac_pll_locked)
);

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = mac_pll_locked;
    end
endgenerate


mac_rgmii rgmii_0 (
    .status_o(mac_status[(0*4) +: 4]),
    .fifo_status(mac_fifo_status[(0*4) +: 4]),
    .dbg_fifo_rd(),

    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(0*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[0]         ),
    .phy_rxc   (rgmii_rxc   [0]         ),
    .phy_txd   (rgmii_txd   [(0*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[0]         ),
    .phy_txc   (rgmii_txc   [0]         ),

    // logic side
    .mac_rx_data_o   (mac_rx_tdata [(0*8) +: 8]),
    .mac_rx_valid_o  (mac_rx_tvalid[0]         ),
    .mac_rx_sof_o    (mac_rx_tuser [0]         ),
    .mac_rx_eof_o    (mac_rx_tlast [0]         ),
    .mac_rx_fr_good_o(mac_rx_fr_good[0]),
    .mac_rx_fr_err_o (mac_rx_fr_err[0]),
    .mac_rx_fr_bad_o (mac_rx_fr_bad[0]),
    .mac_rx_clk_o    (mac_rx_clk[0]),
    .dbg_mac_rx_fr_good(mac_rx_fr_good_dbg[0]),

    .mac_tx_data  (mac_rx_tdata [(1*8) +: 8]),
    .mac_tx_valid (mac_rx_tvalid[1]         ),
    .mac_tx_sof   (mac_rx_tuser [1]         ),
    .mac_tx_eof   (mac_rx_tlast [1]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~mac_pll_locked)
);

mac_rgmii rgmii_1 (
    .status_o(mac_status[(1*4) +: 4]),
    .fifo_status(mac_fifo_status[(1*4) +: 4]),
    .dbg_fifo_rd(),

    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(1*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[1]         ),
    .phy_rxc   (rgmii_rxc   [1]         ),
    .phy_txd   (rgmii_txd   [(1*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[1]         ),
    .phy_txc   (rgmii_txc   [1]         ),

    // logic side
    .mac_rx_data_o   (mac_rx_tdata [(1*8) +: 8]),
    .mac_rx_valid_o  (mac_rx_tvalid[1]         ),
    .mac_rx_sof_o    (mac_rx_tuser [1]         ),
    .mac_rx_eof_o    (mac_rx_tlast [1]         ),
    .mac_rx_fr_good_o(mac_rx_fr_good[1]),
    .mac_rx_fr_err_o (mac_rx_fr_err[1]),
    .mac_rx_fr_bad_o (mac_rx_fr_bad[1]),
    .mac_rx_clk_o    (mac_rx_clk[1]),
    .dbg_mac_rx_fr_good(mac_rx_fr_good_dbg[1]),

    .mac_tx_data  (mac_rx_tdata [(0*8) +: 8]),
    .mac_tx_valid (mac_rx_tvalid[0]         ),
    .mac_tx_sof   (mac_rx_tuser [0]         ),
    .mac_tx_eof   (mac_rx_tlast [0]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~mac_pll_locked)
);

mac_rgmii rgmii_2 (
    .status_o(mac_status[(2*4) +: 4]),
    .fifo_status(mac_fifo_status[(2*4) +: 4]),
    .dbg_fifo_rd(),

    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(2*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[2]         ),
    .phy_rxc   (rgmii_rxc   [2]         ),
    .phy_txd   (rgmii_txd   [(2*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[2]         ),
    .phy_txc   (rgmii_txc   [2]         ),

    // logic side
    .mac_rx_data_o   (),
    .mac_rx_valid_o  (),
    .mac_rx_sof_o    (),
    .mac_rx_eof_o    (),
    .mac_rx_fr_good_o(),
    .mac_rx_fr_err_o (),
    .mac_rx_fr_bad_o (),
    .mac_rx_clk_o    (),
    .dbg_mac_rx_fr_good(),

    .mac_tx_data  (mac_rx_tdata [(2*8) +: 8]),
    .mac_tx_valid (mac_rx_tvalid[2]         ),
    .mac_tx_sof   (mac_rx_tuser [2]         ),
    .mac_tx_eof   (mac_rx_tlast [2]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~mac_pll_locked)
);

wire dbg_fifo_rd;
mac_rgmii rgmii_3 (
    .status_o(mac_status[(3*4) +: 4]),
    .fifo_status(mac_fifo_status[(3*4) +: 4]),
    .dbg_fifo_rd(dbg_fifo_rd),

    // phy side (RGMII)
    .phy_rxd   (rgmii_rxd   [(3*4) +: 4]),
    .phy_rx_ctl(rgmii_rx_ctl[3]         ),
    .phy_rxc   (rgmii_rxc   [3]         ),
    .phy_txd   (rgmii_txd   [(3*4) +: 4]),
    .phy_tx_ctl(rgmii_tx_ctl[3]         ),
    .phy_txc   (rgmii_txc   [3]         ),

    // logic side
    .mac_rx_data_o   (mac_rx_tdata [(3*8) +: 8]),
    .mac_rx_valid_o  (mac_rx_tvalid[3]         ),
    .mac_rx_sof_o    (mac_rx_tuser [3]         ),
    .mac_rx_eof_o    (mac_rx_tlast [3]         ),
    .mac_rx_fr_good_o(mac_rx_fr_good[3]),
    .mac_rx_fr_err_o (mac_rx_fr_err[3]),
    .mac_rx_fr_bad_o (mac_rx_fr_bad[3]),
    .mac_rx_clk_o    (mac_rx_clk[3]),
    .dbg_mac_rx_fr_good(mac_rx_fr_good_dbg[3]),

    .mac_tx_data  (0   ),//(mac_rx_axis_tdata [(2*8) +: 8]),
    .mac_tx_valid (1'b0),//(mac_rx_axis_tvalid[2]         ),
    .mac_tx_sof   (1'b0),//(mac_rx_axis_tuser [2]         ),
    .mac_tx_eof   (1'b0),//(mac_rx_axis_tlast [2]         ),
    .mac_tx_clk_90(mac_gtx_clk90),
    .mac_tx_clk   (mac_gtx_clk),

    .rst(~mac_pll_locked)
);

wire [7:0] test_data;
test_phy test_phy (
    .mac_tx_data  (mac_rx_tdata [(2*8) +: 8]),
    .mac_tx_valid (mac_rx_tvalid[2]         ),
    .mac_tx_sof   (mac_rx_tuser [2]         ),
    .mac_tx_eof   (mac_rx_tlast [2]         ),

    .mac_rx_data   (mac_rx_tdata [(3*8) +: 8]),
    .mac_rx_valid  (mac_rx_tvalid[3]         ),
    .mac_rx_sof    (mac_rx_tuser [3]         ),
    .mac_rx_eof    (mac_rx_tlast [3]         ),
    .mac_rx_fr_good(mac_rx_fr_good[3]),
    .mac_rx_fr_err (mac_rx_fr_err[3]),

    .start(reg_ctrl[0]),
    .err(test_err),
    .test_data(test_data),

    .clk(mac_gtx_clk),
    .rst(~mac_pll_locked)
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

assign dbg_out[0] = 1'b0;
assign dbg_out[1] = clk20_div | sysclk25_div &
                    |mac_rx_tdata &
                    |mac_rx_tvalid &
                    |mac_rx_tlast &
                    |mac_rx_tuser &
                    |mac_rx_reset &
                    |mac_tx_tready &
                    |mac_tx_clk &
                    |mac_tx_reset
                    ;

// assign dbg_led = 1'b0;

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
    .p_in_clk   (mac_gtx_clk), //(mac_gtx_clk),//(sysclk25),
    .p_in_rst   (~mac_pll_locked)
);

assign dbg_led = led_blink & !test_gpio[0];



// assign mac_tx_axis_tdata  = 0;
// assign mac_tx_axis_tvalid = 0;
// assign mac_tx_axis_tlast  = 0;
// assign mac_tx_axis_tuser  = 0;

// wire [7:0] mac0_rx_axis_tdata ;
// wire       mac0_rx_axis_tvalid;
// wire       mac0_rx_axis_tlast ;
// wire       mac0_rx_axis_tuser ;
// wire       mac0_rx_axis_fr_good;
// wire       mac0_rx_axis_fr_err;
// wire       mac0_rx_fr_good_dbg;

// wire [7:0] mac1_rx_axis_tdata ;
// wire       mac1_rx_axis_tvalid;
// wire       mac1_rx_axis_tlast ;
// wire       mac1_rx_axis_tuser ;
// wire       mac1_rx_axis_fr_good;
// wire       mac1_rx_axis_fr_err;
// wire       mac1_rx_fr_good_dbg;

// wire [7:0] mac2_rx_axis_tdata ;
// wire       mac2_rx_axis_tvalid;
// wire       mac2_rx_axis_tlast ;
// wire       mac2_rx_axis_tuser ;
// wire       mac2_rx_axis_fr_good;
// wire       mac2_rx_axis_fr_err;
// wire       mac2_rx_fr_good_dbg;

// wire [7:0] mac3_rx_axis_tdata ;
// wire       mac3_rx_axis_tvalid;
// wire       mac3_rx_axis_tlast ;
// wire       mac3_rx_axis_tuser ;
// wire       mac3_rx_axis_fr_good;
// wire       mac3_rx_axis_fr_err;
// wire       mac3_rx_fr_good_dbg;

// assign mac0_rx_axis_tdata   = mac_rx_axis_tdata[(2*8) +: 8];
// assign mac0_rx_axis_tvalid  = mac_rx_axis_tvalid[2];
// assign mac0_rx_axis_tuser   = mac_rx_axis_tuser[2];
// assign mac0_rx_axis_tlast   = mac_rx_axis_tlast[2];
// assign mac0_rx_axis_fr_good = mac_rx_axis_fr_good[2];
// assign mac0_rx_axis_fr_err  = mac_rx_axis_fr_err[2];
// assign mac0_rx_fr_good_dbg  = mac_rx_fr_good_dbg[2];

// assign mac1_rx_axis_tdata   = mac_rx_axis_tdata[(3*8) +: 8];
// assign mac1_rx_axis_tvalid  = mac_rx_axis_tvalid[3];
// assign mac1_rx_axis_tuser   = mac_rx_axis_tuser[3];
// assign mac1_rx_axis_tlast   = mac_rx_axis_tlast[3];
// assign mac1_rx_axis_fr_good = mac_rx_axis_fr_good[3];
// assign mac1_rx_axis_fr_err  = mac_rx_axis_fr_err[3];
// assign mac1_rx_fr_good_dbg  = mac_rx_fr_good_dbg[3];

// reg err_det = 1'b0;
// reg mac0_rx_err_0 = 1'b0;
// reg mac1_rx_err_0 = 1'b0;
// reg mac0_rx_err = 1'b0;
// reg mac1_rx_err = 1'b0;
// always @(posedge mac_gtx_clk) begin
//     mac0_rx_err_0 <= 1'b0;
//     if (mac0_rx_axis_tlast & mac0_rx_axis_tvalid) begin
//         mac0_rx_err_0 <= ~mac0_rx_axis_fr_good;
//     end
//     mac0_rx_err <= mac0_rx_err_0 | mac0_rx_axis_fr_err;
//     err_det = mac0_rx_err;

//     mac1_rx_err_0 <= 1'b0;
//     if (mac1_rx_axis_tlast & mac1_rx_axis_tvalid) begin
//         mac1_rx_err_0 <= ~mac1_rx_axis_fr_good;
//     end
//     mac1_rx_err <= mac1_rx_err_0 | mac1_rx_axis_fr_err;

//     err_det = mac0_rx_err | mac1_rx_err;
// end

// ila_0 dbg_ila (
//     .probe0({
//         dbg_fifo_rd,
//         mac_fifo_status[(3*4) +: 4],
//         test_data,
//         reg_ctrl[0],
//         test_err,

//         mac0_rx_err_0,
//         mac0_rx_err,
//         err_det,

//         mac1_rx_err_0,
//         mac1_rx_err,
//         mac1_rx_fr_good_dbg,
//         mac1_rx_axis_tdata,
//         mac1_rx_axis_tvalid,
//         mac1_rx_axis_tuser,
//         mac1_rx_axis_tlast,
//         mac1_rx_axis_fr_good,
//         mac1_rx_axis_fr_err,

//         mac0_rx_fr_good_dbg,
//         mac0_rx_axis_tdata,
//         mac0_rx_axis_tvalid,
//         mac0_rx_axis_tuser,
//         mac0_rx_axis_tlast,
//         mac0_rx_axis_fr_good,
//         mac0_rx_axis_fr_err
//     }),
//     .clk(mac_gtx_clk) //(mac_rx_aclk[0]) //
// );


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

