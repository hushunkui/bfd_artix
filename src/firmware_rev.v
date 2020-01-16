// Build ID Verilog Module
//
// Date:             16012020
// Time:             191340

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h16012020;
   assign firmware_time = 32'h191340;

endmodule
