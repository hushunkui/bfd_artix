// Build ID Verilog Module
//
// Date:             12022020
// Time:             220526

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h12022020;
   assign firmware_time = 32'h220526;

endmodule
