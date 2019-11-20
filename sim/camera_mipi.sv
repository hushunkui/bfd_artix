//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 14.06.2018 15:38:21
// Module Name : camera_mipi
//
// Description :
//
//------------------------------------------------------------------------

`define  MIPI_CSI_DT_SYNC_FS  (6'h00)
`define  MIPI_CSI_DT_SYNC_FE  (6'h01)
`define  MIPI_CSI_DT_SYNC_LS  (6'h02)
`define  MIPI_CSI_DT_SYNC_LE  (6'h03)

`define  MIPI_CSI_DT_RAW8     (6'h2A)
`define  MIPI_CSI_DT_RAW10    (6'h2B)

`timescale 1ns / 1ps

`include "bmp_io.sv"

module camera_mipi # (
//    parameter START_DELAY = 40000,
    parameter DDRCLK_PERIOD = 8, //8 - 126MHz; 16 - 62.5MHz

    parameter READ_IMG_FILE = "bayer_testimage_2.bmp",

    parameter TEST_CNT_EN = 1, //counter instead data from file

    parameter DPHY_LANE_COUNT = 4,

    parameter DPHY_DELAY_RANDOM_EN = 0, //0 - Fixed delay; 1 - Random delay
    parameter DPHY_DELAY_MAX = 40,      //Value for Fixed delay or MAX value for Random Delay
    parameter DPHY_DELAY_MIN = 1 ,      //MIN value for Random Delay

    parameter DELAY_BETWEEN_LINE = 4,
    parameter PIXEL_WIDTH = 8,
    parameter FRCNT_COUNT = 1 //500,
)(
    output [DPHY_LANE_COUNT-1:0] csi_hs_dp,
    output [DPHY_LANE_COUNT-1:0] csi_hs_dn,
    output                       csi_hs_cp,
    output                       csi_hs_cn,

    output [DPHY_LANE_COUNT-1:0] csi_lp_dp,
    output [DPHY_LANE_COUNT-1:0] csi_lp_dn,
    output                       csi_lp_cp,
    output                       csi_lp_cn,

    input reset
);

BMP_IO image_in;
int xcnt_monitor;
int ycnt_monitor;
int frcnt_monitor;

//***********************************
//System clock gen
//***********************************
reg clk = 1'b1;

always #(DDRCLK_PERIOD/2) clk = ~clk;
//task tick;
//    begin : blk_clkgen
//        @(posedge clk);#0;
//    end : blk_clkgen
//endtask : tick


//***********************************
//
//***********************************
localparam DPHY_LANE_COUNT_MAX = 8;
logic [DPHY_LANE_COUNT_MAX-1:0] hs_dp;
logic [DPHY_LANE_COUNT_MAX-1:0] hs_dn;
logic [DPHY_LANE_COUNT_MAX-1:0] lp_dp;
logic [DPHY_LANE_COUNT_MAX-1:0] lp_dn;

function void PrintTestbanchParam();
    $display("\nCurrent testbanch params:");
    $display("PIXEL_WIDTH - %02d", PIXEL_WIDTH);
    $display("FRCNT_COUNT - %04d", FRCNT_COUNT);
    $display("DPHY_DELAY_RANDOM_EN - %02d", DPHY_DELAY_RANDOM_EN);
    $display("DPHY_DELAY_MAX - %02d", DPHY_DELAY_MAX);
    $display("DPHY_DELAY_MIN - %02d", DPHY_DELAY_MIN);
    $display("\n");
endfunction

function [7:0] calcECC(input [24:0] data);
    begin
        logic [7:0] ecc;

        ecc[7] = 1'b0;
        ecc[6] = 1'b0;
        ecc[5] = data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^ data[15] ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[23];
        ecc[4] = data[4]  ^ data[5]  ^ data[6]  ^ data[7]  ^ data[8]  ^ data[9]  ^ data[16] ^ data[17] ^ data[18] ^ data[19] ^ data[20] ^ data[22] ^ data[23];
        ecc[3] = data[1]  ^ data[2]  ^ data[3]  ^ data[7]  ^ data[8]  ^ data[9]  ^ data[13] ^ data[14] ^ data[15] ^ data[19] ^ data[20] ^ data[21] ^ data[23];
        ecc[2] = data[0]  ^ data[2]  ^ data[3]  ^ data[5]  ^ data[6]  ^ data[9]  ^ data[11] ^ data[12] ^ data[15] ^ data[18] ^ data[20] ^ data[21] ^ data[22];
        ecc[1] = data[0]  ^ data[1]  ^ data[3]  ^ data[4]  ^ data[6]  ^ data[8]  ^ data[10] ^ data[12] ^ data[14] ^ data[17] ^ data[20] ^ data[21] ^ data[22] ^ data[23];
        ecc[0] = data[0]  ^ data[1]  ^ data[2]  ^ data[4]  ^ data[5]  ^ data[7]  ^ data[10] ^ data[11] ^ data[13] ^ data[16] ^ data[20] ^ data[21] ^ data[22] ^ data[23];

        return (ecc);
    end
endfunction : calcECC

task Send32bit(input [31:0] data);
    begin
        fork
            begin : fork_lane0
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 0];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 1];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 2];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 3];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 4];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 5];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 6];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 7];

                if (DPHY_LANE_COUNT == 2) begin
                @(posedge clk); #0; hs_dp[0] = data[(8*2) + 0];
                @(negedge clk); #0; hs_dp[0] = data[(8*2) + 1];
                @(posedge clk); #0; hs_dp[0] = data[(8*2) + 2];
                @(negedge clk); #0; hs_dp[0] = data[(8*2) + 3];
                @(posedge clk); #0; hs_dp[0] = data[(8*2) + 4];
                @(negedge clk); #0; hs_dp[0] = data[(8*2) + 5];
                @(posedge clk); #0; hs_dp[0] = data[(8*2) + 6];
                @(negedge clk); #0; hs_dp[0] = data[(8*2) + 7];
                end
            end

            begin : fork_lane1
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 0];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 1];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 2];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 3];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 4];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 5];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 6];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 7];

                if (DPHY_LANE_COUNT == 2) begin
                @(posedge clk); #0; hs_dp[1] = data[(8*3) + 0];
                @(negedge clk); #0; hs_dp[1] = data[(8*3) + 1];
                @(posedge clk); #0; hs_dp[1] = data[(8*3) + 2];
                @(negedge clk); #0; hs_dp[1] = data[(8*3) + 3];
                @(posedge clk); #0; hs_dp[1] = data[(8*3) + 4];
                @(negedge clk); #0; hs_dp[1] = data[(8*3) + 5];
                @(posedge clk); #0; hs_dp[1] = data[(8*3) + 6];
                @(negedge clk); #0; hs_dp[1] = data[(8*3) + 7];
                end
            end

            begin : fork_lane2
                if (DPHY_LANE_COUNT == 4) begin
                @(posedge clk); #0; hs_dp[2] = data[(8*2) + 0];
                @(negedge clk); #0; hs_dp[2] = data[(8*2) + 1];
                @(posedge clk); #0; hs_dp[2] = data[(8*2) + 2];
                @(negedge clk); #0; hs_dp[2] = data[(8*2) + 3];
                @(posedge clk); #0; hs_dp[2] = data[(8*2) + 4];
                @(negedge clk); #0; hs_dp[2] = data[(8*2) + 5];
                @(posedge clk); #0; hs_dp[2] = data[(8*2) + 6];
                @(negedge clk); #0; hs_dp[2] = data[(8*2) + 7];
                end
            end

            begin : fork_lane3
                if (DPHY_LANE_COUNT == 4) begin
                @(posedge clk); #0; hs_dp[3] = data[(8*3) + 0];
                @(negedge clk); #0; hs_dp[3] = data[(8*3) + 1];
                @(posedge clk); #0; hs_dp[3] = data[(8*3) + 2];
                @(negedge clk); #0; hs_dp[3] = data[(8*3) + 3];
                @(posedge clk); #0; hs_dp[3] = data[(8*3) + 4];
                @(negedge clk); #0; hs_dp[3] = data[(8*3) + 5];
                @(posedge clk); #0; hs_dp[3] = data[(8*3) + 6];
                @(negedge clk); #0; hs_dp[3] = data[(8*3) + 7];
                end
            end
        join
    end
