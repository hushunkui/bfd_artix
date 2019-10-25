//
// author: Golovachenko Victor
//

`timescale 1ns / 1ps

module main #(
    parameter ETHCOUNT = 1
    parameter SIM = 0
) (

  output [(ETHCOUNT*4)-1:0] rgmii_txd   ,
  output [ETHCOUNT-1:0]     rgmii_tx_ctl,
  output [ETHCOUNT-1:0]     rgmii_txc   ,
  input  [(ETHCOUNT*4)-1:0] rgmii_rxd   ,
  input  [ETHCOUNT-1:0]     rgmii_rx_ctl,
  input  [ETHCOUNT-1:0]     rgmii_rxc   ,

  input sysclk_p,
  input sysclk_n
);


wire [(ETHCOUNT*8)-1:0] mac_rx_axis_tdata ;
wire [ETHCOUNT-1:0]     mac_rx_axis_tvalid;
wire [ETHCOUNT-1:0]     mac_rx_axis_tlast ;
wire [ETHCOUNT-1:0]     mac_rx_axis_tuser ;
wire [ETHCOUNT-1:0]     mac_rx_aclk;
wire [ETHCOUNT-1:0]     mac_rx_reset;
wire [79:0]             mac_rx_cfg_vector;

wire [(ETHCOUNT*8)-1:0] mac_tx_axis_tdata ;
wire [ETHCOUNT-1:0]     mac_tx_axis_tvalid;
wire [ETHCOUNT-1:0]     mac_tx_axis_tlast ;
wire [ETHCOUNT-1:0]     mac_tx_axis_tuser ;
wire [ETHCOUNT-1:0]     mac_tx_axis_tready;
wire [ETHCOUNT-1:0]     mac_tx_aclk;
wire [ETHCOUNT-1:0]     mac_tx_reset;
wire [79:0]             mac_tx_cfg_vector;

wire sysrst;

assign sysrst = 1'b1;


eth_mac mac0 (
  .rx_statistics_vector(), // output wire [27 : 0] rx_statistics_vector
  .rx_statistics_valid (), // output wire rx_statistics_valid

  .rx_axis_mac_tdata (mac_rx_axis_tdata [0 +: 8]), // output wire [7 : 0] rx_axis_mac_tdata
  .rx_axis_mac_tvalid(mac_rx_axis_tvalid[0  : 0]), // output wire rx_axis_mac_tvalid
  .rx_axis_mac_tlast (mac_rx_axis_tlast [0  : 0]), // output wire rx_axis_mac_tlast
  .rx_axis_mac_tuser (mac_rx_axis_tuser [0  : 0]), // output wire rx_axis_mac_tuser

  .rx_mac_aclk(mac_rx_aclk[0:0]),  // output wire rx_mac_aclk
  .rx_reset   (mac_rx_reset[0:0]), // output wire rx_reset
  .rx_axi_rstn(1'b1),              // input wire rx_axi_rstn

  .tx_ifg_delay(0),        // input wire [7 : 0] tx_ifg_delay
  .tx_statistics_vector(), // output wire [31 : 0] tx_statistics_vector
  .tx_statistics_valid (), // output wire tx_statistics_valid

  .tx_axis_mac_tready(mac_tx_axis_tready[0  : 0]), // output wire tx_axis_mac_tready
  .tx_axis_mac_tdata (mac_tx_axis_tdata [0 +: 8]), // input wire [7 : 0] tx_axis_mac_tdata
  .tx_axis_mac_tvalid(mac_tx_axis_tvalid[0  : 0]), // input wire tx_axis_mac_tvalid
  .tx_axis_mac_tlast (mac_tx_axis_tlast [0  : 0]), // input wire tx_axis_mac_tlast
  .tx_axis_mac_tuser (mac_tx_axis_tuser [0  : 0]), // input wire [0 : 0] tx_axis_mac_tuser

  .tx_mac_aclk(mac_tx_aclk[0:0]), // output wire tx_mac_aclk
  .tx_reset(mac_tx_reset[0:0])    // output wire tx_reset
  .tx_axi_rstn(1'b1),             // input wire tx_axi_rstn

  .pause_req(1'b0),        // input wire pause_req
  .pause_val(0),           // input wire [15 : 0] pause_val

  .rgmii_txd   (rgmii_txd   [0 +: 4]), // output wire [3 : 0] rgmii_txd
  .rgmii_tx_ctl(rgmii_tx_ctl[0  : 0]), // output wire rgmii_tx_ctl
  .rgmii_txc   (rgmii_txc   [0  : 0]), // output wire rgmii_txc

  .rgmii_rxd   (rgmii_rxd   [0 +: 4]), // input wire [3 : 0] rgmii_rxd
  .rgmii_rx_ctl(rgmii_rx_ctl[0  : 0]), // input wire rgmii_rx_ctl
  .rgmii_rxc   (rgmii_rxc   [0  : 0]), // input wire rgmii_rxc

  .inband_link_status  (),     // output wire inband_link_status
  .inband_clock_speed  (),     // output wire [1 : 0] inband_clock_speed
  .inband_duplex_status(),     // output wire inband_duplex_status

  .speedis100  (),             // output wire speedis100
  .speedis10100(),             // output wire speedis10100

  .rx_configuration_vector(mac_rx_cfg_vector),  // input wire [79 : 0] rx_configuration_vector
  .tx_configuration_vector(mac_tx_cfg_vector),  // input wire [79 : 0] tx_configuration_vector

  .gtx_clk  (gtx_clk),      // input wire gtx_clk
  .gtx_clk90(gtx_clk90),    // input wire gtx_clk90
  .glbl_rstn(sysrst)        // input wire glbl_rstn
);




endmodule

