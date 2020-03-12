// Build ID Verilog Module
//
// Date:             12032020
// Time:             212104

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h12032020;
   assign firmware_time = 32'h212104;

endmodule
