// Build ID Verilog Module
//
// Date:             21122019
// Time:             162820

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h21122019;
   assign firmware_time = 32'h162820;

endmodule
