// Build ID Verilog Module
//
// Date:             16052020
// Time:             120605

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h16052020;
   assign firmware_time = 32'h120605;

endmodule
