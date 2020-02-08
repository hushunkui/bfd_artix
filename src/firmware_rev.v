// Build ID Verilog Module
//
// Date:             08022020
// Time:             180559

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h08022020;
   assign firmware_time = 32'h180559;

endmodule
