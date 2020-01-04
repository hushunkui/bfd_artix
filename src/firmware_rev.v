// Build ID Verilog Module
//
// Date:             04012020
// Time:             212213

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h04012020;
   assign firmware_time = 32'h212213;

endmodule
