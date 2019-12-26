// Build ID Verilog Module
//
// Date:             26122019
// Time:             204551

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h26122019;
   assign firmware_time = 32'h204551;

endmodule
