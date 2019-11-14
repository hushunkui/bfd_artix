//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 19.12.2017 10:52:13
// Module Name : udp_extracter_tb
//
// Description :
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module udp_extracter_tb(
    output  [31:0]  aso_src0_data         ,
    output          aso_src0_valid        ,
    output          aso_src0_startofpacket,
    output          aso_src0_endofpacket  ,
    output  [1:0]   aso_src0_empty
);

localparam   [2:0]   IP_FLAGS_MF = 3'd1; //More Fragments (MF);
localparam   [2:0]   IP_FLAGS_DF = 3'd2; //Don't Fragment (DF);
localparam   [2:0]   IP_FLAGS_ZERO = 3'd0;

localparam  UDP_HEADER_SIZE = 8;
localparam  IP_HEADER_SIZE  = 20;


//***********************************
//user config
//***********************************
localparam  UDP_PKT_TEST_COUNT_MAX = (16);

//Chip Select
localparam [3:0] TEST_DATA_GEN_CS = 4'h1;
localparam [3:0] UDP_INS_CS       = 4'h2;
localparam [3:0] IP_SG_CS         = 4'hB;
localparam [3:0] UDP_EXT_CS       = 4'hC;

localparam [31:0] USER_PROTOCOL_PKT_HEDER_SIZE = (6);//2byte(TRN_Type)+ 4byte(TRN_ID)

`define RANDOM_SIGNAL_TEST_DATAGEN_SRC0_VALID
`define RANDOM_SIGNAL_ASO_SRC0_READY

function [3:0] REG_ADR (input [3:0] in);
    begin
        REG_ADR = in;
    end
endfunction : REG_ADR


//***********************************
//System clock gen
//***********************************
reg sys_rst = 1'b0;
reg sys_clk = 1'b1;
always #2.5 sys_clk = ~sys_clk;
task tick;
    begin : blk_clkgen
        @(posedge sys_clk);#0;
    end : blk_clkgen
endtask : tick


//***********************************
//sim avalon_mm
//***********************************
reg         avmm_write      = 1'b0 ;
reg         avmm_read       = 1'b0 ;
reg  [31:0] avmm_address    = 32'd0;
reg  [3:0]  avmm_byteenable = 4'd0 ;
reg  [31:0] avmm_writedata  = 32'd0;
wire [31:0] avmm_readdata [(2**$size(TEST_DATA_GEN_CS))-1:0];

task AVMM_WRITE ( input [31:0] address
                 ,input [31:0] wdata
                 ,input  [3:0] be
                );
    begin : blk_avmm_writer

        tick;
        avmm_write      = 1'b1;
        avmm_address    = address;
        avmm_writedata  = wdata;
        avmm_byteenable = be;

        tick;
        avmm_write      = 1'b0;

    end : blk_avmm_writer
endtask : AVMM_WRITE

function [31:0] AVMM_ADR (input [31:0] in);
    begin
        AVMM_ADR = in;
    end
endfunction : AVMM_ADR

function [31:0] AVMM_DATA (input [31:0] in);
    begin
        AVMM_DATA = in;
    end
endfunction : AVMM_DATA

function [3:0] AVMM_BE (input [3:0] in);
    begin
        AVMM_BE = in;
    end
endfunction : AVMM_BE


//***********************************
//control signals test_datagen_src0_valid, aso_src0_ready
//***********************************
reg aso_src0_ready = 1'b1;
reg test_datagen_src0_valid_ctrl = 1'b1;

`ifdef RANDOM_SIGNAL_TEST_DATAGEN_SRC0_VALID
always begin : datagen_signal_valid_ctl
    // $urandom_range(maxval,minval)
    while(1) begin
        @(posedge sys_clk);
        test_datagen_src0_valid_ctrl <= 1'b0; #($urandom_range(5,1)*1ns);
        @(posedge sys_clk);
        test_datagen_src0_valid_ctrl <= 1'b1; #($urandom_range(10,1)*1ns);
    end
end : datagen_signal_valid_ctl
`endif

