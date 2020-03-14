// Build ID Verilog Module
//
// Date:             14032020
// Time:             150101

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h14032020;
   assign firmware_time = 32'h150101;

endmodule
