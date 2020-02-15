#
# author: Golovachenko Viktor
#
namespace eval axi \
{
    proc axi_read { addr } {
        delete_hw_axi_txn axi_read_txn -quiet
        create_hw_axi_txn -type read -address $addr axi_read_txn [get_hw_axis]
        run_hw_axi axi_read_txn -quiet
        return 0x[lindex [report_hw_axi_txn axi_read_txn] 1]
        # return 0x1
    }

    proc axi_write { addr data } {
        set data [format %08x $data]
        # puts "$data"
        delete_hw_axi_txn axi_write_txn -quiet
        create_hw_axi_txn -type write -address $addr -data $data axi_write_txn [get_hw_axis]
        run_hw_axi axi_write_txn -quiet
        return -code ok
    }
}; #namespace eval axi

