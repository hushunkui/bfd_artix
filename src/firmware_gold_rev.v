// Build ID Verilog Module
//
// Date:             23032020
// Time:             210206

module firmware_gold_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h23032020;
   assign firmware_time = 32'h210206;

endmodule
