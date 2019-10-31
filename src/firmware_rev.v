// Build ID Verilog Module
//
// Date:             31102019
// Time:             173006

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h31102019;
   assign firmware_time = 32'h173006;

endmodule