`ifdef RANDOM_SIGNAL_ASO_SRC0_READY
always begin : signal_aso_src0_ready_ctl
    // $urandom_range(maxval,minval)
    while(1) begin
        @(posedge sys_clk);
        aso_src0_ready <= 1'b0; #($urandom_range(15,1)*1ns);
        @(posedge sys_clk);
        aso_src0_ready <= 1'b1; #($urandom_range(20,1)*1ns);
    end
end : signal_aso_src0_ready_ctl
`endif


//***********************************
//Module instances
//***********************************
wire        test_datagen_src0_ready        ; //output
wire [31:0] test_datagen_src0_data         ; //input   [31:0]
wire        test_datagen_src0_valid        ; //input
wire        test_datagen_src0_startofpacket; //input
wire        test_datagen_src0_endofpacket  ; //input
wire [1:0]  test_datagen_src0_empty        ; //input   [1:0]

wire        udp_src0_ready        ; //output
wire [31:0] udp_src0_data         ; //input   [31:0]
wire        udp_src0_valid        ; //input
wire        udp_src0_startofpacket; //input
wire        udp_src0_endofpacket  ; //input
wire [1:0]  udp_src0_empty        ; //input   [1:0]

wire        ip_sg_src0_ready        ; //output
wire [31:0] ip_sg_src0_data         ; //input   [31:0]
wire        ip_sg_src0_valid        ; //input
wire        ip_sg_src0_startofpacket; //input
wire        ip_sg_src0_endofpacket  ; //input
wire [1:0]  ip_sg_src0_empty        ; //input   [1:0]


data_packet_generator datagen (
    .dbg ({1'b0, test_datagen_src0_valid_ctrl}),

    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == TEST_DATA_GEN_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == TEST_DATA_GEN_CS)),//input
    .avs_s0_address   (avmm_address[1:0]),//input   [1:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[TEST_DATA_GEN_CS] ),//output  [31:0]

    // source interface
    .aso_src0_error(),
    .aso_src0_ready        (test_datagen_src0_ready        ),//(aso_src0_ready        ),//input
    .aso_src0_data         (test_datagen_src0_data         ),//(aso_src0_data         ),//output  [31:0]
    .aso_src0_valid        (test_datagen_src0_valid        ),//(aso_src0_valid        ),//output
    .aso_src0_startofpacket(test_datagen_src0_startofpacket),//(aso_src0_startofpacket),//output
    .aso_src0_endofpacket  (test_datagen_src0_endofpacket  ),//(aso_src0_endofpacket  ),//output
    .aso_src0_empty        (test_datagen_src0_empty        ) //(aso_src0_empty        ) //output  [1:0]
);


udp_payload_inserter udp_ins (
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == UDP_INS_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == UDP_INS_CS)),//input
    .avs_s0_address   (avmm_address[3:0]),//input   [3:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[UDP_INS_CS] ),//output  [31:0]

    // source interface
    .aso_src0_ready        (udp_src0_ready        ),//(aso_src0_ready        ),//input
    .aso_src0_data         (udp_src0_data         ),//(aso_src0_data         ),//output  reg [31:0]
    .aso_src0_valid        (udp_src0_valid        ),//(aso_src0_valid        ),//output
    .aso_src0_startofpacket(udp_src0_startofpacket),//(aso_src0_startofpacket),//output  reg
    .aso_src0_endofpacket  (udp_src0_endofpacket  ),//(aso_src0_endofpacket  ),//output  reg
    .aso_src0_empty        (udp_src0_empty        ),//(aso_src0_empty        ),//output  reg [1:0]

    // sink interface
    .asi_snk0_ready        (test_datagen_src0_ready        ),//output
    .asi_snk0_data         (test_datagen_src0_data         ),//input   [31:0]
    .asi_snk0_valid        (test_datagen_src0_valid        ),//input
    .asi_snk0_startofpacket(test_datagen_src0_startofpacket),//input
    .asi_snk0_endofpacket  (test_datagen_src0_endofpacket  ),//input
    .asi_snk0_empty        (test_datagen_src0_empty        ) //input   [1:0]
);

