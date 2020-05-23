// Build ID Verilog Module
//
// Date:             23052020
// Time:             140644

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h23052020;
   assign firmware_time = 32'h140644;

endmodule