endtask : Send32bit


task Send16bit(input [15:0] data);
    begin
        fork
            begin
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 0];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 1];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 2];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 3];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 4];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 5];
                @(posedge clk); #0; hs_dp[0] = data[(8*0) + 6];
                @(negedge clk); #0; hs_dp[0] = data[(8*0) + 7];

            end

            begin
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 0];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 1];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 2];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 3];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 4];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 5];
                @(posedge clk); #0; hs_dp[1] = data[(8*1) + 6];
                @(negedge clk); #0; hs_dp[1] = data[(8*1) + 7];
            end
        join
    end
endtask : Send16bit


task SendLP(input [31:0] data);
    begin
        fork
            begin
                lp_dn[0] = data[(4*0) + 0];
                lp_dp[0] = data[(4*0) + 1];
            end

            begin
                lp_dn[1] = data[(4*1) + 0];
                lp_dp[1] = data[(4*1) + 1];
            end

            begin
                lp_dn[2] = data[(4*2) + 0];
                lp_dp[2] = data[(4*2) + 1];
            end

            begin
                lp_dn[3] = data[(4*3) + 0];
                lp_dp[3] = data[(4*3) + 1];
            end
        join
    end
endtask : SendLP

task MIPI_LP11();
    begin
        #0; SendLP(32'h00003333);
    end
