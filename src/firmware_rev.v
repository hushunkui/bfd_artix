// Build ID Verilog Module
//
// Date:             02072020
// Time:             205233

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h02072020;
   assign firmware_time = 32'h205233;

endmodule
