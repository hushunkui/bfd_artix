//
// author: Golovachenko Viktor
//
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module RGMIIDDR (
    input [4:0]  datain,
    input  inclock,
    output [4:0]  dataout_h,
    output [4:0]  dataout_l
);

localparam IDDR_MODE = "SAME_EDGE_PIPELINED"; //"OPPOSITE_EDGE";

wire phy_rxc_ibuf;
wire phy_rxc_bufio;
wire phy_rx_ctl_ibuf;
wire [3:0] phy_rxd_ibuf;
wire phy_rxclk;
wire mac_rx_clk;


IBUF ibuf_rxclk (.I(inclock), .O(phy_rxc_ibuf));
BUFG bufio_rxclk (.I(phy_rxc_ibuf), .O(phy_rxc_bufio));
// BUFG bufr_rxclk (.I(phy_rxc_ibuf), .O(phy_rxclk)); //, .CE(1'b1), .CLR(0));

IBUF ibuf_rxctl (.I(datain[4]), .O(phy_rx_ctl_ibuf));
genvar a;
generate for (a=0; a<4; a=a+1)
    begin : ibuf_rxd
        IBUF inst (.I(datain[a]), .O(phy_rxd_ibuf[a]));
    end
endgenerate


// IDDR for rx channel
wire rx_dv;
wire rx_err;
wire [7:0] rx_data;

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rx_ctrl (
    .D(datain[4]),
    .Q1(rx_dv),
    .Q2(rx_err),

    .CE(1'b1), .R(1'b0), .S(1'b0),
    .C(phy_rxc_bufio)
);

genvar c;
generate for (c=0; c<4; c=c+1)
    begin : iddr_rxd
        IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) inst (
            .D(datain[c]),
            .Q1(rx_data[c]),
            .Q2(rx_data[c+4]),

            .CE(1'b1), .R(1'b0), .S(1'b0),
            .C(phy_rxc_bufio)
        );
    end
endgenerate


assign dataout_h[4] = rx_err;
assign dataout_h[3] = rx_data[7];
assign dataout_h[2] = rx_data[6];
assign dataout_h[1] = rx_data[5];
assign dataout_h[0] = rx_data[4];

assign dataout_l[4] = rx_dv;
assign dataout_l[3] = rx_data[3];
assign dataout_l[2] = rx_data[2];
assign dataout_l[1] = rx_data[1];
assign dataout_l[0] = rx_data[0];


endmodule

