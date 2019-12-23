
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

module main #(
    parameter ETHCOUNT = 4, //max 4
    parameter AURORA_CHCOUNT = 1,
    parameter AURORA_LANE_COUNT = 2,
    parameter SIM = 0
) (
    // input [13:0] usr_lvds_p,
    // input [13:0] usr_lvds_n,
    input [9:0] usr_lvds_p,

    output [(ETHCOUNT*4)-1:0] rgmii_txd   ,
    output [ETHCOUNT-1:0]     rgmii_tx_ctl,
    output [ETHCOUNT-1:0]     rgmii_txc   ,
    input  [(ETHCOUNT*4)-1:0] rgmii_rxd   ,
    input  [ETHCOUNT-1:0]     rgmii_rx_ctl,
    input  [ETHCOUNT-1:0]     rgmii_rxc   ,

    output [ETHCOUNT-1:0]     eth_phy_rst ,

    inout                     eth_phy_mdio,
    output                    eth_phy_mdc ,

    input [0:(AURORA_CHCOUNT*AURORA_LANE_COUNT)-1] gt_rx_rxn,
    input [0:(AURORA_CHCOUNT*AURORA_LANE_COUNT)-1] gt_rx_rxp,
    output [0:(AURORA_CHCOUNT*AURORA_LANE_COUNT)-1] gt_tx_txn,
    output [0:(AURORA_CHCOUNT*AURORA_LANE_COUNT)-1] gt_tx_txp,
    input gt_refclk_n,
    input gt_refclk_p,
    output mgt_pwr_en,
    // input mgt_refclk_n,
    // input mgt_refclk_p,

    input  uart_rx,
    output uart_tx,

//    inout spi_clk ,
    inout spi_cs  ,
    inout spi_mosi,
    inout spi_miso,

    output dbg_led,
    output [1:0] dbg_out,

    input clk20_p,
    input clk20_n,

    input sysclk25
);

wire [63:0] probe;

wire [ETHCOUNT-1:0] mac_rx_ok;
wire [ETHCOUNT-1:0] mac_rx_bd;
wire [ETHCOUNT-1:0] mac_rx_er;
wire [ETHCOUNT-1:0] mac_rx_fr_good_dbg;

wire [7:0]              mac_rx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     mac_rx_tvalid;
wire [ETHCOUNT-1:0]     mac_rx_tlast ;
wire [ETHCOUNT-1:0]     mac_rx_tuser ;
wire [ETHCOUNT-1:0]     mac_rx_clk;
wire [ETHCOUNT-1:0]     mac_rx_nreset;

wire [7:0]              mac_tx_tdata [ETHCOUNT-1:0];// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tvalid;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tlast ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tuser ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tready;
wire [ETHCOUNT-1:0]     mac_tx_clk;
wire [ETHCOUNT-1:0]     mac_tx_reset;

wire [ETHCOUNT-1:0]     mac_fifo_resetn;

// wire [3:0] mac_fifo_status [ETHCOUNT-1:0];
wire [3:0] mac_status [ETHCOUNT-1:0];

