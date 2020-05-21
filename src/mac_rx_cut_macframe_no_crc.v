//
// author: Golovachenko Viktor
//

module mac_rx_cut_macframe_no_crc #(
    parameter SIM = 0
) (
    input [7:0] mac_rx_data_i ,
    input       mac_rx_valid_i,
    input       mac_rx_sof_i  ,
    input       mac_rx_eof_i  ,

    output     [7:0] mac_rx_data_o,
    output reg       mac_rx_valid_o = 0,
    output           mac_rx_sof_o,
    output           mac_rx_eof_o,

    input rstn,
    input clk
);

reg [7:0] sr_mac_rx_data_i [(8+4)-1:0];
reg [(8+4)-1:0] sr_mac_rx_valid_i = 0;
reg [(8+4)-1:0] sr_mac_rx_sof_i   = 0;
reg [(8+4)-1:0] sr_mac_rx_eof_i   = 0;
integer i;
always @(posedge clk) begin
    sr_mac_rx_data_i [0] <= mac_rx_data_i ;
    sr_mac_rx_valid_i[0] <= mac_rx_valid_i;
    sr_mac_rx_sof_i  [0] <= mac_rx_sof_i  ;
    sr_mac_rx_eof_i  [0] <= mac_rx_eof_i  ;

    for (i=1; i<(8+4); i=i+1) begin
        sr_mac_rx_data_i [i] <= sr_mac_rx_data_i [i-1];
        sr_mac_rx_valid_i[i] <= sr_mac_rx_valid_i[i-1];
        sr_mac_rx_sof_i  [i] <= sr_mac_rx_sof_i  [i-1];
        sr_mac_rx_eof_i  [i] <= sr_mac_rx_eof_i  [i-1];
    end

    if (sr_mac_rx_sof_i[10]) begin
        mac_rx_valid_o <= 1'b1;
    end else if (mac_rx_eof_i) begin
        mac_rx_valid_o <= 1'b0;
    end

end

assign mac_rx_data_o = sr_mac_rx_data_i[3];
assign mac_rx_sof_o = sr_mac_rx_sof_i[11];
assign mac_rx_eof_o = mac_rx_eof_i;

endmodule
