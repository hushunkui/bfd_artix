// Build ID Verilog Module
//
// Date:             18052020
// Time:             192908

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h18052020;
   assign firmware_time = 32'h192908;

endmodule
