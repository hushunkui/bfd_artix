
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
    output reg                eth_phy_mdc = 1'b0,

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

    output qspi_cs ,
    output qspi_io0,//mosi,
    input  qspi_io1,//miso,
    output qspi_io2,
    output qspi_io3,
    input  usr_spi_clk,
    input [1:0] usr_spi_cs,
    input  usr_spi_mosi,
    output usr_spi_miso,

    output dbg_led,
    output [1:0] dbg_out,

    input clk20_p,
    input clk20_n,

    input sysclk25
);

wire [3:0]              mac_link;

wire [7:0]              mac_rx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     mac_rx_tvalid;
wire [ETHCOUNT-1:0]     mac_rx_tlast;
wire [ETHCOUNT-1:0]     mac_rx_tuser;
wire [ETHCOUNT-1:0]     mac_rx_err;
wire [31:0]             mac_rx_cnterr [ETHCOUNT-1:0];

wire [7:0]              mac_tx_tdata [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     mac_tx_tvalid;
wire [ETHCOUNT-1:0]     mac_tx_tlast;
wire [ETHCOUNT-1:0]     mac_tx_tuser;
wire [0:0]              mac_tx_ack [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     mac_tx_rq;

wire [7:0]              dbg_rgmii_rx_data [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_den;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_sof;
wire [ETHCOUNT-1:0]     dbg_rgmii_rx_eof;

wire [7:0]              dbg1_rgmii_rx_data [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0]     dbg1_rgmii_rx_den;
wire [ETHCOUNT-1:0]     dbg1_rgmii_rx_sof;
wire [ETHCOUNT-1:0]     dbg1_rgmii_rx_eof;

reg ethphy_mdio_data;
reg ethphy_mdio_dir;
wire [3:0] ethphy_rst;
wire [15:0] test_mac_pkt_size;
wire [15:0] test_mac_pause_size;

wire clk125M;
wire clk125M_p90;
wire clk375M;
wire clk200M;
wire mac_pll_locked;

wire aurora_axi_rx_tready;
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

wire [ETHCOUNT-1:0]      aurora_axi_rx_tready_eth;
wire [(ETHCOUNT*32)-1:0] aurora_axi_rx_tdata_eth;
wire [(ETHCOUNT*4-1):0]  aurora_axi_rx_tkeep_eth;
wire [ETHCOUNT-1:0]      aurora_axi_rx_tlast_eth;
wire [ETHCOUNT-1:0]      aurora_axi_rx_tvalid_eth;

wire [ETHCOUNT-1:0]      aurora_axi_tx_tready_eth;
wire [(ETHCOUNT*32)-1:0] aurora_axi_tx_tdata_eth;
wire [(ETHCOUNT*4-1):0]  aurora_axi_tx_tkeep_eth;
wire [ETHCOUNT-1:0]      aurora_axi_tx_tlast_eth;
wire [ETHCOUNT-1:0]      aurora_axi_tx_tvalid_eth;
wire [ETHCOUNT-1:0] aurora_status_channel_up_eth;

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
wire [1:0] sum_trunc;
reg [3:0] eth_rx_mask = 0;
wire eth_tx_sync;

wire usr_miso;
wire [(`FPGA_REG_DWIDTH * `FPGA_REG_COUNT)-1:0] reg_rd_data;
wire [7:0]  reg_wr_addr;
wire [15:0] reg_wr_data;
wire        reg_wr_en;

reg [`FPGA_REG_DWIDTH-1:0] reg_test_array [0:`FPGA_REG_TEST_ARRAY_COUNT-1];
reg [3:0] reg_eth_phy_rst = 4'd0;


wire sysrst;
assign sysrst = 1'b0;

assign mgt_pwr_en = 1'b1;
assign uart_tx = uart_rx;



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

clk25_wiz0 pll0(
    .clk_out1(clk200M),
    .clk_out2(clk125M),
    .clk_out3(clk375M),
    .clk_out4(clk125M_p90),
    .locked(mac_pll_locked),
    .clk_in1(sysclk25_g),
    .reset(sysrst)
);

wire [31:0] firmware_date;
wire [31:0] firmware_time;
firmware_rev m_firmware_rev (
   .firmware_date (firmware_date),
   .firmware_time (firmware_time)
);

wire [11:0]  device_temp;
mig_7series_v4_1_tempmon tempmon(
  .clk(clk125M),
  .xadc_clk(clk125M),
  .rst(1'b0),
  .device_temp_i(12'd0),
  .device_temp(device_temp)
);

system system_i(
    .aurora_axi_rx_tready(aurora_axi_rx_tready),
    .aurora_axi_rx_tdata(aurora_axi_rx_tdata), //output
    .aurora_axi_rx_tkeep(aurora_axi_rx_tkeep), //output
    .aurora_axi_rx_tvalid(aurora_axi_rx_tvalid),//output
    .aurora_axi_rx_tlast(aurora_axi_rx_tlast), //output
    .aurora_axi_tx_tready(aurora_axi_tx_tready),//output
    .aurora_axi_tx_tdata(aurora_axi_tx_tdata), //input
    .aurora_axi_tx_tkeep(aurora_axi_tx_tkeep), //input
    .aurora_axi_tx_tvalid(aurora_axi_tx_tvalid), //input
    .aurora_axi_tx_tlast(aurora_axi_tx_tlast), //input
    .aurora_control_power_down(1'b0),
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
    .firmware_date (firmware_date),
    .firmware_time (firmware_time),
    .test_gpio (test_gpio),
    .reg_ctrl (reg_ctrl),
    .status_aurora({30'd0, 1'b0, aurora_status_channel_up}),
    .status_eth({21'd0, 4'd0, mac_link[3:0], 3'd0}),
    .cnterr_eth0(mac_rx_cnterr[0]),
    .cnterr_eth1(mac_rx_cnterr[1]),
    .cnterr_eth2(mac_rx_cnterr[2]),
    .cnterr_eth3(mac_rx_cnterr[3]),
    .ethphy_mdio_clk_o(),//(eth_phy_mdc),
    .ethphy_mdio_data_o(),//(ethphy_mdio_data),
    .ethphy_mdio_dir_o(),//(ethphy_mdio_dir),
    .ethphy_mdio_data_i(1'b0),//(eth_phy_mdio),
    .ethphy_nrst_o(),
    .aurora_o_ctl_0(),
    .aurora_o_ctl_1(),
    .aurora_i_ctl_0(0),
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
    .reg_clk    (clk125M),
    .rst(~mac_pll_locked)
);

//Read User resisters
assign reg_rd_data[`FPGA_RREG_FIRMWARE_DATE * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = firmware_date;
assign reg_rd_data[`FPGA_RREG_FIRMWARE_TIME * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = firmware_time;
assign reg_rd_data[`FPGA_RREG_FIRMWARE_TYPE * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = `FPGA_FIRMWARE_UPDATE;
assign reg_rd_data[`FPGA_RREG_DEVICE_TEMP * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {4'd0, device_temp};
assign reg_rd_data[`FPGA_RREG_MAC_LINK * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = ({8'd0, 4'd0, mac_link[3:0]});
assign reg_rd_data[`FPGA_RREG_MAC0_RXERR * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = mac_rx_cnterr[0];
assign reg_rd_data[`FPGA_RREG_MAC1_RXERR * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = mac_rx_cnterr[1];
assign reg_rd_data[`FPGA_RREG_MAC2_RXERR * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = mac_rx_cnterr[2];
assign reg_rd_data[`FPGA_RREG_MAC3_RXERR * `FPGA_REG_DWIDTH +: (`FPGA_REG_DWIDTH*2)] = mac_rx_cnterr[3];
assign reg_rd_data[`FPGA_RREG_ETHPHY_RST * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = ({8'd0, 4'd0, reg_eth_phy_rst[3:0]});
assign reg_rd_data[`FPGA_RREG_ETHPHY_MDIO_CLK_O * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {15'd0, eth_phy_mdc};
assign reg_rd_data[`FPGA_RREG_ETHPHY_MDIO_DATA_O * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {15'd0, ethphy_mdio_data};
assign reg_rd_data[`FPGA_RREG_ETHPHY_MDIO_DIR_O * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {15'd0, ethphy_mdio_dir};
assign reg_rd_data[`FPGA_RREG_ETHPHY_MDIO_DATA_I * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {15'd0, eth_phy_mdio};
assign reg_rd_data[`FPGA_RREG_AURORA_STATUS * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {15'd0, aurora_status_channel_up};
assign reg_rd_data[`FPGA_RREG_ETH_RX_CTL * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = {12'd0, eth_rx_mask[3:0]};

genvar a;
generate
    for (a = 0; a < `FPGA_REG_TEST_ARRAY_COUNT; a = a + 1) begin
        assign reg_rd_data[(`FPGA_RREG_TEST_ARRAY + a) * `FPGA_REG_DWIDTH +: `FPGA_REG_DWIDTH] = reg_test_array[a];
    end
endgenerate

integer i;
//Write User resisters
always @ (posedge clk125M) begin
    for (i = 0; i < `FPGA_REG_TEST_ARRAY_COUNT; i = i + 1) begin
        if (reg_wr_en && (reg_wr_addr == (`FPGA_WREG_TEST_ARRAY + i))) reg_test_array[i] <= reg_wr_data;
    end

    if (reg_wr_en && (reg_wr_addr == `FPGA_WREG_ETHPHY_RST)) begin reg_eth_phy_rst <= reg_wr_data[3:0]; end
    if (reg_wr_en && (reg_wr_addr == `FPGA_WREG_ETHPHY_MDIO_CLK_O)) begin eth_phy_mdc <= reg_wr_data[0]; end
    if (reg_wr_en && (reg_wr_addr == `FPGA_WREG_ETHPHY_MDIO_DATA_O)) begin ethphy_mdio_data <= reg_wr_data[0]; end
    if (reg_wr_en && (reg_wr_addr == `FPGA_WREG_ETHPHY_MDIO_DIR_O)) begin ethphy_mdio_dir <= reg_wr_data[0]; end
    if (reg_wr_en && (reg_wr_addr == `FPGA_WREG_ETH_RX_CTL)) begin eth_rx_mask[3:0] <= reg_wr_data[3:0]; end
end

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
assign qspi_cs = usr_spi_cs[0];
assign qspi_io0 = usr_spi_mosi;
assign usr_spi_miso = (qspi_io1 | usr_spi_cs[0]) && (usr_miso | usr_spi_cs[1]);
assign qspi_io2 = 1'b1;
assign qspi_io3 = 1'b1;

assign eth_phy_mdio = (ethphy_mdio_dir) ? ethphy_mdio_data : 1'bz;
// assign eth_phy_mdio = 1'bz;
// assign eth_phy_mdc = 1'b0;


assign gt_rst = usr_lvds_p[0];
assign aurora_rst = usr_lvds_p[1];
assign eth_tx_sync = usr_lvds_p[2];
assign sum_trunc = usr_lvds_p[4:3];

assign usr_lvds_p_o[0] = mac_link[0];
assign usr_lvds_p_o[1] = mac_link[1];
assign usr_lvds_p_o[2] = mac_link[2];
assign usr_lvds_p_o[3] = mac_link[3];

//aurora_axi_rx -> mac_txbuf -> eth_mac
aurora_axi_rx_mux #(
    .ETHCOUNT(ETHCOUNT),
    .SIM(SIM)
) aurora_axi_rx_mux (
    // .axis_m_sel(3'd0),

    .axis_s_tready(aurora_axi_rx_tready), //output
    .axis_s_tdata (aurora_axi_rx_tdata ), //input [31:0]
    .axis_s_tkeep (aurora_axi_rx_tkeep ), //input [3:0]
    .axis_s_tvalid(aurora_axi_rx_tvalid), //input
    .axis_s_tlast (aurora_axi_rx_tlast ), //input

    .axis_m_tready(aurora_axi_rx_tready_eth ), //input [ETHCOUNT-1:0]
    .axis_m_tdata (aurora_axi_rx_tdata_eth  ), //output [(ETHCOUNT*32)-1:0]
    .axis_m_tkeep (aurora_axi_rx_tkeep_eth  ), //output [(ETHCOUNT*4-1):0]
    .axis_m_tvalid(aurora_axi_rx_tvalid_eth ), //output [ETHCOUNT-1:0]
    .axis_m_tlast (aurora_axi_rx_tlast_eth  ), //output [ETHCOUNT-1:0]

    .rstn(mac_pll_locked),
    .clk(clk125M)
);

//aurora_axi_tx <- mac_rxbuf <- eth_mac
aurora_axi_tx_mux #(
    .ETHCOUNT(ETHCOUNT),
    .SIM(SIM)
) aurora_axi_tx_mux (
    .trunc(sum_trunc),
    .eth_mask(eth_rx_mask),

    .axis_s_tready(aurora_axi_tx_tready_eth), //output [ETHCOUNT-1:0]
    .axis_s_tdata ({aurora_axi_tx_tdata_eth [(0*32) +:32],
                    aurora_axi_tx_tdata_eth [(0*32) +:32],
                    aurora_axi_tx_tdata_eth [(0*32) +:32],
                    aurora_axi_tx_tdata_eth [(0*32) +:32]} ), //input  [(ETHCOUNT*32)-1:0]

    .axis_s_tkeep ({aurora_axi_tx_tkeep_eth [(0*4) +:4],
                    aurora_axi_tx_tkeep_eth [(0*4) +:4],
                    aurora_axi_tx_tkeep_eth [(0*4) +:4],
                    aurora_axi_tx_tkeep_eth [(0*4) +:4]}), //input  [(ETHCOUNT*4-1):0]

    .axis_s_tvalid({aurora_axi_tx_tvalid_eth[0],
                    aurora_axi_tx_tvalid_eth[0],
                    aurora_axi_tx_tvalid_eth[0],
                    aurora_axi_tx_tvalid_eth[0]}), //input  [ETHCOUNT-1:0]

    .axis_s_tlast ({aurora_axi_tx_tlast_eth[0],
                    aurora_axi_tx_tlast_eth[0],
                    aurora_axi_tx_tlast_eth[0],
                    aurora_axi_tx_tlast_eth[0]}), //input  [ETHCOUNT-1:0]

    .axis_m_tready(aurora_axi_tx_tready), //input
    .axis_m_tdata (aurora_axi_tx_tdata ), //output[31:0]
    .axis_m_tkeep (aurora_axi_tx_tkeep ), //output[3:0]
    .axis_m_tvalid(aurora_axi_tx_tvalid), //output
    .axis_m_tlast (aurora_axi_tx_tlast ), //output

    .rstn(mac_pll_locked),
    .clk(clk125M)
);

genvar x;
generate
    for (x=0; x < ETHCOUNT; x=x+1)  begin : eth
        assign eth_phy_rst[x] = mac_pll_locked;

        mac_txbuf # (
            .SIM(SIM)
        ) txbuf (
            .synch(eth_tx_sync),

            .axis_tready(),
            .axis_tdata (aurora_axi_rx_tdata_eth [(x*32) +: 32]), //input [31:0]
            .axis_tkeep (aurora_axi_rx_tkeep_eth [(x*4) +: 4]), //input [3:0]
            .axis_tvalid(aurora_axi_rx_tvalid_eth[x]), //input
            .axis_tlast (aurora_axi_rx_tlast_eth [x]), //input

            .mac_tx_data (mac_tx_tdata [x]), //output [7:0]
            .mac_tx_valid(mac_tx_tvalid[x]), //output
            .mac_tx_sof  (mac_tx_tuser [x]), //output
            .mac_tx_eof  (mac_tx_tlast [x]), //output
            .mac_tx_rq   (mac_tx_rq    [x]),
            .mac_tx_ack  (mac_tx_ack   [x][0]),

            .rstn(mac_pll_locked),
            .clk(clk125M)
        );

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

            .dbg_rgmii_rx_data(dbg_rgmii_rx_data[x]),//(),//
            .dbg_rgmii_rx_den (dbg_rgmii_rx_den [x]),//(),//
            .dbg_rgmii_rx_sof (dbg_rgmii_rx_sof [x]),//(),//
            .dbg_rgmii_rx_eof (dbg_rgmii_rx_eof [x]),//(),//
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
            .SOF_OUT (mac_rx_tuser [x]), //output
            .EOF_OUT (mac_rx_tlast [x]), //output
            .ENA_OUT (mac_rx_tvalid[x]), //output
            .ERR_OUT (mac_rx_err   [x]), //output
            .DATA_OUT(mac_rx_tdata [x]), //output  [7 :0]
            .InputCRC_ErrorCounter(mac_rx_cnterr[x]) //output  [31 :0]
        );

        // mac_rx_cut_macframe_no_crc # (
        //     .SIM(0)
        // ) mac_rx_cut (
        //     .mac_rx_data_i (dbg_rgmii_rx_data[x]),//mac_rx_tdata [x]),//
        //     .mac_rx_valid_i(dbg_rgmii_rx_den [x]),//mac_rx_tvalid[x]),//
        //     .mac_rx_sof_i  (dbg_rgmii_rx_sof [x]),//mac_rx_tuser [x]),//
        //     .mac_rx_eof_i  (dbg_rgmii_rx_eof [x]),//mac_rx_tlast [x]),//

        //     .mac_rx_data_o (dbg1_rgmii_rx_data[x]),//
        //     .mac_rx_valid_o(dbg1_rgmii_rx_den [x]),//
        //     .mac_rx_sof_o  (dbg1_rgmii_rx_sof [x]),//
        //     .mac_rx_eof_o  (dbg1_rgmii_rx_eof [x]),//

        //     .rstn(mac_pll_locked),
        //     .clk(clk125M)
        // );
        assign dbg1_rgmii_rx_data[x] = mac_rx_tdata [x];
        assign dbg1_rgmii_rx_den [x] = mac_rx_tvalid[x];
        assign dbg1_rgmii_rx_sof [x] = mac_rx_tuser [x];
        assign dbg1_rgmii_rx_eof [x] = mac_rx_tlast [x];

        mac_rxbuf # (
            .SIM(SIM)
        ) rxbuf (
            .axis_tready(aurora_axi_tx_tready_eth[x]), //input
            .axis_tdata (aurora_axi_tx_tdata_eth [(x*32) +: 32]), //output [31:0]
            .axis_tkeep (aurora_axi_tx_tkeep_eth [(x*4) +: 4]), //output [3:0]
            .axis_tvalid(aurora_axi_tx_tvalid_eth[x]), //output
            .axis_tlast (aurora_axi_tx_tlast_eth [x]), //output

            .mac_rx_data (dbg1_rgmii_rx_data[x]),//(mac_rx_tdata [x]), //input [7:0]
            .mac_rx_valid(dbg1_rgmii_rx_den [x]),//(mac_rx_tvalid[x]), //input
            .mac_rx_sof  (dbg1_rgmii_rx_sof [x]),//(mac_rx_tuser [x]), //input
            .mac_rx_eof  (dbg1_rgmii_rx_eof [x]),//(mac_rx_tlast [x]), //input
            .mac_rx_err  (1'b0                 ),//(mac_rx_err   [x]), //input

            .rstn(mac_pll_locked),
            .clk(clk125M)
        );
    end
endgenerate

ila_0 rx_ila (
    .probe0({
        aurora_axi_rx_tready,
        aurora_axi_rx_tdata,
        aurora_axi_rx_tkeep,
        aurora_axi_rx_tvalid,
        aurora_axi_rx_tlast,

        // mac_tx_rq    [1],
        // mac_tx_ack   [1][0],
        // mac_tx_tdata [1],
        // mac_tx_tvalid[1],
        // mac_tx_tuser [1],
        // mac_tx_tlast [1],

        // mac_rx_tdata [1],
        // mac_rx_tvalid[1],
        // mac_rx_tuser [1],
        // mac_rx_tlast [1],

        mac_tx_rq    [0],
        mac_tx_ack   [0][0],
        mac_tx_tdata [0],
        mac_tx_tvalid[0],
        mac_tx_tuser [0],
        mac_tx_tlast [0],

        mac_tx_rq    [1],
        mac_tx_ack   [1][0],
        mac_tx_tdata [1],
        mac_tx_tvalid[1],
        mac_tx_tuser [1],
        mac_tx_tlast [1],

        eth_tx_sync,

        // mac_rx_tdata [0],
        // mac_rx_tvalid[0],
        // mac_rx_tuser [0],
        // mac_rx_tlast [0]

        aurora_axi_tx_tready_eth[1],
        // aurora_axi_tx_tdata_eth [1],
        // aurora_axi_tx_tkeep_eth [1],
        aurora_axi_tx_tvalid_eth[1],
        aurora_axi_tx_tlast_eth [1],

        aurora_axi_tx_tready, //input
        // aurora_axi_tx_tdata , //output[31:0]
        // aurora_axi_tx_tkeep , //output[3:0]
        aurora_axi_tx_tvalid, //output
        aurora_axi_tx_tlast , //output

        dbg1_rgmii_rx_data[0],
        dbg1_rgmii_rx_den [0],
        dbg1_rgmii_rx_sof [0],
        dbg1_rgmii_rx_eof [0],

        dbg1_rgmii_rx_data[1],
        dbg1_rgmii_rx_den [1],
        dbg1_rgmii_rx_sof [1],
        dbg1_rgmii_rx_eof [1],

        dbg_rgmii_rx_data[1],
        dbg_rgmii_rx_den [1],
        dbg_rgmii_rx_sof [1],
        dbg_rgmii_rx_eof [1]
    }),
    .clk(clk125M)
);
// ila_0 tx_ila (
//     .probe0({
//         mac_rx_tvalid[0],
//         tx_fifo_tvalid[0],
//         eth_en,
//         sum_trunc,
//         aurora_status_channel_up,
//         {aurora_status_lane_up[0]},

//         aurora_axi_rx_tdata [(0*8) +: 8],
//         aurora_axi_rx_tvalid,
//         aurora_axi_rx_tlast ,

//         aurora_axi_rx_tdata_eth [0][(0*8) +: 8],
//         aurora_axi_rx_tvalid_eth[0]            ,
//         aurora_axi_rx_tlast_eth [0]            ,

//         aurora_axi_tx_tready,
//         aurora_axi_tx_tdata [(0*8) +: 8],
//         aurora_axi_tx_tkeep ,
//         aurora_axi_tx_tvalid,
//         aurora_axi_tx_tlast ,

//         aurora_axi_tx_tready_eth[0]            ,
//         aurora_axi_tx_tdata_eth [0][(0*8) +: 8],
//         aurora_axi_tx_tvalid_eth[0]            ,
//         aurora_axi_tx_tlast_eth [0]
//     }),
//     .clk(clk125M)
// );


//----------------------------------
//DEBUG
//----------------------------------
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
    .p_in_clk   (clk125M),
    .p_in_rst   (~mac_pll_locked)
);

// reg clk20_div = 1'b0;
// always @(posedge clk20_g) begin
//     clk20_div <= ~clk20_div;
// end

assign dbg_out[0] = 1'b0;
assign dbg_out[1] = reg_ctrl[0];


endmodule
