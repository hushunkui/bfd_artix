// Build ID Verilog Module
//
// Date:             04072020
// Time:             125130

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h04072020;
   assign firmware_time = 32'h125130;

endmodule
