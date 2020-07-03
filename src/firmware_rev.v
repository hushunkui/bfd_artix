// Build ID Verilog Module
//
// Date:             03072020
// Time:             153109

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h03072020;
   assign firmware_time = 32'h153109;

endmodule
