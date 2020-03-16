// Build ID Verilog Module
//
// Date:             16032020
// Time:             214041

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h16032020;
   assign firmware_time = 32'h214041;

endmodule
