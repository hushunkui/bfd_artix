//
// author: Golovachenko Victor
//

`timescale 1ns / 1ps

module main #(
    parameter SIM = 0
) (

);

wire sys_clk;
wire sys_rstn;

wire MDIO_0_mdio_i;
wire MDIO_0_mdio_o;
wire MDIO_0_mdio_t;

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


z_system system
    (.eth0_cfg_vector_rx(eth0_cfg_vector_rx),
    .eth0_cfg_vector_tx(eth0_cfg_vector_tx),
    .eth0_glbl_rstn(eth0_glbl_rstn),
    .eth0_gtx_clk(eth0_gtx_clk),
    .eth0_gtx_clk90(eth0_gtx_clk90),
    .eth0_m_axis_rx_tdata(eth0_m_axis_rx_tdata),
    .eth0_m_axis_rx_tlast(eth0_m_axis_rx_tlast),
    .eth0_m_axis_rx_tuser(eth0_m_axis_rx_tuser),
    .eth0_m_axis_rx_tvalid(eth0_m_axis_rx_tvalid),
    .eth0_rgmii_rd(eth0_rgmii_rd),
    .eth0_rgmii_rx_ctl(eth0_rgmii_rx_ctl),
    .eth0_rgmii_rxc(eth0_rgmii_rxc),
    .eth0_rgmii_status_duplex_status(eth0_rgmii_status_duplex_status),
    .eth0_rgmii_status_link_speed(eth0_rgmii_status_link_speed),
    .eth0_rgmii_status_link_status(eth0_rgmii_status_link_status),
    .eth0_rgmii_td(eth0_rgmii_td),
    .eth0_rgmii_tx_ctl(eth0_rgmii_tx_ctl),
    .eth0_rgmii_txc(eth0_rgmii_txc),
    .eth0_rx_axi_rstn(eth0_rx_axi_rstn),
    .eth0_rx_mac_aclk(eth0_rx_mac_aclk),
    .eth0_s_axis_pause_tdata(eth0_s_axis_pause_tdata),
    .eth0_s_axis_pause_tvalid(eth0_s_axis_pause_tvalid),
    .eth0_s_axis_tx_tdata(eth0_s_axis_tx_tdata),
    .eth0_s_axis_tx_tlast(eth0_s_axis_tx_tlast),
    .eth0_s_axis_tx_tready(eth0_s_axis_tx_tready),
    .eth0_s_axis_tx_tuser(eth0_s_axis_tx_tuser),
    .eth0_s_axis_tx_tvalid(eth0_s_axis_tx_tvalid),
    .eth0_statistics_rx_statistics_data(eth0_statistics_rx_statistics_data),
    .eth0_statistics_rx_statistics_valid(eth0_statistics_rx_statistics_valid),
    .eth0_statistics_tx_statistics_data(eth0_statistics_tx_statistics_data),
    .eth0_statistics_tx_statistics_valid(eth0_statistics_tx_statistics_valid),
    .eth0_tx_axi_rstn(eth0_tx_axi_rstn),
    .eth0_tx_ifg_delay(eth0_tx_ifg_delay),
    .eth0_tx_mac_aclk(eth0_tx_mac_aclk)
);




endmodule

