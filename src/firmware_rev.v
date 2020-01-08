// Build ID Verilog Module
//
// Date:             08012020
// Time:             213311

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h08012020;
   assign firmware_time = 32'h213311;

endmodule
