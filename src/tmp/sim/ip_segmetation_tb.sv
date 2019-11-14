//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 07.12.2017 11:39:26
// Module Name : ip_segmetation_tb
//
// Description :
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module ip_segmetation_tb(
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
localparam  TESTGEN_DATA_SIZE_MAX = (1024*8);


//***********************************
//user config
//***********************************
//Chip Select
localparam [3:0] TEST_DATA_GEN_CS = 4'h1;
localparam [3:0] UDP_INS_CS       = 4'h2;
localparam [3:0] IP_SG_CS         = 4'hB;

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
        test_datagen_src0_valid_ctrl <= 1'b0; #($urandom_range(3,1)*1ns);
        @(posedge sys_clk);
        test_datagen_src0_valid_ctrl <= 1'b1; #($urandom_range(5,1)*1ns);
    end
end : datagen_signal_valid_ctl
`endif

`ifdef RANDOM_SIGNAL_ASO_SRC0_READY
always begin : signal_aso_src0_ready_ctl
    // $urandom_range(maxval,minval)
    while(1) begin
        @(posedge sys_clk);
        aso_src0_ready <= 1'b0; #($urandom_range(5,1)*1ns);
        @(posedge sys_clk);
        aso_src0_ready <= 1'b1; #($urandom_range(15,1)*1ns);
    end
end : signal_aso_src0_ready_ctl
`endif


//***********************************
//Module instances
//***********************************
wire        test_datagen_src0_ready        ;
wire [31:0] test_datagen_src0_data         ;
wire        test_datagen_src0_valid        ;
wire        test_datagen_src0_startofpacket;
wire        test_datagen_src0_endofpacket  ;
wire [1:0]  test_datagen_src0_empty        ;

wire        udp_src0_ready        ;
wire [31:0] udp_src0_data         ;
wire        udp_src0_valid        ;
wire        udp_src0_startofpacket;
wire        udp_src0_endofpacket  ;
wire [1:0]  udp_src0_empty        ;

wire        ip_sg_src0_ready        ;
wire [31:0] ip_sg_src0_data         ;
wire        ip_sg_src0_valid        ;
wire        ip_sg_src0_startofpacket;
wire        ip_sg_src0_endofpacket  ;
wire [1:0]  ip_sg_src0_empty        ;


data_packet_generator datagen (
    .dbg ({1'b0, test_datagen_src0_valid_ctrl}),

    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == TEST_DATA_GEN_CS)),
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == TEST_DATA_GEN_CS)),
    .avs_s0_address   (avmm_address[1:0]),
    .avs_s0_byteenable(avmm_byteenable  ),
    .avs_s0_writedata (avmm_writedata   ),
    .avs_s0_readdata  (avmm_readdata[TEST_DATA_GEN_CS] ),

    // source interface
    .aso_src0_error(),
    .aso_src0_ready        (test_datagen_src0_ready        ),
    .aso_src0_data         (test_datagen_src0_data         ),
    .aso_src0_valid        (test_datagen_src0_valid        ),
    .aso_src0_startofpacket(test_datagen_src0_startofpacket),
    .aso_src0_endofpacket  (test_datagen_src0_endofpacket  ),
    .aso_src0_empty        (test_datagen_src0_empty        )
);


udp_payload_inserter udp_ins (
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == UDP_INS_CS)),
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == UDP_INS_CS)),
    .avs_s0_address   (avmm_address[3:0]),
    .avs_s0_byteenable(avmm_byteenable  ),
    .avs_s0_writedata (avmm_writedata   ),
    .avs_s0_readdata  (avmm_readdata[UDP_INS_CS] ),

    // source interface
    .aso_src0_ready        (udp_src0_ready        ),
    .aso_src0_data         (udp_src0_data         ),
    .aso_src0_valid        (udp_src0_valid        ),
    .aso_src0_startofpacket(udp_src0_startofpacket),
    .aso_src0_endofpacket  (udp_src0_endofpacket  ),
    .aso_src0_empty        (udp_src0_empty        ),

    // sink interface
    .asi_snk0_ready        (test_datagen_src0_ready        ),
    .asi_snk0_data         (test_datagen_src0_data         ),
    .asi_snk0_valid        (test_datagen_src0_valid        ),
    .asi_snk0_startofpacket(test_datagen_src0_startofpacket),
    .asi_snk0_endofpacket  (test_datagen_src0_endofpacket  ),
    .asi_snk0_empty        (test_datagen_src0_empty        )
);

ip_segmentation ip_sg (
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == IP_SG_CS)),
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == IP_SG_CS)),
    .avs_s0_address   (avmm_address[3:0]),
    .avs_s0_byteenable(avmm_byteenable  ),
    .avs_s0_writedata (avmm_writedata   ),
    .avs_s0_readdata  (avmm_readdata[IP_SG_CS] ),

    // source interface
    .aso_src0_ready        (aso_src0_ready        ),//(ip_sg_src0_ready        ),
    .aso_src0_data         (aso_src0_data         ),//(ip_sg_src0_data         ),
    .aso_src0_valid        (aso_src0_valid        ),//(ip_sg_src0_valid        ),
    .aso_src0_startofpacket(aso_src0_startofpacket),//(ip_sg_src0_startofpacket),
    .aso_src0_endofpacket  (aso_src0_endofpacket  ),//(ip_sg_src0_endofpacket  ),
    .aso_src0_empty        (aso_src0_empty        ),//(ip_sg_src0_empty        ),

    // sink interface
    .asi_snk0_ready        (udp_src0_ready        ),
    .asi_snk0_data         (udp_src0_data         ),
    .asi_snk0_valid        (udp_src0_valid        ),
    .asi_snk0_startofpacket(udp_src0_startofpacket),
    .asi_snk0_endofpacket  (udp_src0_endofpacket  ),
    .asi_snk0_empty        (udp_src0_empty        )
);



//***********************************
//main
//***********************************
logic        nxt_test_pkt = 1'b0;
logic [31:0] test_payload_size = '0;
logic [31:0] ip_fg_delay = '0;

always begin : main_ctl
//    $dumpfile("./ip_segmetation_tb.v.fst");
//    $dumpvars;

    sys_rst = 1'b0;
    #3;
    sys_rst = 1'b1;
    #3;
    sys_rst = 1'b0;
    #3;

    //######  udp_inserter config #####
    #50;
    //udp_inserter config: Set Destenation MAC address: 90-E2-BA-E3-95-88
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

    //udp_inserter config: Set source MAC address: 00-1C-23-17-4A-CB
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

    //udp_inserter config: Set source IP address: 192.168.1.69
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h5)})
        , AVMM_DATA(32'hC0A801A9)
        , AVMM_BE  (4'hF)
        );
    #3;

    //udp_inserter config: Set Destenation IP address: 192.168.1.169
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h6)})
        , AVMM_DATA(32'hC0A80145)
        , AVMM_BE  (4'hF)
        );
    #3;

    //udp_inserter config: Set ports of UDP packet
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h7)})
        , AVMM_DATA({16'd6464, 16'd6464})  //{PortSRC , PortDST}
        , AVMM_BE  (4'hF)
        );
    #3;

    //udp_inserter config: Set transaction ID (TRN_ID) of user protocol header
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'hB)})
        , AVMM_DATA(32'hAAAA5515)
        , AVMM_BE  (4'hF)
        );
    #3;

    //udp_inserter config: Set transaction TYPE (TRN_TYPE) of user protocol header
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'hA)})
        , AVMM_DATA(32'h00CB)
        , AVMM_BE  (4'hF)
        );
    #3;

    //###### Test data generator config ######
    #50;
    //Test data generator config: Set initial value of data generator
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h2)})
        , AVMM_DATA(32'h00020001)
        , AVMM_BE  (4'hF)
        );
    #3;

    while(1) begin : loop_udp_packet_send

        test_payload_size = $urandom_range(8192,1);
        ip_fg_delay = $urandom_range(256,0);

        //ip segmentation config: set a delay between the fragments of the IP packet
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, IP_SG_CS, REG_ADR(4'h1)})
            , AVMM_DATA(ip_fg_delay)
            , AVMM_BE  (4'hF)
            );
        #3;

        //udp_inserter config: set payload of UDP packet
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h9)})
            , AVMM_DATA(test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
            , AVMM_BE  (4'hF)
            );
        #3;

        //udp_inserter config: start work module
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h0)})
//            , AVMM_DATA(32'h3) //with gen test data from udp inserter
            , AVMM_DATA(32'h1)
            , AVMM_BE  (4'hF)
            );

        $display("TestDataSize = %03d(dec); %08H(hex); UserProtocolHeaderSize = %03d(dec)", test_payload_size
                                                                                          , test_payload_size
                                                                                          , USER_PROTOCOL_PKT_HEDER_SIZE
                                                                                          );
        $display("UdpPayload   = %03d(dec); %08H(hex)", (test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
                                                      , (test_payload_size + USER_PROTOCOL_PKT_HEDER_SIZE)
                                                      );
        $display("IP Fragment Delay = %03d(dec)", ip_fg_delay);
        #3;


        //###### Test data generator config ######
        //Test data generator config: set size of data
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h1)})
            , AVMM_DATA(test_payload_size)
            , AVMM_BE  (4'hF)
            );
        #3;

        //Test data generator config: start work module
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h0)})
            , AVMM_DATA(32'h000001) //(32'h200001)
            , AVMM_BE  (4'hF)
            );

        #3;
        //Test data generator config: stop work module
        AVMM_WRITE (
              AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h0)})
            , AVMM_DATA(32'h200000)
            , AVMM_BE  (4'hF)
            );

        //wait checking packet
        @(posedge nxt_test_pkt);
        if (mon.out.err.cnt > 0) begin
            $display("Simulation faild. mon.out.err.cnt = %02d", mon.out.err.cnt);
            $finish;
        end

    end : loop_udp_packet_send

end : main_ctl

always begin : sim_time_ctl
    #300000;
    $display("Simulation time complete.");
    $stop;
end : sim_time_ctl


//***********************************
//monitor packets
//***********************************
struct {
    struct {
        logic [7:0] data [(TESTGEN_DATA_SIZE_MAX)-1:0];
        logic [15:0] cnt;
    } in;

    struct {
        logic [7:0] data [(TESTGEN_DATA_SIZE_MAX)-1:0];
        logic [15:0] cnt;

        struct {
            logic  [2:0] flags;
            logic [12:0] fragment_offset;
            logic [12:0] fragment_num;
            logic [15:0] length;
            struct {
                logic [15:0] size;
                logic [15:0] cnt;
            } payload;
            struct {
                logic [15:0] data [31:0];
                logic [15:0] cnt;
            } header;
        } ip;
        struct {
            logic [15:0] length;
            struct {
                logic [15:0] size;
                logic [15:0] cnt;
            } payload;
            logic [15:0] pkt_num;
        } udp;

        struct {
            logic [7:0] cnt;
        } err;

        struct {
            logic header;
            logic payload;
        } verbose;
    } out;

} mon;

integer i;

//monitoring stream from ip_segmentation module
always begin : monitoring_stream_ip_sg
    for (i = 0; i < $size(mon.out.data); i++) begin
    mon.out.data[i] = 0;
    end
    for (i = 0; i < $size(mon.out.ip.header.data); i++) begin
    mon.out.ip.header.data[i] = 0;
    end
    mon.out.ip.header.cnt = 0;

    mon.out.cnt = 0;
    mon.out.ip.flags = 0;
    mon.out.ip.fragment_offset = 0;
    mon.out.ip.fragment_num = 0;
    mon.out.ip.length = 0;
    mon.out.ip.payload.size = 0;
    mon.out.ip.payload.cnt = 0;
    mon.out.udp.length = 0;
    mon.out.udp.payload.size = 0;
    mon.out.udp.payload.cnt = 0;
    mon.out.udp.pkt_num = 0;

    mon.out.err.cnt = 0;

    mon.out.verbose.header = 1'b0;
    mon.out.verbose.payload = 1'b0;

    while(1) begin

        while(1) begin
            @(posedge sys_clk);
            nxt_test_pkt = 1'b0;
            if (aso_src0_ready & aso_src0_valid & aso_src0_startofpacket) begin
                mon.out.ip.header.cnt = 0;
                mon.out.cnt++;
                mon.out.ip.payload.cnt = 0;
                break;
            end
        end

        while(1) begin
            @(posedge sys_clk);
            if (aso_src0_ready & aso_src0_valid) begin

                if ( ((mon.out.cnt == 11) && (mon.out.ip.fragment_offset == 0))
                  || ((mon.out.cnt ==  9) && (mon.out.ip.fragment_offset > 0))) begin


                    for (i = 0; i < (4 - aso_src0_empty); i++) begin
                        if (mon.out.verbose.payload) begin
                            $display("(%05d) %02H", mon.out.udp.payload.cnt, aso_src0_data[32 - (8* (i+1)) +: 8]);
                        end
                        mon.out.data[mon.out.udp.payload.cnt++] = aso_src0_data[32 - (8* (i+1)) +: 8];
                        mon.out.ip.payload.cnt++;
                    end

                    if (aso_src0_endofpacket) begin

                        mon.out.cnt = 0;

                        if (mon.out.ip.payload.cnt != mon.out.ip.payload.size) begin
                            mon.out.err.cnt++;
                            $display("UdpPkt(%02d):Fg(%02d):ERROR: mon.out.ip.payload.cnt(%04d) != mon.out.ip.payload.size (%04d)\n", mon.out.udp.pkt_num
                                                                                                            , mon.out.ip.fragment_num
                                                                                                            , mon.out.ip.payload.cnt
                                                                                                            , mon.out.ip.payload.size);
                            $stop;
                        end

                        if (mon.out.ip.flags == IP_FLAGS_MF) begin
                            mon.out.ip.fragment_num++;

                        end else if ((mon.out.ip.flags == IP_FLAGS_DF)
                                  || (mon.out.ip.flags == IP_FLAGS_ZERO)) begin

                            if (mon.out.udp.payload.cnt != mon.out.udp.payload.size) begin
                                mon.out.err.cnt++;
                                $display("UdpPkt(%02d):Fg(%02d):ERROR: mon.out.udp.payload.cnt(%04d) != mon.out.udp.payload.size (%04d)\n", mon.out.udp.pkt_num
                                                                                                            , mon.out.ip.fragment_num
                                                                                                            , mon.out.udp.payload.cnt
                                                                                                            , mon.out.udp.payload.size);
                                $stop;
                            end

                            for (i = USER_PROTOCOL_PKT_HEDER_SIZE; i < mon.out.udp.payload.size; i++) begin
                                if (mon.in.data[(i - USER_PROTOCOL_PKT_HEDER_SIZE)] != mon.out.data[i]) begin
                                    if ((i - USER_PROTOCOL_PKT_HEDER_SIZE) == 0) begin
                                        $display("UdpPkt(%02d): check payload:", mon.out.udp.pkt_num);
                                    end
                                    if ((i - USER_PROTOCOL_PKT_HEDER_SIZE) < 32) begin
                                        $display("\t EROOR: mon.in.data[%04d] = %02H; mon.out.data.[%04d] = %02H", (i - USER_PROTOCOL_PKT_HEDER_SIZE)
                                                                                                                 , mon.in.data[(i - USER_PROTOCOL_PKT_HEDER_SIZE)]
                                                                                                                 , i
                                                                                                                 , mon.out.data[i]
                                                                                                                 );
                                    end
                                    mon.out.err.cnt++;
                                end
                            end

                            if (!mon.out.err.cnt) begin
                                $display("UdpPkt(%02d): check payload OK.\n", mon.out.udp.pkt_num);
                            end

                            mon.out.udp.payload.cnt = 0;
                            mon.out.ip.fragment_num = 0;
                            mon.out.udp.pkt_num++;

                            nxt_test_pkt = 1'b1;
                        end

                        break;
                    end

                end else begin : header_parsing

                    if (mon.out.cnt == 4) begin

                        mon.out.ip.length = aso_src0_data[16 +: 16];
                        mon.out.ip.payload.size = (mon.out.ip.length - IP_HEADER_SIZE);

                    end else if (mon.out.cnt == 5) begin

                        mon.out.ip.flags = aso_src0_data[31:29];
                        mon.out.ip.fragment_offset = aso_src0_data[28:16];

                        if (mon.out.verbose.header) begin
                        $display("ip : length = %05d (payload = %05d); flags  = %01d; fragment_offset = %05d",
                                                                        mon.out.ip.length
                                                                      , mon.out.ip.payload.size
                                                                      , mon.out.ip.flags
                                                                      , mon.out.ip.fragment_offset
                                                                      );
                        end

                    end else if (mon.out.cnt == 8) begin

                        case (aso_src0_empty)
                            0 : begin
                                    for (i = 2; i < 4; i++) begin
                                        if (mon.out.ip.fragment_offset > 0) begin
                                            if (mon.out.verbose.payload) begin
                                                $display("(%05d) %02H", mon.out.udp.payload.cnt, aso_src0_data[32 - (8*(i+1)) +: 8]);
                                            end
                                            mon.out.data[mon.out.udp.payload.cnt++] = aso_src0_data[32 - (8*(i+1)) +: 8];
                                        end
                                        mon.out.ip.payload.cnt++;
                                    end
                                end
                            1 : begin
                                    for (i = 3; i < 4; i++) begin
                                        if (mon.out.ip.fragment_offset > 0) begin
                                            if (mon.out.verbose.payload) begin
                                                $display("(%05d) %02H", mon.out.udp.payload.cnt, aso_src0_data[32 - (8*(i+1)) +: 8]);
                                            end
                                            mon.out.data[mon.out.udp.payload.cnt++] = aso_src0_data[32 - (8*(i+1)) +: 8];
                                        end
                                        mon.out.ip.payload.cnt++;
                                    end
                                end
                            default : begin
                                $display("(ERROR: Bad value. aso_src0_empty = %02d", aso_src0_empty);
                                $stop;
                                end
                        endcase

                    end else if (mon.out.cnt == 9) begin

                        mon.out.udp.length = aso_src0_data[0 +: 16];
                        mon.out.udp.payload.size = (mon.out.udp.length - UDP_HEADER_SIZE);
                        for (i = 0; i < (4 - aso_src0_empty); i++) begin
                        mon.out.ip.payload.cnt++;
                        end

//                        if (mon.out.verbose.header) begin
//                        $display("udp: length = %05d (payload = %05d)", mon.out.udp.length
//                                                                      , mon.out.udp.payload.size);
//                        end

                    end else if (mon.out.cnt == 10) begin

                        for (i = 0; i < (4 - aso_src0_empty); i++) begin
                        mon.out.ip.payload.cnt++;
                        end

                        case (aso_src0_empty)
                            0 : begin
                                    for (i = 2; i < 4; i++) begin
                                        if (mon.out.ip.fragment_offset == 0) begin
                                            if (mon.out.verbose.payload) begin
                                                $display("(%05d) %02H", mon.out.udp.payload.cnt, aso_src0_data[32 - (8*(i+1)) +: 8]);
                                            end
                                            mon.out.data[mon.out.udp.payload.cnt++] = aso_src0_data[32 - (8*(i+1)) +: 8];
                                        end
                                    end
                                end
                            1 : begin
                                    for (i = 3; i < 4; i++) begin
                                        if (mon.out.ip.fragment_offset == 0) begin
                                            if (mon.out.verbose.payload) begin
                                                $display("(%05d) %02H", mon.out.udp.payload.cnt, aso_src0_data[32 - (8*(i+1)) +: 8]);
                                            end
                                            mon.out.data[mon.out.udp.payload.cnt++] = aso_src0_data[32 - (8*(i+1)) +: 8];
                                        end
                                    end
                                end
                            default : begin
                                $display("(ERROR: Bad value. aso_src0_empty = %02d", aso_src0_empty);
                                $stop;
                                end
                        endcase
                    end

                    mon.out.cnt++;

                end : header_parsing
            end
        end
    end
end : monitoring_stream_ip_sg


//monitoring stream from test_datagen module
always begin : monitoring_stream_datagen
    for (i = 0; i < $size(mon.in.data); i++) begin
    mon.in.data[i] = 0;
    end
    mon.in.cnt = 0;

    while(1) begin
        while(1) begin
            @(posedge sys_clk);
            if (test_datagen_src0_ready & test_datagen_src0_valid & test_datagen_src0_startofpacket) begin
                mon.in.cnt = 0;
//                $display("TestPkt:SOF");
                for (i = 0; i < (4 - test_datagen_src0_empty); i++) begin
//                    $display("(%05d) %02H", mon.in.cnt, test_datagen_src0_data[(8*i) +: 8]);
                    mon.in.data[mon.in.cnt++] = test_datagen_src0_data[32 - (8* (i+1)) +: 8];
                end
                break;
            end
        end

        while(1) begin
            @(posedge sys_clk);
            if (test_datagen_src0_ready & test_datagen_src0_valid) begin
                for (i = 0; i < (4 - test_datagen_src0_empty); i++) begin
//                    $display("(%05d) %02H", mon.in.cnt, test_datagen_src0_data[(8*i) +: 8]);
                    mon.in.data[mon.in.cnt++] = test_datagen_src0_data[32 - (8* (i+1)) +: 8];
                end

                if (test_datagen_src0_endofpacket) begin
//                    $display("TestPkt:EOF");
                    break;
                end
            end
        end
    end
end : monitoring_stream_datagen


endmodule : ip_segmetation_tb
