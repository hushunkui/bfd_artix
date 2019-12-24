// Build ID Verilog Module
//
// Date:             24122019
// Time:             212748

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h24122019;
   assign firmware_time = 32'h212748;

endmodule
