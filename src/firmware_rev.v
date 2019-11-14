// Build ID Verilog Module
//
// Date:             14112019
// Time:             210639

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h14112019;
   assign firmware_time = 32'h210639;

endmodule
