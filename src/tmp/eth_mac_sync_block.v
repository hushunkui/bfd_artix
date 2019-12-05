`timescale 1ps / 1ps

module eth_mac_sync_block (
    input clk,
    input data_in,
    output reg data_out = 1'b0
);

// To write use port A
always @(posedge clk)
begin
    data_out <= data_in;
end

endmodule