wire [7:0]              usr_rx_tdata  [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     usr_rx_tvalid;
wire [ETHCOUNT-1:0]     usr_rx_tlast ;

wire [3:0]              rx_fifo_status  [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     rx_fifo_overflow;

wire [7:0]              test_tx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     test_tx_tvalid;
wire [ETHCOUNT-1:0]     test_tx_tuser ;
wire [ETHCOUNT-1:0]     test_tx_tlast ;

wire [7:0]              test_rx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     test_rx_tvalid;
wire [ETHCOUNT-1:0]     test_rx_tuser ;
wire [ETHCOUNT-1:0]     test_rx_tlast ;

wire mac_gtx_clk;
wire mac_gtx_clk90;


// wire [31:0] firmware_date;
// wire [31:0] firmware_time;
wire [31:0] aurora_axi_rx_tdata [AURORA_CHCOUNT-1:0];
wire [3:0] aurora_axi_rx_tkeep [AURORA_CHCOUNT-1:0];
wire [AURORA_CHCOUNT-1:0] aurora_axi_rx_tlast;
wire [AURORA_CHCOUNT-1:0] aurora_axi_rx_tvalid;
wire [31:0]aurora_axi_tx_tdata [AURORA_CHCOUNT-1:0];
wire [3:0]aurora_axi_tx_tkeep [AURORA_CHCOUNT-1:0];
genvar i;
generate
    for (i=0; i < AURORA_CHCOUNT; i=i+1) begin
        assign aurora_axi_tx_tkeep[i] = 4'h1;
    end
endgenerate
wire [AURORA_CHCOUNT-1:0] aurora_axi_tx_tlast;
wire [AURORA_CHCOUNT-1:0] aurora_axi_tx_tready;
wire [AURORA_CHCOUNT-1:0] aurora_axi_tx_tvalid;
wire [AURORA_CHCOUNT-1:0] aurora_status_channel_up;
wire [AURORA_CHCOUNT-1:0] aurora_status_frame_err;
wire [AURORA_CHCOUNT-1:0] aurora_status_hard_err;
wire [0:0] aurora_status_lane_up [AURORA_CHCOUNT-1:0];
wire [AURORA_CHCOUNT-1:0] aurora_status_rx_resetdone_out;
wire [AURORA_CHCOUNT-1:0] aurora_status_soft_err;
wire [AURORA_CHCOUNT-1:0] aurora_status_tx_lock;
wire [AURORA_CHCOUNT-1:0] aurora_status_tx_resetdone_out;
// wire [8:0] aurora_drp_if_daddr  [AURORA_CHCOUNT-1:0];
// wire [AURORA_CHCOUNT-1:0] aurora_drp_if_den;
// wire [15:0] aurora_drp_if_di [AURORA_CHCOUNT-1:0];
// wire [15:0] aurora_drp_if_do [AURORA_CHCOUNT-1:0];
// wire [AURORA_CHCOUNT-1:0] aurora_drp_if_drdy;
// wire [AURORA_CHCOUNT-1:0] aurora_drp_if_dwe;

wire [31:0] aurora_axi_rx_tdata_eth [ETHCOUNT-1:0];
wire [3:0] aurora_axi_rx_tkeep_eth [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0] aurora_axi_rx_tlast_eth;
wire [ETHCOUNT-1:0] aurora_axi_rx_tvalid_eth;
wire [31:0]aurora_axi_tx_tdata_eth [ETHCOUNT-1:0];
wire [3:0]aurora_axi_tx_tkeep_eth [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0] aurora_axi_tx_tlast_eth;
wire [ETHCOUNT-1:0] aurora_axi_tx_tready_eth;
wire [ETHCOUNT-1:0] aurora_axi_tx_tvalid_eth;
wire [ETHCOUNT-1:0] aurora_status_channel_up_eth;
wire [ETHCOUNT-1:0] aurora_status_frame_err_eth;
wire [ETHCOUNT-1:0] aurora_status_hard_err_eth;
wire [0:0] aurora_status_lane_up_eth [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0] aurora_status_rx_resetdone_out_eth;
wire [ETHCOUNT-1:0] aurora_status_soft_err_eth;
wire [ETHCOUNT-1:0] aurora_status_tx_lock_eth;
wire [ETHCOUNT-1:0] aurora_status_tx_resetdone_out_eth;

wire aurora_control_pwd;
wire gt_rst;
wire aurora_rst;
wire aurora_usr_clk;

wire [1:0] sel_eth_ch;
wire  sel_aurora_ch;

wire [31:0] aurora_fifo_di;
wire [31:0] aurora_fifo_do;

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

// IBUFDS_GTE2 #(
//     .CLKCM_CFG("TRUE"),   // Refer to Transceiver User Guide
//     .CLKRCV_TRST("TRUE"), // Refer to Transceiver User Guide
//     .CLKSWING_CFG(2'b11)  // Refer to Transceiver User Guide
// ) gtrefclk_buf (
//     .O(gt_refclk), // 1-bit output: Refer to Transceiver User Guide
//     .ODIV2(aurora_init_clk), // 1-bit output: Refer to Transceiver User Guide
//     .CEB(1'b0),          // 1-bit input: Refer to Transceiver User Guide
//     .I(gt_refclk_p),  // 1-bit input: Refer to Transceiver User Guide
//     .IB(gt_refclk_n)  // 1-bit input: Refer to Transceiver User Guide
// );
// BUFG bufg_gtrefclk_div2 (
//     .I (aurora_init_clk), .O(aurora_init_clkg)
// );

system system_i(
    .aurora0_axi_rx_tdata(aurora_axi_rx_tdata[0]), //output
    .aurora0_axi_rx_tkeep(aurora_axi_rx_tkeep[0]), //output
    .aurora0_axi_rx_tvalid(aurora_axi_rx_tvalid[0]),//output
    .aurora0_axi_rx_tlast(aurora_axi_rx_tlast[0]), //output
    .aurora0_axi_tx_tready(aurora_axi_tx_tready[0]),//output
    .aurora0_axi_tx_tdata(aurora_axi_tx_tdata[0]), //input
    .aurora0_axi_tx_tkeep(aurora_axi_tx_tkeep[0]), //input
    .aurora0_axi_tx_tvalid(aurora_axi_tx_tvalid[0]), //input
    .aurora0_axi_tx_tlast(aurora_axi_tx_tlast[0]), //input
    .aurora0_control_power_down(aurora_control_pwd),
    .aurora0_status_lane_up(aurora_status_lane_up[0]),
    .aurora0_status_channel_up(aurora_status_channel_up[0]),
    .aurora0_status_frame_err(aurora_status_frame_err[0]),
    .aurora0_status_hard_err(aurora_status_hard_err[0]),
    .aurora0_status_soft_err(aurora_status_soft_err[0]),
    .aurora0_status_tx_lock(aurora_status_tx_lock[0]),
    .aurora0_status_tx_resetdone_out(aurora_status_tx_resetdone_out[0]),
    .aurora0_status_rx_resetdone_out(aurora_status_rx_resetdone_out[0]),
    .aurora0_gt_rx_rxn(gt_rx_rxn[0:1]),
    .aurora0_gt_rx_rxp(gt_rx_rxp[0:1]),
    .aurora0_gt_tx_txn(gt_tx_txn[0:1]),
    .aurora0_gt_tx_txp(gt_tx_txp[0:1]),

    // .aurora1_axi_rx_tdata(aurora_axi_rx_tdata[1]), //output
    // .aurora1_axi_rx_tkeep(aurora_axi_rx_tkeep[1]), //output
    // .aurora1_axi_rx_tvalid(aurora_axi_rx_tvalid[1]),//output
    // .aurora1_axi_rx_tlast(aurora_axi_rx_tlast[1]), //output
    // .aurora1_axi_tx_tready(aurora_axi_tx_tready[1]),//output
    // .aurora1_axi_tx_tdata(aurora_axi_tx_tdata[1]), //input
    // .aurora1_axi_tx_tkeep(aurora_axi_tx_tkeep[1]), //input
    // .aurora1_axi_tx_tvalid(aurora_axi_tx_tvalid[1]), //input
    // .aurora1_axi_tx_tlast(aurora_axi_tx_tlast[1]), //input
    // .aurora1_control_power_down(aurora_control_pwd),
    // .aurora1_status_lane_up(aurora_status_lane_up[1]),
    // .aurora1_status_channel_up(aurora_status_channel_up[1]),
    // .aurora1_status_frame_err(aurora_status_frame_err[1]),
    // .aurora1_status_hard_err(aurora_status_hard_err[1]),
    // .aurora1_status_soft_err(aurora_status_soft_err[1]),
    // .aurora1_status_tx_lock(aurora_status_tx_lock[1]),
    // .aurora1_status_tx_resetdone_out(aurora_status_tx_resetdone_out[1]),
    // .aurora1_status_rx_resetdone_out(aurora_status_rx_resetdone_out[1]),
    // .aurora1_gt_rx_rxn(gt_rx_rxn[1:1]),
    // .aurora1_gt_rx_rxp(gt_rx_rxp[1:1]),
    // .aurora1_gt_tx_txn(gt_tx_txn[1:1]),
    // .aurora1_gt_tx_txp(gt_tx_txp[1:1]),

    .aurora_gt_refclk_clk_n(gt_refclk_n),//(mgt_refclk_n),//
    .aurora_gt_refclk_clk_p(gt_refclk_p),//(mgt_refclk_p),//
    .aurora_gt_rst(gt_rst),
    .aurora_init_clk(mac_gtx_clk),
    .aurora_rst(aurora_rst),
    .aurora_usr_clk(aurora_usr_clk),

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


// assign aurora_axi_tx_tdata  = aurora_axi_rx_tdata ;
// assign aurora_axi_tx_tkeep  = aurora_axi_rx_tkeep ;
// assign aurora_axi_tx_tvalid = aurora_axi_rx_tvalid;
// assign aurora_axi_tx_tlast  = aurora_axi_rx_tlast ;

// assign aurora_fifo_di[0] = aurora_axi_rx_tdata[0];
// assign aurora_fifo_di[1] = aurora_axi_rx_tdata[1];
// assign aurora_fifo_di[2] = aurora_axi_rx_tdata[2];
// assign aurora_fifo_di[3] = aurora_axi_rx_tdata[3];
// assign aurora_fifo_di[4] = aurora_axi_rx_tdata[4];
// assign aurora_fifo_di[5] = aurora_axi_rx_tdata[5];
// assign aurora_fifo_di[6] = aurora_axi_rx_tdata[6];
// assign aurora_fifo_di[7] = aurora_axi_rx_tdata[7];
// assign aurora_fifo_di[8] = aurora_axi_rx_tdata[8];
// assign aurora_fifo_di[9] = aurora_axi_rx_tdata[9];
// assign aurora_fifo_di[10] = aurora_axi_rx_tdata[10];
// assign aurora_fifo_di[11] = aurora_axi_rx_tdata[11];
// assign aurora_fifo_di[12] = aurora_axi_rx_tdata[12];
// assign aurora_fifo_di[13] = aurora_axi_rx_tdata[13];
// assign aurora_fifo_di[14] = aurora_axi_rx_tdata[14];
// assign aurora_fifo_di[15] = aurora_axi_rx_tdata[15];
// assign aurora_fifo_di[16] = aurora_axi_rx_tkeep[0];
// assign aurora_fifo_di[17] = aurora_axi_rx_tkeep[1];
// assign aurora_fifo_di[18] = aurora_axi_rx_tlast;
// assign aurora_fifo_di[19] = aurora_axi_rx_tvalid;
// assign aurora_fifo_di[31:20] = 0;
// aurora_rx_fifo aurora_rx_fifo (
//     .din   (aurora_fifo_di),                 // input wire [31 : 0] din
//     .wr_en (aurora_axi_rx_tvalid),
//     .wr_clk(aurora_usr_clk),

//     .dout  (aurora_usr_data),                // output wire [15 : 0] dout
//     .rd_en (~aurora_rx_fifo_empty),
//     .rd_clk(mac_gtx_clk),

//     .full(aurora_rx_fifo_full),
//     .empty(aurora_rx_fifo_empty),
//     .wr_rst_busy(),
//     .rd_rst_busy(),

//     .rst(aurora_sysrst)
// );

// aurora_tx_fifo aurora_tx_fifo (
//     .din   (aurora_usr_data),                 // input wire [15 : 0] din
//     .wr_en (~aurora_rx_fifo_empty),
//     .wr_clk(mac_gtx_clk),

//     .dout  (aurora_fifo_do),                // output wire [31 : 0] dout
//     .rd_en (~aurora_tx_empty & aurora_axi_tx_tready),
//     .rd_clk(aurora_usr_clk),

//     .full(aurora_tx_full),
//     .empty(aurora_tx_empty),
//     .wr_rst_busy(),
//     .rd_rst_busy(),

//     .rst(aurora_sysrst)
// );
//     // .aurora_axi_tx_tready(aurora_axi_tx_tready),//output
// assign aurora_axi_tx_tdata[0]  = aurora_fifo_do[0] ;
// assign aurora_axi_tx_tdata[1]  = aurora_fifo_do[1] ;
// assign aurora_axi_tx_tdata[2]  = aurora_fifo_do[2] ;
// assign aurora_axi_tx_tdata[3]  = aurora_fifo_do[3] ;
// assign aurora_axi_tx_tdata[4]  = aurora_fifo_do[4] ;
// assign aurora_axi_tx_tdata[5]  = aurora_fifo_do[5] ;
// assign aurora_axi_tx_tdata[6]  = aurora_fifo_do[6] ;
// assign aurora_axi_tx_tdata[7]  = aurora_fifo_do[7] ;
// assign aurora_axi_tx_tdata[8]  = aurora_fifo_do[8] ;
// assign aurora_axi_tx_tdata[9]  = aurora_fifo_do[9] ;
// assign aurora_axi_tx_tdata[10] = aurora_fifo_do[10];
// assign aurora_axi_tx_tdata[11] = aurora_fifo_do[11];
// assign aurora_axi_tx_tdata[12] = aurora_fifo_do[12];
// assign aurora_axi_tx_tdata[13] = aurora_fifo_do[13];
// assign aurora_axi_tx_tdata[14] = aurora_fifo_do[14];
// assign aurora_axi_tx_tdata[15] = aurora_fifo_do[15];
// assign aurora_axi_tx_tkeep[0] = aurora_fifo_do[16];
// assign aurora_axi_tx_tkeep[1] = aurora_fifo_do[17];
// assign aurora_axi_tx_tlast = aurora_fifo_do[18];
// assign aurora_axi_rx_tvalid = aurora_fifo_do[19];


assign mgt_pwr_en = 1'b1;

assign uart_tx = uart_rx;

//assign  spi_clk  = 1'bz;
assign  spi_cs   = 1'bz;
assign  spi_mosi = 1'bz;
assign  spi_miso = 1'bz;

assign eth_phy_mdio = 1'bz;
assign eth_phy_mdc = 1'b0;

// wire [13:0] usr_lvds;
// genvar i;
// generate
//     for (i=0; i < 14; i=i+1) begin
//         IBUFDS buf_diff_usr_lvds (
//             .I (usr_lvds_p[i]), .IB(usr_lvds_n[i]), .O(usr_lvds[i])
//         );
//         // OBUFDS buf_diff_usr_lvds (
//         //     .O (usr_lvds_p[i]), .OB(usr_lvds_n[i]), .I(usr_lvds[i])
//         // );
//     end
// endgenerate

// assign usr_lvds = 14'h2AAA;
// always @(posedge mac_gtx_clk) begin
//     usr_lvds_io <= usr_lvds_io + 1;
// end

assign gt_rst = usr_lvds_p[0];
assign aurora_rst = usr_lvds_p[1];
assign sel_eth_ch = usr_lvds_p[3:2];
assign sel_aurora_ch = usr_lvds_p[4];
assign aurora_control_pwd = usr_lvds_p[8];

//connect ETH to AURORA
assign mac_fifo_resetn[3] = (sel_aurora_ch & (sel_eth_ch == 2'd3)) ? aurora_status_tx_lock[0] : 1'b0;
assign mac_fifo_resetn[2] = (sel_aurora_ch & (sel_eth_ch == 2'd2)) ? aurora_status_tx_lock[0] : 1'b0;
assign mac_fifo_resetn[1] = (sel_aurora_ch & (sel_eth_ch == 2'd1)) ? aurora_status_tx_lock[0] : 1'b0;
assign mac_fifo_resetn[0] = (sel_aurora_ch & (sel_eth_ch == 2'd0)) ? aurora_status_tx_lock[0] : 1'b0;

assign aurora_axi_tx_tready_eth [3] = (sel_eth_ch == 2'd3) ? aurora_axi_tx_tready[0] : 1'b0;
assign aurora_axi_tx_tready_eth [2] = (sel_eth_ch == 2'd2) ? aurora_axi_tx_tready[0] : 1'b0;
assign aurora_axi_tx_tready_eth [1] = (sel_eth_ch == 2'd1) ? aurora_axi_tx_tready[0] : 1'b0;
assign aurora_axi_tx_tready_eth [0] = (sel_eth_ch == 2'd0) ? aurora_axi_tx_tready[0] : 1'b0;

assign aurora_axi_tx_tdata [0][(0*8) +: 8] = (sel_eth_ch == 2'd3) ? aurora_axi_tx_tdata_eth[3][(0*8) +: 8] :
                                             (sel_eth_ch == 2'd1) ? aurora_axi_tx_tdata_eth[2][(0*8) +: 8] :
                                             (sel_eth_ch == 2'd1) ? aurora_axi_tx_tdata_eth[1][(0*8) +: 8] :
                                                                    aurora_axi_tx_tdata_eth[0][(0*8) +: 8];

assign aurora_axi_tx_tvalid[0] = (sel_eth_ch == 2'd3) ? aurora_axi_tx_tvalid_eth[3] :
                                 (sel_eth_ch == 2'd2) ? aurora_axi_tx_tvalid_eth[2] :
                                 (sel_eth_ch == 2'd1) ? aurora_axi_tx_tvalid_eth[1] :
                                                        aurora_axi_tx_tvalid_eth[0];

assign aurora_axi_tx_tlast [0] = (sel_eth_ch == 2'd3) ? aurora_axi_tx_tlast_eth[3] :
                                 (sel_eth_ch == 2'd2) ? aurora_axi_tx_tlast_eth[2] :
                                 (sel_eth_ch == 2'd1) ? aurora_axi_tx_tlast_eth[1] :
                                                        aurora_axi_tx_tlast_eth[0];

assign aurora_axi_rx_tdata_eth  [3][(0*8) +: 8] = aurora_axi_rx_tdata [0][(0*8) +: 8];
assign aurora_axi_rx_tvalid_eth [3]             = (sel_eth_ch == 2'd3) ? aurora_axi_rx_tvalid[0] : 1'b0;
assign aurora_axi_rx_tlast_eth  [3]             = (sel_eth_ch == 2'd3) ? aurora_axi_rx_tvalid[0] : 1'b0;

assign aurora_axi_rx_tdata_eth  [2][(0*8) +: 8] = aurora_axi_rx_tdata [0][(0*8) +: 8];
assign aurora_axi_rx_tvalid_eth [2]             = (sel_eth_ch == 2'd2) ? aurora_axi_rx_tvalid[0] : 1'b0;
assign aurora_axi_rx_tlast_eth  [2]             = (sel_eth_ch == 2'd2) ? aurora_axi_rx_tvalid[0] : 1'b0;

assign aurora_axi_rx_tdata_eth  [1][(0*8) +: 8] = aurora_axi_rx_tdata [0][(0*8) +: 8];
assign aurora_axi_rx_tvalid_eth [1]             = (sel_eth_ch == 2'd1) ? aurora_axi_rx_tvalid[0] : 1'b0;
assign aurora_axi_rx_tlast_eth  [1]             = (sel_eth_ch == 2'd1) ? aurora_axi_rx_tvalid[0] : 1'b0;

assign aurora_axi_rx_tdata_eth  [0][(0*8) +: 8] = aurora_axi_rx_tdata [0][(0*8) +: 8];
assign aurora_axi_rx_tvalid_eth [0]             = (sel_eth_ch == 2'd0) ? aurora_axi_rx_tvalid[0] : 1'b0;
assign aurora_axi_rx_tlast_eth  [0]             = (sel_eth_ch == 2'd0) ? aurora_axi_rx_tvalid[0] : 1'b0;


IDELAYCTRL idelayctrl (
    .RDY(),
    .REFCLK(clk200M),
    .RST(mac_pll_locked)
);

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = mac_pll_locked;

        mac_rgmii rgmii (
            .status_o(mac_status[x]),
            // .fifo_status(mac_fifo_status[x]),
            // .dbg_fifo_rd(dbg_fifo_rd),

            // phy side (RGMII)
            .phy_rxd   (rgmii_rxd   [(x*4) +: 4]),
            .phy_rx_ctl(rgmii_rx_ctl[x]         ),
            .phy_rxc   (rgmii_rxc   [x]         ),
            .phy_txd   (rgmii_txd   [(x*4) +: 4]),
            .phy_tx_ctl(rgmii_tx_ctl[x]         ),
            .phy_txc   (rgmii_txc   [x]         ),

            // logic side
            .mac_rx_data_o  (mac_rx_tdata [x]),
            .mac_rx_valid_o (mac_rx_tvalid[x]),
            .mac_rx_sof_o   (mac_rx_tuser [x]),
            .mac_rx_eof_o   (mac_rx_tlast [x]),
            .mac_rx_ok_o    (mac_rx_ok[x]),
            .mac_rx_bd_o    (mac_rx_bd[x]),
            .mac_rx_er_o    (mac_rx_er[x]),
            .mac_rx_clk_o   (mac_rx_clk[x]),
            // .dbg_mac_rx_fr_good(mac_rx_fr_good_dbg[x]),

            .mac_tx_data  (mac_tx_tdata [x]),
            .mac_tx_valid (mac_tx_tvalid[x]),
            .mac_tx_sof   (mac_tx_tuser [x]),
            .mac_tx_eof   (mac_tx_tlast [x]),
            .mac_tx_clk_90(mac_gtx_clk90),
            .mac_tx_clk   (mac_gtx_clk),

            .rst(~mac_pll_locked)
        );
        // bit[0] - link
        // bit[1:0] - speed
        //work only if link up 1Gb!!!
        assign mac_rx_nreset[x] = mac_status[x][0] && (mac_status[x][2:1] == 2'b10) && mac_pll_locked;

        mac_fifo fifo(
            //USER IF
            .tx_fifo_aclk       (aurora_usr_clk), //input
            .tx_fifo_resetn     (mac_fifo_resetn[x]), //input
            .tx_axis_fifo_tdata (aurora_axi_rx_tdata_eth  [x][(0*8) +: 8]), //input [7:0]
            .tx_axis_fifo_tvalid(aurora_axi_rx_tvalid_eth [x]            ), //input
            .tx_axis_fifo_tlast (aurora_axi_rx_tlast_eth  [x]            ), //input
            .tx_axis_fifo_tready(), //output

            .rx_fifo_aclk       (aurora_usr_clk), //input
            .rx_fifo_resetn     (mac_fifo_resetn[x]), //input
            .rx_axis_fifo_tready(aurora_axi_tx_tready_eth [x]            ), //input
            .rx_axis_fifo_tdata (aurora_axi_tx_tdata_eth  [x][(0*8) +: 8]), //output [7:0]
            .rx_axis_fifo_tvalid(aurora_axi_tx_tvalid_eth [x]            ), //output
            .rx_axis_fifo_tlast (aurora_axi_tx_tlast_eth  [x]            ), //output

            //MAC IF
            .tx_mac_aclk        (mac_gtx_clk  ), //input
            .tx_mac_resetn      (mac_pll_locked  ), //input
            .tx_axis_mac_tdata  (mac_tx_tdata [x]), //output [7:0]
            .tx_axis_mac_tvalid (mac_tx_tvalid[x]), //output
            .tx_axis_mac_tlast  (mac_tx_tlast [x]), //output
            .tx_axis_mac_tready (1'b1),//(mac_tx_tready), //input
            .tx_axis_mac_tuser  (),//(mac_tx_tuser ), //output
            .tx_axis_mac_sof    (mac_tx_tuser [x]),
            .tx_fifo_overflow   (), //output
            .tx_fifo_status     (), //output   [3:0]
            .tx_collision       (1'b0), //input
            .tx_retransmit      (1'b0), //input

            .rx_mac_aclk        (mac_rx_clk[x]   ),//input
            .rx_mac_resetn      (mac_rx_nreset[x]),//input
            .rx_axis_mac_tdata  (mac_rx_tdata [x]),//input [7:0]
            .rx_axis_mac_tvalid (mac_rx_tvalid[x]),//input
            .rx_axis_mac_tlast  (mac_rx_tlast [x]),//input
            .rx_axis_mac_tuser  (mac_rx_bd[x]),//input
            .rx_fifo_status     (rx_fifo_status[x]), //output   [3:0]
            .rx_fifo_overflow   (rx_fifo_overflow[x])  //output
        );

        // ila_0 rx_ila (
        //     .probe0({
        //         rx_fifo_status[x],
        //         rx_fifo_overflow[x],
        //         mac_status[x],
        //         mac_rx_er[x],
        //         mac_rx_bd[x],
        //         mac_rx_ok[x],
        //         mac_rx_tdata[x],
        //         mac_rx_tvalid[x],
        //         mac_rx_tuser[x],
        //         mac_rx_tlast[x]
        //     }),
        //     .clk(mac_rx_clk[x])
        // );

        // ila_0 tx_ila (
        //     .probe0({
        //         mac_tx_tdata [x],
        //         mac_tx_tvalid[x],
        //         mac_tx_tlast [x],
        //         mac_tx_tuser [x]
        //     }),
        //     .clk(mac_gtx_clk)
        // );
    end
endgenerate

// ila_1 aurora_ila (
//     .probe0({
//         aurora_status_tx_lock,
//         aurora_status_lane_up,
//         aurora_status_channel_up,
//         aurora_status_frame_err,
//         aurora_status_hard_err,
//         aurora_status_soft_err
//     }),
//     .clk(aurora_usr_clk)
// );


// wire [7:0] test_data;

// //set channel for transfer test data
// assign mac_tx_tdata [0] = test_tx_tdata [0]; //0;
// assign mac_tx_tvalid[0] = test_tx_tvalid[0]; //1'b0;
// assign mac_tx_tlast [0] = test_tx_tuser [0]; //1'b0;
// assign mac_tx_tuser [0] = test_tx_tlast [0]; //1'b0;

// assign mac_tx_tdata [1] = 0;
// assign mac_tx_tvalid[1] = 1'b0;
// assign mac_tx_tlast [1] = 1'b0;
// assign mac_tx_tuser [1] = 1'b0;

// assign mac_tx_tdata [2] = 0;
// assign mac_tx_tvalid[2] = 1'b0;
// assign mac_tx_tlast [2] = 1'b0;
// assign mac_tx_tuser [2] = 1'b0;

// assign mac_tx_tdata [3] = 0;
// assign mac_tx_tvalid[3] = 1'b0;
// assign mac_tx_tlast [3] = 1'b0;
// assign mac_tx_tuser [3] = 1'b0;

// test_phy test_phy (
//     .mac_tx_data  (test_tx_tdata [0]),
//     .mac_tx_valid (test_tx_tvalid[0]),
//     .mac_tx_sof   (test_tx_tuser [0]),
//     .mac_tx_eof   (test_tx_tlast [0]),

//     .mac_rx_data   (test_rx_tdata [0]),
//     .mac_rx_valid  (test_rx_tvalid[0]),
//     .mac_rx_sof    (1'b0),
//     .mac_rx_eof    (test_rx_tlast[0]),
//     .mac_rx_fr_good(1'b1),
//     .mac_rx_fr_err (1'b0),

//     .start(reg_ctrl[0]),
//     .err(test_err),
//     .test_data(test_data),

//     .clk(mac_gtx_clk),
//     .rst(~mac_pll_locked)
// );




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
assign dbg_out[1] = clk20_div | sysclk25_div | led_blink | reg_ctrl[0];// &
                    // |mac_rx_tvalid &
                    // |mac_rx_tlast &
                    // |mac_rx_tuser &
                    // |mac_tx_tready &
                    // |mac_tx_clk &
                    // |mac_tx_reset
                    // ;
                    // |mac_rx_reset &
                    // |mac_rx_tdata &
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

assign dbg_led = led_blink & !gt_rst;// !test_gpio[0] & !aurora_gt_rst;// & test_err;




// reg [31:0] mac_rx_cnterr [ETHCOUNT-1:0];
// genvar a;
// generate
//     for (a=3; a < ETHCOUNT; a=a+1)  begin : cnterr
//         ila_0 mac_ila (
//             .probe0({
//                 test_err,
//                 rx_fifo_status[a],
//                 rx_fifo_overflow[a],
//                 mac_status[a],
//                 mac_rx_cnterr[a],
//                 mac_rx_er[a],
//                 mac_rx_bd[a],
//                 mac_rx_ok[a],
//                 mac_rx_tdata[a],
//                 mac_rx_tvalid[a],
//                 mac_rx_tuser[a],
//                 mac_rx_tlast[a]
//             }),
//             .clk(mac_rx_clk[a])
//         );

//         always @(posedge mac_rx_clk[a]) begin
//             if (!mac_rx_nreset[a]) begin
//                 mac_rx_cnterr[a] <= 0;
//             end else if (mac_rx_bd[a] | mac_rx_er[a]) begin
//                 mac_rx_cnterr[a] <= mac_rx_cnterr[a] + 1;
//             end
//         end
//     end
// endgenerate

// ila_0 usr_ila (
//     .probe0({
//         test_tx_tdata [0],
//         test_tx_tvalid[0],
//         test_tx_tuser [0],
//         test_tx_tlast [0],
//         test_data,
//         test_err,
//         test_rx_tdata[0] ,
//         test_rx_tvalid[0],
//         test_rx_tlast[0]
//     }),
//     .clk(mac_gtx_clk)
// );


endmodule

