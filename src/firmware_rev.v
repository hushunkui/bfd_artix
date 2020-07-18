// Build ID Verilog Module
//
// Date:             18072020
// Time:             155416

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h18072020;
   assign firmware_time = 32'h155416;

endmodule
