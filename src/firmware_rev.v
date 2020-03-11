// Build ID Verilog Module
//
// Date:             11032020
// Time:             193038

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h11032020;
   assign firmware_time = 32'h193038;

endmodule
