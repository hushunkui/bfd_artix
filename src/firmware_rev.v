// Build ID Verilog Module
//
// Date:             04122019
// Time:             212954

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h04122019;
   assign firmware_time = 32'h212954;

endmodule
