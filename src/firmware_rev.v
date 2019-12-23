// Build ID Verilog Module
//
// Date:             23122019
// Time:             211432

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h23122019;
   assign firmware_time = 32'h211432;

endmodule
