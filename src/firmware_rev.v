// Build ID Verilog Module
//
// Date:             08022020
// Time:             161403

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h08022020;
   assign firmware_time = 32'h161403;

endmodule
