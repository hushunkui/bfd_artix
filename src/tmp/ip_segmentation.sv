//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 05.12.2017 15:28:37
// Module Name : ip_segmentation
//
// Description : Splits the input UDP packet into fragments (IP packets)
//
//------------------------------------------------------------------------

module ip_segmentation
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,

    // slave interface
    input           avs_s0_write     ,
    input           avs_s0_read      ,
    input   [3:0]   avs_s0_address   ,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata ,
    output  [31:0]  avs_s0_readdata  ,

    // source interface
    input               aso_src0_ready,
    output  reg [31:0]  aso_src0_data          = 32'd0,
    output  reg         aso_src0_valid         = 1'b0,
    output  reg         aso_src0_startofpacket = 1'b0,
    output  reg         aso_src0_endofpacket   = 1'b0,
    output  reg [1:0]   aso_src0_empty         = 2'd0,

    // sink interface
    output          asi_snk0_ready        ,
    input   [31:0]  asi_snk0_data         ,
    input           asi_snk0_valid        ,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket  ,
    input   [1:0]   asi_snk0_empty
);


localparam   [2:0]   IP_FLAGS_MF = 3'd1; //More Fragments (MF);
localparam   [2:0]   IP_FLAGS_DF = 3'd2; //Don't Fragment (DF);
localparam   [2:0]   IP_FLAGS_ZERO = 3'd0;

localparam  [15:0]   UDP_HEADER_SIZE = 16'd8;
localparam  [15:0]   IP_HEADER_SIZE  = 16'd20;
localparam  [15:0]   IP_HEADER_UDP_HEADER_SIZE = IP_HEADER_SIZE + UDP_HEADER_SIZE;

enum int unsigned {
IDLE  ,
SAVE  ,
FG0_H , //Fragment(0) Header send
FGN_H , //Fragment(N) Header send
FGN_D , //Fragment(N) Data send
FGN_HU, //Fragment(N) Header update
FGL_D   //Fragment(Last) Data send
} fsm_state = IDLE;

reg            go_bit    = 1'b0;

localparam  [3:0]   FG0_HEADER_COUNT = 4'd11; //mac,eth_type,ip_header,udp_header
localparam  [3:0]   FGN_HEADER_COUNT = 4'd9;  //mac,eth_type,ip_header
reg    [31:0]  headers [FG0_HEADER_COUNT-1:0];
reg     [3:0]  x = 4'd0;
reg     [3:0]  cnt = 4'd0;

reg            busy = 1'b0;

reg    [15:0]  udp_pd = 16'd0; //udp payload data size only

reg    [15:0]  ip_fg_offset = 16'd0;
reg    [15:0]  ip_fg_pd_size = 16'd0; //ip fragment payload data size only
reg    [15:0]  ip_fg_pd_cnt = 16'd0; //ip fragment payload data counter

reg    [31:0]  sv_snk0_data = 32'd0; // save tmp data

wire   [31:0]  ip_dw [4:0]; //ip header

reg    [16:0]  ip_header_sum_0 = 17'd0;
reg    [16:0]  ip_header_sum_1 = 17'd0;
reg    [15:0]  ip_header_sum_2 = 16'd0;
reg    [16:0]  ip_header_sum_3 = 17'd0;
reg    [16:0]  ip_header_sum_4 = 17'd0;
reg    [17:0]  ip_header_sum_a = 18'd0;
reg    [17:0]  ip_header_sum_b = 18'd0;
reg    [18:0]  ip_header_sum_c = 19'd0;
reg    [19:0]  ip_header_sum_d = 20'd0;
reg    [16:0]  ip_header_carry_sum = 17'd0;
wire   [15:0]  ip_header_carry_sum_o;

reg            first_data = 1'b0;

reg    [15:0]  ip_fg_delay = 16'd0;
reg    [15:0]  ip_fg_delay_cnt = 16'd0;

