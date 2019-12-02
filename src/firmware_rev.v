// Build ID Verilog Module
//
// Date:             02122019
// Time:             211556

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h02122019;
   assign firmware_time = 32'h211556;

endmodule
