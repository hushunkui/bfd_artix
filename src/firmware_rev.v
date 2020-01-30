// Build ID Verilog Module
//
// Date:             30012020
// Time:             202047

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h30012020;
   assign firmware_time = 32'h202047;

endmodule
