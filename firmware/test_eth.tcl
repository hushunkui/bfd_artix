#
# author: Golovachenko Viktor
#
source ./hw_usr.tcl
source ./axi_wr.tcl
source ./mdio_if.tcl

proc usr_open {} {
    set fpga_index 0
    open_hw
    connect_hw_server -url localhost:3121
    open_hw_target
    refresh_hw_device [lindex [get_hw_devices] $fpga_index]
    current_hw_device [lindex [get_hw_devices] $fpga_index]
}

proc usr_close {} {
    close_hw
}

proc main {argc argv} {

    usr_open
    reset_hw_axi [get_hw_axis]

    while (1) {
        eval exec >&@stdout <@stdin [auto_execok cls]

        puts "\nSTATUS:"
        set aurora_status [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_AURORA}]] ]
        puts "\tinterface aurora:"
        for {set i 0} {$i < ${::hw_usr::AURORA_CHCOUNT}} {incr i} {
            puts "\t\taurora ch($i) - link: [ expr [ expr $aurora_status >> $i ] & 0x01 ]"
        }

        set eth_status [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_ETH}]] ]
        puts "\n\tmodule ZYNQ: firmware:[string trimleft [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_DATE}]] ] 0x]:[string\
         trimleft [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_TIME}]] ] 0x]"
        for {set i 0} {$i < ${::hw_usr::MODULE_ZYNQ_ETHCOUNT}} {incr i} {
            puts "\t\teth ch($i) - link: [ expr { ($eth_status >> $i ) & 0x01} ]"
        }

        set artix_m [expr { ($eth_status >> ${::hw_usr::MODULE_ZYNQ_ETHCOUNT_MAX}) & 0xFF } ]
        for {set i 0} {$i < ${::hw_usr::MODULE_ARTIX_COUNT}} {incr i} {
            puts "\n\tmodule ARTIX($i): "
            set artix_eth [expr { ($artix_m >> ($i*${::hw_usr::MODULE_ARTIX_ETHCOUNT_MAX})) & 0xF } ]
            for {set x 0} {$x < ${::hw_usr::MODULE_ARTIX_ETHCOUNT}} {incr x} {
                puts "\t\teth ch($x) - link: [ expr { ($artix_eth >> $x) & 0x01 } ]"
            }
        }
        puts "\nUSR CTRL:"
        set usr_ctrl [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] ]
        puts "\tzynq eth: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ZYNQ_ETH_BIT}) & 0x3 } ]"
        puts "\tartix eth: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ARTIX_ETH_BIT}) & 0x7 } ]"
        # puts "\tenable: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_EN_BIT}) & 0x1 } ]"

        puts "\nMAC_RX_CNTERR:"
        set mac0_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH0}]] ]
        set mac1_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH1}]] ]
        set mac2_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH2}]] ]
        set mac3_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH3}]] ]
        puts "\teth0: $mac0_rx_cnterr"
        puts "\teth1: $mac1_rx_cnterr"
        puts "\teth2: $mac2_rx_cnterr"
        puts "\teth2: $mac3_rx_cnterr"

        puts "\n0 - quit"
        puts "1 - get status"
        puts "2 - set ctrl"
        puts "3 - EthPHY"
        puts -nonewline "Enter key: "
        flush stdout
        set usr_key [gets stdin]
        if {[string compare $usr_key "0"] == 0} {
            eval exec >&@stdout <@stdin [auto_execok cls]
            break;
        } elseif {[string compare $usr_key "2"] == 0} {
            puts -nonewline "Enter value(hex): "
            set usr_key [gets stdin]
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] $usr_key
        } elseif {[string compare $usr_key "3"] == 0} {
            set ethphy_adr 0x00
            set ethphy_reg_adr ${::mdio::REG_PHY_Identifier_1}
            set ethphy_mmd_dev_adr 0x2
            set ethphy_mmd_reg_adr 0x8
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_RST}]] 0xF
            # set ethhy_test_prm_pkt_size 0x200
            # set ethhy_test_prm_pause_size 0x40
            set ethhy_test_prm [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_TEST_PRM}]] ]
            set ethhy_test_prm_pkt_size  0x[format %04x [ expr { ($ethhy_test_prm >> ${::hw_usr::UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET} ) & 0xFFFF } ] ]
            set ethhy_test_prm_pause_size  0x[format %04x [ expr { ($ethhy_test_prm >> ${::hw_usr::UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET} ) & 0xFFFF } ] ]
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                puts "\ntest param:"
                puts "\tpkt_size: [format %d $ethhy_test_prm_pkt_size ]"
                puts "\tpause_size: [format %d $ethhy_test_prm_pause_size ]"
                puts "\nMAC_RX_CNTERR:"
                set mac0_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH0}]] ]
                set mac1_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH1}]] ]
                set mac2_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH2}]] ]
                set mac3_rx_cnterr [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH3}]] ]
                puts "\teth0: $mac0_rx_cnterr"
                puts "\teth1: $mac1_rx_cnterr"
                puts "\teth2: $mac2_rx_cnterr"
                puts "\teth2: $mac3_rx_cnterr"
                puts "\ncurrent EthPHY addr: $ethphy_adr"
                puts "\nEthPHY Ctrl:"
                puts "0 - quit"
                puts "1 - standart reg write/read"
                puts "2 - mmd reg write/read"
                puts "3 - reset all PHY"
                puts "4 - testphy prm pkt_size"
                puts "5 - testphy prm pause_size"
                puts "6 - testphy prm write"
                puts "7 - testphy prm read"
                puts -nonewline "Enter key: "
                set usr_key [gets stdin]
                if {[string compare $usr_key "0"] == 0} {
                    break;
                } elseif {[string compare $usr_key "1"] == 0} {
                    while (1) {
                        eval exec >&@stdout <@stdin [auto_execok cls]
                        puts "\ncurrent EthPHY addr: $ethphy_adr"
                        puts "current reg addr: $ethphy_reg_adr"
                        puts "\nEthPHY Ctrl:"
                        puts "0 - quit"
                        puts "1 - set PHY adr"
                        puts "2 - reg addr"
                        puts "3 - reg read"
                        puts "4 - reg write"
                        puts -nonewline "Enter key: "
                        set usr_key [gets stdin]
                        if {[string compare $usr_key "0"] == 0} {
                            break;
                        } elseif {[string compare $usr_key "1"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_adr [gets stdin]
                        } elseif {[string compare $usr_key "2"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_reg_adr [gets stdin]
                        } elseif {[string compare $usr_key "3"] == 0} {
                            puts "rdata: [ ::mdio::mdio_read $ethphy_adr $ethphy_reg_adr ]"
                            puts -nonewline "press any key for continue: "
                            set usr_key [gets stdin]
                        } elseif {[string compare $usr_key "4"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_reg_wdata [gets stdin]
                            ::mdio::mdio_write $ethphy_adr $ethphy_reg_adr $ethphy_reg_wdata
                            set usr_key [gets stdin]
                        }
                    }
                } elseif {[string compare $usr_key "2"] == 0} {
                    while (1) {
                        eval exec >&@stdout <@stdin [auto_execok cls]
                        puts "\ncurrent EthPHY addr: $ethphy_adr"
                        puts "current mmd dev addr: $ethphy_mmd_dev_adr"
                        puts "current mmd reg addr: $ethphy_mmd_reg_adr"
                        puts "\nEthPHY Ctrl:"
                        puts "0 - quit"
                        puts "1 - set PHY adr"
                        puts "2 - mmd reg adr"
                        puts "3 - mmd reg read"
                        puts "4 - mmd reg write"
                        puts "5 - mmd dev adr"
                        puts -nonewline "Enter key: "
                        set usr_key [gets stdin]
                        if {[string compare $usr_key "0"] == 0} {
                            break;
                        } elseif {[string compare $usr_key "1"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_adr [gets stdin]
                        } elseif {[string compare $usr_key "2"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_mmd_reg_adr [gets stdin]
                        } elseif {[string compare $usr_key "3"] == 0} {
                            puts "rdata: [ ::mdio::mmd_read $ethphy_adr $ethphy_mmd_dev_adr $ethphy_mmd_reg_adr ]"
                            puts -nonewline "press any key for continue: "
                            set usr_key [gets stdin]
                        } elseif {[string compare $usr_key "4"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_mmd_reg_wdata [gets stdin]
                            ::mdio::mmd_write $ethphy_adr $ethphy_mmd_dev_adr $ethphy_mmd_reg_adr $ethphy_mmd_reg_wdata
                        } elseif {[string compare $usr_key "5"] == 0} {
                            puts -nonewline "Enter value(hex): "
                            set ethphy_mmd_dev_adr [gets stdin]
                        }
                    }
                } elseif {[string compare $usr_key "3"] == 0} {
                    ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_RST}]] 0x0
                    ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_RST}]] 0xF
                } elseif {[string compare $usr_key "4"] == 0} {
                    puts -nonewline "Enter value(dec): "
                    set ethhy_test_prm_pkt_size 0x[format %04x [gets stdin]]
                    set val [expr {($ethhy_test_prm_pause_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET}) | ($ethhy_test_prm_pkt_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET})}]
                    ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_TEST_PRM}]] $val
                } elseif {[string compare $usr_key "5"] == 0} {
                    puts -nonewline "Enter value(dec): "
                    set ethhy_test_prm_pause_size 0x[format %04x [gets stdin]]
                    set val [expr {($ethhy_test_prm_pause_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET}) | ($ethhy_test_prm_pkt_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET})}]
                    ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_TEST_PRM}]] $val
                } elseif {[string compare $usr_key "6"] == 0} {
                    set val [expr {($ethhy_test_prm_pause_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET}) | ($ethhy_test_prm_pkt_size << ${::hw_usr::UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET})}]
                    ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_TEST_PRM}]] $val
                } elseif {[string compare $usr_key "7"] == 0} {
                    set ethhy_test_prm [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_TEST_PRM}]] ]
                    puts "pkt_size: 0x[format %04x [ expr { ($ethhy_test_prm >> ${::hw_usr::UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET} ) & 0xFFFF } ] ]"
                    puts "pause_size: 0x[format %04x [ expr { ($ethhy_test_prm >> ${::hw_usr::UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET} ) & 0xFFFF } ] ]"
                    puts -nonewline "press any key for continue: "
                    set usr_key [gets stdin]
                }
            }
        }
    }

    usr_close
}


# Start the program
main $argc $argv