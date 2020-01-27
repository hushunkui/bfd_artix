#
# author: Golovachenko Viktor
#
source ./hw_usr.tcl
source ./axi_wr.tcl

namespace eval mdio \
{
    variable REG_PHY_Identifier_1   0x02
    variable REG_PHY_Identifier_2   0x03

    proc mdio_clk { } {
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_CLK_O}]] 1
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_CLK_O}]] 0
        return -code ok
    }

    proc mdio_preamble { } {
        # puts "preamble:"
        #set output buffer as output
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DIR_O}]] 1
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        for {set i 0} {$i < 2} {incr i} {
            mdio_clk
        }
        return -code ok
    }

    proc mdio_start { } {
        # puts "start condition:"
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 0
        mdio_clk
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        mdio_clk
        return -code ok
    }

    proc mdio_op_write { } {
        # puts "op:"
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 0
        mdio_clk
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        mdio_clk
        return -code ok
    }

    proc mdio_op_read { } {
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        mdio_clk
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 0
        mdio_clk
        return -code ok
    }

    proc mdio_set_addr { addr } {
        # puts "set addr: [format %08x [expr $addr]]"
        for {set i 0} {$i < 5} {incr i} {
            set bitnum [expr 4 - $i]
            set val [expr { ($addr >> $bitnum) & 0x1} ]
            # puts "\tbit([format %02d $bitnum]):$val"
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] $val
            mdio_clk
        }
        return -code ok
    }

    proc mdio_set_data { wdata } {
        # puts "set data: [format %08x [expr $wdata]]"
        for {set i 0} {$i < 16} {incr i} {
            set bitnum [expr 15 - $i]
            set val [expr { ($wdata >> $bitnum) & 0x1 } ]
            # puts "\tbit([format %02d $bitnum]):$val"
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] $val
            mdio_clk
        }
        return -code ok
    }

    proc mdio_get_data { } {
        # puts "get data:"
        set var 0
        for {set i 0} {$i < 16} {incr i} {
            set bitnum [expr 15 - $i]
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_CLK_O}]] 1
            set rdata [::axi::axi_read [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_I}]] ]
            lappend var [expr { [lindex $var $i ] | ($rdata << $bitnum)} ]
            ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_CLK_O}]] 0
        }
        return 0x[format %04x [lindex $var $i ]]
    }

    proc mdio_write { phy_adr reg_addr reg_data } {
        mdio_preamble
        mdio_start
        mdio_op_write
        mdio_set_addr $phy_adr
        mdio_set_addr $reg_addr
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        mdio_clk
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 0
        mdio_clk
        mdio_set_data $reg_data
        return -code ok
    }

    proc mdio_read { phy_adr reg_addr } {
        mdio_preamble
        mdio_start
        mdio_op_read
        mdio_set_addr $phy_adr
        mdio_set_addr $reg_addr
        #set output buffer as input
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DIR_O}]] 0
        mdio_clk
        return [ mdio_get_data ]
    }
}; #namespace eval mdio
