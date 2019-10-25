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


eth_mac mac0 (
  .rx_statistics_vector(),        // output wire [27 : 0] rx_statistics_vector
  .rx_statistics_valid (),        // output wire rx_statistics_valid

  .rx_axis_mac_tdata (rx_axis_mac_tdata ),            // output wire [7 : 0] rx_axis_mac_tdata
  .rx_axis_mac_tvalid(rx_axis_mac_tvalid),            // output wire rx_axis_mac_tvalid
  .rx_axis_mac_tlast (rx_axis_mac_tlast ),            // output wire rx_axis_mac_tlast
  .rx_axis_mac_tuser (rx_axis_mac_tuser ),            // output wire rx_axis_mac_tuser

  .rx_mac_aclk(rx_mac_aclk),                          // output wire rx_mac_aclk
  .rx_reset   (rx_reset),                             // output wire rx_reset
  .rx_axi_rstn(rx_axi_rstn),                          // input wire rx_axi_rstn

  .tx_ifg_delay(0),               // input wire [7 : 0] tx_ifg_delay
  .tx_statistics_vector(),        // output wire [31 : 0] tx_statistics_vector
  .tx_statistics_valid (),        // output wire tx_statistics_valid

  .tx_axis_mac_tready(tx_axis_mac_tready),            // output wire tx_axis_mac_tready
  .tx_axis_mac_tdata (tx_axis_mac_tdata ),            // input wire [7 : 0] tx_axis_mac_tdata
  .tx_axis_mac_tvalid(tx_axis_mac_tvalid),            // input wire tx_axis_mac_tvalid
  .tx_axis_mac_tlast (tx_axis_mac_tlast ),            // input wire tx_axis_mac_tlast
  .tx_axis_mac_tuser (tx_axis_mac_tuser ),            // input wire [0 : 0] tx_axis_mac_tuser

  .tx_mac_aclk(tx_mac_aclk),                          // output wire tx_mac_aclk
  .tx_reset(tx_reset),                                // output wire tx_reset
  .tx_axi_rstn(tx_axi_rstn),                          // input wire tx_axi_rstn

  .pause_req(1'b0),                              // input wire pause_req
  .pause_val(0),                                // input wire [15 : 0] pause_val

  .rgmii_txd   (rgmii_txd   ),                        // output wire [3 : 0] rgmii_txd
  .rgmii_tx_ctl(rgmii_tx_ctl),                        // output wire rgmii_tx_ctl
  .rgmii_txc   (rgmii_txc   ),                        // output wire rgmii_txc

  .rgmii_rxd   (rgmii_rxd   ),                        // input wire [3 : 0] rgmii_rxd
  .rgmii_rx_ctl(rgmii_rx_ctl),                        // input wire rgmii_rx_ctl
  .rgmii_rxc   (rgmii_rxc   ),                        // input wire rgmii_rxc

  .inband_link_status  (),                // output wire inband_link_status
  .inband_clock_speed  (),                // output wire [1 : 0] inband_clock_speed
  .inband_duplex_status(),                // output wire inband_duplex_status

  .speedis100  (),                        // output wire speedis100
  .speedis10100(),                        // output wire speedis10100

  .rx_configuration_vector(mac_rx_cfg_vector),  // input wire [79 : 0] rx_configuration_vector
  .tx_configuration_vector(mac_tx_cfg_vector),  // input wire [79 : 0] tx_configuration_vector

  .gtx_clk  (gtx_clk),                                // input wire gtx_clk
  .gtx_clk90(gtx_clk90),                              // input wire gtx_clk90
  .glbl_rstn(glbl_rstn)                               // input wire glbl_rstn
);




endmodule

