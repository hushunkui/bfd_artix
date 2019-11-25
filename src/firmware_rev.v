// Build ID Verilog Module
//
// Date:             25112019
// Time:             214227

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h25112019;
   assign firmware_time = 32'h214227;

endmodule
