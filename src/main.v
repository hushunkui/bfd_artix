
//
// author: Golovachenko Viktor
//
`timescale 1ns / 1ps

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

    output qspi_cs  ,
    output qspi_mosi,
    output qspi_miso,
    input  usr_spi_clk ,
    input  usr_spi_cs  ,
    input  usr_spi_mosi,
    output usr_spi_miso,

    output dbg_led,
    output [1:0] dbg_out,

    input clk20_p,
    input clk20_n,

    input sysclk25
);

wire [63:0] probe;

// wire [ETHCOUNT-1:0] mac_rx_ok;
// wire [ETHCOUNT-1:0] mac_rx_bd;
// wire [ETHCOUNT-1:0] mac_rx_er;
// wire [ETHCOUNT-1:0] mac_rx_fr_good_dbg;

// wire usr_spi_clk ;
// wire usr_spi_cs  ;
// wire usr_spi_mosi;
// wire usr_spi_miso;

wire [ETHCOUNT-1:0]     mac_fifo_resetn;
wire [3:0]              mac_link;

reg  [7:0]              mac_rx_tdata [ETHCOUNT-1:0];
reg  [ETHCOUNT-1:0]     mac_rx_tvalid= 0;
reg  [ETHCOUNT-1:0]     mac_rx_tlast = 0;
reg  [ETHCOUNT-1:0]     mac_rx_tuser = 0;
wire [ETHCOUNT-1:0]     mac_rx_err;
wire [31:0]             mac_rx_cnterr [ETHCOUNT-1:0];

reg  [7:0]              mac_tx_tdata [ETHCOUNT-1:0];// = 0;
reg  [ETHCOUNT-1:0]     mac_tx_tvalid = 0;
reg  [ETHCOUNT-1:0]     mac_tx_tlast  = 0;
reg  [ETHCOUNT-1:0]     mac_tx_tuser  = 0;
wire [0:0]              mac_tx_ack [ETHCOUNT-1:0];
reg [ETHCOUNT-1:0]      mac_tx_rq = 0;

reg [ETHCOUNT-1:0]      tx_fifo_tready = 0;
wire [7:0]              tx_fifo_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     tx_fifo_tvalid;
wire [ETHCOUNT-1:0]     tx_fifo_tlast ;
wire [ETHCOUNT-1:0]     tx_fifo_tuser ;
reg [ETHCOUNT-1:0]      sr_tx_fifo_tready = 0;

wire [3:0]              rx_fifo_status  [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     rx_fifo_overflow;

wire [7:0]              dbg_rgmii_rx_data [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_den;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_sof;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_eof;

reg [7:0] rgmii_rx_data_i [ETHCOUNT-1:0];
reg [ETHCOUNT-1:0] rgmii_rx_den_i = 0;
reg [ETHCOUNT-1:0] rgmii_rx_sof_i = 0;
reg [ETHCOUNT-1:0] rgmii_rx_eof_i = 0;

reg [7:0] sr00_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr01_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr02_rgmii_rx_data [ETHCOUNT-1:0];
reg [7:0] sr03_rgmii_rx_data [ETHCOUNT-1:0];

reg [ETHCOUNT-1:0] sr00_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr01_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr02_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr03_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr04_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr05_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr06_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr07_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr08_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr09_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr10_rgmii_rx_den = 0;
reg [ETHCOUNT-1:0] sr11_rgmii_rx_den = 0;

reg [ETHCOUNT-1:0] sr00_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr01_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr02_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr03_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr04_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr05_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr06_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr07_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr08_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr09_rgmii_rx_sof  = 0;
reg [ETHCOUNT-1:0] sr10_rgmii_rx_sof = 0;
reg [ETHCOUNT-1:0] sr11_rgmii_rx_sof = 0;

reg [7:0] rgmii_rx_data_o [ETHCOUNT-1:0] ;
reg [ETHCOUNT-1:0] rgmii_rx_den_o = 0;
reg [ETHCOUNT-1:0] rgmii_rx_sof_o = 0;
reg [ETHCOUNT-1:0] rgmii_rx_eof_o = 0;

wire ethphy_mdio_data;
wire ethphy_mdio_dir;
wire [3:0] ethphy_rst;
wire [15:0] test_mac_pkt_size;
wire [15:0] test_mac_pause_size;

wire clk125M;
wire clk125M_p90;
wire clk375M;
wire clk200M;
wire mac_pll_locked;

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
wire aurora_user_clk;

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

wire [7:0] test_gpio;
wire [31:0] reg_ctrl;
wire test_err;

wire [1:0] eth_num;
wire [3:0] eth_en;
wire  module_en;



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

clk25_wiz0 pll0(
    .clk_out1(clk200M),//(clk125M),
    .clk_out2(clk125M),//(clk125M_p90),
    .clk_out3(clk375M),
    .clk_out4(clk125M_p90),
    .locked(mac_pll_locked),
    .clk_in1(sysclk25_g),
    .reset(sysrst)
);


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
    .aurora_status_pll_not_locked_out(aurora_status_pll_not_locked_out),
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
    .aurora_usr_clk(aurora_user_clk),

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
    .status_eth({21'd0, 4'd0, mac_link[3:0], 3'd0}),
    .cnterr_eth0(mac_rx_cnterr[0]),
    .cnterr_eth1(mac_rx_cnterr[1]),
    .cnterr_eth2(mac_rx_cnterr[2]),
    .cnterr_eth3(mac_rx_cnterr[3]),
    .ethphy_mdio_clk_o(eth_phy_mdc),
    .ethphy_mdio_data_o(ethphy_mdio_data),
    .ethphy_mdio_dir_o(ethphy_mdio_dir),
    .ethphy_mdio_data_i(eth_phy_mdio),
    .ethphy_nrst_o(),//(ethphy_rst),
    .aurora_o_ctl_0(),//(aurora_axi_tx_tdata),
    .aurora_o_ctl_1(),//({aurora_axi_tx_tlast, aurora_axi_tx_tvalid}),
    .aurora_i_ctl_0(0),//((aurora_axi_rx_tlast & aurora_axi_rx_tvalid) ? aurora_axi_rx_tdata : 0),
    .ethphy_test_pkt_size(),//(test_mac_pkt_size),
    .ethphy_test_pause_size(),//(test_mac_pause_size),

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

assign mgt_pwr_en = 1'b1;

assign uart_tx = uart_rx;

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
    .USRCCLKO(usr_spi_clk), //(test_gpio[1]),// 1-bit input: User CCLK input
                            // For Zynq-7000 devices, this input must be tied to GND
    .USRCCLKTS(1'b0),       // 1-bit input: User CCLK 3-state enable input
                            // For Zynq-7000 devices, this input must be tied to VCC
    .USRDONEO(1'b1),        // 1-bit input: User DONE pin output control
    .USRDONETS(1'b1)        // 1-bit input: User DONE 3-state enable output
);

assign qspi_cs = usr_spi_cs;//test_gpio[0];//
assign qspi_mosi = usr_spi_mosi;//test_gpio[2];//
assign usr_spi_miso = qspi_miso;

assign eth_phy_mdio = (ethphy_mdio_dir) ? ethphy_mdio_data : 1'bz;
// assign eth_phy_mdio = 1'bz;
// assign eth_phy_mdc = 1'b0;

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


assign aurora_axi_tx_tdata  = (module_en && (eth_num == 2'd0)) ? aurora_axi_tx_tdata_eth[0][(0*8) +: 8] :
                            (module_en && (eth_num == 2'd1)) ? aurora_axi_tx_tdata_eth[1][(0*8) +: 8] :
                            (module_en && (eth_num == 2'd2)) ? aurora_axi_tx_tdata_eth[2][(0*8) +: 8] : aurora_axi_tx_tdata_eth[3][(0*8) +: 8];

assign aurora_axi_tx_tvalid = (module_en && (eth_num == 2'd0)) ? aurora_axi_tx_tvalid_eth[0] :
                            (module_en && (eth_num == 2'd1)) ? aurora_axi_tx_tvalid_eth[1] :
                            (module_en && (eth_num == 2'd2)) ? aurora_axi_tx_tvalid_eth[2] :
                            (module_en && (eth_num == 2'd3)) ? aurora_axi_tx_tvalid_eth[3] : 1'b0;

assign aurora_axi_tx_tlast = (module_en && (eth_num == 2'd0)) ? aurora_axi_tx_tlast_eth[0] :
                            (module_en && (eth_num == 2'd1)) ? aurora_axi_tx_tlast_eth[1] :
                            (module_en && (eth_num == 2'd2)) ? aurora_axi_tx_tlast_eth[2] :
                            (module_en && (eth_num == 2'd3)) ? aurora_axi_tx_tlast_eth[3] : 1'b0;

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = mac_pll_locked;

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

            .ReqIn0 (mac_tx_rq    [x]),//input
            .DataIn0(mac_tx_tdata [x]),//input [7:0]
            .ValIn0 (mac_tx_tvalid[x]),//input
            .SoFIn0 (mac_tx_tuser [x]),//input
            .EoFIn0 (mac_tx_tlast [x]),//input

            .ReqConfirm(mac_tx_ack[x]),//output

            .dbg_rgmii_rx_data(dbg_rgmii_rx_data[x]),
            .dbg_rgmii_rx_den (dbg_rgmii_rx_den [x]),
            .dbg_rgmii_rx_sof (dbg_rgmii_rx_sof [x]),
            .dbg_rgmii_rx_eof (dbg_rgmii_rx_eof [x]),
            .dbg_fi(),//(dbg_fi[x]),
            .dbg_fi_dcnt(),//(dbg_fi_dcnt[x]),
            .dbg_fi_wr_data_count(),//(dbg_fi_wr_data_count[x]),
            .dbg_fo(),//(dbg_fo[x]),
            .dbg_fo_dcnt(),//(dbg_fo_dcnt[x]),
            .dbg_fo_rd_data_count(),//(dbg_fo_rd_data_count[x]),
            .dbg_fi_wRGMII_Clk(),//(dbg_fi_wRGMII_Clk[x]),
            .dbg_fi_wDataDDRL(),//(dbg_fi_wDataDDRL[x]),
            .dbg_fi_wDataDDRH(),//(dbg_fi_wDataDDRH[x]),
            .dbg_fi_wCondition(),//(dbg_fi_wCondition[x]),
            .dbg_fi_LoadDDREnaD0(),//(dbg_fi_LoadDDREnaD0[x]),
            .dbg_crc(),//(dbg_crc[x]),
            .dbg_crc_rdy(),//(dbg_crc_rdy[x]),
            .dbg_wDataCRCOut(),//(dbg_wDataCRCOut[x]),
            .dbg_wDataCRCVal(),//(dbg_wDataCRCVal[x]),
            .dbg_wDataCRCSoF(),//(dbg_wDataCRCSoF[x]),
            .dbg_wDataCRCEoF(),//(dbg_wDataCRCEoF[x]),

            .Remote_MACOut(), //output   [47:0]
            .Remote_IP_Out(), //output   [31:0]
            .RemotePortOut(), //output   [15:0]
            .SOF_OUT (),//(mac_rx_tuser [x]), //output
            .EOF_OUT (),//(mac_rx_tlast [x]), //output
            .ENA_OUT (),//(mac_rx_tvalid[x]), //output
            .ERR_OUT (),//(mac_rx_err   [x]), //output
            .DATA_OUT(),//(mac_rx_tdata [x]), //output  [7 :0]
            .InputCRC_ErrorCounter(mac_rx_cnterr[x]) //output  [31 :0]
        );

        //get txpkt from txfifo
        always @(posedge clk125M) begin
            if (tx_fifo_tvalid[x]) begin
                mac_tx_rq[x] <= 1'b1;
                if (mac_tx_ack[x][0]) begin
                    tx_fifo_tready[x] <= 1'b1;
                    if (tx_fifo_tlast[x]) begin
                        tx_fifo_tready[x] <= 1'b0;
                    end
                end
            end else begin
                mac_tx_rq[x] <= 1'b0;
                tx_fifo_tready[x] <= 1'b0;
            end
            sr_tx_fifo_tready[x] <= tx_fifo_tready[x];

            mac_tx_tdata[x] <= tx_fifo_tdata[x];
            mac_tx_tvalid[x] <= tx_fifo_tready[x];
            mac_tx_tuser[x] <= !sr_tx_fifo_tready[x] & tx_fifo_tready[x];//tx_fifo_tuser[x] & tx_fifo_tready[x];
            mac_tx_tlast[x] <= tx_fifo_tlast[x] & tx_fifo_tready[x];
        end

        //cut payload from rxdata
        always @ (posedge clk125M) begin
            rgmii_rx_data_i[x] <= dbg_rgmii_rx_data[x];
            rgmii_rx_den_i [x] <= dbg_rgmii_rx_den[x];
            rgmii_rx_sof_i [x] <= dbg_rgmii_rx_sof[x];
            rgmii_rx_eof_i [x] <= dbg_rgmii_rx_eof[x];

            sr00_rgmii_rx_data[x] <= rgmii_rx_data_i[x];
            sr01_rgmii_rx_data[x] <= sr00_rgmii_rx_data[x];
            sr02_rgmii_rx_data[x] <= sr01_rgmii_rx_data[x];
            sr03_rgmii_rx_data[x] <= sr02_rgmii_rx_data[x];

            sr00_rgmii_rx_den[x] <= rgmii_rx_den_i[x];
            sr01_rgmii_rx_den[x] <= sr00_rgmii_rx_den[x];
            sr02_rgmii_rx_den[x] <= sr01_rgmii_rx_den[x];
            sr03_rgmii_rx_den[x] <= sr02_rgmii_rx_den[x];
            sr04_rgmii_rx_den[x] <= sr03_rgmii_rx_den[x];
            sr05_rgmii_rx_den[x] <= sr04_rgmii_rx_den[x];
            sr06_rgmii_rx_den[x] <= sr05_rgmii_rx_den[x];
            sr07_rgmii_rx_den[x] <= sr06_rgmii_rx_den[x];
            sr08_rgmii_rx_den[x] <= sr07_rgmii_rx_den[x];
            sr09_rgmii_rx_den[x] <= sr08_rgmii_rx_den[x];
            sr10_rgmii_rx_den[x] <= sr09_rgmii_rx_den[x];
            sr11_rgmii_rx_den[x] <= sr10_rgmii_rx_den[x];

            sr00_rgmii_rx_sof[x] <= rgmii_rx_sof_i[x];
            sr01_rgmii_rx_sof[x] <= sr00_rgmii_rx_sof[x];
            sr02_rgmii_rx_sof[x] <= sr01_rgmii_rx_sof[x];
            sr03_rgmii_rx_sof[x] <= sr02_rgmii_rx_sof[x];
            sr04_rgmii_rx_sof[x] <= sr03_rgmii_rx_sof[x];
            sr05_rgmii_rx_sof[x] <= sr04_rgmii_rx_sof[x];
            sr06_rgmii_rx_sof[x] <= sr05_rgmii_rx_sof[x];
            sr07_rgmii_rx_sof[x] <= sr06_rgmii_rx_sof[x];
            sr08_rgmii_rx_sof[x] <= sr07_rgmii_rx_sof[x];
            sr09_rgmii_rx_sof[x] <= sr08_rgmii_rx_sof[x];
            sr10_rgmii_rx_sof[x] <= sr09_rgmii_rx_sof[x];
            sr11_rgmii_rx_sof[x] <= sr10_rgmii_rx_sof[x];

            mac_rx_tdata[x] <= sr03_rgmii_rx_data[x];
            mac_rx_tvalid[x] <= sr11_rgmii_rx_den[x] & rgmii_rx_den_i[x];
            mac_rx_tuser[x] <= sr11_rgmii_rx_sof[x];
            mac_rx_tlast[x] <= rgmii_rx_eof_i[x];
        end

        assign mac_fifo_resetn[x] = mac_link[x] && aurora_status_channel_up && eth_en[x];

        assign eth_en[x] = module_en && (eth_num == x);

        assign aurora_axi_rx_tdata_eth [x][(0*8) +: 8] = aurora_axi_rx_tdata[(0*8) +: 8];//input [7:0]
        assign aurora_axi_rx_tvalid_eth[x]             = aurora_axi_rx_tvalid;//input
        assign aurora_axi_rx_tlast_eth [x]             = aurora_axi_rx_tlast;//input

        assign aurora_axi_tx_tready_eth[x] = aurora_axi_tx_tready; //input

        mac_fifo fifo(
            //USER IF
            .tx_fifo_aclk       (aurora_user_clk), //input
            .tx_fifo_resetn     (mac_fifo_resetn[x]), //input
            .tx_axis_fifo_tdata (aurora_axi_rx_tdata_eth [x][(0*8) +: 8]),//input [7:0]
            .tx_axis_fifo_tvalid(aurora_axi_rx_tvalid_eth[x]            ),//input
            .tx_axis_fifo_tlast (aurora_axi_rx_tlast_eth [x]            ),//input
            .tx_axis_fifo_tready(), //output

            .rx_fifo_aclk       (aurora_user_clk), //input
            .rx_fifo_resetn     (mac_fifo_resetn[x]), //input
            .rx_axis_fifo_tready(aurora_axi_tx_tready_eth[x]            ), //input
            .rx_axis_fifo_tdata (aurora_axi_tx_tdata_eth [x][(0*8) +: 8]), //output [7:0]
            .rx_axis_fifo_tvalid(aurora_axi_tx_tvalid_eth[x]            ), //output
            .rx_axis_fifo_tlast (aurora_axi_tx_tlast_eth [x]            ), //output

            //MAC IF
            .tx_mac_aclk        (clk125M  ), //input
            .tx_mac_resetn      (mac_fifo_resetn[x]), //input
            .tx_axis_mac_tdata  (tx_fifo_tdata [x]), //output [7:0]
            .tx_axis_mac_tvalid (tx_fifo_tvalid[x]), //output
            .tx_axis_mac_tlast  (tx_fifo_tlast [x]), //output
            .tx_axis_mac_tready (tx_fifo_tready[x]), //input
            .tx_axis_mac_tuser  (),//(mac_tx_tuser ), //output
            .tx_axis_mac_sof    (tx_fifo_tuser [x]),
            .tx_fifo_overflow   (), //output
            .tx_fifo_status     (), //output   [3:0]
            .tx_collision       (1'b0), //input
            .tx_retransmit      (1'b0), //input

            .rx_mac_aclk        (clk125M),//input
            .rx_mac_resetn      (mac_fifo_resetn[x]),//input
            .rx_axis_mac_tdata  (mac_rx_tdata [x]),//input [7:0]
            .rx_axis_mac_tvalid (mac_rx_tvalid[x]),//input
            .rx_axis_mac_tlast  (mac_rx_tlast [x]),//input
            .rx_axis_mac_tuser  (1'b0),//(mac_rx_bd[x]),//input
            .rx_fifo_status     (rx_fifo_status[x]), //output   [3:0]
            .rx_fifo_overflow   (rx_fifo_overflow[x])  //output
        );

        // eth_fifo mac_rxfifo (
        //     .s_axis_tready(),  // output wire s_axis_tready
        //     .s_axis_tdata (mac_rx_tdata [x]),  // input wire [7 : 0] s_axis_tdata
        //     .s_axis_tvalid(mac_rx_tvalid[x]),  // input wire s_axis_tvalid
        //     .s_axis_tlast (mac_rx_tlast [x]),  // input wire s_axis_tlast
        //     // .s_axis_tuser ({mac_rx_tuser[x]}), // input wire [0 : 0] s_axis_tuser
        //     .s_aclk(clk125M),                // input wire s_aclk

        //     .m_axis_tready(aurora_axi_tx_tready_eth[x]),            //input wire m_axis_tready
        //     .m_axis_tdata (aurora_axi_tx_tdata_eth [x][(0*8) +: 8]),// output wire [7 : 0] m_axis_tdata
        //     .m_axis_tvalid(aurora_axi_tx_tvalid_eth[x] ),           // output wire m_axis_tvalid
        //     .m_axis_tlast (aurora_axi_tx_tlast_eth [x]),            // output wire m_axis_tlast
        //     // .m_axis_tuser (), // output wire [0 : 0] m_axis_tuser
        //     .m_aclk(aurora_user_clk),                // input wire m_aclk

        //     .wr_rst_busy(),      // output wire wr_rst_busy
        //     .rd_rst_busy(),      // output wire rd_rst_busy
        //     // .s_aclk(clk125M),                // input wire s_aclk
        //     .s_aresetn(mac_fifo_resetn[x])          // input wire s_aresetn
        // );

        // eth_fifo mac_txfifo (
        //     .s_axis_tready(),  // output wire s_axis_tready
        //     .s_axis_tdata (aurora_axi_rx_tdata_eth [x][(0*8) +: 8]),  // input wire [7 : 0] s_axis_tdata
        //     .s_axis_tvalid(aurora_axi_rx_tvalid_eth[x]            ),  // input wire s_axis_tvalid
        //     .s_axis_tlast (aurora_axi_rx_tlast_eth [x]            ),  // input wire s_axis_tlast
        //     // .s_axis_tuser (1'b0), // input wire [0 : 0] s_axis_tuser
        //     .s_aclk(aurora_user_clk),                // input wire s_aclk

        //     .m_axis_tready(tx_fifo_tready[x]),//input wire m_axis_tready
        //     .m_axis_tdata (tx_fifo_tdata [x]),// output wire [7 : 0] m_axis_tdata
        //     .m_axis_tvalid(tx_fifo_tvalid[x]),// output wire m_axis_tvalid
        //     .m_axis_tlast (tx_fifo_tlast [x]),// output wire m_axis_tlast
        //     // .m_axis_tuser (), // output wire [0 : 0] m_axis_tuser
        //     .m_aclk(clk125M),                // input wire m_aclk

        //     .wr_rst_busy(),      // output wire wr_rst_busy
        //     .rd_rst_busy(),      // output wire rd_rst_busy
        //     // .s_aclk(clk125M),                // input wire s_aclk
        //     .s_aresetn(mac_fifo_resetn[x]) // input wire s_aresetn
        // );
    end
endgenerate

ila_0 rx_ila (
    .probe0({
        mac_tx_rq[0],
        mac_tx_ack[0][0],
        mac_tx_tdata[0],
        mac_tx_tvalid[0],
        mac_tx_tuser[0],
        mac_tx_tlast[0],

        tx_fifo_tdata [0],
        tx_fifo_tvalid[0],
        tx_fifo_tlast [0],
        tx_fifo_tready[0],
        tx_fifo_tuser [0],

        mac_fifo_resetn[0],

        mac_rx_tdata [0],
        mac_rx_tvalid[0],
        mac_rx_tuser[0],
        mac_rx_tlast[0],
        dbg_rgmii_rx_data[0],
        dbg_rgmii_rx_den [0],
        dbg_rgmii_rx_sof [0],
        dbg_rgmii_rx_eof [0]
    }),
    .clk(clk125M)
);
ila_0 tx_ila (
    .probe0({
        mac_rx_tvalid[0],
        tx_fifo_tvalid[0],
        eth_en,
        eth_num,
        aurora_status_channel_up,
        {aurora_status_lane_up[0]},

        aurora_axi_rx_tdata [(0*8) +: 8],
        aurora_axi_rx_tvalid,
        aurora_axi_rx_tlast ,

        aurora_axi_rx_tdata_eth [0][(0*8) +: 8],
        aurora_axi_rx_tvalid_eth[0]            ,
        aurora_axi_rx_tlast_eth [0]            ,

        aurora_axi_tx_tready,
        aurora_axi_tx_tdata [(0*8) +: 8],
        aurora_axi_tx_tkeep ,
        aurora_axi_tx_tvalid,
        aurora_axi_tx_tlast ,

        aurora_axi_tx_tready_eth[0]            ,
        aurora_axi_tx_tdata_eth [0][(0*8) +: 8],
        aurora_axi_tx_tvalid_eth[0]            ,
        aurora_axi_tx_tlast_eth [0]
    }),
    .clk(aurora_user_clk)
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
    .p_in_clk   (clk125M), //(clk125M),//(sysclk25),
    .p_in_rst   (~mac_pll_locked)
);

assign dbg_led = led_blink & !gt_rst;//aurora_user_clk;//

reg clk20_div = 1'b0;
always @(posedge clk20_g) begin
    clk20_div <= ~clk20_div;
end

reg sysclk25_div = 1'b0;
always @(posedge sysclk25_g) begin
    sysclk25_div <= ~sysclk25_div;
end

assign dbg_out[0] = usr_spi_miso;//1'b0;
assign dbg_out[1] = clk20_div | sysclk25_div | led_blink | reg_ctrl[0];// &


endmodule
