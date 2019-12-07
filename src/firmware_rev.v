// Build ID Verilog Module
//
// Date:             07122019
// Time:             171006

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h07122019;
   assign firmware_time = 32'h171006;

endmodule
