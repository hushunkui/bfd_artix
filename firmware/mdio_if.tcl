#
# author: Golovachenko Viktor
#
# https://en.wikipedia.org/wiki/Management_Data_Input/Output
#
source ./hw_usr.tcl
source ./axi_wr.tcl

namespace eval mdio \
{
    # The register space within the KSZ9031RNX consists of two distinct areas.
    # • Standard registers // Direct register access
    # • MDIO Manageable device (MMD) registers // Indirect register access

    #STANDARD REGISTERS (IEEE-Defined Registers)
    variable REG_PHY_Identifier_1     0x02
    variable REG_PHY_Identifier_2     0x03
    variable REG_MMD_Access_Control   0x0D
    variable REG_MMD_Access_Reg_Data  0x0E

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
        for {set i 0} {$i < 32} {incr i} {
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

    #write/read Standard registers
    proc mdio_write { ethphy_adr mdio_reg_addr mdio_reg_data } {
        mdio_preamble
        mdio_start
        mdio_op_write
        mdio_set_addr $ethphy_adr
        mdio_set_addr $mdio_reg_addr
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 1
        mdio_clk
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DATA_O}]] 0
        mdio_clk
        mdio_set_data $mdio_reg_data
        return -code ok
    }

    proc mdio_read { ethphy_adr mdio_reg_addr } {
        mdio_preamble
        mdio_start
        mdio_op_read
        mdio_set_addr $ethphy_adr
        mdio_set_addr $mdio_reg_addr
        #set output buffer as input
        ::axi::axi_write [format %08x [expr ${::hw_usr::BASE_ADDR} + ${::hw_usr::UREG_ETHPHY_MDIO_DIR_O}]] 0
        mdio_clk
        return [ mdio_get_data ]
    }

    #write/read MDIO Manageable device (MMD) registers
    proc mmd_write { ethphy_adr mmd_dev_addr mmd_reg_addr mmd_reg_data } {
        set reg_adr ${::mdio::REG_MMD_Access_Control}
        set reg_val $mmd_dev_addr
        puts "mmd_write: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Reg_Data}
        set reg_val $mmd_reg_addr
        puts "mmd_write: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Control}
        set reg_val 0x[format %04x [expr { (4 << 12) | ($mmd_dev_addr & 0x1F) }]]
        puts "mmd_write: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Reg_Data}
        set reg_val $mmd_reg_data
        puts "mmd_write: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        return -code ok
    }

    proc mmd_read { ethphy_adr mmd_dev_addr mmd_reg_addr } {
        set reg_adr ${::mdio::REG_MMD_Access_Control}
        set reg_val $mmd_dev_addr
        puts "mmd_read: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Reg_Data}
        set reg_val $mmd_reg_addr
        puts "mmd_read: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Control}
        set reg_val 0x[format %04x [expr { (4 << 12) | ($mmd_dev_addr & 0x1F) }]]
        puts "mmd_read: mdio_write $ethphy_adr; $reg_adr; $reg_val"
        mdio_write $ethphy_adr $reg_adr $reg_val
        # puts -nonewline "press any key for continue: "
        # set usr_key [gets stdin]

        set reg_adr ${::mdio::REG_MMD_Access_Reg_Data}
        puts "mmd_read: mdio_read $ethphy_adr; $reg_adr"
        return [ mdio_read $ethphy_adr $reg_adr ]
    }
}; #namespace eval mdio
