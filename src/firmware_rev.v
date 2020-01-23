// Build ID Verilog Module
//
// Date:             23012020
// Time:             185619

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h23012020;
   assign firmware_time = 32'h185619;

endmodule
