// Build ID Verilog Module
//
// Date:             25072020
// Time:             134816

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h25072020;
   assign firmware_time = 32'h134816;

endmodule
