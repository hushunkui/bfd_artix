// Build ID Verilog Module
//
// Date:             30102019
// Time:             215405

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h30102019;
   assign firmware_time = 32'h215405;

endmodule
