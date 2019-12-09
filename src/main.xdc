#
#author: Golovachenko Viktor
#

#MODULE TE0714-02-35
#https://shop.trenz-electronic.de/en/TE0714-03-35-2I-FPGA-Module-with-Xilinx-Artix-7-XC7A35T-2CSG325I-3-3-V-Configuration-4-x-3-cm?c=366

set_property PACKAGE_PIN H14 [get_ports {dbg_out[0]}]
set_property PACKAGE_PIN D10 [get_ports {dbg_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dbg_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dbg_out[1]}]

set_property PACKAGE_PIN D6 [get_ports aurora_gt_refclk_clk_p]
set_property PACKAGE_PIN D2 [get_ports {aurora_gt_tx_txp[0]}]
#set_property PACKAGE_PIN B2 [get_ports {aurora_gt_tx_txp[1]}]

set_property PACKAGE_PIN T14 [get_ports sysclk25]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk25]
create_clock -period 40.000 -name sysclk25 -waveform {0.000 20.000} [get_ports sysclk25]

#set_property PACKAGE_PIN         [get_ports {spi_clk }]
set_property PACKAGE_PIN L15 [get_ports spi_cs]
set_property PACKAGE_PIN K16 [get_ports spi_mosi]
set_property PACKAGE_PIN L17 [get_ports spi_miso]
#set_property IOSTANDARD LVCMOS33 [get_ports {spi_clk }]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]

set_property PACKAGE_PIN K18 [get_ports dbg_led]
set_property IOSTANDARD LVCMOS33 [get_ports dbg_led]

set_property PACKAGE_PIN M15 [get_ports mgt_pwr_en]
set_property IOSTANDARD LVCMOS33 [get_ports mgt_pwr_en]

#P/N on board swap
set_property PACKAGE_PIN R3 [get_ports clk20_p]
set_property IOSTANDARD LVDS_25 [get_ports clk20_p]
create_clock -period 50.000 -name clk20_p -waveform {0.000 25.000} [get_ports clk20_p]

set_property PACKAGE_PIN V8 [get_ports uart_rx]
set_property PACKAGE_PIN V7 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS25 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS25 [get_ports uart_tx]

#ETHPHY MDIO
set_property PACKAGE_PIN C11 [get_ports eth_phy_mdio]
set_property PACKAGE_PIN B11 [get_ports eth_phy_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports eth_phy_mdio]
set_property IOSTANDARD LVCMOS33 [get_ports eth_phy_mdc]

