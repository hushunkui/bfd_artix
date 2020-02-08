
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

`include "fpga_reg.v"
module main #(
    parameter ETHCOUNT = 4, //max 4
    parameter SIM = 0
) (
    // input [13:0] usr_lvds_p,
    // input [13:0] usr_lvds_n,
    input [5:0] usr_lvds_p,
    output [3:0] usr_lvds_p_o,

    output [(ETHCOUNT*4)-1:0] rgmii_txd   ,
    output [ETHCOUNT-1:0]     rgmii_tx_ctl,
    output [ETHCOUNT-1:0]     rgmii_txc   ,
    input  [(ETHCOUNT*4)-1:0] rgmii_rxd   ,
    input  [ETHCOUNT-1:0]     rgmii_rx_ctl,
    input  [ETHCOUNT-1:0]     rgmii_rxc   ,

    output [ETHCOUNT-1:0]     eth_phy_rst ,

    inout                     eth_phy_mdio,
    output                    eth_phy_mdc ,

    input [0:0] gt_rx_rxn,
    input [0:0] gt_rx_rxp,
    output [0:0] gt_tx_txn,
    output [0:0] gt_tx_txp,
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
wire [ETHCOUNT-1:0]     mac_fifo_resetn;
wire [31:0]             mac_rx_cnterr [ETHCOUNT-1:0];
reg  [31:0]             mac_rx_cnterr_mjtag [ETHCOUNT-1:0];
reg  [31:0]             mac_rx_cnterr_aurclk [ETHCOUNT-1:0];

wire [7:0]              mac_tx_tdata [ETHCOUNT-1:0];// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tvalid;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tlast ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tuser ;// = 0;
wire [ETHCOUNT-1:0]     mac_tx_tready;
wire [ETHCOUNT-1:0]     mac_tx_clk;
wire [ETHCOUNT-1:0]     mac_tx_reset;

// wire [3:0] mac_fifo_status [ETHCOUNT-1:0];
wire [3:0] mac_status [ETHCOUNT-1:0];
wire [3:0] mac_link;
reg [3:0] mac_link_mjtag;

wire [7:0]              usr_rx_tdata  [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     usr_rx_tvalid;
wire [ETHCOUNT-1:0]     usr_rx_tlast ;

wire [3:0]              rx_fifo_status  [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     rx_fifo_overflow;

wire [7:0]              test_mac_tx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     test_mac_tx_tvalid;
wire [ETHCOUNT-1:0]     test_mac_tx_tuser ;
wire [ETHCOUNT-1:0]     test_mac_tx_tlast ;
wire [ETHCOUNT-1:0]     test_mac_tx_tready;
wire [ETHCOUNT-1:0]     test_mac_tx_rq;

wire [7:0]              test_mac_rx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     test_mac_rx_tvalid;
wire [ETHCOUNT-1:0]     test_mac_rx_tuser ;
wire [ETHCOUNT-1:0]     test_mac_rx_tlast ;
wire [ETHCOUNT-1:0]     test_mac_start;
wire [ETHCOUNT-1:0]     test_mac_rx_tsof;
wire [ETHCOUNT-1:0]     test_mac_rx_terr;

wire [0:0] mac_tx_ack [ETHCOUNT-1:0];

wire [7:0]              dbg_rgmii_rx_data [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_den;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_sof;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_eof;

wire [3:0] dbg_fi [ETHCOUNT-1:0];
wire [9:0] dbg_fi_dcnt [ETHCOUNT-1:0];
wire [6:0] dbg_fi_wr_data_count [ETHCOUNT-1:0];
wire [3:0] dbg_fo [ETHCOUNT-1:0];
wire [9:0] dbg_fo_dcnt [ETHCOUNT-1:0];
wire [6:0] dbg_fo_rd_data_count [ETHCOUNT-1:0];
wire [1:0] dbg_fi_wRGMII_Clk [ETHCOUNT-1:0];
wire [4:0] dbg_fi_wDataDDRL [ETHCOUNT-1:0];
wire [4:0] dbg_fi_wDataDDRH [ETHCOUNT-1:0];
wire [3:0] dbg_fi_wCondition [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0] dbg_fi_LoadDDREnaD0;


reg [7:0] rgmii_rx_data_i [ETHCOUNT-1:0];
reg [ETHCOUNT-1:0] rgmii_rx_den_i = 0;
reg [ETHCOUNT-1:0] rgmii_rx_sof_i = 0;
reg [ETHCOUNT-1:0] rgmii_rx_eof_i = 0;

reg [7:0] sr0_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr1_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr2_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr3_rgmii_rx_data [ETHCOUNT-1:0];

reg [ETHCOUNT-1:0] sr0_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr1_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr2_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr3_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr4_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr5_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr6_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr7_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr8_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr9_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr10_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr11_rgmii_rx_den = 0;

reg [ETHCOUNT-1:0] sr0_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr1_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr2_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr3_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr4_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr5_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr6_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr7_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr8_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr9_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr10_rgmii_rx_sof = 0;
reg [ETHCOUNT-1:0] sr11_rgmii_rx_sof = 0;

reg [7:0] rgmii_rx_data_o [ETHCOUNT-1:0] ;
reg [ETHCOUNT-1:0] rgmii_rx_den_o = 0;
reg [ETHCOUNT-1:0] rgmii_rx_sof_o = 0;
reg [ETHCOUNT-1:0] rgmii_rx_eof_o = 0;


wire clk125M;
wire clk125M_p90;
wire clk375M;


// wire [31:0] firmware_date;
// wire [31:0] firmware_time;

wire [31:0]aurora_axi_rx_tdata;
wire [3:0]aurora_axi_rx_tkeep;
wire aurora_axi_rx_tlast;
wire aurora_axi_rx_tvalid;
wire [31:0]aurora_axi_tx_tdata;
wire [3:0]aurora_axi_tx_tkeep;
wire aurora_axi_tx_tlast;
wire aurora_axi_tx_tready;
wire aurora_axi_tx_tvalid;
wire gt_rst;
wire aurora_rst;
wire aurora_control_pwd;
wire aurora_status_channel_up;
wire aurora_status_frame_err;
wire aurora_status_hard_err;
wire [0:0]aurora_status_lane_up;
wire aurora_status_pll_not_locked_out;
wire aurora_status_rx_resetdone_out;
wire aurora_status_soft_err;
wire aurora_status_tx_lock;
wire aurora_status_tx_resetdone_out;
wire aurora_usr_clk;

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
wire [ETHCOUNT-1:0] test_err;
wire [7:0] test_data [ETHCOUNT-1:0];


wire [1:0] eth_num;
wire [3:0] eth_en;
wire  module_en;

wire ethphy_mdio_data;
wire ethphy_mdio_dir;
wire [3:0] ethphy_rst;

wire [7:0] vio_test_start;
wire [43:0]  vio_in ;
wire [7:0]   vio_out;

wire [15:0] test_mac_pkt_size;
wire [15:0] test_mac_pause_size;


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
    .clk_out1(clk200M),//(clk125M),
    .clk_out2(clk125M),//(clk125M_p90),
    .clk_out3(clk375M),
    .clk_out4(clk125M_p90),
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
    .aurora_axi_rx_tdata(aurora_axi_rx_tdata), //output
    .aurora_axi_rx_tkeep(aurora_axi_rx_tkeep), //output
    .aurora_axi_rx_tvalid(aurora_axi_rx_tvalid),//output
    .aurora_axi_rx_tlast(aurora_axi_rx_tlast), //output
    .aurora_axi_tx_tready(aurora_axi_tx_tready),//output
    .aurora_axi_tx_tdata(aurora_axi_tx_tdata), //input
    .aurora_axi_tx_tkeep(4'hF),//(aurora_axi_tx_tkeep), //input
    .aurora_axi_tx_tvalid(aurora_axi_tx_tvalid), //input
    .aurora_axi_tx_tlast(aurora_axi_tx_tlast), //input
    .aurora_control_power_down(aurora_control_pwd),
    .aurora_status_lane_up(aurora_status_lane_up),
    .aurora_status_channel_up(aurora_status_channel_up),
    .aurora_status_frame_err(aurora_status_frame_err),
    .aurora_status_hard_err(aurora_status_hard_err),
    .aurora_status_soft_err(aurora_status_soft_err),
    // .aurora_status_pll_not_locked_out(aurora_status_pll_not_locked_out),
    .aurora_status_tx_lock(aurora_status_tx_lock),
    .aurora_status_tx_resetdone_out(aurora_status_tx_resetdone_out),
    .aurora_status_rx_resetdone_out(aurora_status_rx_resetdone_out),
    .aurora_gt_rx_rxn(gt_rx_rxn),
    .aurora_gt_rx_rxp(gt_rx_rxp),
    .aurora_gt_tx_txn(gt_tx_txn),
    .aurora_gt_tx_txp(gt_tx_txp),

    .aurora_gt_refclk_clk_n(gt_refclk_n),//(mgt_refclk_n),//
    .aurora_gt_refclk_clk_p(gt_refclk_p),//(mgt_refclk_p),//
    .aurora_gt_rst(gt_rst),
    .aurora_init_clk(clk125M),
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

    .aclk(clk125M),
    .areset_n(mac_pll_locked)
);

usr_logic #(
    .SIM (SIM)
) m_usr (
//user part
    .test_gpio (test_gpio),
    .reg_ctrl (reg_ctrl),
    .status_aurora({30'd0, 1'b0, aurora_status_channel_up}),
    .status_eth({21'd0, 4'd0, mac_link_mjtag[3:0], 3'd0}),
    .cnterr_eth0(mac_rx_cnterr_mjtag[0]),
    .cnterr_eth1(mac_rx_cnterr_mjtag[1]),
    .cnterr_eth2(mac_rx_cnterr_mjtag[2]),
    .cnterr_eth3(mac_rx_cnterr_mjtag[3]),
    .ethphy_mdio_clk_o(eth_phy_mdc),
    .ethphy_mdio_data_o(ethphy_mdio_data),
    .ethphy_mdio_dir_o(ethphy_mdio_dir),
    .ethphy_mdio_data_i(eth_phy_mdio),
    .ethphy_nrst_o(ethphy_rst),
    .aurora_o_ctl_0(aurora_axi_tx_tdata),
    .aurora_o_ctl_1({aurora_axi_tx_tlast, aurora_axi_tx_tvalid}),
    .aurora_i_ctl_0((aurora_axi_rx_tlast & aurora_axi_rx_tvalid) ? aurora_axi_rx_tdata : 0),
    .ethphy_test_pkt_size(test_mac_pkt_size),
    .ethphy_test_pause_size(test_mac_pause_size),

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
    .s_axi_clk (clk125M)
);

assign eth_phy_mdio = (ethphy_mdio_dir) ? ethphy_mdio_data : 1'bz;


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
//     .rd_clk(clk125M),

//     .full(aurora_rx_fifo_full),
//     .empty(aurora_rx_fifo_empty),
//     .wr_rst_busy(),
//     .rd_rst_busy(),

//     .rst(aurora_sysrst)
// );

// aurora_tx_fifo aurora_tx_fifo (
//     .din   (aurora_usr_data),                 // input wire [15 : 0] din
//     .wr_en (~aurora_rx_fifo_empty),
//     .wr_clk(clk125M),

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
// always @(posedge clk125M) begin
//     usr_lvds_io <= usr_lvds_io + 1;
// end

assign gt_rst = usr_lvds_p[0];
assign aurora_rst = usr_lvds_p[1];
assign aurora_control_pwd = usr_lvds_p[2];
assign eth_num = usr_lvds_p[4:3];
assign module_en = usr_lvds_p[5];

assign usr_lvds_p_o[0] = mac_link[0];
assign usr_lvds_p_o[1] = mac_link[1];
assign usr_lvds_p_o[2] = mac_link[2];
assign usr_lvds_p_o[3] = mac_link[3];


IDELAYCTRL idelayctrl (
    .RDY(),
    .REFCLK(clk200M),
    .RST(mac_pll_locked)
);

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = mac_pll_locked & ethphy_rst[x];

        assign test_mac_start[x] = reg_ctrl[x];// | vio_test_start[x];

        // always @(posedge clk125M) begin
        //     if (reg_ctrl[24]) begin
        //         mac_rx_cnterr[x] <= 0;
        //     end else begin
        //         if (mac_rx_tvalid[x] && mac_rx_tlast[x]) begin
        //             if (mac_rx_bd[x] || mac_rx_er[x]) begin
        //                 mac_rx_cnterr[x] <= mac_rx_cnterr[x] + 1;
        //             end
        //         end
        //     end
        // end

        always @(posedge clk125M) begin
            mac_rx_cnterr_mjtag[x] <= mac_rx_cnterr[x];
            mac_link_mjtag[x] <= mac_link[x];
        end

        always @(posedge aurora_usr_clk) begin
            mac_rx_cnterr_aurclk[x] <= mac_rx_cnterr[x];
        end

        CustomGMAC_Wrap rgmii (
            .clk375(clk375M),
            .clk125(clk125M),

            .RXC   (rgmii_rxc   [x]         ), //input
            .RX_CTL(rgmii_rx_ctl[x]         ), //input
            .RXD   (rgmii_rxd   [(x*4) +: 4]), //input [3:0]

            .CLK_TX(rgmii_txc   [x]         ),//output
            .TX_CTL(rgmii_tx_ctl[x]         ),//output
            .TXDATA(rgmii_txd   [(x*4) +: 4]),//output [3:0]

            .MODE(),//output
            .LINK_UP(mac_link[x]),//output

            .ValIn0 (test_mac_tx_tvalid[x]), //input
            .SoFIn0 (test_mac_tx_tuser [x]), //input
            .EoFIn0 (test_mac_tx_tlast [x]), //input
            .ReqIn0 (test_mac_tx_tvalid[x]), //input
            .DataIn0(test_mac_tx_tdata [x]), //input [7:0]

            // .ValIn1 (1'b0),//input
            // .SoFIn1 (1'b0),//input
            // .EoFIn1 (1'b0),//input
            // .ReqIn1 (1'b0),//input
            // .DataIn1(0),//input [7:0]

            .ReqConfirm(mac_tx_ack[x]),//output

            .dbg_rgmii_rx_data(dbg_rgmii_rx_data[x]),
            .dbg_rgmii_rx_den (dbg_rgmii_rx_den [x]),
            .dbg_rgmii_rx_sof (dbg_rgmii_rx_sof [x]),
            .dbg_rgmii_rx_eof (dbg_rgmii_rx_eof [x]),
            .dbg_fi(dbg_fi[x]),
            .dbg_fi_dcnt(dbg_fi_dcnt[x]),
            .dbg_fi_wr_data_count(dbg_fi_wr_data_count[x]),
            .dbg_fo(dbg_fo[x]),
            .dbg_fo_dcnt(dbg_fo_dcnt[x]),
            .dbg_fo_rd_data_count(dbg_fo_rd_data_count[x]),
            .dbg_fi_wRGMII_Clk(dbg_fi_wRGMII_Clk[x]),
            .dbg_fi_wDataDDRL(dbg_fi_wDataDDRL[x]),
            .dbg_fi_wDataDDRH(dbg_fi_wDataDDRH[x]),
            .dbg_fi_wCondition(dbg_fi_wCondition[x]),
            .dbg_fi_LoadDDREnaD0(dbg_fi_LoadDDREnaD0[x]),

            .Remote_MACOut(), //output   [47:0]
            .Remote_IP_Out(), //output   [31:0]
            .RemotePortOut(), //output   [15:0]
            .SOF_OUT(test_mac_rx_tsof[x]), //output
            .EOF_OUT(test_mac_rx_tlast[x]), //output
            .ENA_OUT(test_mac_rx_tvalid[x]), //output
            .ERR_OUT(test_mac_rx_terr[x]), //output
            .DATA_OUT(test_mac_rx_tdata[x]), //output  [7 :0]
            .InputCRC_ErrorCounter(mac_rx_cnterr[x]) //output  [31 :0]
        );

        always @ (posedge clk125M) begin
            rgmii_rx_data_i[x] <= dbg_rgmii_rx_data[x];
            rgmii_rx_den_i[x] <= dbg_rgmii_rx_den[x];
            rgmii_rx_sof_i[x] <= dbg_rgmii_rx_sof[x];
            rgmii_rx_eof_i[x] <= dbg_rgmii_rx_eof[x];

            sr0_rgmii_rx_data[x] <= rgmii_rx_data_i[x];
            sr1_rgmii_rx_data[x] <= sr0_rgmii_rx_data[x];
            sr2_rgmii_rx_data[x] <= sr1_rgmii_rx_data[x];
            sr3_rgmii_rx_data[x] <= sr2_rgmii_rx_data[x];
            rgmii_rx_data_o[x] <= sr3_rgmii_rx_data[x];

            sr0_rgmii_rx_den[x] <= rgmii_rx_den_i[x];
            sr1_rgmii_rx_den[x] <= sr0_rgmii_rx_den[x];
            sr2_rgmii_rx_den[x] <= sr1_rgmii_rx_den[x];
            sr3_rgmii_rx_den[x] <= sr2_rgmii_rx_den[x];
            sr4_rgmii_rx_den[x] <= sr3_rgmii_rx_den[x];
            sr5_rgmii_rx_den[x] <= sr4_rgmii_rx_den[x];
            sr6_rgmii_rx_den[x] <= sr5_rgmii_rx_den[x];
            sr7_rgmii_rx_den[x] <= sr6_rgmii_rx_den[x];
            sr8_rgmii_rx_den[x] <= sr7_rgmii_rx_den[x];
            sr9_rgmii_rx_den[x] <= sr8_rgmii_rx_den[x];
            sr10_rgmii_rx_den[x] <= sr9_rgmii_rx_den[x];
            sr11_rgmii_rx_den[x] <= sr10_rgmii_rx_den[x];
            rgmii_rx_den_o[x] <= sr11_rgmii_rx_den[x] & rgmii_rx_den_i[x];

            sr0_rgmii_rx_sof[x] <= rgmii_rx_sof_i[x];
            sr1_rgmii_rx_sof[x] <= sr0_rgmii_rx_sof[x];
            sr2_rgmii_rx_sof[x] <= sr1_rgmii_rx_sof[x];
            sr3_rgmii_rx_sof[x] <= sr2_rgmii_rx_sof[x];
            sr4_rgmii_rx_sof[x] <= sr3_rgmii_rx_sof[x];
            sr5_rgmii_rx_sof[x] <= sr4_rgmii_rx_sof[x];
            sr6_rgmii_rx_sof[x] <= sr5_rgmii_rx_sof[x];
            sr7_rgmii_rx_sof[x] <= sr6_rgmii_rx_sof[x];
            sr8_rgmii_rx_sof[x] <= sr7_rgmii_rx_sof[x];
            sr9_rgmii_rx_sof[x] <= sr8_rgmii_rx_sof[x];
            sr10_rgmii_rx_sof[x] <= sr9_rgmii_rx_sof[x];
            sr11_rgmii_rx_sof[x] <= sr10_rgmii_rx_sof[x];
            rgmii_rx_sof_o[x] <= sr11_rgmii_rx_sof[x];

            rgmii_rx_eof_o[x] <= rgmii_rx_eof_i[x];
        end

        // test_rx test_rx_eth0 (
        //     .mac_rx_data   (test_mac_rx_tdata [x]   ),
        //     .mac_rx_valid  (test_mac_rx_tvalid[x]  ),
        //     .mac_rx_sof    (test_mac_rx_tsof[x]    ),
        //     .mac_rx_eof    (test_mac_rx_tlast[x]    ),
        //     .mac_rx_fr_good(1'b1),
        //     .mac_rx_fr_err (1'b0 ),

        //     .start(test_mac_start[x]),
        //     .err(),
        //     .test_data(),

        //     .clk(clk125M),
        //     .rst(~mac_pll_locked)
        // );

        // ila_0 rx_ila (
        //     .probe0({
        //         mac_rx_cnterr[x][9:0],
        //         test_mac_rx_tdata[x],           //11
        //         test_mac_rx_tvalid[x],         //3
        //         test_mac_rx_tsof[x], //sof   //2
        //         test_mac_rx_tlast[x]  //eof  //1
        //     }),
        //     .clk(clk125M)
        // );

        // ila_0 rx_ila (
        //     .probe0({
        //         dbg[x][0],//assign dbg[0] = wFIFOValid;
        //         dbg[x][1],//assign dbg[1] = FIFOValidDelay[0];
        //         dbg[x][2],//assign dbg[2] = wFIFODat[8];
        //         mac_rx_cnterr[x][9:0],
        //         dbg_rgmii_rx_data[x],
        //         dbg_rgmii_rx_den [x],
        //         dbg_rgmii_rx_sof [x],
        //         dbg_rgmii_rx_eof [x]
        //     }),
        //     .clk(clk125M)
        // );


        // test_tx test_tx_eth0 (
        //     .mac_tx_data (test_mac_tx_tdata [x]),
        //     .mac_tx_valid(test_mac_tx_tvalid[x]),
        //     .mac_tx_sof  (test_mac_tx_tuser [x]),
        //     .mac_tx_eof  (test_mac_tx_tlast [x]),
        //     .mac_tx_rq   (test_mac_tx_rq[x]),
        //     .mac_tx_ack  (mac_tx_ack[x][0]),

        //     .start(test_mac_start[x]),
        //     .pkt_size(test_mac_pkt_size),
        //     .pause_size(test_mac_pause_size),

        //     .clk(clk125M),
        //     .rst(~mac_pll_locked)
        // );

        // ila_0 tx_ila (
        //     .probe0({
        //         test_mac_tx_tdata[x],           //11
        //         test_mac_tx_tvalid[x],         //3
        //         test_mac_tx_tuser[x], //sof   //2
        //         test_mac_tx_tlast[x]  //eof  //1
        //     }),
        //     .clk(clk125M)
        // );

        // mac_rgmii rgmii (
        //     .status_o(mac_status[x]),//output [3:0]
        //     // .fifo_status(mac_fifo_status[x]),
        //     // .dbg_fifo_rd(dbg_fifo_rd),

        //     // phy side (RGMII)
        //     .phy_rxd   (rgmii_rxd   [(x*4) +: 4]),
        //     .phy_rx_ctl(rgmii_rx_ctl[x]         ),
        //     .phy_rxc   (rgmii_rxc   [x]         ),
        //     .phy_txd   (rgmii_txd   [(x*4) +: 4]),
        //     .phy_tx_ctl(rgmii_tx_ctl[x]         ),
        //     .phy_txc   (rgmii_txc   [x]         ),

        //     // logic side
        //     .mac_rx_data_o  (mac_rx_tdata [x]),
        //     .mac_rx_valid_o (mac_rx_tvalid[x]),
        //     .mac_rx_sof_o   (mac_rx_tuser [x]),
        //     .mac_rx_eof_o   (mac_rx_tlast [x]),
        //     .mac_rx_ok_o    (mac_rx_ok[x]),
        //     .mac_rx_bd_o    (mac_rx_bd[x]),
        //     .mac_rx_er_o    (mac_rx_er[x]),
        //     .mac_rx_clk_o   (clk125M),
        //     // .dbg_mac_rx_fr_good(mac_rx_fr_good_dbg[x]),

        //     .mac_tx_data  (mac_tx_tdata [x]),
        //     .mac_tx_valid (mac_tx_tvalid[x]),
        //     .mac_tx_sof   (mac_tx_tuser [x]),
        //     .mac_tx_eof   (mac_tx_tlast [x]),
        //     .mac_tx_clk_90(clk125M_p90),
        //     .mac_tx_clk   (clk125M),

        //     .rst(~mac_pll_locked)
        // );
        // // bit[0] - link
        // // bit[1:0] - speed
        // //work only if link up 1Gb!!!
        // assign mac_link[x] = mac_status[x][0] && (mac_status[x][2:1] == 2'b10) && mac_pll_locked;
        // assign mac_fifo_resetn[x] = mac_link[x];

        // mac_fifo fifo(
        //     //USER IF
        //     .tx_fifo_aclk       (aurora_usr_clk), //input
        //     .tx_fifo_resetn     (mac_fifo_resetn[x]), //input
        //     .tx_axis_fifo_tdata (test_mac_tx_tdata [x][(0*8) +: 8]),//input [7:0]
        //     .tx_axis_fifo_tvalid(test_mac_tx_tvalid[x]            ),//input
        //     .tx_axis_fifo_tlast (test_mac_tx_tlast [x]            ),//input
        //     .tx_axis_fifo_tready(test_mac_tx_tready[x]), //output

        //     .rx_fifo_aclk       (aurora_usr_clk), //input
        //     .rx_fifo_resetn     (mac_fifo_resetn[x]), //input
        //     .rx_axis_fifo_tready(1'b1), //input
        //     .rx_axis_fifo_tdata (test_mac_rx_tdata [x][(0*8) +: 8]), //output [7:0]
        //     .rx_axis_fifo_tvalid(test_mac_rx_tvalid[x]            ), //output
        //     .rx_axis_fifo_tlast (test_mac_rx_tlast [x]            ), //output

        //     //MAC IF
        //     .tx_mac_aclk        (clk125M  ), //input
        //     .tx_mac_resetn      (mac_fifo_resetn[x]), //input
        //     .tx_axis_mac_tdata  (mac_tx_tdata [x]), //output [7:0]
        //     .tx_axis_mac_tvalid (mac_tx_tvalid[x]), //output
        //     .tx_axis_mac_tlast  (mac_tx_tlast [x]), //output
        //     .tx_axis_mac_tready (1'b1),//(mac_tx_tready), //input
        //     .tx_axis_mac_tuser  (),//(mac_tx_tuser ), //output
        //     .tx_axis_mac_sof    (mac_tx_tuser [x]),
        //     .tx_fifo_overflow   (), //output
        //     .tx_fifo_status     (), //output   [3:0]
        //     .tx_collision       (1'b0), //input
        //     .tx_retransmit      (1'b0), //input

        //     .rx_mac_aclk        (clk125M   ),//input
        //     .rx_mac_resetn      (mac_fifo_resetn[x]),//input
        //     .rx_axis_mac_tdata  (mac_rx_tdata [x]),//input [7:0]
        //     .rx_axis_mac_tvalid (mac_rx_tvalid[x]),//input
        //     .rx_axis_mac_tlast  (mac_rx_tlast [x]),//input
        //     .rx_axis_mac_tuser  (mac_rx_bd[x]),//input
        //     .rx_fifo_status     (rx_fifo_status[x]), //output   [3:0]
        //     .rx_fifo_overflow   (rx_fifo_overflow[x])  //output
        // );

        // ila_0 rx_ila (
        //     .probe0({
        //         mac_fifo_resetn[x],               //24
        //         rx_fifo_status[x], //4bit        //23
        //         rx_fifo_overflow[x],            //19
        //         mac_status[x], //4bit          //18
        //         mac_rx_er[x],                 //14
        //         mac_rx_bd[x],                //13
        //         mac_rx_ok[x],               //12
        //         mac_rx_tdata[x],           //11
        //         mac_rx_tvalid[x],         //3
        //         mac_rx_tuser[x], //sof   //2
        //         mac_rx_tlast[x]  //eof  //1
        //     }),
        //     .clk(clk125M)
        // );

        // ila_0 rx_ila (
        //     .probe0({
        //         test_err[x],
        //         mac_rx_cnterr[x][9:0],
        //         rx_fifo_status[x], //4bit       //19
        //         rx_fifo_overflow[x],           //15
        //         mac_rx_er[x],                 //14
        //         mac_rx_bd[x],                //13
        //         mac_rx_ok[x],               //12
        //         mac_rx_tdata[x],           //11
        //         mac_rx_tvalid[x],         //3
        //         mac_rx_tuser[x], //sof   //2
        //         mac_rx_tlast[x]  //eof  //1
        //     }),
        //     .clk(clk125M)
        // );

        // ila_0 tx_ila (
        //     .probe0({
        //         mac_fifo_resetn[x],
        //         mac_tx_tdata [x],
        //         mac_tx_tvalid[x],
        //         mac_tx_tlast [x],
        //         mac_tx_tuser [x]
        //     }),
        //     .clk(clk125M)
        // );

        // ila_0 tx_ila (
        //     .probe0({
        //         test_mac_rx_tvalid[x],
        //         test_mac_rx_tlast[x],
        //         test_mac_rx_tdata[x],
        //         test_data[x], //8b
        //         test_err[x],
        //         test_mac_start[x]
        //     }),
        //     .clk(aurora_usr_clk)
        // );

        // ila_0 tx_ila (
        //     .probe0({
        //         test_mac_tx_tvalid[x],
        //         test_mac_tx_tlast[x],
        //         test_mac_tx_tready[x],
        //         test_mac_tx_tdata[x], //8b
        //         test_mac_rx_tvalid[x],
        //         test_mac_rx_tlast[x],
        //         test_mac_rx_tdata[x], //8b
        //         test_err[x],
        //         test_mac_start[x]
        //     }),
        //     .clk(aurora_usr_clk)
        // );

    end
endgenerate


eth_txfifo eth0_txfifo (
    .s_axis_tready(),  // output wire s_axis_tready
    .s_axis_tdata(rgmii_rx_data_o[1]),    // input wire [7 : 0] s_axis_tdata
    .s_axis_tvalid(rgmii_rx_den_o[1]),  // input wire s_axis_tvalid
    .s_axis_tuser({rgmii_rx_sof_o[1]}),    // input wire [0 : 0] s_axis_tuser
    .s_axis_tlast(rgmii_rx_eof_o[1]),    // input wire s_axis_tlast

    .m_axis_tready(mac_tx_ack[0][0]),  // input wire m_axis_tready
    .m_axis_tdata(test_mac_tx_tdata [0]),    // output wire [7 : 0] m_axis_tdata
    .m_axis_tvalid(test_mac_tx_tvalid[0]),  // output wire m_axis_tvalid
    .m_axis_tuser({test_mac_tx_tuser [0]}),    // output wire [0 : 0] m_axis_tuser
    .m_axis_tlast(test_mac_tx_tlast [0]),    // output wire m_axis_tlast

    .wr_rst_busy(),      // output wire wr_rst_busy
    .rd_rst_busy(),      // output wire rd_rst_busy
    .s_aclk(clk125M),                // input wire s_aclk
    .s_aresetn(eth_phy_rst[0])          // input wire s_aresetn
);

eth_txfifo eth1_txfifo (
    .s_axis_tready(),  // output wire s_axis_tready
    .s_axis_tdata(rgmii_rx_data_o[0]),    // input wire [7 : 0] s_axis_tdata
    .s_axis_tvalid(rgmii_rx_den_o[0]),  // input wire s_axis_tvalid
    .s_axis_tuser({rgmii_rx_sof_o[0]}),    // input wire [0 : 0] s_axis_tuser
    .s_axis_tlast(rgmii_rx_eof_o[0]),    // input wire s_axis_tlast

    .m_axis_tready(mac_tx_ack[1][0]),  // input wire m_axis_tready
    .m_axis_tdata(test_mac_tx_tdata [1]),    // output wire [7 : 0] m_axis_tdata
    .m_axis_tvalid(test_mac_tx_tvalid[1]),  // output wire m_axis_tvalid
    .m_axis_tuser({test_mac_tx_tuser [1]}),    // output wire [0 : 0] m_axis_tuser
    .m_axis_tlast(test_mac_tx_tlast [1]),    // output wire m_axis_tlast

    .wr_rst_busy(),      // output wire wr_rst_busy
    .rd_rst_busy(),      // output wire rd_rst_busy
    .s_aclk(clk125M),                // input wire s_aclk
    .s_aresetn(eth_phy_rst[1])          // input wire s_aresetn
);

eth_txfifo eth2_txfifo (
    .s_axis_tready(),  // output wire s_axis_tready
    .s_axis_tdata(rgmii_rx_data_o[3]),    // input wire [7 : 0] s_axis_tdata
    .s_axis_tvalid(rgmii_rx_den_o[3]),  // input wire s_axis_tvalid
    .s_axis_tuser({rgmii_rx_sof_o[3]}),    // input wire [0 : 0] s_axis_tuser
    .s_axis_tlast(rgmii_rx_eof_o[3]),    // input wire s_axis_tlast

    .m_axis_tready(mac_tx_ack[2][0]),  // input wire m_axis_tready
    .m_axis_tdata(test_mac_tx_tdata [2]),    // output wire [7 : 0] m_axis_tdata
    .m_axis_tvalid(test_mac_tx_tvalid[2]),  // output wire m_axis_tvalid
    .m_axis_tuser({test_mac_tx_tuser [2]}),    // output wire [0 : 0] m_axis_tuser
    .m_axis_tlast(test_mac_tx_tlast [2]),    // output wire m_axis_tlast

    .wr_rst_busy(),      // output wire wr_rst_busy
    .rd_rst_busy(),      // output wire rd_rst_busy
    .s_aclk(clk125M),                // input wire s_aclk
    .s_aresetn(eth_phy_rst[2])          // input wire s_aresetn
);

eth_txfifo eth3_txfifo (
    .s_axis_tready(),  // output wire s_axis_tready
    .s_axis_tdata(rgmii_rx_data_o[2]),    // input wire [7 : 0] s_axis_tdata
    .s_axis_tvalid(rgmii_rx_den_o[2]),  // input wire s_axis_tvalid
    .s_axis_tuser({rgmii_rx_sof_o[2]}),    // input wire [0 : 0] s_axis_tuser
    .s_axis_tlast(rgmii_rx_eof_o[2]),    // input wire s_axis_tlast

    .m_axis_tready(mac_tx_ack[3][0]),  // input wire m_axis_tready
    .m_axis_tdata(test_mac_tx_tdata [3]),    // output wire [7 : 0] m_axis_tdata
    .m_axis_tvalid(test_mac_tx_tvalid[3]),  // output wire m_axis_tvalid
    .m_axis_tuser({test_mac_tx_tuser [3]}),    // output wire [0 : 0] m_axis_tuser
    .m_axis_tlast(test_mac_tx_tlast [3]),    // output wire m_axis_tlast

    .wr_rst_busy(),      // output wire wr_rst_busy
    .rd_rst_busy(),      // output wire rd_rst_busy
    .s_aclk(clk125M),                // input wire s_aclk
    .s_aresetn(eth_phy_rst[3])          // input wire s_aresetn
);

ila_1 ila_125M_tx (
    .probe0({
        mac_link[3],
        mac_tx_ack[0][0],
        test_mac_tx_tdata[0],           //11
        test_mac_tx_tvalid[0],         //3
        test_mac_tx_tuser[0], //sof   //2
        test_mac_tx_tlast[0]  //eof  //1
    }),
    .clk(clk125M)
);

ila_1 ila_125M_rx (
    .probe0({
        // dbg_fo[3][0],//assign dbg[0] = wFIFOValid;
        // dbg_fo[3][1],//assign dbg[1] = FIFOValidDelay[0];
        // dbg_fo[3][2],//assign dbg[2] = wFIFODat[8];
        mac_link[1],
        dbg_fo[31], //output [3:0]
        dbg_fo_dcnt[1], //output [9:0]
        dbg_fo_rd_data_count[1], //output [6:0]
        mac_rx_cnterr[1][9:0],
        rgmii_rx_data_o[1],
        rgmii_rx_den_o [1],
        rgmii_rx_sof_o [1],
        rgmii_rx_eof_o [1]
    }),
    .clk(clk125M)
);

// ila_1 ila_375M (
//     .probe0({
//         dbg_fi_wRGMII_Clk[3],
//         dbg_fi_wDataDDRL[3],
//         dbg_fi_wDataDDRH[3],
//         dbg_fi_wCondition[3],
//         dbg_fi_LoadDDREnaD0[3],
//         // dbg_fo[3][0],//assign dbg[0] = wFIFOValid;
//         // dbg_fo[3][1],//assign dbg[1] = FIFOValidDelay[0];
//         // dbg_fo[3][2],//assign dbg[2] = wFIFODat[8];
//         dbg_fi[3], //output [3:0]
//         dbg_fi_dcnt[3], //output [9:0]
//         dbg_fi_wr_data_count[3] //output [6:0]
//     }),
//     .clk(clk375M)
// );



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

// vio_0 vvv (
//     .probe_in0(test_mac_start[3:0]),    // input wire [3 : 0] probe_in0
//     .probe_in1(test_err[3:0]),    // input wire [3 : 0] probe_in1
//     .probe_in2(mac_rx_cnterr_aurclk[0][9:0]),    // input wire [9 : 0] probe_in2
//     .probe_in3(mac_rx_cnterr_aurclk[1][9:0]),    // input wire [9 : 0] probe_in3
//     .probe_in4(mac_rx_cnterr_aurclk[2][9:0]),    // input wire [9 : 0] probe_in4
//     .probe_in5(mac_rx_cnterr_aurclk[3][9:0]),    // input wire [9 : 0] probe_in5
//     .probe_out0(vio_test_start),  // output wire [7 : 0] probe_out0
//     .clk(aurora_usr_clk)
// );


// // //set channel for transfer test data
// test_phy test_rx_eth0 (
//     .mac_tx_data  (test_mac_tx_tdata [1]),
//     .mac_tx_valid (test_mac_tx_tvalid[1]),
//     .mac_tx_sof   (test_mac_tx_tuser [1]),
//     .mac_tx_eof   (test_mac_tx_tlast [1]),
//     .mac_tx_rdy   (test_mac_tx_tready[1]),

//     .mac_rx_data   (test_mac_rx_tdata [0]),
//     .mac_rx_valid  (test_mac_rx_tvalid[0]),
//     .mac_rx_sof    (test_mac_rx_tsof[0]),
//     .mac_rx_eof    (test_mac_rx_tlast[0]),
//     .mac_rx_fr_good(1'b1),
//     .mac_rx_fr_err (1'b0),

//     .start(test_mac_start[0]),
//     .pkt_size(test_mac_pkt_size),
//     .pause_size(test_mac_pause_size),
//     .err(test_err[0]),
//     .test_data(test_data[0]),

//     .clk(clk125M),
//     .rst(~mac_pll_locked)
// );

// test_phy test_rx_eth1 (
//     .mac_tx_data  (test_mac_tx_tdata [0]),
//     .mac_tx_valid (test_mac_tx_tvalid[0]),
//     .mac_tx_sof   (test_mac_tx_tuser [0]),
//     .mac_tx_eof   (test_mac_tx_tlast [0]),
//     .mac_tx_rdy   (test_mac_tx_tready[0]),

//     .mac_rx_data   (test_mac_rx_tdata [1]),
//     .mac_rx_valid  (test_mac_rx_tvalid[1]),
//     .mac_rx_sof    (test_mac_rx_tsof[1]),
//     .mac_rx_eof    (test_mac_rx_tlast[1]),
//     .mac_rx_fr_good(1'b1),
//     .mac_rx_fr_err (1'b0),

//     .start(test_mac_start[1]),
//     .pkt_size(test_mac_pkt_size),
//     .pause_size(test_mac_pause_size),
//     .err(test_err[1]),
//     .test_data(test_data[1]),

//     .clk(aurora_usr_clk),
//     .rst(~mac_pll_locked)
// );

// test_phy test_rx_eth2 (
//     .mac_tx_data  (test_mac_tx_tdata [3]),
//     .mac_tx_valid (test_mac_tx_tvalid[3]),
//     .mac_tx_sof   (test_mac_tx_tuser [3]),
//     .mac_tx_eof   (test_mac_tx_tlast [3]),
//     .mac_tx_rdy   (test_mac_tx_tready[3]),

//     .mac_rx_data   (test_mac_rx_tdata [2]),
//     .mac_rx_valid  (test_mac_rx_tvalid[2]),
//     .mac_rx_sof    (test_mac_rx_tsof[2]),
//     .mac_rx_eof    (test_mac_rx_tlast[2]),
//     .mac_rx_fr_good(1'b1),
//     .mac_rx_fr_err (1'b0),

//     .start(test_mac_start[2]),
//     .pkt_size(test_mac_pkt_size),
//     .pause_size(test_mac_pause_size),
//     .err(test_err[2]),
//     .test_data(test_data[2]),

//     .clk(aurora_usr_clk),
//     .rst(~mac_pll_locked)
// );

// test_phy test_rx_eth3 (
//     .mac_tx_data  (test_mac_tx_tdata [2]),
//     .mac_tx_valid (test_mac_tx_tvalid[2]),
//     .mac_tx_sof   (test_mac_tx_tuser [2]),
//     .mac_tx_eof   (test_mac_tx_tlast [2]),
//     .mac_tx_rdy   (test_mac_tx_tready[2]),

//     .mac_rx_data   (test_mac_rx_tdata [3]),
//     .mac_rx_valid  (test_mac_rx_tvalid[3]),
//     .mac_rx_sof    (test_mac_rx_tsof[3]),
//     .mac_rx_eof    (test_mac_rx_tlast[3]),
//     .mac_rx_fr_good(1'b1),
//     .mac_rx_fr_err (1'b0),

//     .start(test_mac_start[3]),
//     .pkt_size(test_mac_pkt_size),
//     .pause_size(test_mac_pause_size),
//     .err(test_err[3]),
//     .test_data(test_data[3]),

//     .clk(aurora_usr_clk),
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
    .p_in_clk   (clk125M), //(clk125M),//(sysclk25),
    .p_in_rst   (~mac_pll_locked)
);

assign dbg_led = clk125M;//led_blink & !gt_rst;// !test_gpio[0] & !aurora_gt_rst;// & test_err;

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
//             if (!mac_fifo_resetn[a]) begin
//                 mac_rx_cnterr[a] <= 0;
//             end else if (mac_rx_bd[a] | mac_rx_er[a]) begin
//                 mac_rx_cnterr[a] <= mac_rx_cnterr[a] + 1;
//             end
//         end
//     end
// endgenerate

// ila_0 usr_ila (
//     .probe0({
//         test_mac_tx_tdata [0],
//         test_mac_tx_tvalid[0],
//         test_mac_tx_tuser [0],
//         test_mac_tx_tlast [0],
//         test_data,
//         test_err,
//         test_mac_rx_tdata[0] ,
//         test_mac_rx_tvalid[0],
//         test_mac_rx_tlast[0]
//     }),
//     .clk(clk125M)
// );


endmodule