struct packed {
    logic [15:0]   udp_len;
    logic [15:0]   payload_len;
    logic [15:0]   ip_total_len;
    logic [12:0]   fragment_offset;
    logic [15:0]   ip_crc;
    logic  [2:0]   ip_flags;
} info;


assign info.payload_len = udp_pd;
assign info.ip_total_len = headers[4][16 +: 16];
assign info.udp_len = headers[9][0 +: 16];
assign info.fragment_offset = headers[5][28:16];
assign info.ip_crc = headers[6][31:16];
assign info.ip_flags = headers[5][31:29];


//
//FSM
//

assign asi_snk0_ready = aso_src0_ready & (~busy);

always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset) begin
        fsm_state <= IDLE;

        for (x = 0; x < FG0_HEADER_COUNT; x = x + 1) begin
            headers[x] <= 32'd0;
        end

        cnt <= 4'd1;

        udp_pd <= 16'd0;
        ip_fg_pd_size <= 16'd0;
        ip_fg_pd_cnt <= 16'd0;
        ip_fg_offset <= 16'd0;

        first_data <= 1'b0;

    end else begin
        case (fsm_state)
            IDLE: begin
                if (aso_src0_ready) begin

                    aso_src0_valid         <= 1'b0;
                    aso_src0_startofpacket <= 1'b0;
                    aso_src0_endofpacket   <= 1'b0;
                    aso_src0_empty         <= {2{1'b0}};

                    if (asi_snk0_valid & asi_snk0_startofpacket) begin
                        headers[0] <= asi_snk0_data;
                        cnt <= 4'd1;
//                        if (go_bit) begin
                            fsm_state <= SAVE;
//                        end
                    end
                end
            end

            SAVE: begin //save mac, eth type, ip header
                if (aso_src0_ready & asi_snk0_valid) begin
                    for (x = 1; x < FG0_HEADER_COUNT; x = x + 1) begin
                        if (cnt == x) begin
                            headers[x] <= asi_snk0_data;
                        end
                    end

                    if (cnt == (FG0_HEADER_COUNT - 1)) begin
                        cnt <= 4'd0;
                        busy <= 1'b1;

                        //calc ip fragment payload data size (byte)
                        ip_fg_pd_size <= info.ip_total_len - IP_HEADER_UDP_HEADER_SIZE;
                        ip_fg_offset <= info.ip_total_len - IP_HEADER_SIZE;

                        //calc udp payload data size (byte).
                        udp_pd <= info.udp_len - UDP_HEADER_SIZE;

                        fsm_state <= FG0_H;

                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            end

            //Fragment(0) Header send (mac, eth_type, ip_header, udp_header)
            FG0_H: begin
                if (aso_src0_ready) begin
                    for (x = 0; x < FG0_HEADER_COUNT; x = x + 1) begin
                        if (cnt == x) begin
                            aso_src0_data <= headers[x];
                        end
                    end

                    aso_src0_valid         <= 1'b1;
                    aso_src0_startofpacket <= ~(|cnt) ;
                    aso_src0_endofpacket   <= 1'b0;
                    aso_src0_empty         <= {2{1'b0}};

                    if (cnt == (FG0_HEADER_COUNT - 1)) begin
                        cnt <= 4'd0;
                        busy <= 1'b0;

                        if (info.ip_flags == IP_FLAGS_DF) begin //Don't Fragment (DF)
                            fsm_state <= FGL_D;//Goto Last Fragment Data
                        end else begin
                            ip_fg_pd_cnt <= ip_fg_pd_size;
                            first_data <= 1'b1;

                            fsm_state <= FGN_D;
                        end

                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            end

            //Fragment(N) Header send (mac, eth_type, ip_header)
            FGN_H: begin
                if (aso_src0_ready) begin
                    //update ip crc
                    headers[6][31:16] <= ~ip_header_carry_sum_o;

                    for (x = 0; x < FGN_HEADER_COUNT; x = x + 1) begin
                        if (cnt == x) begin
                            if (cnt == (FGN_HEADER_COUNT - 1)) begin
                                aso_src0_data[0  +: 16] <= sv_snk0_data[0 +: 16];
                                aso_src0_data[16 +: 16] <= headers[x][16 +: 16];
                            end else begin
                                aso_src0_data           <= headers[x];
                            end
                        end
                    end

                    aso_src0_valid         <= 1'b1;
                    aso_src0_startofpacket <= ~(|cnt) ;
                    aso_src0_empty         <= {2{1'b0}};

                    if (cnt == (FGN_HEADER_COUNT - 1)) begin
                        cnt <= 4'd0;
                        busy <= 1'b0;

                        if (info.ip_flags == IP_FLAGS_ZERO) begin
                            if (ip_fg_pd_size <= 16'd2) begin
                                aso_src0_endofpacket <= 1'b1;
                                fsm_state <= IDLE;
                            end else begin
                                aso_src0_endofpacket <= 1'b0;
                                fsm_state <= FGL_D;
                            end
                        end else begin
                            ip_fg_pd_cnt <= ip_fg_pd_size;
                            first_data <= 1'b1;
                            fsm_state <= FGN_D;
                        end

                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            end

            //Fragment(N) Data send
            FGN_D: begin
                if (aso_src0_ready) begin

                    aso_src0_data  <= asi_snk0_data ;
                    aso_src0_valid <= asi_snk0_valid;

                    if (asi_snk0_valid) begin
                        if (ip_fg_pd_cnt <= 16'd6) begin

                            sv_snk0_data <= asi_snk0_data;
                            aso_src0_endofpacket <= 1'b1;
                            aso_src0_empty <= 2'd2;

                            busy <= 1'b1;
                            ip_fg_pd_cnt <= 16'd0;
                            udp_pd <= udp_pd - ip_fg_pd_size;

                            fsm_state <= FGN_HU;

                        end else begin
                            //first time subtract 2 bytes then subtract 4 bytes
                            ip_fg_pd_cnt <= ip_fg_pd_cnt - {{12{1'b0}}, 1'b0, ~first_data, first_data, 1'b0};
                            first_data <= 1'b0;
                        end
                    end
                end
            end

            //Fragment(N) Header update
            FGN_HU: begin
                if (aso_src0_ready) begin

                    aso_src0_endofpacket <= 1'b0;
                    aso_src0_valid       <= 1'b0;
                    aso_src0_empty       <= 2'd0;

                    if (udp_pd <= ip_fg_offset) begin
                        ip_fg_pd_size <= udp_pd;
                        headers[5][31:29] <= IP_FLAGS_ZERO; //update ip flags
                        headers[4][16 +: 16] <= udp_pd + IP_HEADER_SIZE; //update ip total length
                    end else begin
                        ip_fg_pd_size <= ip_fg_offset;
                        headers[4][16 +: 16] <= ip_fg_offset + IP_HEADER_SIZE; //update ip total length
                    end

                    if (ip_fg_delay_cnt == ip_fg_delay) begin
                        //update ip fragment offset for next header:
                        //!!! The fragment offset field is measured in units of eight-byte blocks !!!
                        headers[5][28:16] <= headers[5][28:16] + {{3{1'b0}}, ip_fg_offset[12:3]};
                        fsm_state <= FGN_H;
                    end

                end
            end

            //Fragment(Last) Data send
            FGL_D: begin
                if (aso_src0_ready) begin

                    aso_src0_data          <= asi_snk0_data         ;
                    aso_src0_valid         <= asi_snk0_valid        ;
                    aso_src0_startofpacket <= asi_snk0_startofpacket;
                    aso_src0_endofpacket   <= asi_snk0_endofpacket  ;
                    aso_src0_empty         <= asi_snk0_empty        ;

                    if (asi_snk0_valid & asi_snk0_endofpacket) begin
                        fsm_state <= IDLE;
                    end
                end
            end

            default: begin
                fsm_state <= IDLE;
            end
        endcase
    end
end


//
//
//
always @ (posedge csi_clock_clk)
begin
    if (aso_src0_ready) begin
        if (fsm_state != FGN_HU) begin
            ip_fg_delay_cnt <= 16'd0;
        end else begin
            ip_fg_delay_cnt <= ip_fg_delay_cnt + 1;
        end
    end
end

//
// IP CRC calc
//

assign ip_dw[0] = {headers[3][15:0],headers[4][31:16]}; //{IP_VERSION, IP_HEADER_LENGTH, IP_TOS, ip_total_length};
assign ip_dw[1] = {headers[4][15:0],headers[5][31:16]}; //{ip_identification, IP_FLAGS, IP_FRAGMENT_OFFSET};
assign ip_dw[2] = {headers[5][15:0],headers[6][31:16]}; //{IP_TTL, IP_PROTOCOL, ip_crc};
assign ip_dw[3] = {headers[6][15:0],headers[7][31:16]}; //ip.src;
assign ip_dw[4] = {headers[7][15:0],headers[8][31:16]}; //ip.dst;

always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset) begin
        ip_header_sum_0 <= 17'd0;
        ip_header_sum_1 <= 17'd0;
        ip_header_sum_2 <= 16'd0;
        ip_header_sum_3 <= 17'd0;
        ip_header_sum_4 <= 17'd0;

        ip_header_sum_a <= 18'd0;
        ip_header_sum_b <= 18'd0;

        ip_header_sum_c <= 19'd0;

        ip_header_sum_d <= 20'd0;

        ip_header_carry_sum <= 17'd0;

    end else begin
        // stage 1 of header checksum pipeline
        ip_header_sum_0[16:0] <= ip_dw[0][31:16] + ip_dw[0][15:0];
        ip_header_sum_1[16:0] <= ip_dw[1][31:16] + ip_dw[1][15:0];
        ip_header_sum_2[15:0] <= ip_dw[2][31:16];//+ 0
        ip_header_sum_3[16:0] <= ip_dw[3][31:16] + ip_dw[3][15:0];
        ip_header_sum_4[16:0] <= ip_dw[4][31:16] + ip_dw[4][15:0];

        // stage 2 of header checksum pipeline
        ip_header_sum_a[17:0] <= ip_header_sum_0[16:0] + ip_header_sum_1[16:0];
        ip_header_sum_b[17:0] <= ip_header_sum_3[16:0] + ip_header_sum_4[16:0];

        // stage 3 of header checksum pipeline
        ip_header_sum_c[18:0] <= ip_header_sum_a[17:0] + ip_header_sum_b[17:0];

        // stage 4 of header checksum pipeline
        ip_header_sum_d[19:0] <= {{3{1'b0}}, ip_header_sum_2[15:0]} + ip_header_sum_c[18:0];

        // stage 5 of header checksum pipeline
        ip_header_carry_sum[16:0] <= {{12{1'b0}}, ip_header_sum_d[19:16]} + ip_header_sum_d[15:0];

    end
end

assign ip_header_carry_sum_o[15:0] = {{15{1'b0}}, ip_header_carry_sum[16]} + ip_header_carry_sum[15:0];

//
// slave interface machine
//
assign avs_s0_readdata  =  ({{31{1'b0}}, go_bit});

always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset) begin
        go_bit <= 1'b0;
        ip_fg_delay <= 16'd0;

    end else if (avs_s0_write) begin

        case (avs_s0_address)
            2'h0: begin
                if (avs_s0_byteenable[0] == 1'b1) begin
                    go_bit <= avs_s0_writedata[0];
                end
            end
            2'h1: begin
                if (avs_s0_byteenable[0] == 1'b1) ip_fg_delay[0 +: 8]  <= avs_s0_writedata[7:0];
                if (avs_s0_byteenable[1] == 1'b1) ip_fg_delay[8 +: 8]  <= avs_s0_writedata[15:8];
            end
            default: ;
        endcase

    end
end


endmodule : ip_segmentation
