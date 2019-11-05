//
// author: Golovachenko Viktor
//
//
// Date:             04112019
// Time:             211456

module firmware_rev
(
   output [31:0]  firmware_date,
   output [31:0]  firmware_time
);

   assign firmware_date = 32'h04112019;
   assign firmware_time = 32'h211456;

endmodule
