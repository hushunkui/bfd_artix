#
#author: Golovachenko Victor
#

#MODULE TE0714-02-35
#https://shop.trenz-electronic.de/en/TE0714-03-35-2I-FPGA-Module-with-Xilinx-Artix-7-XC7A35T-2CSG325I-3-3-V-Configuration-4-x-3-cm?c=366

set_property PACKAGE_PIN  H14    [get_ports {dbg_out[0]}]
set_property PACKAGE_PIN  D10    [get_ports {dbg_out[1]}]

set_property IOSTANDART LVCMOS33 [get_ports {dbg_out[0]}]
set_property IOSTANDART LVCMOS33 [get_ports {dbg_out[1]}]


set_property PACKAGE_PIN  T14    [get_ports {sysclk25}]
set_property IOSTANDART LVCMOS33 [get_ports {sysclk25}]
create_clock -period 40.000 -name sysclk25 -waveform {0.000 20.00} [get_ports sysclk25]

#set_property PACKAGE_PIN         [get_ports {spi_clk }]
set_property PACKAGE_PIN  L15    [get_ports {spi_cs  }]
set_property PACKAGE_PIN  K16    [get_ports {spi_mosi}]
set_property PACKAGE_PIN  L17    [get_ports {spi_miso}]
#set_property IOSTANDART LVCMOS33 [get_ports {spi_clk }]
set_property IOSTANDART LVCMOS33 [get_ports {spi_cs  }]
set_property IOSTANDART LVCMOS33 [get_ports {spi_mosi}]
set_property IOSTANDART LVCMOS33 [get_ports {spi_miso}]

set_property PACKAGE_PIN  K18    [get_ports {dbg_led}]
set_property IOSTANDART LVCMOS33 [get_ports {dbg_led}]

set_property PACKAGE_PIN  M15    [get_ports {mgt_pwr_en}]
set_property IOSTANDART LVCMOS33 [get_ports {mgt_pwr_en}]

set_property PACKAGE_PIN  R3     [get_ports {clk20_p}] #P/N on board swap
set_property IOSTANDART LVDS_25  [get_ports {clk20_p}]
create_clock -period 50.000 -name clk20_p -waveform {0.000 25.00} [get_ports clk20_p]

set_property PACKAGE_PIN  V8     [get_ports {uart_rx}]
set_property PACKAGE_PIN  V7     [get_ports {uart_tx}]
set_property IOSTANDART LVCMOS25 [get_ports {uart_rx}]
set_property IOSTANDART LVCMOS25 [get_ports {uart_tx}]

#ETHPHY MDIO
set_property PACKAGE_PIN  C11    [get_ports {eth_phy_mdio}]
set_property PACKAGE_PIN  B11    [get_ports {eth_phy_mdc}]
set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_mdio}]
set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_mdc}]

