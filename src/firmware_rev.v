// Build ID Verilog Module
//
// Date:             27052020
// Time:             213719

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h27052020;
   assign firmware_time = 32'h213719;

endmodule
