// Build ID Verilog Module
//
// Date:             23072020
// Time:             204241

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h23072020;
   assign firmware_time = 32'h204241;

endmodule
