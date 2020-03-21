// Build ID Verilog Module
//
// Date:             21032020
// Time:             182953

module firmware_gold_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h21032020;
   assign firmware_time = 32'h182953;

endmodule
