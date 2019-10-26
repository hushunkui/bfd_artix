// Build ID Verilog Module
//
// Date:             26102019
// Time:             180321

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h26102019;
   assign firmware_time = 32'h180321;

endmodule
