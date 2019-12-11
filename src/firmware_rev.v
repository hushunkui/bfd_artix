// Build ID Verilog Module
//
// Date:             11122019
// Time:             210121

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h11122019;
   assign firmware_time = 32'h210121;

endmodule
