// Build ID Verilog Module
//
// Date:             21032020
// Time:             151958

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h21032020;
   assign firmware_time = 32'h151958;

endmodule
