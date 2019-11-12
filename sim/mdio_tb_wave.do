onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mdio_tb/mdio_m/clk
add wave -noupdate /mdio_tb/mdio_m/clkdiv
add wave -noupdate -color {Slate Blue} -itemcolor Gold /mdio_tb/mdio_m/fsm_cs
add wave -noupdate -radix unsigned /mdio_tb/mdio_m/bitcnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {630 ns}
