// Build ID Verilog Module
//
// Date:             09032020
// Time:             215540

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h09032020;
   assign firmware_time = 32'h215540;

endmodule
