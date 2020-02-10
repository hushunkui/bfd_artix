// Build ID Verilog Module
//
// Date:             10022020
// Time:             201657

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h10022020;
   assign firmware_time = 32'h201657;

endmodule
