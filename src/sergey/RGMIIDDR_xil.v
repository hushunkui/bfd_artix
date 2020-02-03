//
// author: Golovachenko Viktor
//
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module RGMIIDDR (
    input [4:0]  datain,
    input  inclock,
    input  inclock2,
    output reg [4:0]  dataout_h = 0,
    output reg [4:0]  dataout_l = 0
);

localparam IDDR_MODE = "SAME_EDGE_PIPELINED"; //"OPPOSITE_EDGE";

wire phy_rxc_bufio;
wire phy_rx_ctl_ibuf;
wire [3:0] phy_rxd_ibuf;
wire phy_rxclk;

wire phy_rx_ctl_delay;
wire [3:0] phy_rxd_delay;

wire rst;

assign rst = 1'b0;

assign phy_rxc_bufio = inclock2;
assign phy_rxclk = inclock;

IBUF ibuf_rxctl (.I(datain[4]), .O(phy_rx_ctl_ibuf));
genvar a;
generate for (a=0; a<4; a=a+1)
    begin : ibuf_rxd
        IBUF inst (.I(datain[a]), .O(phy_rxd_ibuf[a]));
    end
endgenerate

// rx channel IDELAYE2 for data and ctl inputs
localparam RX_DATA_DELAY = 12; // 13 - 0.085 setup

IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) idelay_rxctl (
    .CNTVALUEOUT(),                 // 5-bit output: Counter value output
    .DATAOUT    (phy_rx_ctl_delay),// 1-bit output: Delayed data output
    .C          (1'b0),             // 1-bit input: Clock input
    .CE         (1'b0),             // 1-bit input: Active high enable increment/decrement input
    .CINVCTRL   (1'b0),             // 1-bit input: Dynamic clock inversion input
    .CNTVALUEIN (5'd0),             // 5-bit input: Counter value input
    .DATAIN     (1'b0),             // 1-bit input: Internal delay data input
    .IDATAIN    (phy_rx_ctl_ibuf), // 1-bit input: Data input from the I/O
    .INC        (1'b0),             // 1-bit input: Increment / Decrement tap delay input
    .LD         (1'b0),             // 1-bit input: Load IDELAY_VALUE input
    .LDPIPEEN   (1'b0),             // 1-bit input: Enable PIPELINE register to load data input
    .REGRST     (rst)               // 1-bit input: Active-high reset tap-delay input
);

genvar b;
generate for (b=0; b<4; b=b+1)
    begin : idelay_rxd
        IDELAYE2 #(
            .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
            .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
            .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
            .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
            .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
            .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
            .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
            .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
        ) inst (
            .CNTVALUEOUT(),                 // 5-bit output: Counter value output
            .DATAOUT    (phy_rxd_delay[b]), // 1-bit output: Delayed data output
            .C          (1'b0),             // 1-bit input: Clock input
            .CE         (1'b0),             // 1-bit input: Active high enable increment/decrement input
            .CINVCTRL   (1'b0),             // 1-bit input: Dynamic clock inversion input
            .CNTVALUEIN (5'd0),             // 5-bit input: Counter value input
            .DATAIN     (1'b0),             // 1-bit input: Internal delay data input
            .IDATAIN    (phy_rxd_ibuf[b]),  // 1-bit input: Data input from the I/O
            .INC        (1'b0),             // 1-bit input: Increment / Decrement tap delay input
            .LD         (1'b0),             // 1-bit input: Load IDELAY_VALUE input
            .LDPIPEEN   (1'b0),             // 1-bit input: Enable PIPELINE register to load data input
            .REGRST     (rst)               // 1-bit input: Active-high reset tap-delay input
        );
    end
endgenerate

// IDDR for rx channel
wire rx_dv;
wire rx_err;
wire [7:0] rx_data;

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rx_ctrl (
    .D(phy_rx_ctl_delay),
    .Q1(rx_dv),
    .Q2(rx_err),

    .CE(1'b1), .R(rst), .S(1'b0),
    .C(phy_rxc_bufio)
);

genvar c;
generate for (c=0; c<4; c=c+1)
    begin : iddr_rxd
        IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) inst (
            .D(phy_rxd_delay[c]),
            .Q1(rx_data[c]),
            .Q2(rx_data[c+4]),

            .CE(1'b1), .R(rst), .S(1'b0),
            .C(phy_rxc_bufio)
        );
    end
endgenerate


always @(posedge phy_rxclk) begin
    dataout_h[4] <= rx_err;
    dataout_h[3] <= rx_data[3];
    dataout_h[2] <= rx_data[2];
    dataout_h[1] <= rx_data[1];
    dataout_h[0] <= rx_data[0];

    dataout_l[4] <= rx_dv;
    dataout_l[3] <= rx_data[7];
    dataout_l[2] <= rx_data[6];
    dataout_l[1] <= rx_data[5];
    dataout_l[0] <= rx_data[4];
end

endmodule

