`timescale 1ps / 1ps

module mac_bram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12
) (
    // Port A
    input   wire                      a_clk,
    input   wire                      a_rst,
    input   wire                      a_wr,
    input   wire    [ADDR_WIDTH-1:0]  a_addr,
    input   wire    [DATA_WIDTH-1:0]  a_din,

    // Port B
    input   wire                      b_clk,
    input   wire                      b_en,
    input   wire                      b_rst,
    input   wire    [ADDR_WIDTH-1:0]  b_addr,
    output  reg     [DATA_WIDTH-1:0]  b_dout
);

// Shared memory
localparam RAM_DEPTH = 2 ** ADDR_WIDTH;
reg [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];

// To write use port A
always @(posedge a_clk)
begin
    if(!a_rst && a_wr) begin
        mem[a_addr] <= a_din;
    end
end

// To read use Port B
always @(posedge b_clk)
begin
    if(b_rst)
       b_dout      <= {DATA_WIDTH{1'b0}};
    else if(b_en)
       b_dout      <= mem[b_addr];
end

endmodule

