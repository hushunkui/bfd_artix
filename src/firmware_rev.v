// Build ID Verilog Module
//
// Date:             30122019
// Time:             205849

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h30122019;
   assign firmware_time = 32'h205849;

endmodule
