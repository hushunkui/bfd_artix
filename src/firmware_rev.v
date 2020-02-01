// Build ID Verilog Module
//
// Date:             01022020
// Time:             193339

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h01022020;
   assign firmware_time = 32'h193339;

endmodule
