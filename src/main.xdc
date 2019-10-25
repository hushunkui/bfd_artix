#
#author: Golovachenko Victor
#

#ETH PHY - TLK106RHBR: setting with resistros
#PHYAD[4..0]: 00001
#pin (RX_DV/MILL_MODE) - '0' - MII mode
#pin (RX_ER/AMDIX_EN) - '0' - AutoMDIX enable


set_property PACKAGE_PIN Y8 [get_ports MDIO_0_mdc]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO_0_mdc]
set_property PACKAGE_PIN U9 [get_ports MDIO_0_mdio_io]
set_property IOSTANDARD LVCMOS33 [get_ports MDIO_0_mdio_io]

set_property PACKAGE_PIN AB7 [get_ports MII_0_tx_clk]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_tx_clk]
set_property PACKAGE_PIN AB6 [get_ports MII_0_tx_en]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_tx_en]
set_property PACKAGE_PIN AB5 [get_ports {MII_0_txd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_txd[0]}]
set_property PACKAGE_PIN AB4 [get_ports {MII_0_txd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_txd[1]}]
set_property PACKAGE_PIN AB2 [get_ports {MII_0_txd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_txd[2]}]
set_property PACKAGE_PIN AB1 [get_ports {MII_0_txd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_txd[3]}]

set_property PACKAGE_PIN Y9 [get_ports MII_0_rx_clk]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_rx_clk]
set_property PACKAGE_PIN AB12 [get_ports MII_0_rx_dv]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_rx_dv]
set_property PACKAGE_PIN AB11 [get_ports MII_0_rx_er]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_rx_er]
set_property PACKAGE_PIN AB10 [get_ports {MII_0_rxd[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_rxd[0]}]
set_property PACKAGE_PIN AB9 [get_ports {MII_0_rxd[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_rxd[1]}]
set_property PACKAGE_PIN AA9 [get_ports {MII_0_rxd[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_rxd[2]}]
set_property PACKAGE_PIN AA8 [get_ports {MII_0_rxd[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {MII_0_rxd[3]}]

set_property PACKAGE_PIN AA12 [get_ports MII_0_crs]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_crs]
set_property PACKAGE_PIN AA11 [get_ports MII_0_col]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_col]

set_property PACKAGE_PIN U12 [get_ports MII_0_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports MII_0_rst_n]


set_property PULLDOWN true [get_ports MII_0_col]
set_property SLEW SLOW [get_ports MII_0_rst_n]

set_property PACKAGE_PIN R7 [get_ports eth_phy_npwr_dwn]
set_property IOSTANDARD LVCMOS33 [get_ports eth_phy_npwr_dwn]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_ports MII_0_tx_clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_ports MII_0_rx_clk]

set_property PACKAGE_PIN H22 [get_ports usr_led]
set_property IOSTANDARD LVCMOS33 [get_ports usr_led]
