//
// author: Golovachenko Viktor
//
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module DDR_OUT (
    input  [5:0]  datain_h,
    input  [5:0]  datain_l,
    input         outclock,
    output [5:0]  dataout
);

localparam ODDR_MODE = "SAME_EDGE";

wire phy_txc_obuf;
wire phy_tx_ctl_obuf;
wire [3:0] phy_txd_obuf;

// tx channel, make DDR from 8 bit data
ODDR #(.DDR_CLK_EDGE(ODDR_MODE)) oddr_txclk (
    .D1 (datain_h[5]),
    .D2 (datain_l[5]),
    .Q  (phy_txc_obuf),

    .CE (1'b1), .R(1'b0), .S(1'b0),
    .C  (outclock)
);

ODDR #(.DDR_CLK_EDGE(ODDR_MODE)) oddr_txctl (
    .D1 (datain_h[4]),
    .D2 (datain_l[4]),
    .Q  (phy_tx_ctl_obuf),

    .CE (1'b1), .R(1'b0), .S(1'b0),
    .C  (outclock)
);

genvar d;
generate for (d=0; d<4; d=d+1)
    begin : oddr_txd
        ODDR #(.DDR_CLK_EDGE(ODDR_MODE)) inst (
            .D1 (datain_h[d]),
            .D2 (datain_l[d]),
            .Q  (phy_txd_obuf[d]),

            .CE (1'b1), .R(1'b0), .S(1'b0),
            .C  (outclock)
        );
    end
endgenerate

// tx channel, rgmii OBUF
OBUF obuf_txclk (.I(phy_txc_obuf), .O(dataout[5]));
OBUF obuf_txctl (.I(phy_tx_ctl_obuf), .O(dataout[4]));
genvar e;
generate for (e=0; e<4; e=e+1)
    begin : obuf_txd
        OBUF inst (.I(phy_txd_obuf[e]), .O(dataout[e]));
    end
endgenerate


endmodule
