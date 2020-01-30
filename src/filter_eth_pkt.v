//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 14.10.2017 13:38:17
// Module Name : filter_eth_pkt
//
// Description :
//
//------------------------------------------------------------------------

module filter_eth_pkt
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,

    // slave interface
    input           avs_s0_write     ,
    input           avs_s0_read      ,
    input   [1:0]   avs_s0_address   ,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata ,
    output  [31:0]  avs_s0_readdata  ,

    // source interface
    input              aso_src0_ready        ,
    output reg [31:0]  aso_src0_data          = 32'd0,
    output reg         aso_src0_valid         = 1'b0,
    output reg         aso_src0_startofpacket = 1'b0,
    output reg         aso_src0_endofpacket   = 1'b0,
    output reg [1:0]   aso_src0_empty         = 2'd0,

    // sink interface
    output          asi_snk0_ready        ,
    input   [31:0]  asi_snk0_data         ,
    input           asi_snk0_valid        ,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket  ,
    input   [1:0]   asi_snk0_empty
);

localparam  [15:0]   ETH_TYPE_IP         = 16'h0800;
localparam  [15:0]   ETH_TYPE_ARP        = 16'h0806;

localparam  [15:0]   ARP_HLENPLEN = {8'd6, 8'd4};//HLEN=6; PLEN=4
localparam  [15:0]   ARP_OP_REQ   = 16'd1;

localparam  [15:0]   ICMP_ECHO_REQ  = {8'd8, 8'd0}; //Type=8;Code=0

localparam   [7:0]   IP_VERSION          = {4'd4, 4'd5}; //Ver=4; HeaderLen=5
localparam   [7:0]   IP_PROTOCOL_UDP     = 8'd17;
localparam   [7:0]   IP_PROTOCOL_ICMP    = 8'd1;


enum int unsigned {
IDLE ,
CHK_1,
CHK_2,
CHK_3,
CHK_4,
CHK_5,
CHK_6,
CHK_7,
CHK_8,
CHK_9,
CHK_10,
WAIT_EOF,
S_PAUSE
} state = IDLE;

reg            rst_bit = 1'b0;
reg            go_bit    = 1'b0;
reg    [31:0]  dev_ip = 32'd0;
reg    [15:0]  dev_udp_port [1:0];

reg    [15:0]  ip_dst_h = 16'd0;
reg    [31:0]  mac_dst_h = 32'd0;

reg            en_arp = 1'b0;
reg            en_icmp = 1'b0;
reg            en_udp = 1'b0;
reg            en_udp_broadcast = 1'b0;
reg            en_arp_syn = 1'b0;
reg            en_icmp_syn = 1'b0;
reg            en_udp_syn = 1'b0;
reg            en_udp_broadcast_syn = 1'b0;

reg     [3:0]  check = 4'd0;
reg            detect_arp = 1'b0;
reg            detect_ipv4 = 1'b0;
reg            detect_icmp = 1'b0;
reg            detect_udp  = 1'b0;
reg            detect_mac_dst_broadcast = 1'b0;

reg     [3:0]  pause_cnt = 4'd0;
reg            pause = 1'b0;

localparam   [3:0]   C_PIPELINE = 11;

