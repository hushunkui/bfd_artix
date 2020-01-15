// Build ID Verilog Module
//
// Date:             15012020
// Time:             201250

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h15012020;
   assign firmware_time = 32'h201250;

endmodule
