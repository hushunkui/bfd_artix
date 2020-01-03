// Build ID Verilog Module
//
// Date:             03012020
// Time:             195820

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h03012020;
   assign firmware_time = 32'h195820;

endmodule
