//-----------------------------------------------------------------------
// Engineer    : Romashko Dmitry
//
// Create Date :
//
// Description : Stream to RGMII converter. Checks CRC on receive channel
//               and generates on transmit channel.
//
//               Important: Module works at Eth 1Gb only!!!!!
//------------------------------------------------------------------------
module mac_rgmii(
//    output [3:0] dbg,
    output reg [3:0] eth_status_o = 0, /** [0] - link up/down = 1/0
                                      *  [2:1] - phy_rx_clk speed:
                                                 00 - 2.5MHz (Eth:10Mb)
                                                 01 - 25MHz  (Eth:100Mb)
                                                 10 - 125MHz (Eth:1Gb)
                                         [3] - duplex full/half = 1/0
                                      */
    input refclk,

    // receive channel, phy side (RGMII)
    input       phy_rx_clk ,
    input       phy_rx_ctrl,
    input [3:0] phy_rxd    ,
    // receive channel, logic side
    output           mac_rx_clk_o,      // global clock
    output reg       mac_rx_sof_o = 0,
    output reg       mac_rx_eof_o = 0,  // generated only if CRC is valid
    output reg       mac_rx_valid_o = 0,
    output reg [7:0] mac_rx_data_o = 0,

    // transmit channel, phy side (RGMII)
    output       phy_tx_clk ,
    output       phy_tx_ctrl,
    output [3:0] phy_txd    ,
    // transmit channel, logic side
    output      mac_tx_clk,
    input       mac_tx_sof,
    input       mac_tx_eof,
    input       mac_tx_valid,
    input [7:0] mac_tx_data
);

function [31:0] BitReverse;
    input [31:0] in;
    integer i;
    reg [31:0] result;
    begin
        for (i = 0; i < 32; i = i + 1)
            result[i] = in[31-i];
        BitReverse = result;
    end
endfunction


// ------------------------------------------------------------------------------------------
// rx channel output buffering
// ------------------------------------------------------------------------------------------
reg [7:0] mac_rx_data = 0;
reg       mac_rx_sof = 1'b0;
reg       mac_rx_eof = 1'b0;
reg       mac_rx_valid = 1'b0;
reg [3:0] eth_status = 0;

(* ASYNC_REG = "TRUE" *) reg [7:0] sr_mac_rx_data = 0;
(* ASYNC_REG = "TRUE" *) reg       sr_mac_rx_sof = 1'b0;
(* ASYNC_REG = "TRUE" *) reg       sr_mac_rx_eof = 1'b0;
(* ASYNC_REG = "TRUE" *) reg       sr_mac_rx_valid = 1'b0;
(* ASYNC_REG = "TRUE" *) reg [3:0] sr_eth_status = 0;

assign mac_rx_clk_o = mac_tx_clk;

always @(posedge mac_tx_clk) begin
    sr_mac_rx_data  <= mac_rx_data ;
    sr_mac_rx_sof   <= mac_rx_sof  ;
    sr_mac_rx_eof   <= mac_rx_eof  ;
    sr_mac_rx_valid <= mac_rx_valid;
    sr_eth_status   <= eth_status  ;

    mac_rx_data_o  <= sr_mac_rx_data  ;
    mac_rx_sof_o   <= sr_mac_rx_sof   ;
    mac_rx_eof_o   <= sr_mac_rx_eof   ;
    mac_rx_valid_o <= sr_mac_rx_valid ;
    eth_status_o   <= sr_eth_status   ;
end


// ------------------------------------------------------------------------------------------
// rx channel IBUFs
// ------------------------------------------------------------------------------------------

wire phy_rx_clk_ibuf;
wire phy_rx_ctrl_ibuf;
wire [3:0] phy_rxd_ibuf;
wire mac_rx_clk;