#ETH0 (POARTA)
set_property PACKAGE_PIN A10 [get_ports {rgmii_txd[0]}]
set_property PACKAGE_PIN B10 [get_ports {rgmii_txd[1]}]
set_property PACKAGE_PIN A9 [get_ports {rgmii_txd[2]}]
set_property PACKAGE_PIN B9 [get_ports {rgmii_txd[3]}]
set_property PACKAGE_PIN B12 [get_ports {rgmii_tx_ctl[0]}]
set_property PACKAGE_PIN A12 [get_ports {rgmii_txc[0]}]
set_property PACKAGE_PIN A15 [get_ports {rgmii_rxd[0]}]
set_property PACKAGE_PIN B14 [get_ports {rgmii_rxd[1]}]
set_property PACKAGE_PIN A14 [get_ports {rgmii_rxd[2]}]
set_property PACKAGE_PIN A13 [get_ports {rgmii_rxd[3]}]
set_property PACKAGE_PIN C12 [get_ports {rgmii_rx_ctl[0]}]
set_property PACKAGE_PIN D13 [get_ports {rgmii_rxc[0]}]
set_property PACKAGE_PIN C13 [get_ports {eth_phy_rst[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[0]}]

set_property SLEW FAST [get_ports {rgmii_txd[0]}]
set_property SLEW FAST [get_ports {rgmii_txd[1]}]
set_property SLEW FAST [get_ports {rgmii_txd[2]}]
set_property SLEW FAST [get_ports {rgmii_txd[3]}]
set_property SLEW FAST [get_ports {rgmii_tx_ctl[0]}]
set_property SLEW FAST [get_ports {rgmii_txc[0]}]

#ETH1 (POARTB)
set_property PACKAGE_PIN C14 [get_ports {rgmii_txd[4]}]
set_property PACKAGE_PIN B15 [get_ports {rgmii_txd[5]}]
set_property PACKAGE_PIN A17 [get_ports {rgmii_txd[6]}]
set_property PACKAGE_PIN B16 [get_ports {rgmii_txd[7]}]
set_property PACKAGE_PIN C16 [get_ports {rgmii_tx_ctl[1]}]
set_property PACKAGE_PIN B17 [get_ports {rgmii_txc[1]}]
set_property PACKAGE_PIN E17 [get_ports {rgmii_rxd[4]}]
set_property PACKAGE_PIN D18 [get_ports {rgmii_rxd[5]}]
set_property PACKAGE_PIN C17 [get_ports {rgmii_rxd[6]}]
set_property PACKAGE_PIN C18 [get_ports {rgmii_rxd[7]}]
set_property PACKAGE_PIN E13 [get_ports {rgmii_rx_ctl[1]}]
set_property PACKAGE_PIN D14 [get_ports {rgmii_rxc[1]}]
set_property PACKAGE_PIN D16 [get_ports {eth_phy_rst[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[1]}]

set_property SLEW FAST [get_ports {rgmii_txd[4]}]
set_property SLEW FAST [get_ports {rgmii_txd[5]}]
set_property SLEW FAST [get_ports {rgmii_txd[6]}]
set_property SLEW FAST [get_ports {rgmii_txd[7]}]
set_property SLEW FAST [get_ports {rgmii_tx_ctl[1]}]
set_property SLEW FAST [get_ports {rgmii_txc[1]}]

##ETH1 (POARTB) test rx from PHY
#set_property PACKAGE_PIN C14 [get_ports {rgmii_txd[0]}]
#set_property PACKAGE_PIN B15 [get_ports {rgmii_txd[1]}]
#set_property PACKAGE_PIN A17 [get_ports {rgmii_txd[2]}]
#set_property PACKAGE_PIN B16 [get_ports {rgmii_txd[3]}]
#set_property PACKAGE_PIN C16 [get_ports {rgmii_tx_ctl[0]}]
#set_property PACKAGE_PIN B17 [get_ports {rgmii_txc[0]}]
#set_property PACKAGE_PIN E17 [get_ports {rgmii_rxd[0]}]
#set_property PACKAGE_PIN D18 [get_ports {rgmii_rxd[1]}]
#set_property PACKAGE_PIN C17 [get_ports {rgmii_rxd[2]}]
#set_property PACKAGE_PIN C18 [get_ports {rgmii_rxd[3]}]
#set_property PACKAGE_PIN E13 [get_ports {rgmii_rx_ctl[0]}]
#set_property PACKAGE_PIN D14 [get_ports {rgmii_rxc[0]}]
#set_property PACKAGE_PIN D16 [get_ports {eth_phy_rst[0]}]
#
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[0]}]
#
#set_property SLEW FAST [get_ports {rgmii_txd[0]}]
#set_property SLEW FAST [get_ports {rgmii_txd[1]}]
#set_property SLEW FAST [get_ports {rgmii_txd[2]}]
#set_property SLEW FAST [get_ports {rgmii_txd[3]}]
#set_property SLEW FAST [get_ports {rgmii_tx_ctl[0]}]
#set_property SLEW FAST [get_ports {rgmii_txc[0]}]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {rgmii_0/phy_rxc_ibuf}]

