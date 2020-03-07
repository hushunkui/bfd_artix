// Build ID Verilog Module
//
// Date:             07032020
// Time:             141211

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h07032020;
   assign firmware_time = 32'h141211;

endmodule
