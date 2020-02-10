// Build ID Verilog Module
//
// Date:             10022020
// Time:             204955

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h10022020;
   assign firmware_time = 32'h204955;

endmodule