reg            [3:0] i;
reg   [C_PIPELINE:0] pkt_valid = {(C_PIPELINE+1){1'b0}};

reg           [31:0] sr_snk0_data         [C_PIPELINE-1:0];
reg [C_PIPELINE-1:0] sr_snk0_valid         = {C_PIPELINE{1'b0}};
reg [C_PIPELINE-1:0] sr_snk0_startofpacket = {C_PIPELINE{1'b0}};
reg [C_PIPELINE-1:0] sr_snk0_endofpacket   = {C_PIPELINE{1'b0}};
reg            [1:0] sr_snk0_empty        [C_PIPELINE-1:0];


//
// check packet state machine
//

always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset || rst_bit) begin
        state <= IDLE;

        check <= 4'd0;

        detect_arp <= 1'b0;
        detect_ipv4 <= 1'b0;
        detect_icmp <= 1'b0;
        detect_udp <= 1'b0;
        detect_mac_dst_broadcast <= 1'b0;

        pkt_valid[0] <= 1'b0;

        ip_dst_h <= 16'd0;
        mac_dst_h <= 32'd0;

        en_arp_syn <= 1'b0;
        en_icmp_syn <= 1'b0;
        en_udp_syn <= 1'b0;
        en_udp_broadcast_syn <= 1'b0;

        pause_cnt <= 4'd0;
        pause <= 1'b0;

    end else begin
        case (state)
            IDLE: begin // data[0]  = mac_dst[47:16];
                if (aso_src0_ready & asi_snk0_valid & asi_snk0_startofpacket) begin
                    en_arp_syn <= en_arp;
                    en_icmp_syn <= en_icmp;
                    en_udp_syn <= en_udp;
                    en_udp_broadcast_syn <= en_udp_broadcast;

                    mac_dst_h[0 +: 32] <= asi_snk0_data[0 +: 32];

                    if (go_bit) begin
                        state <= CHK_1;
                    end
                end
            end

            CHK_1: begin // data[1]  = {mac_dst[15:0], mac_src[47:32]};
                if (aso_src0_ready & asi_snk0_valid) begin
                    if ({mac_dst_h, asi_snk0_data[16 +: 16]} == {48{1'b1}}) begin
                        detect_mac_dst_broadcast <= 1'b1;
                    end
                    state <= CHK_2;
                end
            end

            CHK_2: begin // data[2]  = mac_src[31:0];
                if (aso_src0_ready & asi_snk0_valid) begin
                    state <= CHK_3;
                end
            end

            CHK_3:  begin // data[3]  = {MAC_TYPE, ip_word_0[31:16]};
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (asi_snk0_data[16 +: 16] == ETH_TYPE_ARP) begin

                        detect_arp <= en_arp_syn;//1'b1;
                        check[0] <= 1'b1;
                        state <= CHK_4;

                    end else if (asi_snk0_data[16 +: 16] == ETH_TYPE_IP) begin

                        if (asi_snk0_data[8 +: 8] == IP_VERSION) begin

                            detect_ipv4 <= (en_icmp_syn | en_udp_syn);//1'b1;
                            check[0] <= 1'b1;
                            state <= CHK_4;

                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else begin
                        state <= WAIT_EOF;
                    end
                end
            end

            CHK_4: begin // data[4]  = ip_word_0[15:0]; ip_word_1[31:16];
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (detect_arp) begin
                        if (asi_snk0_data[0 +: 16] == ARP_HLENPLEN) begin

                            check[1] <= 1'b1;
                            state <= CHK_5;

                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else begin
                        state <= CHK_5;
                    end
                end
            end

            CHK_5: begin // data[5]  = ip_word_1[15:0]; ip_word_2[31:16];
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (detect_arp) begin
                        if (asi_snk0_data[16 +: 16] == ARP_OP_REQ) begin

                            check[3:2] <= {2{1'b1}};
                            state <= CHK_6;

                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else if (detect_ipv4) begin
                        if (asi_snk0_data[0 +: 8] == IP_PROTOCOL_ICMP) begin

                            detect_icmp <= en_icmp_syn;//1'b1;
                            check[3:1] <= {3{1'b1}};
                            state <= CHK_6;

                        end else if (asi_snk0_data[0 +: 8] == IP_PROTOCOL_UDP) begin

                            detect_udp <= en_udp_syn;//1'b1;
                            check[2:1] <= {2{1'b1}};
                            state <= CHK_6;

                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else begin
                        state <= WAIT_EOF;
                    end
                end
            end

            CHK_6: begin // data[6]  = ip_word_2[15:0]; ip_word_3[31:16];
                if (aso_src0_ready & asi_snk0_valid) begin
                    state <= CHK_7;
                end
            end

            CHK_7: begin // data[7]  = ip_word_3[15:0]; ip_word_4[31:16];
                if (aso_src0_ready & asi_snk0_valid) begin
                    ip_dst_h <= asi_snk0_data[0 +: 16];
                    state <= CHK_8;
                end
            end

            CHK_8: begin // data[8]  = ip_word_4[15:0]; udp_word0[31:16]
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (detect_ipv4) begin
                        if ({ip_dst_h, asi_snk0_data[16 +: 16]} == dev_ip) begin

                            if (detect_udp) begin

                                check[3] <= 1'b1;
                                state <= CHK_9;

                            end else if (detect_icmp) begin
                                    if (asi_snk0_data[0 +: 16] == ICMP_ECHO_REQ) begin
                                        pkt_valid[0] <= &check;
                                    end
                                    state <= WAIT_EOF;
                            end else begin
                                state <= WAIT_EOF;
                            end
                        end else begin

                            if (detect_udp & (en_udp_broadcast_syn & detect_mac_dst_broadcast)) begin
                                check[3] <= 1'b1;
                                state <= CHK_9;

                            end else begin
                                state <= WAIT_EOF;
                            end

                        end
                    end else begin
                        state <= CHK_9;
                    end
                end
            end

            CHK_9: begin // data[9]  =  udp_word0[15:0];
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (detect_arp) begin

                        ip_dst_h <= asi_snk0_data[0 +: 16];
                        state <= CHK_10;

                    end else if (detect_ipv4) begin
                        if (detect_udp) begin
                                if ((asi_snk0_data[16 +: 16] == dev_udp_port[0])
                                 || (asi_snk0_data[16 +: 16] == dev_udp_port[1])
                                 || (en_udp_broadcast_syn & detect_mac_dst_broadcast)) begin

                                    pkt_valid[0] <= &check;
                                end
                                state <= WAIT_EOF;
                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else begin
                        state <= WAIT_EOF;
                    end
                end
            end

            CHK_10: begin // data[9]  =  udp_word0[15:0];
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (detect_arp) begin

                        if ({ip_dst_h, asi_snk0_data[16 +: 16]} == dev_ip) begin

                            pkt_valid[0] <= &check;

                            if (asi_snk0_endofpacket) begin

                                check <= 4'd0;
                                detect_arp <= 1'b0;
                                detect_ipv4 <= 1'b0;
                                detect_icmp <= 1'b0;
                                detect_udp <= 1'b0;
                                detect_mac_dst_broadcast <= 1'b0;

                                pause <= 1'b1;
                                state <= S_PAUSE;

                            end else begin
                                state <= WAIT_EOF;
                            end
                        end else begin
                            state <= WAIT_EOF;
                        end
                    end else begin
                        state <= WAIT_EOF;
                    end
                end
            end

            WAIT_EOF: begin
                if (aso_src0_ready & asi_snk0_valid) begin
                    if (asi_snk0_endofpacket) begin
                        check <= 4'd0;
                        detect_arp <= 1'b0;
                        detect_ipv4 <= 1'b0;
                        detect_icmp <= 1'b0;
                        detect_udp <= 1'b0;
                        detect_mac_dst_broadcast <= 1'b0;
                        pkt_valid[0] <= 1'b0;

                        pause <= 1'b1;
                        state <= S_PAUSE;
                    end
                end
            end

            S_PAUSE: begin
                pkt_valid[0] <= 1'b0;

                if (pause_cnt == 4'd3) begin
                    pause_cnt <= 4'd0;
                    pause <= 1'b0;
                    state <= IDLE;
                end else begin
                    pause_cnt <= pause_cnt + 1;
                end
            end

            default:
            begin
                state <= IDLE;
            end
        endcase
    end
end


always @ (posedge csi_clock_clk)
begin
//    if (csi_clock_reset) begin
//
//        for(i = 0; i < C_PIPELINE; i = i + 1) begin
//            sr_snk0_data         [i] <= 32'd0;
//            sr_snk0_valid        [i] <= 1'b0;
//            sr_snk0_startofpacket[i] <= 1'b0;
//            sr_snk0_endofpacket  [i] <= 1'b0;
//            sr_snk0_empty        [i] <= 2'd0;
//
//            pkt_valid[i+1] <= 1'b0;
//        end
//
//        aso_src0_data          <= 32'd0;
//        aso_src0_valid         <= 1'b0 ;
//        aso_src0_startofpacket <= 1'b0 ;
//        aso_src0_endofpacket   <= 1'b0 ;
//        aso_src0_empty         <= 2'd0 ;
//
//    end else begin
        if (aso_src0_ready) begin

        sr_snk0_data         [0] <= asi_snk0_data         ;
        sr_snk0_valid        [0] <= asi_snk0_valid        ;
        sr_snk0_startofpacket[0] <= asi_snk0_startofpacket;
        sr_snk0_endofpacket  [0] <= asi_snk0_endofpacket  ;
        sr_snk0_empty        [0] <= asi_snk0_empty        ;

        pkt_valid[1]           <= pkt_valid[0];

        //pipeline
        for(i = 0; i < (C_PIPELINE - 1); i = i + 1) begin
            sr_snk0_data         [i+1] <= sr_snk0_data         [i];
            sr_snk0_valid        [i+1] <= sr_snk0_valid        [i];
            sr_snk0_startofpacket[i+1] <= sr_snk0_startofpacket[i];
            sr_snk0_endofpacket  [i+1] <= sr_snk0_endofpacket  [i];
            sr_snk0_empty        [i+1] <= sr_snk0_empty        [i];

            pkt_valid[i+2] <= pkt_valid[i+1];
        end

        //pipeline end
        aso_src0_empty         <= sr_snk0_empty        [C_PIPELINE-1] ;
        aso_src0_data          <= sr_snk0_data         [C_PIPELINE-1] ;

        aso_src0_valid         <= sr_snk0_valid        [C_PIPELINE-1] & ((detect_icmp) ? (|pkt_valid[C_PIPELINE:2]) :
                                                                         (detect_udp)  ? (|pkt_valid[C_PIPELINE:1]) :
                                                                                         (|pkt_valid) );

        aso_src0_startofpacket <= sr_snk0_startofpacket[C_PIPELINE-1] & ((detect_icmp) ? (|pkt_valid[C_PIPELINE:2]) :
                                                                         (detect_udp)  ? (|pkt_valid[C_PIPELINE:1]) :
                                                                                         (|pkt_valid) );

        aso_src0_endofpacket   <= sr_snk0_endofpacket  [C_PIPELINE-1] & ((detect_icmp) ? (|pkt_valid[C_PIPELINE:2]) :
                                                                         (detect_udp)  ? (|pkt_valid[C_PIPELINE:1]) :
                                                                                         (|pkt_valid) );
        end
//    end
end


assign asi_snk0_ready = (~pause) & aso_src0_ready;




//
// slave interface machine
//
assign avs_s0_readdata  =  (avs_s0_address == 2'h0) ? ({{26{1'b0}}, rst_bit, en_udp_broadcast, en_udp, en_icmp, en_arp, go_bit}) :
                           (avs_s0_address == 2'h1) ? dev_ip :
                           (avs_s0_address == 2'h2) ? ({{16{1'b0}}, dev_udp_port[0]}) :
                           ({{16{1'b0}}, dev_udp_port[1]});

always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset) begin
        go_bit <= 1'b0;

        en_arp <= 1'b0;
        en_icmp <= 1'b0;
        en_udp <= 1'b0;
        en_udp_broadcast <= 1'b0;

        dev_ip <= 32'd0;
        dev_udp_port[0] <= 16'd0;
        dev_udp_port[1] <= 16'd0;

        rst_bit <= 1'b0;

    end else if (avs_s0_write) begin

        case (avs_s0_address)
            2'h0: begin
                if (avs_s0_byteenable[0] == 1'b1) begin
                    go_bit <= avs_s0_writedata[0];
                    en_arp <= avs_s0_writedata[1];
                    en_icmp <= avs_s0_writedata[2];
                    en_udp <= avs_s0_writedata[3];
                    en_udp_broadcast <= avs_s0_writedata[4];
                    rst_bit <= avs_s0_writedata[5];
                end
            end
            2'h1: begin
                if (avs_s0_byteenable[0] == 1'b1) dev_ip[0  +: 8] <= avs_s0_writedata[0  +: 8];
                if (avs_s0_byteenable[1] == 1'b1) dev_ip[8  +: 8] <= avs_s0_writedata[8  +: 8];
                if (avs_s0_byteenable[2] == 1'b1) dev_ip[16 +: 8] <= avs_s0_writedata[16 +: 8];
                if (avs_s0_byteenable[3] == 1'b1) dev_ip[24 +: 8] <= avs_s0_writedata[24 +: 8];
            end
            2'h2: begin
                if (avs_s0_byteenable[0] == 1'b1) dev_udp_port[0][0 +: 8] <= avs_s0_writedata[0 +: 8];
                if (avs_s0_byteenable[1] == 1'b1) dev_udp_port[0][8 +: 8] <= avs_s0_writedata[8 +: 8];
            end
            2'h3: begin
                if (avs_s0_byteenable[0] == 1'b1) dev_udp_port[1][0 +: 8] <= avs_s0_writedata[0 +: 8];
                if (avs_s0_byteenable[1] == 1'b1) dev_udp_port[1][8 +: 8] <= avs_s0_writedata[8 +: 8];
            end
            default: ;
        endcase

    end
end


endmodule
