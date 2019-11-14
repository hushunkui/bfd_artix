//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 10.10.2017 9:49:44
// Module Name : filter_eth_pkt_tb
//
// Description :
//
//------------------------------------------------------------------------

`timescale 1ns / 1ps
module filter_eth_pkt_tb(
//    input           aso_src0_ready,
    output  [31:0]  aso_src0_data,
    output          aso_src0_valid,
    output          aso_src0_startofpacket,
    output          aso_src0_endofpacket,
    output  [1:0]   aso_src0_empty
);


localparam  UDP_HEADER_SIZE = 8;
localparam  IP_HEADER_SIZE  = 20;


//***********************************
//user config
//***********************************
//Chip Select
localparam [3:0] TEST_DATA_GEN_CS  = 4'h1;
localparam [3:0] UDP_INS_CS        = 4'h2;
localparam [3:0] ARP_GEN_CS        = 4'h3;
localparam [3:0] FILTER_ETH_CS     = 4'h8;
localparam [3:0] TEST_DATA_GEN2_CS = 4'h9;

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
                 ,input  [3:0] be);
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
wire        datagen2_src0_ready        ; //output
wire [31:0] datagen2_src0_data         ; //input   [31:0]
wire        datagen2_src0_valid        ; //input
wire        datagen2_src0_startofpacket; //input
wire        datagen2_src0_endofpacket  ; //input
wire [1:0]  datagen2_src0_empty        ; //input   [1:0]

wire        datagen_src0_ready        ; //output
wire [31:0] datagen_src0_data         ; //input   [31:0]
wire        datagen_src0_valid        ; //input
wire        datagen_src0_startofpacket; //input
wire        datagen_src0_endofpacket  ; //input
wire [1:0]  datagen_src0_empty        ; //input   [1:0]

wire        udp_src0_ready        ; //output
wire [31:0] udp_src0_data         ; //input   [31:0]
wire        udp_src0_valid        ; //input
wire        udp_src0_startofpacket; //input
wire        udp_src0_endofpacket  ; //input
wire [1:0]  udp_src0_empty        ; //input   [1:0]

wire        arp_src0_ready        ; //output
wire [31:0] arp_src0_data         ; //input   [31:0]
wire        arp_src0_valid        ; //input
wire        arp_src0_startofpacket; //input
wire        arp_src0_endofpacket  ; //input
wire [1:0]  arp_src0_empty        ; //input   [1:0]

wire        pkt_mux_src0_ready        ; //output
wire [31:0] pkt_mux_src0_data         ; //input   [31:0]
wire        pkt_mux_src0_valid        ; //input
wire        pkt_mux_src0_startofpacket; //input
wire        pkt_mux_src0_endofpacket  ; //input
wire [1:0]  pkt_mux_src0_empty        ; //input   [1:0]

//wire        filter_pkt_src0_ready        ; //output
//wire [31:0] filter_pkt_src0_data         ; //input   [31:0]
//wire        filter_pkt_src0_valid        ; //input
//wire        filter_pkt_src0_startofpacket; //input
//wire        filter_pkt_src0_endofpacket  ; //input
//wire [1:0]  filter_pkt_src0_empty        ; //input   [1:0]

data_packet_generator datagen2 (
    .dbg ({1'b0, 1'b0}),

    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == TEST_DATA_GEN2_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == TEST_DATA_GEN2_CS)),//input
    .avs_s0_address   (avmm_address[1:0]),//input   [1:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[TEST_DATA_GEN2_CS] ),//output  [31:0]

    // source interface
    .aso_src0_error(),
    .aso_src0_ready        (datagen2_src0_ready        ),//input
    .aso_src0_data         (datagen2_src0_data         ),//output  [31:0]
    .aso_src0_valid        (datagen2_src0_valid        ),//output
    .aso_src0_startofpacket(datagen2_src0_startofpacket),//output
    .aso_src0_endofpacket  (datagen2_src0_endofpacket  ),//output
    .aso_src0_empty        (datagen2_src0_empty        ) //output  [1:0]
);

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
    .aso_src0_ready        (datagen_src0_ready        ),//input
    .aso_src0_data         (datagen_src0_data         ),//output  [31:0]
    .aso_src0_valid        (datagen_src0_valid        ),//output
    .aso_src0_startofpacket(datagen_src0_startofpacket),//output
    .aso_src0_endofpacket  (datagen_src0_endofpacket  ),//output
    .aso_src0_empty        (datagen_src0_empty        ) //output  [1:0]
);


udp_payload_inserter gen_udp_pkt (
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
    .aso_src0_ready        (udp_src0_ready        ),//input
    .aso_src0_data         (udp_src0_data         ),//output  reg [31:0]
    .aso_src0_valid        (udp_src0_valid        ),//output
    .aso_src0_startofpacket(udp_src0_startofpacket),//output  reg
    .aso_src0_endofpacket  (udp_src0_endofpacket  ),//output  reg
    .aso_src0_empty        (udp_src0_empty        ),//output  reg [1:0]

    // sink interface
    .asi_snk0_ready        (datagen_src0_ready        ),//output
    .asi_snk0_data         (datagen_src0_data         ),//input   [31:0]
    .asi_snk0_valid        (datagen_src0_valid        ),//input
    .asi_snk0_startofpacket(datagen_src0_startofpacket),//input
    .asi_snk0_endofpacket  (datagen_src0_endofpacket  ),//input
    .asi_snk0_empty        (datagen_src0_empty        ) //input   [1:0]
);

arp_sender gen_arp_pkt (
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == ARP_GEN_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == ARP_GEN_CS)),//input
    .avs_s0_address   (avmm_address[2:0]),//input   [1:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[ARP_GEN_CS] ),//output  [31:0]

    // source interface
    .aso_src0_ready        (arp_src0_ready        ),//input
    .aso_src0_data         (arp_src0_data         ),//output  [31:0]
    .aso_src0_valid        (arp_src0_valid        ),//output
    .aso_src0_startofpacket(arp_src0_startofpacket),//output
    .aso_src0_endofpacket  (arp_src0_endofpacket  ),//output
    .aso_src0_empty        (arp_src0_empty        ) //output  [1:0]
);


ethernet_packet_multiplexer3 pkt_mux(
    // clock interface
    .csi_clock_clk  (sys_clk  ),
    .csi_clock_reset_n(~sys_rst),

    // Interface: in0
    .asi_in0_ready        (udp_src0_ready        ),
    .asi_in0_data         (udp_src0_data         ),
    .asi_in0_valid        (udp_src0_valid        ),
    .asi_in0_startofpacket(udp_src0_startofpacket),
    .asi_in0_endofpacket  (udp_src0_endofpacket  ),
    .asi_in0_empty        (udp_src0_empty        ),
    // Interface: in1
    .asi_in1_ready        (arp_src0_ready        ),
    .asi_in1_data         (arp_src0_data         ),
    .asi_in1_valid        (arp_src0_valid        ),
    .asi_in1_startofpacket(arp_src0_startofpacket),
    .asi_in1_endofpacket  (arp_src0_endofpacket  ),
    .asi_in1_empty        (arp_src0_empty        ),
    // Interface: in2
    .asi_in2_ready        (datagen2_src0_ready        ),
    .asi_in2_data         (datagen2_src0_data         ),
    .asi_in2_valid        (datagen2_src0_valid        ),
    .asi_in2_startofpacket(datagen2_src0_startofpacket),
    .asi_in2_endofpacket  (datagen2_src0_endofpacket  ),
    .asi_in2_empty        (datagen2_src0_empty        ),
    // Interface: out
    .aso_out_ready        (pkt_mux_src0_ready        ),
    .aso_out_data         (pkt_mux_src0_data         ),
    .aso_out_valid        (pkt_mux_src0_valid        ),
    .aso_out_startofpacket(pkt_mux_src0_startofpacket),
    .aso_out_endofpacket  (pkt_mux_src0_endofpacket  ),
    .aso_out_empty        (pkt_mux_src0_empty        )
);


filter_eth_pkt  eth_filter(
    // clock interface
    .csi_clock_clk  (sys_clk),
    .csi_clock_reset(sys_rst),

    // slave interface
    .avs_s0_write     (avmm_write & (avmm_address[7:4] == FILTER_ETH_CS)),//input
    .avs_s0_read      (avmm_read  & (avmm_address[7:4] == FILTER_ETH_CS)),//input
    .avs_s0_address   (avmm_address[1:0]),//input   [3:0]
    .avs_s0_byteenable(avmm_byteenable  ),//input   [3:0]
    .avs_s0_writedata (avmm_writedata   ),//input   [31:0]
    .avs_s0_readdata  (avmm_readdata[FILTER_ETH_CS] ),//output  [31:0]

    // source interface
    .aso_src0_ready        (aso_src0_ready        ),//(filter_pkt_src0_ready        ),//input
    .aso_src0_data         (aso_src0_data         ),//(filter_pkt_src0_data         ),//output reg [31:0]
    .aso_src0_valid        (aso_src0_valid        ),//(filter_pkt_src0_valid        ),//output reg
    .aso_src0_startofpacket(aso_src0_startofpacket),//(filter_pkt_src0_startofpacket),//output reg
    .aso_src0_endofpacket  (aso_src0_endofpacket  ),//(filter_pkt_src0_endofpacket  ),//output reg
    .aso_src0_empty        (aso_src0_empty        ),//(filter_pkt_src0_empty        ),//output reg [1:0]

    // sink interface
    .asi_snk0_ready        (pkt_mux_src0_ready        ),//output
    .asi_snk0_data         (pkt_mux_src0_data         ),//input   [31:0]
    .asi_snk0_valid        (pkt_mux_src0_valid        ),//input
    .asi_snk0_startofpacket(pkt_mux_src0_startofpacket),//input
    .asi_snk0_endofpacket  (pkt_mux_src0_endofpacket  ),//input
    .asi_snk0_empty        (pkt_mux_src0_empty        ) //input   [1:0]
);


//***********************************
//main
//***********************************
logic        nxt_test_pkt = 1'b0;
logic [31:0] test_payload_size = 0;
logic [31:0] eth_filter_start_prm = 0;
logic        pp = 0;

initial begin : main_ctl
//    $dumpfile("./filter_eth_pkt_tb.v.fst");
//    $dumpvars;
    pp = 0;
    sys_rst = 1'b0;
    #3;
    sys_rst = 1'b1;
    #3;
    sys_rst = 1'b0;
    #3;

    //######  eth_filter config  #####
    //IP DST:
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, FILTER_ETH_CS, REG_ADR(4'h1)})
        , AVMM_DATA(32'hC0A80145) //192.168.1.69
        , AVMM_BE  (4'hF)
        );
    #3;

    //UDP_PORT(DST)_0
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, FILTER_ETH_CS, REG_ADR(4'h2)})
        , AVMM_DATA(32'd6464)
        , AVMM_BE  (4'hF)
        );
    #3;

    //Start
    eth_filter_start_prm[0] = 1'b1; //Start
    eth_filter_start_prm[1] = 1'b1; //ARP_EN
    eth_filter_start_prm[2] = 1'b0; //ICMP_EN
    eth_filter_start_prm[3] = 1'b1; //UDP_EN
    eth_filter_start_prm[4] = 1'b1; //UDP_EN_broadcast
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, FILTER_ETH_CS, REG_ADR(4'h0)})
        , AVMM_DATA(eth_filter_start_prm)
        , AVMM_BE  (4'hF)
        );
    #50;


    //######  ARP_GEN config  #####
    //MAC(SRC): 90-E2-BA-E3-95-88
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h3)})  //(MSB)
        , AVMM_DATA(32'h90E2BAE3)
        , AVMM_BE  (4'hF)
        );
    #3;
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h4)})  //(LSB)
        , AVMM_DATA(32'h00009588)
        , AVMM_BE  (4'hF)
        );
    #3;

    //MAC(SRC): 00-1C-23-17-4A-CB
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h1)})  //(MSB)
        , AVMM_DATA(32'h001C2317)
        , AVMM_BE  (4'hF)
        );
    #3;
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h2)})  //(LSB)
        , AVMM_DATA(32'h00004ACB)
        , AVMM_BE  (4'hF)
        );
    #3;

    //IP SRC:
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h5)})
        , AVMM_DATA(32'hC0A801A9) //192.168.1.69
        , AVMM_BE  (4'hF)
        );
    #3;

    //IP DST:
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h6)})
        , AVMM_DATA(32'hC0A80145) //192.168.1.169
        , AVMM_BE  (4'hF)
        );
    #3;

    //Start
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, ARP_GEN_CS, REG_ADR(4'h0)})
        , AVMM_DATA(32'h1)
        , AVMM_BE  (4'hF)
        );
    #50;


    //######  udp_inserter config #####
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
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'hA)})
        , AVMM_DATA(32'h00CB)
        , AVMM_BE  (4'hF)
        );
    #3;


    //######  test_data_gen config ######
    #50;
    //TEST_DATA_GEN: Init value
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN2_CS, REG_ADR(4'h2)})
        , AVMM_DATA(32'h00020001)
        , AVMM_BE  (4'hF)
        );
    #3;
    //TEST_DATA_GEN: Byte count
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN2_CS, REG_ADR(4'h1)})
        , AVMM_DATA(test_payload_size)
        , AVMM_BE  (4'hF)
        );
    #3;

    //TEST_DATA_GEN: Start
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN2_CS, REG_ADR(4'h0)})
        , AVMM_DATA(32'h000001) //(32'h200001)
        , AVMM_BE  (4'hF)
        );


    //######  test_data_gen config ######
    #50;
    //TEST_DATA_GEN: Init value
    AVMM_WRITE (
          AVMM_ADR ({{24{1'b0}}, TEST_DATA_GEN_CS, REG_ADR(4'h2)})
        , AVMM_DATA(32'h00020001)
        , AVMM_BE  (4'hF)
        );
    #3;

    while(1) begin : loop_udp_packet_send
        test_payload_size = $urandom_range(2600, 8);

        if (pp) begin
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

            //UDP_ISN: IP_DST: 192.168.1.169
            AVMM_WRITE (
                  AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h6)})
                , AVMM_DATA(32'hC0A80145)
                , AVMM_BE  (4'hF)
                );
            #3;
        end else begin
            //UDP_ISN: MAC_DST: 90-E2-BA-E3-95-88
            AVMM_WRITE (
                  AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h1)})  //MAC_DST(MSB)
                , AVMM_DATA(32'hFFFFFFFF)
                , AVMM_BE  (4'hF)
                );
            #3;
            AVMM_WRITE (
                  AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h2)})  //MAC_DST(LSB)
                , AVMM_DATA(32'h0000FFFF)
                , AVMM_BE  (4'hF)
                );
            #3;

            //UDP_ISN: IP_DST: 192.168.1.005
            AVMM_WRITE (
                  AVMM_ADR ({{24{1'b0}}, UDP_INS_CS, REG_ADR(4'h6)})
                , AVMM_DATA(32'hC0A80105)
                , AVMM_BE  (4'hF)
                );
            #3;
        end

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
        @(negedge udp_src0_endofpacket);

        pp = ~pp;

    end : loop_udp_packet_send

end : main_ctl

initial begin : sim_time_ctl
    #300000;
    $display("Simulation time complete.");
    $stop;
end : sim_time_ctl


endmodule : filter_eth_pkt_tb
