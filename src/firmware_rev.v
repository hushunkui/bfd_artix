// Build ID Verilog Module
//
// Date:             09122019
// Time:             120857

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h09122019;
   assign firmware_time = 32'h120857;

endmodule
