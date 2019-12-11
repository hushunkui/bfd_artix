`timescale 1ps / 1ps

module mac_fifo # (
    parameter FULL_DUPLEX_ONLY = 1
) (
    input             tx_fifo_aclk,           // tx fifo clock
    input             tx_fifo_resetn,          // tx fifo clock synchronous reset
    // tx fifo AXI-Stream interface
    input    [7:0]    tx_axis_fifo_tdata,
    input             tx_axis_fifo_tvalid,
    input             tx_axis_fifo_tlast,
    output            tx_axis_fifo_tready,

    input             tx_mac_aclk,            // tx_mac clock
    input             tx_mac_resetn,           // tx mac clock synchronous reset
    // tx mac AXI-Stream interface
    output   [7:0]    tx_axis_mac_tdata,
    output            tx_axis_mac_tvalid,
    output            tx_axis_mac_tlast,
    input             tx_axis_mac_tready,
    output            tx_axis_mac_tuser,
    // tx FIFO status outputs
    output            tx_fifo_overflow,
    output   [3:0]    tx_fifo_status,
    // tx fifo duplex controls
    input             tx_collision,
    input             tx_retransmit,

    input             rx_fifo_aclk,           // rx fifo clock
    input             rx_fifo_resetn,          // rx fifo clock synchronous reset
    // rx fifo AXI-Stream interface
    output   [7:0]    rx_axis_fifo_tdata,
    output            rx_axis_fifo_tvalid,
    output            rx_axis_fifo_tlast,
    input             rx_axis_fifo_tready,

    input             rx_mac_aclk,            // rx mac clock
    input             rx_mac_resetn,           // rx mac clock synchronous reset
    // rx mac AXI-Stream interface
    input    [7:0]    rx_axis_mac_tdata,
    input             rx_axis_mac_tvalid,
    input             rx_axis_mac_tlast,
    input             rx_axis_mac_tuser,
    // rx fifo status outputs
    output   [3:0]    rx_fifo_status,
    output            rx_fifo_overflow
);

mac_fifo_tx # (
    .FULL_DUPLEX_ONLY (FULL_DUPLEX_ONLY)
) tx_fifo_i (
    .tx_fifo_aclk       (tx_fifo_aclk),
    .tx_fifo_resetn     (tx_fifo_resetn),
    .tx_axis_fifo_tdata (tx_axis_fifo_tdata),
    .tx_axis_fifo_tvalid(tx_axis_fifo_tvalid),
    .tx_axis_fifo_tlast (tx_axis_fifo_tlast),
    .tx_axis_fifo_tready(tx_axis_fifo_tready),

    .tx_mac_aclk        (tx_mac_aclk),
    .tx_mac_resetn      (tx_mac_resetn),
    .tx_axis_mac_tdata  (tx_axis_mac_tdata),
    .tx_axis_mac_tvalid (tx_axis_mac_tvalid),
    .tx_axis_mac_tlast  (tx_axis_mac_tlast),
    .tx_axis_mac_tready (tx_axis_mac_tready),
    .tx_axis_mac_tuser  (tx_axis_mac_tuser),

    .fifo_overflow      (tx_fifo_overflow),
    .fifo_status        (tx_fifo_status),

    .tx_collision       (tx_collision),
    .tx_retransmit      (tx_retransmit)
);

mac_fifo_rx rx_fifo_i
(
    .rx_fifo_aclk       (rx_fifo_aclk),
    .rx_fifo_resetn     (rx_fifo_resetn),
    .rx_axis_fifo_tdata (rx_axis_fifo_tdata),
    .rx_axis_fifo_tvalid(rx_axis_fifo_tvalid),
    .rx_axis_fifo_tlast (rx_axis_fifo_tlast),
    .rx_axis_fifo_tready(rx_axis_fifo_tready),

    .rx_mac_aclk        (rx_mac_aclk),
    .rx_mac_resetn      (rx_mac_resetn),
    .rx_axis_mac_tdata  (rx_axis_mac_tdata),
    .rx_axis_mac_tvalid (rx_axis_mac_tvalid),
    .rx_axis_mac_tlast  (rx_axis_mac_tlast),
    .rx_axis_mac_tuser  (rx_axis_mac_tuser),

    .fifo_status        (rx_fifo_status),
    .fifo_overflow      (rx_fifo_overflow)
);

endmodule
