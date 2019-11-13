// Build ID Verilog Module
//
// Date:             13112019
// Time:             215014

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h13112019;
   assign firmware_time = 32'h215014;

endmodule
