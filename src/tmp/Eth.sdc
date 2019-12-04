 set Eth_Tco_max       0.5 
 set Eth_Tco_min       -0.5
 
create_clock -name {RXC} -period 8.0 -waveform { 0.000 4.0 } [get_ports {RXC}]
create_clock -period 8.0 -name rgmii_rx_virt_clk

set_input_delay -clock rgmii_rx_virt_clk -max [expr $Eth_Tco_max ] [get_ports RXD*]  -add_delay
set_input_delay -clock rgmii_rx_virt_clk -min [expr $Eth_Tco_min ] [get_ports RXD*]  -add_delay

set_input_delay -clock rgmii_rx_virt_clk -clock_fall  -max [expr $Eth_Tco_max ]   [get_ports RXD*]  -add_delay
set_input_delay -clock rgmii_rx_virt_clk -clock_fall  -min [expr $Eth_Tco_min ]   [get_ports RXD*]  -add_delay