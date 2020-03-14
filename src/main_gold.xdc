#
#author: Golovachenko Viktor
#

#MODULE TE0714-02-35
#https://shop.trenz-electronic.de/en/TE0714-03-35-2I-FPGA-Module-with-Xilinx-Artix-7-XC7A35T-2CSG325I-3-3-V-Configuration-4-x-3-cm?c=366


set_property PACKAGE_PIN T14 [get_ports sysclk25]
set_property IOSTANDARD LVCMOS33 [get_ports sysclk25]
create_clock -period 40.000 -name sysclk25 -waveform {0.000 20.000} [get_ports sysclk25]

set_property PACKAGE_PIN K18 [get_ports dbg_led]
set_property IOSTANDARD LVCMOS33 [get_ports dbg_led]

set_property PACKAGE_PIN M15 [get_ports mgt_pwr_en]
set_property IOSTANDARD LVCMOS33 [get_ports mgt_pwr_en]

set_property PACKAGE_PIN L15 [get_ports qspi_cs]
set_property PACKAGE_PIN K16 [get_ports qspi_mosi]
set_property PACKAGE_PIN L17 [get_ports qspi_miso]
set_property IOSTANDARD LVCMOS33 [get_ports qspi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports qspi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports qspi_miso]

set_property PACKAGE_PIN K2 [get_ports usr_spi_clk ]
set_property PACKAGE_PIN R1 [get_ports usr_spi_cs  ]
set_property PACKAGE_PIN R2 [get_ports usr_spi_mosi]
set_property PACKAGE_PIN K1 [get_ports usr_spi_miso]
set_property IOSTANDARD LVCMOS25 [get_ports usr_spi_clk ]
set_property IOSTANDARD LVCMOS25 [get_ports usr_spi_cs  ]
set_property IOSTANDARD LVCMOS25 [get_ports usr_spi_mosi]
set_property IOSTANDARD LVCMOS25 [get_ports usr_spi_miso]


###############################################################################
#Configutarion params
###############################################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]
set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0X00400000 [current_design]