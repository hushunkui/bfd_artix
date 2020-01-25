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
        set aurora_status [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_AURORA}]] ]
        puts "\tinterface aurora:"
        for {set i 0} {$i < ${::hw_usr::AURORA_CHCOUNT}} {incr i} {
            puts "\t\taurora ch($i) - link: [ expr [ expr $aurora_status >> $i ] & 0x01 ]"
        }

        set eth_status [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_STATUS_ETH}]] ]
        puts "\n\tmodule ZYNQ: firmware:[string trimleft [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_DATE}]] ] 0x]:[string\
         trimleft [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_FIRMWARE_TIME}]] ] 0x]"
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
        set usr_ctrl [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] ]
        puts "\tzynq eth: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ZYNQ_ETH_BIT}) & 0x3 } ]"
        puts "\tartix eth: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_SEL_ARTIX_ETH_BIT}) & 0x7 } ]"
        # puts "\tenable: [expr { ($usr_ctrl >> ${::hw_usr::UREG_CTRL_EN_BIT}) & 0x1 } ]"

        puts "\nMAC_RX_CNTERR:"
        set mac0_rx_cnterr [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH0}]] ]
        set mac1_rx_cnterr [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH1}]] ]
        set mac2_rx_cnterr [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH2}]] ]
        set mac3_rx_cnterr [axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CNTERR_ETH3}]] ]
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
            # eval exec >&@stdout <@stdin [auto_execok cls]
            puts -nonewline "Enter value(hex): "
            set usr_key [gets stdin]
            axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_CTRL}]] $usr_key
        } elseif {[string compare $usr_key "3"] == 0} {
            while (1) {
                eval exec >&@stdout <@stdin [auto_execok cls]
                puts "\nEthPHY Ctrl:"
                puts "0 - quit"
                puts "1 - select PHY"
                puts "2 - get reg data"
                puts -nonewline "Enter key: "
                set usr_key [gets stdin]
                if {[string compare $usr_key "0"] == 0} {
                    break;
                } elseif {[string compare $usr_key "1"] == 0} {
                    puts -nonewline "Enter mask(hex): "
                    set usr_key [gets stdin]
                    axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_RST}]] $usr_key
                    puts -nonewline "press any key for continue: "
                    set usr_key [gets stdin]
                } elseif {[string compare $usr_key "2"] == 0} {
                    set phy_adr 0x0
                    set reg_adr ${::mdio::REG_PHY_Identifier_2}
                    puts "rdata: [ ::mdio::mdio_read $phy_adr $reg_adr ]"
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