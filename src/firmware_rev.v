// Build ID Verilog Module
//
// Date:             28112019
// Time:             195543

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h28112019;
   assign firmware_time = 32'h195543;

endmodule
