// Build ID Verilog Module
//
// Date:             30112019
// Time:             152926

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h30112019;
   assign firmware_time = 32'h152926;

endmodule
