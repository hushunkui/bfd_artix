//
//author: Golovachenko Viktor
//
`timescale 1ns / 1ps
module aurora_axi_tx_mux_tb #(
    parameter SIM = 0
);
localparam ETHCOUNT = 4;

reg clk = 1;
always #20 clk = ~clk;

reg rstn = 1'b0;

reg         axis_m_tready = 1'b1;
wire [31:0] axis_m_tdata ;
wire [3:0]  axis_m_tkeep ;
wire        axis_m_tvalid;
wire        axis_m_tlast ;

wire [ETHCOUNT-1:0] axis_tready;
wire [31:0] axis_tdata [ETHCOUNT-1:0];
wire [3:0]  axis_tkeep [ETHCOUNT-1:0];
wire [ETHCOUNT-1:0] axis_tvalid;
wire [ETHCOUNT-1:0] axis_tlast ;
wire [ETHCOUNT-1:0] axis_tuser ;

localparam MACCOUNT = 1;
reg [7:0] mac_rx_data [MACCOUNT-1:0];
reg [MACCOUNT-1:0] mac_rx_valid;
reg [MACCOUNT-1:0] mac_rx_sof  ;
reg [MACCOUNT-1:0] mac_rx_eof  ;
reg [MACCOUNT-1:0] mac_rx_err  ;

integer x,len,i;
initial begin
    for (i=0;i<MACCOUNT;i=i+1) begin
        mac_rx_data[i]  = 0;
        mac_rx_valid[i] = 0;
        mac_rx_sof[i]   = 0;
        mac_rx_eof[i]   = 0;
        mac_rx_err[i]   = 0;
    end

    axis_m_tready = 1'b1;
    #100;

    rstn = 1'b1;
    #100;
    rstn = 1'b0;
    #100;
    rstn = 1'b1;
    #1000;

    @(posedge clk)
    mac_rx_valid[0] = 0;
    mac_rx_sof[0]   = 0;
    mac_rx_eof[0]   = 0;
    mac_rx_err[0]   = 0;

    for (i=0;i<32;i=i+1) begin
        len=1 + i;
        mac_rx_data[0] = 0;
        for (x=0;x<len;x=x+1) begin
            @(posedge clk)
            mac_rx_data[0] = mac_rx_data[0] + 1;
            mac_rx_valid[0] = 1;
            mac_rx_sof[0] = (x==0) ? 1 : 0;
            mac_rx_eof[0] = (x==(len-1)) ? 1 : 0;
            mac_rx_err[0] = 0;
        end
        @(posedge clk)
        mac_rx_valid[0] = 0;
        mac_rx_sof[0]   = 0;
        mac_rx_eof[0]   = 0;
        mac_rx_err[0]   = 0;
        #500;
    end

    // fork
    //     begin
    //         @(posedge clk)
    //         @(posedge clk)
    //         mac_rx_valid[0] = 0;
    //         mac_rx_sof[0]   = 0;
    //         mac_rx_eof[0]   = 0;
    //         mac_rx_err[0]   = 0;

    //         for (i=0;i<32;i=i+1) begin
    //             len=1 + i;
    //             mac_rx_data[0] = 0;
    //             for (x=0;x<len;x=x+1) begin
    //                 @(posedge clk)
    //                 mac_rx_data[0] = mac_rx_data[0] + 1;
    //                 mac_rx_valid[0] = 1;
    //                 mac_rx_sof[0] = (x==0) ? 1 : 0;
    //                 mac_rx_eof[0] = (x==(len-1)) ? 1 : 0;
    //                 mac_rx_err[0] = 0;
    //             end
    //             @(posedge clk)
    //             mac_rx_valid[0] = 0;
    //             mac_rx_sof[0]   = 0;
    //             mac_rx_eof[0]   = 0;
    //             mac_rx_err[0]   = 0;
    //             #500;
    //         end
    //     end

    //     begin
    //         @(posedge clk)
    //         mac_rx_valid[1] = 0;
    //         mac_rx_sof[1]   = 0;
    //         mac_rx_eof[1]   = 0;
    //         mac_rx_err[1]   = 0;

    //         for (i=0;i<32;i=i+1) begin
    //             len=1 + i;
    //             mac_rx_data[1] = 0;
    //             for (x=0;x<len;x=x+1) begin
    //                 @(posedge clk)
    //                 mac_rx_data[1] = mac_rx_data[1] + 1;
    //                 mac_rx_valid[1] = 1;
    //                 mac_rx_sof[1] = (x==0) ? 1 : 0;
    //                 mac_rx_eof[1] = (x==(len-1)) ? 1 : 0;
    //                 mac_rx_err[1] = 0;
    //             end
    //             @(posedge clk)
    //             mac_rx_valid[1] = 0;
    //             mac_rx_sof[1]   = 0;
    //             mac_rx_eof[1]   = 0;
    //             mac_rx_err[1]   = 0;
    //             #500;
    //         end
    //     end

    //     begin
    //         @(posedge clk)
    //         mac_rx_valid[2] = 0;
    //         mac_rx_sof[2]   = 0;
    //         mac_rx_eof[2]   = 0;
    //         mac_rx_err[2]   = 0;

    //         for (i=0;i<32;i=i+1) begin
    //             len=1 + i;
    //             mac_rx_data[2] = 0;
    //             for (x=0;x<len;x=x+1) begin
    //                 @(posedge clk)
    //                 mac_rx_data[2] = mac_rx_data[2] + 1;
    //                 mac_rx_valid[2] = 1;
    //                 mac_rx_sof[2] = (x==0) ? 1 : 0;
    //                 mac_rx_eof[2] = (x==(len-1)) ? 1 : 0;
    //                 mac_rx_err[2] = 0;
    //             end
    //             @(posedge clk)
    //             mac_rx_valid[2] = 0;
    //             mac_rx_sof[2]   = 0;
    //             mac_rx_eof[2]   = 0;
    //             mac_rx_err[2]   = 0;
    //             #500;
    //         end
    //     end

    //     begin
    //         @(posedge clk)
    //         mac_rx_valid[3] = 0;
    //         mac_rx_sof[3]   = 0;
    //         mac_rx_eof[3]   = 0;
    //         mac_rx_err[3]   = 0;

    //         for (i=0;i<32;i=i+1) begin
    //             len=1 + i;
    //             mac_rx_data[3] = 0;
    //             for (x=0;x<len;x=x+1) begin
    //                 @(posedge clk)
    //                 mac_rx_data[3] = mac_rx_data[3] + 1;
    //                 mac_rx_valid[3] = 1;
    //                 mac_rx_sof[3] = (x==0) ? 1 : 0;
    //                 mac_rx_eof[3] = (x==(len-1)) ? 1 : 0;
    //                 mac_rx_err[3] = 0;
    //             end
    //             @(posedge clk)
    //             mac_rx_valid[3] = 0;
    //             mac_rx_sof[3]   = 0;
    //             mac_rx_eof[3]   = 0;
    //             mac_rx_err[3]   = 0;
    //             #500;
    //         end
    //     end
    // join

    // $finish;
end

genvar a;
generate
    for (a=0; a < ETHCOUNT; a=a+1)  begin : eth
        mac_rxbuf # (
            .SIM(SIM)
        ) mac1_rxbuf (
            .axis_tready(axis_tready[a]), //input
            .axis_tdata (axis_tdata [a]), //output [31:0]
            .axis_tkeep (axis_tkeep [a]), //output [3:0]
            .axis_tvalid(axis_tvalid[a]), //output
            .axis_tlast (axis_tlast [a]), //output
            .axis_tuser (axis_tuser [a]), //output

            .mac_rx_data (mac_rx_data[0] ), //input [7:0]
            .mac_rx_valid(mac_rx_valid[0]), //input
            .mac_rx_sof  (mac_rx_sof[0]  ), //input
            .mac_rx_eof  (mac_rx_eof[0]  ), //input
            .mac_rx_err  (mac_rx_err[0]  ), //input

            .rstn(rstn),
            .clk(clk)
        );
    end
endgenerate

aurora_axi_tx_mux #(
    .ETHCOUNT(4),
    .SIM(SIM)
) aurora0_axi_tx_mux (
    .trunc(0), //input [1:0]
    .eth_mask(4'hE),

    .axis_s_tready(axis_tready), //output [ETHCOUNT-1:0]
    .axis_s_tdata ({axis_tdata[3],axis_tdata[2],axis_tdata[1],axis_tdata[0]}), //input  [(ETHCOUNT*32)-1:0]
    .axis_s_tkeep ({axis_tkeep[3],axis_tkeep[2],axis_tkeep[1],axis_tkeep[0]}), //input  [(ETHCOUNT*4-1):0]
    .axis_s_tvalid({axis_tvalid[3],axis_tvalid[2],axis_tvalid[1],axis_tvalid[0]}), //input  [ETHCOUNT-1:0]
    .axis_s_tlast ({axis_tlast[3],axis_tlast[2],axis_tlast[1],axis_tlast[0]}), //input  [ETHCOUNT-1:0]
    .axis_s_tuser ({axis_tuser[3],axis_tuser[2],axis_tuser[1],axis_tuser[0]}), //input  [ETHCOUNT-1:0]

    .axis_m_tready(axis_m_tready), //input
    .axis_m_tdata (axis_m_tdata ), //output reg [31:0]
    .axis_m_tkeep (axis_m_tkeep ), //output reg [3:0]
    .axis_m_tvalid(axis_m_tvalid), //output reg
    .axis_m_tlast (axis_m_tlast ), //output reg

    .rstn(rstn),
    .clk(clk)
);

endmodule

