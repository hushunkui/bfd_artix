#
#author: Golovachenko Viktor
#

proc generateFirmwareRevisionUpdate {} {

    # Get the timestamp (see: http://www.altera.com/support/examples/tcl/tcl-date-time-stamp.html)
    set firmware_Date [ clock format [ clock seconds ] -format %d%m%Y ]
    set firmware_Time [ clock format [ clock seconds ] -format %H%M%S ]

    # Create a Verilog file for output at dir ./prj/frame_grabber.runs/synth_1
    set outputFileName "../../../src/firmware_gold_rev.v"
    set outputFile [open $outputFileName "w"]

    # Output the Verilog source
    puts $outputFile "// Build ID Verilog Module"
    puts $outputFile "//"
    puts $outputFile "// Date:             $firmware_Date"
    puts $outputFile "// Time:             $firmware_Time"
    puts $outputFile ""
    puts $outputFile "module firmware_gold_rev"
    puts $outputFile "("
    puts $outputFile "   output \[31:0\]  firmware_date,"
    puts $outputFile "   output \[31:0\]  firmware_time"
    puts $outputFile ");"
    puts $outputFile ""
    puts $outputFile "   assign firmware_date = 32'h$firmware_Date;"
    puts $outputFile "   assign firmware_time = 32'h$firmware_Time;"
    puts $outputFile ""
    puts $outputFile "endmodule"
    close $outputFile

    # Send confirmation message to the Messages window
    puts "Generated firmware_gold_rev identification Verilog module: [pwd]/$outputFileName"
    puts "Date:  $firmware_Date"
    puts "Time:  $firmware_Time"
}


set_param general.maxThreads 4

# Comment out this line to prevent the process from automatically executing when the file is sourced:
generateFirmwareRevisionUpdate
