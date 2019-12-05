`timescale 1ps / 1ps

module eth_mac_sync_block (
    input clk,
    input data_in,
    output data_out
);

// To write use port A
always @(posedge clk)
begin
    data_out <= data_in;
end

endmodule

