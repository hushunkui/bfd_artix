// Build ID Verilog Module
//
// Date:             22012020
// Time:             213504

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h22012020;
   assign firmware_time = 32'h213504;

endmodule
