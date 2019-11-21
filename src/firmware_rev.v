// Build ID Verilog Module
//
// Date:             21112019
// Time:             191117

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h21112019;
   assign firmware_time = 32'h191117;

endmodule