#ETH2 (POARTC)
set_property PACKAGE_PIN E18 [get_ports {rgmii_txd[8]}]
set_property PACKAGE_PIN F17 [get_ports {rgmii_txd[9]}]
set_property PACKAGE_PIN F18 [get_ports {rgmii_txd[10]}]
set_property PACKAGE_PIN G17 [get_ports {rgmii_txd[11]}]
set_property PACKAGE_PIN G15 [get_ports {rgmii_tx_ctl[2]}]
set_property PACKAGE_PIN F15 [get_ports {rgmii_txc[2]}]
set_property PACKAGE_PIN L18 [get_ports {rgmii_rxd[8]}]
set_property PACKAGE_PIN K17 [get_ports {rgmii_rxd[9]}]
set_property PACKAGE_PIN H18 [get_ports {rgmii_rxd[10]}]
set_property PACKAGE_PIN H17 [get_ports {rgmii_rxd[11]}]
set_property PACKAGE_PIN M17 [get_ports {rgmii_rx_ctl[2]}]
set_property PACKAGE_PIN D15 [get_ports {rgmii_rxc[2]}]
set_property PACKAGE_PIN E16 [get_ports {eth_phy_rst[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[2]}]

set_property SLEW FAST [get_ports {rgmii_txd[8]}]
set_property SLEW FAST [get_ports {rgmii_txd[9]}]
set_property SLEW FAST [get_ports {rgmii_txd[10]}]
set_property SLEW FAST [get_ports {rgmii_txd[11]}]
set_property SLEW FAST [get_ports {rgmii_tx_ctl[2]}]
set_property SLEW FAST [get_ports {rgmii_txc[2]}]

##ETH2 (POARTC) test rx from PHY
#set_property PACKAGE_PIN E18 [get_ports {rgmii_txd[0]}]
#set_property PACKAGE_PIN F17 [get_ports {rgmii_txd[1]}]
#set_property PACKAGE_PIN F18 [get_ports {rgmii_txd[2]}]
#set_property PACKAGE_PIN G17 [get_ports {rgmii_txd[3]}]
#set_property PACKAGE_PIN G15 [get_ports {rgmii_tx_ctl[0]}]
#set_property PACKAGE_PIN F15 [get_ports {rgmii_txc[0]}]
#set_property PACKAGE_PIN L18 [get_ports {rgmii_rxd[0]}]
#set_property PACKAGE_PIN K17 [get_ports {rgmii_rxd[1]}]
#set_property PACKAGE_PIN H18 [get_ports {rgmii_rxd[2]}]
#set_property PACKAGE_PIN H17 [get_ports {rgmii_rxd[3]}]
#set_property PACKAGE_PIN M17 [get_ports {rgmii_rx_ctl[0]}]
#set_property PACKAGE_PIN D15 [get_ports {rgmii_rxc[0]}]
#set_property PACKAGE_PIN E16 [get_ports {eth_phy_rst[0]}]
#
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[0]}]
#
#set_property SLEW FAST [get_ports {rgmii_txd[0]}]
#set_property SLEW FAST [get_ports {rgmii_txd[1]}]
#set_property SLEW FAST [get_ports {rgmii_txd[2]}]
#set_property SLEW FAST [get_ports {rgmii_txd[3]}]
#set_property SLEW FAST [get_ports {rgmii_tx_ctl[0]}]
#set_property SLEW FAST [get_ports {rgmii_txc[0]}]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {rgmii_0/phy_rxc_ibuf}]


