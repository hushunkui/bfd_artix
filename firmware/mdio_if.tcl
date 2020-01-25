#
# author: Golovachenko Viktor
#
source ./hw_usr.tcl
source ./axi_wr.tcl

proc mdio_read { addr } {
    set result [axi_read $addr ]
    return $result
}

proc mdio_write { addr data } {
    axi_write $addr $data
    return -code ok
}

