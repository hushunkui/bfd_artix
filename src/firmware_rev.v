// Build ID Verilog Module
//
// Date:             21052020
// Time:             204228

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h21052020;
   assign firmware_time = 32'h204228;

endmodule