#ETH3 (POARTD)
set_property PACKAGE_PIN M16 [get_ports {rgmii_txd[12]}]
set_property PACKAGE_PIN R18 [get_ports {rgmii_txd[13]}]
set_property PACKAGE_PIN T18 [get_ports {rgmii_txd[14]}]
set_property PACKAGE_PIN N18 [get_ports {rgmii_txd[15]}]
set_property PACKAGE_PIN T17 [get_ports {rgmii_tx_ctl[3]}]
set_property PACKAGE_PIN P18 [get_ports {rgmii_txc[3]}]
set_property PACKAGE_PIN U16 [get_ports {rgmii_rxd[12]}]
set_property PACKAGE_PIN V16 [get_ports {rgmii_rxd[13]}]
set_property PACKAGE_PIN V17 [get_ports {rgmii_rxd[14]}]
set_property PACKAGE_PIN U17 [get_ports {rgmii_rxd[15]}]
set_property PACKAGE_PIN U15 [get_ports {rgmii_rx_ctl[3]}]
set_property PACKAGE_PIN U14 [get_ports {rgmii_rxc[3]}]
set_property PACKAGE_PIN V14 [get_ports {eth_phy_rst[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[3]}]

set_property SLEW FAST [get_ports {rgmii_txd[12]}]
set_property SLEW FAST [get_ports {rgmii_txd[13]}]
set_property SLEW FAST [get_ports {rgmii_txd[14]}]
set_property SLEW FAST [get_ports {rgmii_txd[15]}]
set_property SLEW FAST [get_ports {rgmii_tx_ctl[3]}]
set_property SLEW FAST [get_ports {rgmii_txc[3]}]

##ETH3 (POARTD) test rx from PHY
#set_property PACKAGE_PIN M16 [get_ports {rgmii_txd[0]}]
#set_property PACKAGE_PIN R18 [get_ports {rgmii_txd[1]}]
#set_property PACKAGE_PIN T18 [get_ports {rgmii_txd[2]}]
#set_property PACKAGE_PIN N18 [get_ports {rgmii_txd[3]}]
#set_property PACKAGE_PIN T17 [get_ports {rgmii_tx_ctl[0]}]
#set_property PACKAGE_PIN P18 [get_ports {rgmii_txc[0]}]
#set_property PACKAGE_PIN U16 [get_ports {rgmii_rxd[0]}]
#set_property PACKAGE_PIN V16 [get_ports {rgmii_rxd[1]}]
#set_property PACKAGE_PIN V17 [get_ports {rgmii_rxd[2]}]
#set_property PACKAGE_PIN U17 [get_ports {rgmii_rxd[3]}]
#set_property PACKAGE_PIN U15 [get_ports {rgmii_rx_ctl[0]}]
#set_property PACKAGE_PIN U14 [get_ports {rgmii_rxc[0]}]
#set_property PACKAGE_PIN V14 [get_ports {eth_phy_rst[0]}]
#
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_tx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_txc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxd[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rx_ctl[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {rgmii_rxc[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {eth_phy_rst[0]}]
#
#set_property SLEW FAST [get_ports {rgmii_txd[0]}]
#set_property SLEW FAST [get_ports {rgmii_txd[1]}]
#set_property SLEW FAST [get_ports {rgmii_txd[2]}]
#set_property SLEW FAST [get_ports {rgmii_txd[3]}]
#set_property SLEW FAST [get_ports {rgmii_tx_ctl[0]}]
#set_property SLEW FAST [get_ports {rgmii_txc[0]}]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {rgmii_0/phy_rxc_ibuf}]


#user lvds
set_property PACKAGE_PIN L4 [get_ports {usr_lvds_p[0]}]
set_property PACKAGE_PIN M4 [get_ports {usr_lvds_p[1]}]
set_property PACKAGE_PIN N3 [get_ports {usr_lvds_p[2]}]
set_property PACKAGE_PIN L5 [get_ports {usr_lvds_p[3]}]
set_property PACKAGE_PIN M2 [get_ports {usr_lvds_p[4]}]
set_property PACKAGE_PIN K2 [get_ports {usr_lvds_p[5]}]
set_property PACKAGE_PIN R2 [get_ports {usr_lvds_p[6]}]
set_property PACKAGE_PIN P4 [get_ports {usr_lvds_p[7]}]
set_property PACKAGE_PIN U2 [get_ports {usr_lvds_p[8]}]
set_property PACKAGE_PIN T4 [get_ports {usr_lvds_p[9]}]
set_property PACKAGE_PIN R5 [get_ports {usr_lvds_p[10]}]
set_property PACKAGE_PIN P6 [get_ports {usr_lvds_p[11]}]
set_property PACKAGE_PIN U4 [get_ports {usr_lvds_p[12]}]
set_property PACKAGE_PIN V3 [get_ports {usr_lvds_p[13]}]

set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[5]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[6]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[7]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[8]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[9]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[10]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[11]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[12]}]
set_property IOSTANDARD LVDS_25 [get_ports {usr_lvds_p[13]}]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {eth[1].rgmii/phy_rxc_ibuf}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {eth[2].rgmii/phy_rxc_ibuf}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {eth[3].rgmii/phy_rxc_ibuf}]


# input      _______________________________                                  ________
# clock    _|                               |________________________________|
#           |                               |
#           |-> (trco_min+trce_dly_min)     |-> (tfco_min+trce_dly_min)
#           |-----> (trco_max+trce_dly_max) |-----> (tfco_max+trce_dly_max)
#          ____    ____________________________    ____________________________    ___
# data     ____XXXX__________Rise_Data_________XXXX__________Fall_Data_________XXXX___
#
create_clock -period 8 -name rgmii0_rx_clk [get_ports {rgmii_rxc[0]}]
create_clock -period 8 -name rgmii1_rx_clk [get_ports {rgmii_rxc[1]}]
create_clock -period 8 -name rgmii2_rx_clk [get_ports {rgmii_rxc[2]}]
create_clock -period 8 -name rgmii3_rx_clk [get_ports {rgmii_rxc[3]}]
set trco_max        0.500;          # Maximum clock to output delay from rising edge (external device)
set trco_min        -0.500;          # Minimum clock to output delay from rising edge (external device)
set tfco_max        0.500;          # Maximum clock to output delay from falling edge (external device)
set tfco_min        -0.500;          # Minimum clock to output delay from falling edge (external device)
set trce_dly_max    0.000;          # Maximum board trace delay
set trce_dly_min    0.000;          # Minimum board trace delay
set rgmii0_rx_ports     {rgmii_rxd[0] rgmii_rxd[1] rgmii_rxd[2] rgmii_rxd[3] rgmii_rx_ctl[0]};
set rgmii1_rx_ports     {rgmii_rxd[4] rgmii_rxd[5] rgmii_rxd[6] rgmii_rxd[7] rgmii_rx_ctl[1]};
set rgmii2_rx_ports     {rgmii_rxd[8] rgmii_rxd[9] rgmii_rxd[10] rgmii_rxd[11] rgmii_rx_ctl[2]};
set rgmii3_rx_ports     {rgmii_rxd[12] rgmii_rxd[13] rgmii_rxd[14] rgmii_rxd[15] rgmii_rx_ctl[3]};

# Input Delay Constraint
set_input_delay -clock rgmii0_rx_clk -max [expr $trco_max + $trce_dly_max] [get_ports $rgmii0_rx_ports];
set_input_delay -clock rgmii0_rx_clk -min [expr $trco_min + $trce_dly_min] [get_ports $rgmii0_rx_ports];
set_input_delay -clock rgmii0_rx_clk -max [expr $tfco_max + $trce_dly_max] [get_ports $rgmii0_rx_ports] -clock_fall -add_delay;
set_input_delay -clock rgmii0_rx_clk -min [expr $tfco_min + $trce_dly_min] [get_ports $rgmii0_rx_ports] -clock_fall -add_delay;

set_input_delay -clock rgmii1_rx_clk -max [expr $trco_max + $trce_dly_max] [get_ports $rgmii1_rx_ports];
set_input_delay -clock rgmii1_rx_clk -min [expr $trco_min + $trce_dly_min] [get_ports $rgmii1_rx_ports];
set_input_delay -clock rgmii1_rx_clk -max [expr $tfco_max + $trce_dly_max] [get_ports $rgmii1_rx_ports] -clock_fall -add_delay;
set_input_delay -clock rgmii1_rx_clk -min [expr $tfco_min + $trce_dly_min] [get_ports $rgmii1_rx_ports] -clock_fall -add_delay;

set_input_delay -clock rgmii2_rx_clk -max [expr $trco_max + $trce_dly_max] [get_ports $rgmii2_rx_ports];
set_input_delay -clock rgmii2_rx_clk -min [expr $trco_min + $trce_dly_min] [get_ports $rgmii2_rx_ports];
set_input_delay -clock rgmii2_rx_clk -max [expr $tfco_max + $trce_dly_max] [get_ports $rgmii2_rx_ports] -clock_fall -add_delay;
set_input_delay -clock rgmii2_rx_clk -min [expr $tfco_min + $trce_dly_min] [get_ports $rgmii2_rx_ports] -clock_fall -add_delay;

set_input_delay -clock rgmii3_rx_clk -max [expr $trco_max + $trce_dly_max] [get_ports $rgmii3_rx_ports];
set_input_delay -clock rgmii3_rx_clk -min [expr $trco_min + $trce_dly_min] [get_ports $rgmii3_rx_ports];
set_input_delay -clock rgmii3_rx_clk -max [expr $tfco_max + $trce_dly_max] [get_ports $rgmii3_rx_ports] -clock_fall -add_delay;
set_input_delay -clock rgmii3_rx_clk -min [expr $tfco_min + $trce_dly_min] [get_ports $rgmii3_rx_ports] -clock_fall -add_delay;

# Report Timing Template
# report_timing -rise_from [get_ports $input_ports] -max_paths 20 -nworst 2 -delay_type min_max -name sys_sync_ddr_in_rise -file sys_sync_ddr_in_rise.txt;
# report_timing -fall_from [get_ports $input_ports] -max_paths 20 -nworst 2 -delay_type min_max -name sys_sync_ddr_in_fall -file sys_sync_ddr_in_fall.txt;

set_property IDELAY_VALUE 1 [get_cells {eth[0].rgmii/idelay_rxd[*].inst}]
set_property IDELAY_VALUE 1 [get_cells {eth[1].rgmii/idelay_rxd[*].inst}]
set_property IDELAY_VALUE 1 [get_cells {eth[2].rgmii/idelay_rxd[*].inst}]
set_property IDELAY_VALUE 1 [get_cells {eth[3].rgmii/idelay_rxd[*].inst}]

## Group IODELAY components
#set_property IODELAY_GROUP iodelay_grp_eth [get_cells *idelay*]

###############################################################################
#Configutarion params
###############################################################################
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
#set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
