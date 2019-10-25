// Build ID Verilog Module
//
// Date:             13062019
// Time:             114730

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h13062019;
   assign firmware_time = 32'h114730;

endmodule
