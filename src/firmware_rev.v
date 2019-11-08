// Build ID Verilog Module
//
// Date:             08112019
// Time:             153247

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h08112019;
   assign firmware_time = 32'h153247;

endmodule
