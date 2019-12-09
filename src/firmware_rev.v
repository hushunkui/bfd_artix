// Build ID Verilog Module
//
// Date:             09122019
// Time:             213442

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h09122019;
   assign firmware_time = 32'h213442;

endmodule
