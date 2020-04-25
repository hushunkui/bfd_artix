// Build ID Verilog Module
//
// Date:             25042020
// Time:             120234

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h25042020;
   assign firmware_time = 32'h120234;

endmodule