ip_segmentation ip_sg (
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == IP_SG_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == IP_SG_CS)),//input
    .avs_s0_address   (avmm_address[3:0]),//input   [3:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[IP_SG_CS] ),//output  [31:0]

    // source interface
    .aso_src0_ready        (ip_sg_src0_ready        ),//(aso_src0_ready        ),////input
    .aso_src0_data         (ip_sg_src0_data         ),//(aso_src0_data         ),////output  reg [31:0]
    .aso_src0_valid        (ip_sg_src0_valid        ),//(aso_src0_valid        ),////output
    .aso_src0_startofpacket(ip_sg_src0_startofpacket),//(aso_src0_startofpacket),////output  reg
    .aso_src0_endofpacket  (ip_sg_src0_endofpacket  ),//(aso_src0_endofpacket  ),////output  reg
    .aso_src0_empty        (ip_sg_src0_empty        ),//(aso_src0_empty        ),////output  reg [1:0]

    // sink interface
    .asi_snk0_ready        (udp_src0_ready        ),//output
    .asi_snk0_data         (udp_src0_data         ),//input   [31:0]
    .asi_snk0_valid        (udp_src0_valid        ),//input
    .asi_snk0_startofpacket(udp_src0_startofpacket),//input
    .asi_snk0_endofpacket  (udp_src0_endofpacket  ),//input
    .asi_snk0_empty        (udp_src0_empty        ) //input   [1:0]
);

udp_extracter udp_ext(
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    .test(),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == UDP_EXT_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == UDP_EXT_CS)),//input
    .avs_s0_address   (avmm_address[1:0]),//input   [3:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[UDP_EXT_CS] ),//output  [31:0]

    // source interface
    .aso_src0_ready        (aso_src0_ready        ),//input
    .aso_src0_data         (aso_src0_data         ),//output  reg [31:0]
    .aso_src0_valid        (aso_src0_valid        ),//output
    .aso_src0_startofpacket(aso_src0_startofpacket),//output  reg
    .aso_src0_endofpacket  (aso_src0_endofpacket  ),//output  reg
    .aso_src0_empty        (aso_src0_empty        ),//output  reg [1:0]

    // sink interface
    .asi_snk0_ready        (ip_sg_src0_ready        ),//output
    .asi_snk0_data         (ip_sg_src0_data         ),//input   [31:0]
    .asi_snk0_valid        (ip_sg_src0_valid        ),//input
    .asi_snk0_startofpacket(ip_sg_src0_startofpacket),//input
    .asi_snk0_endofpacket  (ip_sg_src0_endofpacket  ),//input
    .asi_snk0_empty        (ip_sg_src0_empty        ) //input   [1:0]
);


//***********************************
//main
//***********************************
logic        nxt_test_pkt = 1'b0;
logic [31:0] test_payload_size = 0;
logic [31:0] trn_type = 0;
logic [15:0] err_cnt = 0;

