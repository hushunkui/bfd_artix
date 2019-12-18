// Build ID Verilog Module
//
// Date:             18122019
// Time:             192809

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h18122019;
   assign firmware_time = 32'h192809;

endmodule