IBUF IBUF_rxc (.I(phy_rx_clk), .O(phy_rx_clk_ibuf));
BUFIO BUFIO_rxclk (.I(phy_rx_clk_ibuf), .O(phy_rx_clk_bufio));
BUFR BUFR_rxclk (.I(phy_rx_clk_ibuf), .O(mac_rx_clk), .CE(1'b1), .CLR(0));

IBUF IBUF_rxctl (.I(phy_rx_ctrl), .O(phy_rx_ctrl_ibuf));
IBUF IBUF_rxd0 (.I(phy_rxd[0]), .O(phy_rxd_ibuf[0]));
IBUF IBUF_rxd1 (.I(phy_rxd[1]), .O(phy_rxd_ibuf[1]));
IBUF IBUF_rxd2 (.I(phy_rxd[2]), .O(phy_rxd_ibuf[2]));
IBUF IBUF_rxd3 (.I(phy_rxd[3]), .O(phy_rxd_ibuf[3]));

// ------------------------------------------------------------------------------------------
// rx channel IDELAYE2 for data and ctl inputs
// ------------------------------------------------------------------------------------------
reg idelay_rst = 1;
reg [7:0] idelay_rst_cntr = 0;
always @(posedge refclk) begin
    idelay_rst_cntr <=  idelay_rst_cntr + 1'b1;
    if (idelay_rst_cntr == 255) idelay_rst <= 0;
end

(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYCTRL IDELAYCTRL_rx (
    .REFCLK(refclk),
    .RST(idelay_rst)
);


localparam RX_DATA_DELAY = 12; // 13 - 0.085 setup

wire phy_rx_ctrl_delay;
wire [3:0] phy_rxd_delay;

(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) IDELAYE2_rxctl (
    .IDATAIN(phy_rx_ctrl_ibuf),
    .DATAOUT(phy_rx_ctrl_delay)
);


(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) IDELAYE2_rxd0 (
    .IDATAIN(phy_rxd_ibuf[0]),
    .DATAOUT(phy_rxd_delay[0])
);


(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) IDELAYE2_rxd1 (
    .IDATAIN(phy_rxd_ibuf[1]),
    .DATAOUT(phy_rxd_delay[1])
);

(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) IDELAYE2_rxd2 (
    .IDATAIN(phy_rxd_ibuf[2]),
    .DATAOUT(phy_rxd_delay[2])
);

(* IODELAY_GROUP = "IDELAYE2_mac_rx" *)
IDELAYE2 #(
    .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
    .DELAY_SRC("IDATAIN"),           // Delay input (IDATAIN, DATAIN)
    .HIGH_PERFORMANCE_MODE("TRUE"),  // Reduced jitter ("TRUE"), Reduced power ("FALSE")
    .IDELAY_TYPE("FIXED"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    .IDELAY_VALUE(RX_DATA_DELAY),    // Input delay tap setting (0-31) 78 ps resolution
    .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
    .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
) IDELAYE2_rxd3 (
    .IDATAIN(phy_rxd_ibuf[3]),
    .DATAOUT(phy_rxd_delay[3])
);


// ------------------------------------------------------------------------------------------
// IDDR for rx channel
// ------------------------------------------------------------------------------------------
wire rx_dv;
wire rx_err; // TODO: analyse rxerr
wire [7:0] rx_data;

// localparam IDDR_MODE = "OPPOSITE_EDGE";
localparam IDDR_MODE = "SAME_EDGE_PIPELINED";

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rx_ctrl (
    .C(phy_rx_clk_bufio),
    .D(phy_rx_ctrl_delay),

    .Q1(rx_dv),
    .Q2(rx_err),

    .CE(1'b1), .R(0), .S(0)
);

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rxd3 (
    .C(phy_rx_clk_bufio),
    .D(phy_rxd_delay[3]),

    .Q1(rx_data[3]),
    .Q2(rx_data[7]),

    .CE(1'b1), .R(0), .S(0)
);

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rxd2 (
    .C(phy_rx_clk_bufio),
    .D(phy_rxd_delay[2]),

    .Q1(rx_data[2]),
    .Q2(rx_data[6]),

    .CE(1'b1), .R(0), .S(0)
);

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rxd1 (
    .C(phy_rx_clk_bufio),
    .D(phy_rxd_delay[1]),

    .Q1(rx_data[1]),
    .Q2(rx_data[5]),

    .CE(1'b1), .R(0), .S(0)
);

IDDR #(.DDR_CLK_EDGE(IDDR_MODE)) iddr_rxd0 (
    .C(phy_rx_clk_bufio),
    .D(phy_rxd_delay[0]),

    .Q1(rx_data[0]),
    .Q2(rx_data[4]),

    .CE(1'b1), .R(0), .S(0)
);


// ------------------------------------------------------------------------------------------
// rx channel, register data
// ------------------------------------------------------------------------------------------
reg [7:0] rx_data_d;
reg rx_dv_d;
reg rx_dv_dd;
reg rx_dv_ddd;
reg rx_err_d;

always @(posedge mac_rx_clk) begin
    rx_data_d <= rx_data;
    rx_dv_d <= rx_dv;
    rx_dv_dd <= rx_dv_d;
    rx_dv_ddd <= rx_dv_dd;
    rx_err_d <= rx_err;
end

// ------------------------------------------------------------------------------------------
// rx channel, get status
// ------------------------------------------------------------------------------------------
always @(posedge mac_rx_clk) begin
    if ((rx_dv_d == 1'b0) && (rx_err_d == 1'b0)) begin
        eth_status[3:0] <= rx_data_d[3:0];
    end
end

//assign dbg[0] = rx_data_d[0];
//assign dbg[1] = rx_data_d[1];
//assign dbg[2] = rx_dv_d;
//assign dbg[3] = rx_err_d;

// ------------------------------------------------------------------------------------------
// rx channel, CRC calculation
// ------------------------------------------------------------------------------------------
reg [15:0] rx_cnt = 0;
reg rx_crc_rst = 0;
reg rx_crc_en = 0;
wire [31:0] rx_crc_out;

always @(posedge mac_rx_clk) begin
    rx_cnt <= rx_cnt + 1'b1;
    if (rx_dv_d == 1'b0) rx_cnt <= 0;
    rx_crc_rst <= (rx_cnt == 5);
    if (rx_dv_d == 1'b0) rx_crc_en <= 0;
    if (rx_cnt == 7) rx_crc_en <= 1;
end

mac_crc rx_crc(
    .data_in   (rx_data_d),
    .crc_en    (rx_crc_en),
    .crc_out   (rx_crc_out),
    .rst       (rx_crc_rst),
    .clk       (mac_rx_clk)
);


// ------------------------------------------------------------------------------------------
// rx channel, output stream generation
// ------------------------------------------------------------------------------------------
reg [7:0] rx_data_dd;

always @(posedge mac_rx_clk) begin
    mac_rx_eof <= (rx_crc_out == 32'hC704DD7B); // CRC32 residue detection
    mac_rx_sof <= (rx_cnt == 9);
    if (rx_cnt == 9) mac_rx_valid <= 1;
    if (mac_rx_eof) mac_rx_valid <= 0;
    if (rx_dv_ddd == 1'b0) mac_rx_valid <= 0;
    rx_data_dd <= rx_data_d;
    mac_rx_data <= rx_data_dd;
end




// ------------------------------------------------------------------------------------------
// tx channel, make tx clocks out of rx clock
// ------------------------------------------------------------------------------------------

wire mac_txclk;
wire mac_txclk_90;
wire mac_fbclko;
wire mac_fbclki;

MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(5.0),     // Multiply value for all CLKOUT (2.000-64.000).
    .CLKIN1_PERIOD(8.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    .CLKOUT0_DIVIDE_F(5.0),    // Divide amount for CLKOUT0 (1.000-128.000).
    .CLKOUT1_DIVIDE(5),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(90.0),
    .REF_JITTER1(0.0)         // Reference input jitter in UI (0.000-0.999).
) MMCME2_BASE_clk (
    .CLKIN1(mac_rx_clk),

    .CLKOUT0(mac_txclk),
    .CLKOUT1(mac_txclk_90),

    .CLKFBOUT(mac_fbclko),
    .CLKFBIN(mac_fbclki),

    .LOCKED (),

    .PWRDWN(0),
    .RST(0)
);

BUFG BUFG_mmcm_fbclk (.I(mac_fbclko), .O(mac_fbclki));
BUFG BUFG_mmcm_clko (.I(mac_txclk), .O(mac_tx_clk));
BUFG BUFG_mmcm_clko_90 (.I(mac_txclk_90), .O(mac_tx_clk_90));

// ------------------------------------------------------------------------------------------
// tx channel, make preamble and CRC
// ------------------------------------------------------------------------------------------
reg [7:0] tx_preamble_sending = 0;
reg [13:0] tx_crc_sending = 0;
reg [7:0] tx_data_shr [8:0];
reg tx_dv = 0;
reg [7:0] tx_data = 0;
reg [31:0] tx_crc_stored = 0;

wire [31:0] tx_crc_corrected = BitReverse(~tx_crc_out);

always @(posedge mac_tx_clk) begin
    // data shift register
    tx_data_shr[0] <= mac_tx_valid? mac_tx_data: 0;
    tx_data_shr[1] <= tx_data_shr[0];
    tx_data_shr[2] <= tx_data_shr[1];
    tx_data_shr[3] <= tx_data_shr[2];
    tx_data_shr[4] <= tx_data_shr[3];
    tx_data_shr[5] <= tx_data_shr[4];
    tx_data_shr[6] <= tx_data_shr[5];
    tx_data_shr[7] <= tx_data_shr[6];
    tx_data_shr[8] <= tx_data_shr[7];
    // preamble flag shift register
    tx_preamble_sending <= {tx_preamble_sending[6:0], 1'b0};
    if (mac_tx_sof) tx_preamble_sending <= 8'hFF;
    tx_crc_sending <= {tx_crc_sending[12:0], 1'b0};
    if (mac_tx_eof) tx_crc_sending <= 14'h3FFF;
    if (tx_crc_sending == 14'h3FFF) tx_crc_stored <= tx_crc_corrected;
    // insert preamble
    tx_data <= tx_data_shr[8];
    if (|tx_preamble_sending[6:0]) tx_data <= 8'h55;
    if (tx_preamble_sending == 8'h80) tx_data <= 8'hD5;
    if (tx_crc_sending == 14'h3E00) tx_data <= tx_crc_stored[ 0 +: 8];
    if (tx_crc_sending == 14'h3C00) tx_data <= tx_crc_stored[ 8 +: 8];
    if (tx_crc_sending == 14'h3800) tx_data <= tx_crc_stored[16 +: 8];
    if (tx_crc_sending == 14'h3000) tx_data <= tx_crc_stored[24 +: 8];
    if (tx_preamble_sending == 8'hFF) tx_dv <= 1;
    if (tx_crc_sending == 14'h2000) tx_dv <= 0;
end

wire [31:0] tx_crc_out;

mac_crc tx_crc(
    .data_in   (mac_tx_data),
    .crc_en    (mac_tx_valid),
    .crc_out   (tx_crc_out),
    .rst       (~mac_tx_valid),
    .clk       (mac_tx_clk)
);


// ------------------------------------------------------------------------------------------
// tx channel, make DDR from 8 bit data
// ------------------------------------------------------------------------------------------
wire phy_tx_clk_obuf;
wire phy_tx_ctrl_obuf;
wire [3:0] phy_txd_obuf;

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txclk (
    .C  (mac_tx_clk_90),
    .D1 (1'b1),
    .D2 (1'b0),
    .CE (1'b1),
    .R  (0),
    .S  (0),
    .Q  (phy_tx_clk_obuf)
);

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txctl (
    .C             (mac_tx_clk),
    .D1            (tx_dv),
    .D2            (tx_dv),
    .CE            (1'b1),
    .R             (0),
    .S             (0),
    .Q             (phy_tx_ctrl_obuf)
);

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txd3 (
    .C             (mac_tx_clk),
    .D1            (tx_data[3]),
    .D2            (tx_data[7]),
    .CE            (1'b1),
    .R             (0),
    .S             (0),
    .Q             (phy_txd_obuf[3])
);

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txd2 (
    .C             (mac_tx_clk),
    .D1            (tx_data[2]),
    .D2            (tx_data[6]),
    .CE            (1'b1),
    .R             (0),
    .S             (0),
    .Q             (phy_txd_obuf[2])
);

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txd1 (
    .C             (mac_tx_clk),
    .D1            (tx_data[1]),
    .D2            (tx_data[5]),
    .CE            (1'b1),
    .R             (0),
    .S             (0),
    .Q             (phy_txd_obuf[1])
);

ODDR #(.DDR_CLK_EDGE("SAME_EDGE")) ODDR_txd0 (
    .C             (mac_tx_clk),
    .D1            (tx_data[0]),
    .D2            (tx_data[4]),
    .CE            (1'b1),
    .R             (0),
    .S             (0),
    .Q             (phy_txd_obuf[0])
);


// ------------------------------------------------------------------------------------------
// tx channel, rgmii OBUF
// ------------------------------------------------------------------------------------------

OBUF OBUF_txclk (.I(phy_tx_clk_obuf), .O(phy_tx_clk));
OBUF OBUF_txctl (.I(phy_tx_ctrl_obuf), .O(phy_tx_ctrl));
OBUF OBUF_txd3 (.I(phy_txd_obuf[3]), .O(phy_txd[3]));
OBUF OBUF_txd2 (.I(phy_txd_obuf[2]), .O(phy_txd[2]));
OBUF OBUF_txd1 (.I(phy_txd_obuf[1]), .O(phy_txd[1]));
OBUF OBUF_txd0 (.I(phy_txd_obuf[0]), .O(phy_txd[0]));

endmodule
