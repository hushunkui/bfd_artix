// Build ID Verilog Module
//
// Date:             18112019
// Time:             200229

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h18112019;
   assign firmware_time = 32'h200229;

endmodule