#ETH0 (POARTA)
set_property PACKAGE_PIN  A10    [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN  B10    [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN  A9     [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN  B9     [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN  B12    [get_ports {rgmii_tx_ctl[0]}]
set_property PACKAGE_PIN  A12    [get_ports {rgmii_tx_c[0]}]

set_property PACKAGE_PIN  A15    [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN  B14    [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN  A14    [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN  A13    [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN  C12    [get_ports {rgmii_rx_ctl[0]}]
set_property PACKAGE_PIN  D13    [get_ports {rgmii_rx_c[0]}]

set_property PACKAGE_PIN  C13    [get_ports {eth_phy_rst[0]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[0]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[1]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[2]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[3]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_ctl[0]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_c[0]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[0]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[3]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_ctl[0]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_c[0]}]

set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_rst[0]}]


#ETH1 (POARTB)
set_property PACKAGE_PIN  C14    [get_ports {rgmii_txd[4]}]
set_property PACKAGE_PIN  B15    [get_ports {rgmii_txd[5]}]
set_property PACKAGE_PIN  A17    [get_ports {rgmii_txd[6]}]
set_property PACKAGE_PIN  B16    [get_ports {rgmii_txd[7]}]
set_property PACKAGE_PIN  C16    [get_ports {rgmii_tx_ctl[1]}]
set_property PACKAGE_PIN  B17    [get_ports {rgmii_tx_c[1]}]

set_property PACKAGE_PIN  E17    [get_ports {rgmii_rxd[4]}]
set_property PACKAGE_PIN  D18    [get_ports {rgmii_rxd[5]}]
set_property PACKAGE_PIN  C17    [get_ports {rgmii_rxd[6]}]
set_property PACKAGE_PIN  C18    [get_ports {rgmii_rxd[7]}]
set_property PACKAGE_PIN  E13    [get_ports {rgmii_rx_ctl[1]}]
set_property PACKAGE_PIN  D14    [get_ports {rgmii_rx_c[1]}]

set_property PACKAGE_PIN  D16    [get_ports {eth_phy_rst[1]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[4]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[5]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[6]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[7]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_ctl[1]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_c[1]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[4]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[5]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[6]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[7]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_ctl[1]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_c[1]}]

set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_rst[1]}]

#ETH2 (POARTC)
set_property PACKAGE_PIN  E18    [get_ports {rgmii_txd[8]}]
set_property PACKAGE_PIN  F17    [get_ports {rgmii_txd[9]}]
set_property PACKAGE_PIN  F18    [get_ports {rgmii_txd[10]}]
set_property PACKAGE_PIN  G17    [get_ports {rgmii_txd[11]}]
set_property PACKAGE_PIN  G15    [get_ports {rgmii_tx_ctl[2]}]
set_property PACKAGE_PIN  F15    [get_ports {rgmii_tx_c[2]}]

set_property PACKAGE_PIN  L18    [get_ports {rgmii_rxd[8]}]
set_property PACKAGE_PIN  K17    [get_ports {rgmii_rxd[9]}]
set_property PACKAGE_PIN  H18    [get_ports {rgmii_rxd[10]}]
set_property PACKAGE_PIN  H17    [get_ports {rgmii_rxd[11]}]
set_property PACKAGE_PIN  M17    [get_ports {rgmii_rx_ctl[2]}]
set_property PACKAGE_PIN  D15    [get_ports {rgmii_rx_c[2]}]

set_property PACKAGE_PIN  E16    [get_ports {eth_phy_rst[2]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[8]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[9]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[10]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[11]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_ctl[2]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_c[2}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[8]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[9]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[10]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[11]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_ctl[2]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_c[2]}]

set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_rst[2]}]

#ETH3 (POARTD)
set_property PACKAGE_PIN  M16    [get_ports {rgmii_txd[12]}]
set_property PACKAGE_PIN  R18    [get_ports {rgmii_txd[13]}]
set_property PACKAGE_PIN  T18    [get_ports {rgmii_txd[14]}]
set_property PACKAGE_PIN  N18    [get_ports {rgmii_txd[15]}]
set_property PACKAGE_PIN  T17    [get_ports {rgmii_tx_ctl[3]}]
set_property PACKAGE_PIN  P18    [get_ports {rgmii_tx_c[3]}]

set_property PACKAGE_PIN  U16    [get_ports {rgmii_rxd[12]}]
set_property PACKAGE_PIN  V16    [get_ports {rgmii_rxd[13]}]
set_property PACKAGE_PIN  V17    [get_ports {rgmii_rxd[14]}]
set_property PACKAGE_PIN  U17    [get_ports {rgmii_rxd[15]}]
set_property PACKAGE_PIN  U15    [get_ports {rgmii_rx_ctl[3]}]
set_property PACKAGE_PIN  U14    [get_ports {rgmii_rx_c[3]}]

set_property PACKAGE_PIN  V14    [get_ports {eth_phy_rst[3]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[12]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[13]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[14]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_txd[15]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_ctl[3]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_tx_c[3]}]

set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[12]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[13]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[14]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rxd[15]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_ctl[3]}]
set_property IOSTANDART LVCMOS33 [get_ports {rgmii_rx_c[3]}]

set_property IOSTANDART LVCMOS33 [get_ports {eth_phy_rst[3]}]


#user lvds
set_property PACKAGE_PIN  L4     [get_ports {usr_lvds_p[0]}]
set_property PACKAGE_PIN  M4     [get_ports {usr_lvds_p[1]}]
set_property PACKAGE_PIN  N3     [get_ports {usr_lvds_p[2]}]
set_property PACKAGE_PIN  L5     [get_ports {usr_lvds_p[3]}]
set_property PACKAGE_PIN  M2     [get_ports {usr_lvds_p[4]}]
set_property PACKAGE_PIN  K2     [get_ports {usr_lvds_p[5]}]
set_property PACKAGE_PIN  R2     [get_ports {usr_lvds_p[6]}] #P/N on board swap
set_property PACKAGE_PIN  P4     [get_ports {usr_lvds_p[7]}]
set_property PACKAGE_PIN  U2     [get_ports {usr_lvds_p[8]}]
set_property PACKAGE_PIN  T4     [get_ports {usr_lvds_p[9]}] #P/N on board swap
set_property PACKAGE_PIN  R5     [get_ports {usr_lvds_p[10]}]
set_property PACKAGE_PIN  P6     [get_ports {usr_lvds_p[11]}]
set_property PACKAGE_PIN  U4     [get_ports {usr_lvds_p[12]}]#P/N on board swap
set_property PACKAGE_PIN  V3     [get_ports {usr_lvds_p[13]}]#P/N on board swap

set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[0]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[1]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[2]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[3]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[4]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[5]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[6]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[7]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[8]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[9]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[10]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[11]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[12]}]
set_property IOSTANDART LVDS_25  [get_ports {usr_lvds_p[13]}]