initial begin : main_ctl
    $dumpfile("./udp_extracter_tb.fst");
    $dumpvars;

    sys_rst = 1'b0;
    #3;
    sys_rst = 1'b1;
    #3;
    sys_rst = 1'b0;
    #3;

    //######  udp_inserter config #####
    #50;
    //UDP_ISN: MAC_DST: 90-E2-BA-E3-95-88
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h1)})  //MAC_DST(MSB)
        , AVMM_DATA(32'h001C2317)
        , AVMM_BE  (4'hF)
        );
    #3;
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h2)})  //MAC_DST(LSB)
        , AVMM_DATA(32'h00004ACB)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: MAC_SRC: 00-1C-23-17-4A-CB
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h3)})  //MAC_SRC(MSB)
        , AVMM_DATA(32'h90E2BAE3)
        , AVMM_BE  (4'hF)
        );
    #3;
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h4)})  //MAC_SRC(LSB)
        , AVMM_DATA(32'h00009588)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: IP_SRC: 192.168.1.69
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h5)})
        , AVMM_DATA(32'hC0A801A9)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: IP_DST: 192.168.1.169
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h6)})
        , AVMM_DATA(32'hC0A80145)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: UDP Port
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h7)})
        , AVMM_DATA({16'd6464, 16'd6464})           //{PortSRC , PortDST}
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: User protocol header(TRN_ID)
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'hB)})
        , AVMM_DATA(32'hAAAA5515)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_ISN: User protocol header(TRN_TYPE)
    trn_type = 32'h00CB;
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'hA)})
        , AVMM_DATA(trn_type)
        , AVMM_BE  (4'hF)
        );
    #3;

    //######  test_data_gen config ######
    #50;
    //TEST_DATA_GEN: Init value
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h2)})
        , AVMM_DATA(32'h00020001)
        , AVMM_BE  (4'hF)
        );
    #3;

    //######  udp extracter config ######
    #50;
    //UDP_EXT: set transaction type
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_EXT_CS, REG_ADR(4'h1)})
        , AVMM_DATA(trn_type)
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_EXT: set transaction type
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_EXT_CS, REG_ADR(4'h0)})
        , AVMM_DATA(32'h01)
        , AVMM_BE  (4'hF)
        );
    #3;

    while(1) begin : loop_udp_packet_send

        test_payload_size = $urandom_range(8192,1);

        //UDP_ISN: UDP Payload(Byte)
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h9)})
            , AVMM_DATA(test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
            , AVMM_BE  (4'hF)
            );
        #3;

        //UDP_ISN: Start
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h0)})
            , AVMM_DATA(32'h3) //with gen test data from udp inserter
//            , AVMM_DATA(32'h1)
            , AVMM_BE  (4'hF)
            );

        $display("TestDataSize = %03d(dec); %08H(hex); UserProtocolHeaderSize = %03d(dec)", test_payload_size
                                                                                          , test_payload_size
                                                                                          , USER_PROTOCOL_PKT_HEDER_SIZE
                                                                                          );
        $display("UdpPayload   = %03d(dec); %08H(hex)", (test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
                                                      , (test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
                                                      );
        #3;


        //######  test_data_gen config ######
        //TEST_DATA_GEN: Byte count
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h1)})
            , AVMM_DATA(test_payload_size)
            , AVMM_BE  (4'hF)
            );
        #3;

        //TEST_DATA_GEN: Start
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h0)})
            , AVMM_DATA(32'h000001) //(32'h200001)
            , AVMM_BE  (4'hF)
            );

        #3;
        //TEST_DATA_GEN: Stop
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h0)})
            , AVMM_DATA(32'h200000)
            , AVMM_BE  (4'hF)
            );

        //wait checking packet is end
        @(posedge nxt_test_pkt);
        if (err_cnt > 0) begin
            $display("Simulation faild. mon.out.err.cnt = %02d", err_cnt);
            $finish;
        end

    end : loop_udp_packet_send

end : main_ctl

initial begin : sim_time_ctl
    #300000;
    $display("Simulation time complete.");
    $stop;
end : sim_time_ctl


//***********************************
//monitor packets
//***********************************
logic        payload = 1'b0;
logic [31:0] payload_cnt = 0;

always @(posedge sys_clk) begin
    nxt_test_pkt <= 1'b0;
    if (aso_src0_ready & aso_src0_valid) begin
        if (aso_src0_startofpacket) begin
            payload <= 1'b1;
        end else if (aso_src0_endofpacket) begin
            payload <= 1'b0;
            nxt_test_pkt <= 1'b1;
        end

        if (payload) begin
            payload_cnt<= payload_cnt + 1;
        end
    end
end

logic [15:0] mon_cnt = 1;

//monitoring stream from test_datagen module
always @(posedge sys_clk) begin : monitoring_udp_chk
    if (aso_src0_ready & aso_src0_valid) begin
//        $display("(%05d) %08H", mon_cnt++, aso_src0_data);
        if (payload) begin
            if (aso_src0_data != {payload_cnt[7:0], payload_cnt[15:8], payload_cnt[23:16], payload_cnt[31:24]}) begin
                $display("ERROR: Bad data");
                err_cnt++;
                $stop;
            end else if (aso_src0_endofpacket) begin
                $display("UDP Packet: Test checked OK.\n");
            end
        end
    end
end : monitoring_udp_chk


endmodule : udp_extracter_tb
