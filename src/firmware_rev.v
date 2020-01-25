// Build ID Verilog Module
//
// Date:             25012020
// Time:             194036

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h25012020;
   assign firmware_time = 32'h194036;

endmodule
