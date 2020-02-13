// Build ID Verilog Module
//
// Date:             13022020
// Time:             212747

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h13022020;
   assign firmware_time = 32'h212747;

endmodule