endtask : MIPI_LP11

task MIPI_LP01();
    begin
        #5; SendLP(32'h00001111);
    end
endtask : MIPI_LP01

task MIPI_LP00();
    begin
        #5; SendLP(32'h00000000);
    end
endtask : MIPI_LP00

task MIPI_SoT();
    begin
        Send32bit(32'h00000000);
        Send32bit(32'h00000000);
    end
endtask : MIPI_SoT

task MIPI_EoT(input int delay_value);
    begin
       MIPI_LP11();
        #delay_value;
    end
endtask : MIPI_EoT


task MIPI_SendSyncSequnce();
    begin
        integer i;
        logic [31:0] sync;
        for(i = 0; i < DPHY_LANE_COUNT; i++) begin
            sync[(8*i) +: 8] = 8'hB8;
        end
        if (DPHY_LANE_COUNT == 4) begin
        Send32bit(sync);
        end else begin
        Send16bit(sync[15:0]);
        end
    end
endtask : MIPI_SendSyncSequnce


task MIPI_HeaderPkt(input [7:0] DataID, input [15:0] WordCount);
    begin
        Send32bit({calcECC({WordCount, DataID}), WordCount, DataID});
    end
endtask : MIPI_HeaderPkt


task CSI_ShortPkt_FS (input [15:0] frame_num);
    begin
        logic [15:0] nframe;
        logic [7:0] DataID;
        DataID = {{2{1'b0}}, `MIPI_CSI_DT_SYNC_FS};

        if (frame_num == 0) begin
            $display("\tERROR: frame_num can`t value = 0");
            $stop;
        end

        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        MIPI_HeaderPkt(DataID, frame_num);
        #100;
        MIPI_EoT(500);
    end
endtask : CSI_ShortPkt_FS


task CSI_ShortPkt_FE(input [15:0] frame_num);
    begin
        logic [7:0] DataID;

        DataID = {{2{1'b0}}, `MIPI_CSI_DT_SYNC_FE};

        if (frame_num == 0) begin
            $display("\tERROR: frame_num can`t value = 0");
            $stop;
        end

        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        MIPI_HeaderPkt(DataID, frame_num);
        MIPI_LP11();
        MIPI_EoT(500);
    end
endtask : CSI_ShortPkt_FE


task CSI_ShortPkt_LS(input [15:0] line_num);
    begin
        logic [7:0] DataID;
        DataID = {{2{1'b0}}, `MIPI_CSI_DT_SYNC_LS};

        if (line_num == 0) begin
            $display("\tERROR: line_num can`t value = 0");
            $stop;
        end

        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        MIPI_HeaderPkt(DataID, line_num);
        MIPI_EoT(500);
    end
endtask : CSI_ShortPkt_LS


task CSI_ShortPkt_LE(input [15:0] line_num);
    begin
        logic [7:0] DataID;
        DataID = {{2{1'b0}}, `MIPI_CSI_DT_SYNC_LE};

        if (line_num == 0) begin
            $display("\tERROR: line_num can`t value = 0");
            $stop;
        end

        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        MIPI_HeaderPkt(DataID, line_num);
        MIPI_EoT(500);
    end
endtask : CSI_ShortPkt_LE


task CSI_LongPkt_RAW10(input int num_line);
    begin
        integer i;
        logic [7:0] DataID;
        logic [15:0] WordCount;
        logic [9:0] Pixels_10bit [256-1:0];
        logic [7:0] PixelArrayPack [(256+256/4)-1:0];
        logic [1:0] PixelArrayPackLSB [3:0];
        logic [15:0] PayloadWord [256-1:0];
        logic [15:0] CRC;
        logic [2:0] pixcount_lsb;
        logic [1023:0] pixcount;
        logic [31:0] PayloadDW;

        DataID = 0;
        WordCount = 0;
        CRC = 16'hAA;
        pixcount_lsb = 0;
        pixcount = 0;
        PayloadDW = 0;

        //set pixels
        for(i = 0; i < $size(Pixels_10bit); i++) begin
            Pixels_10bit[i] = i + 1;
        end

        //set packet pixels 10bit to 8bit
        for(i = 0; i < $size(PixelArrayPack); i++) begin
            if (pixcount_lsb == 4) begin
                PixelArrayPack[i] = {PixelArrayPackLSB[3]
                                   , PixelArrayPackLSB[2]
                                   , PixelArrayPackLSB[1]
                                   , PixelArrayPackLSB[0]};
                pixcount_lsb = 0;
            end else begin
                PixelArrayPack[i] = Pixels_10bit[pixcount][9:2];
                PixelArrayPackLSB[pixcount_lsb] = Pixels_10bit[pixcount][1:0];
                pixcount_lsb++;
                pixcount++;
            end
        end

        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        DataID = {{2'b0}, `MIPI_CSI_DT_RAW10};
        WordCount = $size(PixelArrayPack);
        MIPI_HeaderPkt(DataID, WordCount);
        for(i = 0; i < WordCount; i += 4) begin
            PayloadDW = {PixelArrayPack[i+3]
                       , PixelArrayPack[i+2]
                       , PixelArrayPack[i+1]
                       , PixelArrayPack[i]};
            Send32bit(PayloadDW);
        end
        PayloadDW = {16'd0, CRC};
        Send32bit(PayloadDW);
        MIPI_EoT(600);
    end
endtask : CSI_LongPkt_RAW10


task CSI_LongPkt_RAW8(input int num_line);
    begin
        int i;
        logic [7:0] DataID;
        logic [15:0] WordCount;
        logic [7:0] Pixel [4096-1:0]; //Max Frame Line 4096byte!!!!
        logic [15:0] CRC;
        int image_w;

        DataID = 0;
        WordCount = 0;
        CRC = 16'hF0;

        for(i = 0; i < $size(Pixel); i++) begin
            Pixel[i] = 0;
        end

        //get image line
        image_w = image_in.get_x();
        if (image_w % 4) begin
            image_w -= (image_w % 4);
            if (num_line == 0) begin
                $display("\tWarning: Image width(%04d) cat to width(%04d)", image_in.get_x(), image_w);
            end
        end
        for(i = 0; i < image_w; i++) begin
            Pixel[i] = (TEST_CNT_EN) ? (i + 1) : image_in.get_pixel(i, num_line);
        end

        xcnt_monitor = 0;
        #100;
        MIPI_LP11();
        MIPI_LP01();
        MIPI_LP00();
        MIPI_SoT();
        MIPI_SendSyncSequnce();
        DataID = {{2'b0}, `MIPI_CSI_DT_RAW8};
        WordCount = image_w;
        MIPI_HeaderPkt(DataID, WordCount);
        for(i = 0; i < WordCount; i += 4) begin
            Send32bit({Pixel[i+3], Pixel[i+2], Pixel[i+1], Pixel[i]});
            xcnt_monitor += 4;
        end

        Send32bit({16'd0, CRC});
        MIPI_EoT(680);
    end
endtask : CSI_LongPkt_RAW8



initial begin : sim_main
    int i;
    int nfr;
    int nline;

    $display("Camera MIPI (Model): start simulation");

    xcnt_monitor = 0;
    ycnt_monitor = 0;
    frcnt_monitor = 0;

    hs_dp = 0;
    nfr = 16'hBBAA;
    nline = 1;

    image_in = new();

    if (!((PIXEL_WIDTH == 8) || (PIXEL_WIDTH == 10))) begin
        $display("ERRROR Parameter, Simulation stop: Current PIXEL_WIDTH = %04d, (Valid value: 8, 10)", PIXEL_WIDTH);
        $stop;
    end

    PrintTestbanchParam();

//    #START_DELAY
    @(posedge reset)
    $display("Camera MIPI (Model): begin work");

    for (frcnt_monitor = 0; frcnt_monitor < FRCNT_COUNT; frcnt_monitor++) begin

        image_in.fread_bmp(READ_IMG_FILE);

        $display("");
        $display("CSI(lane x%02x) - send frame(%03d)", DPHY_LANE_COUNT, frcnt_monitor);
        MIPI_EoT(100);
        CSI_ShortPkt_FS(nfr); $display("\tShortPkt:FS");
        MIPI_EoT(50);//(2100);

        for(ycnt_monitor = 0; ycnt_monitor < image_in.get_y(); ycnt_monitor++) begin
            if (PIXEL_WIDTH == 8) begin
                CSI_LongPkt_RAW8(ycnt_monitor);
            end else begin
                CSI_LongPkt_RAW10(ycnt_monitor);
            end
            MIPI_EoT(DELAY_BETWEEN_LINE);
        end

        CSI_ShortPkt_FE(nfr);$display("\tShortPkt:FE");
        MIPI_EoT(102100);

        if (nfr == 16) nfr = 1;
        else nfr++;

    end

    #500

    $display("Simulation time complete. frcnt_monitor[%03d]", frcnt_monitor);
    PrintTestbanchParam();
    $stop;
//    $display("Simulation time complete.");
end : sim_main


genvar d;
generate
    for (d=0; d < DPHY_LANE_COUNT_MAX; d=d+1) begin: dn
        assign hs_dn[d] = ~hs_dp[d];
    end
endgenerate

assign csi_hs_dp = hs_dp[DPHY_LANE_COUNT-1:0];
assign csi_hs_dn = hs_dn[DPHY_LANE_COUNT-1:0];
assign csi_hs_cp = clk;
assign csi_hs_cn = ~clk;

assign csi_lp_dp = lp_dp[DPHY_LANE_COUNT-1:0];
assign csi_lp_dn = lp_dn[DPHY_LANE_COUNT-1:0];
assign csi_lp_cp = 1'b0;
assign csi_lp_cn = 1'b0;


endmodule : camera_mipi
