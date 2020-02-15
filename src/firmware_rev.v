// Build ID Verilog Module
//
// Date:             15022020
// Time:             162854

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h15022020;
   assign firmware_time = 32'h162854;

endmodule
