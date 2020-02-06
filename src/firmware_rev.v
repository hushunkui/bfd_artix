// Build ID Verilog Module
//
// Date:             06022020
// Time:             214218

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h06022020;
   assign firmware_time = 32'h214218;

endmodule
