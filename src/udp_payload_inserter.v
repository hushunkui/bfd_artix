//
// author: Golovachenko Viktor
//
// Description : Insert MAC,IP,UDP and User Protocol headers
//               before the input data packet

module udp_payload_inserter (
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,

    // slave interface
    input           avs_s0_write,
    input           avs_s0_read,
    input   [3:0]   avs_s0_address,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata,
    output  [31:0]  avs_s0_readdata,

    // source interface
    input               aso_src0_ready,
    output  reg [31:0]  aso_src0_data = 32'd0,
    output  reg         aso_src0_valid = 1'b0,
    output  reg         aso_src0_sof = 1'b0,
    output  reg         aso_src0_eof = 1'b0,
    output  reg [1:0]   aso_src0_empty = 2'd0,

    // sink interface
    output          asi_snk0_ready,
    input   [31:0]  asi_snk0_data,
    input           asi_snk0_valid,
    input           asi_snk0_sof,
    input           asi_snk0_eof,
    input   [1:0]   asi_snk0_empty
);


`ifdef SIM_FSM
    enum int unsigned {
        IDLE    ,
        INS_N   ,
        SINK_0  ,
        SINK_N  ,
        WAIT_EOP
    } state = IDLE;
`else
    localparam IDLE    = 3'd0;
    localparam INS_N   = 3'd1;
    localparam SINK_0  = 3'd2;
    localparam SINK_N  = 3'd3;
    localparam WAIT_EOP= 3'd4;
    reg [2:0] state = IDLE;
`endif

localparam  [15:0]   MAC_TYPE            = 16'h0800;

localparam  [15:0]   MTU                 = 16'd1500; //Maximum transmission unit
localparam   [2:0]   IP_FLAGS_MF         = 3'd1; //More Fragments (MF);
localparam   [2:0]   IP_FLAGS_DF         = 3'd2; //Don't Fragment (DF);

localparam  [15:0]   IP_HEADER_SIZE      = 16'd20;
localparam   [3:0]   IP_VERSION          = 4;
localparam   [3:0]   IP_HEADER_LENGTH    = 5;
localparam   [7:0]   IP_TOS              = 0;
//localparam   [2:0]   IP_FLAGS            = IP_FLAGS_MF;
wire         [2:0]   IP_FLAGS            ;
localparam  [12:0]   IP_FRAGMENT_OFFSET  = 0;
localparam   [7:0]   IP_TTL              = 128;
localparam   [7:0]   IP_PROTOCOL         = 17;//UDP

localparam  [15:0]   UDP_HEADER_SIZE     = 16'd8;
localparam  [15:0]   UDP_CHECKSUM        = 16'h0000;

localparam   [3:0]   INSERT_COUNT        = 4'd12;

wire   [15:0]  ip_total_length;
wire   [15:0]  ip_header_crc;
reg    [15:0]  ip_identification = 16'd0;

wire   [15:0]  udp_length;

wire   [31:0]  ip_dw [4:0]; //ip header
wire   [31:0]  udp_dw [1:0];

reg            rst_bit = 1'b0;
reg            go_bit = 1'b0;
wire           running_bit;

reg    [31:0]  sink_data  = 32'd0;
reg            sink_eop   = 1'b0;
reg     [1:0]  sink_empty = 2'd0;

reg            pkt_cnt_ld = 1'b0;
reg    [31:0]  pkt_cnt = 32'd0;

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

wire   [31:0]  ins_data [INSERT_COUNT-1:0];

reg            busy = 1'b0;
reg     [3:0]  cnt = 4'd0;
reg     [3:0]  x = 4'd0;

reg    [31:0]  tst_data = 32'd0;
reg            test_gen = 1'b0;

reg            skip_pkt_start = 1'b0;
reg            skip_pkt_en = 1'b0;
reg    [15:0]  skip_pkt_cnt = 16'd0;
reg    [15:0]  skip_pkt_count = 16'd0;

reg            sw_skip_pkt_start = 1'b0;
reg    [15:0]  sw_skip_pkt_count = 16'd0;
reg    [15:0]  hw_skip_pkt = 16'd0;
reg    [31:0]  hw_skip_pkt_ctrl = 16'd0;
reg    [31:0]  hw_skip_pkt_period = 16'd0;
reg            hw_skip_pkt_period_ld = 1'b0;

struct {
    struct {
        logic [15:0] typ;
        logic [31:0] id;
    } trn;

    struct {
        struct {
            struct {
                logic [15:0] src;
                logic [15:0] dst;
            } port;
            logic [31:0] payload_size;
        } udp;
        struct {
            logic [31:0] src;
            logic [31:0] dst;
        } ip;
        struct {
            logic [47:0] src;
            logic [47:0] dst;
        } mac;
    } net;
} cfg;

//reg    [47:0]  cfg_net_mac_src      = 48'd0;
//reg    [47:0]  cfg_net_mac_dst      = 48'd0;
//reg    [31:0]  cfg_net_ip_src       = 32'd0;
//reg    [31:0]  cfg_net_ip_dst       = 32'd0;
//reg    [15:0]  cfg_net_udp_port_src = 16'd0;
//reg    [15:0]  cfg_net_udp_port_dst = 16'd0;
//reg    [31:0]  cfg_net_udp_payload_size = 32'd0;
//reg    [31:0]  cfg_trn_id          = 32'd0;
//reg    [15:0]  cfg_trn_typ         = 16'd0;

//
// misc computations
//
assign udp_length = UDP_HEADER_SIZE + cfg.net.udp.payload_size[15:0];

assign ip_total_length = ((IP_HEADER_SIZE + udp_length) > MTU) ? MTU : (IP_HEADER_SIZE + udp_length);

assign IP_FLAGS = ((IP_HEADER_SIZE + udp_length) > MTU) ? IP_FLAGS_MF : IP_FLAGS_DF;


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

assign ip_header_crc = ~ip_header_carry_sum_o;


//
// IP and UDP header layout
//
assign ip_dw[0]  = {IP_VERSION, IP_HEADER_LENGTH, IP_TOS, ip_total_length};
assign ip_dw[1]  = {ip_identification, IP_FLAGS, IP_FRAGMENT_OFFSET};
assign ip_dw[2]  = {IP_TTL, IP_PROTOCOL, ip_header_crc};
assign ip_dw[3]  = cfg.net.ip.src;
assign ip_dw[4]  = cfg.net.ip.dst;
assign udp_dw[0] = {cfg.net.udp.port.src, cfg.net.udp.port.dst};
assign udp_dw[1] = {udp_length, UDP_CHECKSUM};


//
// inset data layout
//
assign ins_data[ 0] =  cfg.net.mac.dst[47:16];
assign ins_data[ 1] = {cfg.net.mac.dst[15:0], cfg.net.mac.src[47:32]};
assign ins_data[ 2] =  cfg.net.mac.src[31:0];
assign ins_data[ 3] = {MAC_TYPE, ip_dw[0][31:16]};
assign ins_data[ 4] = {ip_dw[0][15:0], ip_dw[1][31:16]};
assign ins_data[ 5] = {ip_dw[1][15:0], ip_dw[2][31:16]};
assign ins_data[ 6] = {ip_dw[2][15:0], ip_dw[3][31:16]};
assign ins_data[ 7] = {ip_dw[3][15:0], ip_dw[4][31:16]};
assign ins_data[ 8] = {ip_dw[4][15:0], udp_dw[0][31:16]};
assign ins_data[ 9] = {udp_dw[0][15:0], udp_dw[1][31:16]};
assign ins_data[10] = {udp_dw[1][15:0], cfg.trn.typ};
assign ins_data[11] = {pkt_cnt[7:0], pkt_cnt[15:8], pkt_cnt[23:16], pkt_cnt[31:24]};


assign asi_snk0_ready = aso_src0_ready & (~busy);


always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset || rst_bit) begin
        state <= IDLE;

        busy <= 1'b0;
        cnt <= 4'd0;

    end else begin

        case (state)

            IDLE: begin
                if (aso_src0_ready) begin

                    //save state sink signal
                    sink_data   <= asi_snk0_data;
                    sink_eop    <= asi_snk0_eof;
                    sink_empty  <= asi_snk0_empty;

                    aso_src0_valid <= 1'b0;
                    aso_src0_sof <= 1'b0;
                    aso_src0_eof <= 1'b0;
                    aso_src0_empty <= 2'd0;

                    if (asi_snk0_valid & asi_snk0_sof) begin
                        if (go_bit) begin
                            if (skip_pkt_en && (skip_pkt_count > 0)) begin
                            //Make skip udp packets
                                state <= WAIT_EOP;
                            end else begin
                                busy <= 1'b1;
                                state <= INS_N;
                            end
                        end
                    end
                end
            end

            INS_N: begin
                if (aso_src0_ready) begin

                    for (x = 0; x < INSERT_COUNT; x = x + 1) begin
                        if (cnt == x) begin
                            aso_src0_data <= ins_data[x];
                        end
                    end

                    aso_src0_valid <= 1'b1;
                    aso_src0_sof <= ~(|cnt) ;
                    aso_src0_eof <= 1'b0;
                    aso_src0_empty <= {2{1'b0}};

                    if (cnt == (INSERT_COUNT - 1)) begin
                        cnt <= 4'd0;
                        state <= SINK_0;

                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            end

            //Insert save state sink signal
            SINK_0: begin
                if (aso_src0_ready) begin

                    if (!test_gen) begin
                    aso_src0_data <= sink_data;
                    end else begin
                    aso_src0_data <= {tst_data[7:0], tst_data[15:8], tst_data[23:16], tst_data[31:24]};
                    end
                    aso_src0_eof <= sink_eop;
                    aso_src0_empty <= sink_empty;

                    busy <= 1'b0;

                    if (sink_eop) begin
                        state <= IDLE;

                    end else begin
                        state <= SINK_N;
                    end
                end
            end

            SINK_N: begin
                if (aso_src0_ready) begin

                    if (!test_gen) begin
                    aso_src0_data <= asi_snk0_data;
                    end else begin
                    aso_src0_data <= {tst_data[7:0], tst_data[15:8], tst_data[23:16], tst_data[31:24]};
                    end
                    aso_src0_valid <= asi_snk0_valid;
                    aso_src0_eof <= asi_snk0_eof;
                    aso_src0_empty <= asi_snk0_empty;

                    if (asi_snk0_valid & asi_snk0_eof) begin
                        state <= IDLE;
                    end
                end
            end

            WAIT_EOP: begin
                if (aso_src0_ready) begin
                    if (asi_snk0_valid & asi_snk0_eof) begin
                        if (skip_pkt_cnt == (skip_pkt_count - 1)) begin
                            skip_pkt_cnt <= 16'd0;
                        end else begin
                            skip_pkt_cnt <= skip_pkt_cnt + 1;
                        end
                        state <= IDLE;
                    end
                end
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end


//
//
//
always @ (posedge csi_clock_clk)
begin
    if (pkt_cnt_ld) begin
        pkt_cnt <= cfg.trn.id;
    end else if ((aso_src0_ready & asi_snk0_valid & asi_snk0_eof) && ((state == SINK_N) || (state == WAIT_EOP))) begin
        pkt_cnt <= pkt_cnt + 1;
    end
end

always @ (posedge csi_clock_clk)
begin
    if ((aso_src0_ready & asi_snk0_valid & asi_snk0_eof) && ((state == SINK_N) || (state == WAIT_EOP))) begin
        ip_identification <= ip_identification + 1;
    end
end


//
// slave read mux
//
assign running_bit = (state == IDLE) ? (1'b0) : (1'b1);

assign avs_s0_readdata = (avs_s0_address == 4'h0) ? ({{26{1'b0}}, rst_bit, test_gen, {2{1'b0}}, running_bit, go_bit}) :
                         (avs_s0_address == 4'h1) ? (cfg.net.mac.dst[47:16]) :
                         (avs_s0_address == 4'h2) ? ({{16{1'b0}}, cfg.net.mac.dst[15:0]}) :
                         (avs_s0_address == 4'h3) ? (cfg.net.mac.src[47:16]) :
                         (avs_s0_address == 4'h4) ? ({{16{1'b0}}, cfg.net.mac.src[15:0]}) :
                         (avs_s0_address == 4'h5) ? (cfg.net.ip.src) :
                         (avs_s0_address == 4'h6) ? (cfg.net.ip.dst) :
                         (avs_s0_address == 4'h7) ? ({cfg.net.udp.port.src, cfg.net.udp.port.dst}) :
                         (avs_s0_address == 4'hA) ? ({{16{1'b0}}, cfg.trn.typ}) :
                                                    (cfg.trn.id);

//
// slave write demux
//
always @ (posedge csi_clock_clk)
begin
    if (csi_clock_reset) begin

        go_bit              <= 1'b0;

        cfg.net.mac.src      <= 48'd0;
        cfg.net.mac.dst      <= 48'd0;
        cfg.net.ip.src       <= 32'd0;
        cfg.net.ip.dst       <= 32'd0;
        cfg.net.udp.port.src <= 16'd0;
        cfg.net.udp.port.dst <= 16'd0;
        cfg.net.udp.payload_size <= 32'd0;

        pkt_cnt_ld  <= 1'b0;
        sw_skip_pkt_start <= 1'b0;

        cfg.trn.id          <= 32'd0;
        cfg.trn.typ         <= 16'd0;

        test_gen <= 1'b0;

        sw_skip_pkt_count <= 16'd0;
        hw_skip_pkt_period <= 32'd0; hw_skip_pkt_period_ld <= 1'b0;
        hw_skip_pkt_ctrl <= 32'd0;

        rst_bit <= 1'b0;

    end else begin
        pkt_cnt_ld <= 1'b0;
        sw_skip_pkt_start <= 1'b0;
        hw_skip_pkt_period_ld <= 1'b0;

        if (avs_s0_write) begin
            case (avs_s0_address)
                4'h0: begin
                    if (avs_s0_byteenable[0] == 1'b1) begin
                        go_bit <= avs_s0_writedata[0];
                        test_gen <= avs_s0_writedata[4];
                        rst_bit <= avs_s0_writedata[5];
                    end
                end
                4'h1: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.mac.dst[23:16] <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.mac.dst[31:24] <= avs_s0_writedata[15:8] ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.mac.dst[39:32] <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.mac.dst[47:40] <= avs_s0_writedata[31:24];
                end
                4'h2: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.mac.dst[7:0]   <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.mac.dst[15:8]  <= avs_s0_writedata[15:8] ;
                end
                4'h3: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.mac.src[23:16] <= avs_s0_writedata[7:0]   ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.mac.src[31:24] <= avs_s0_writedata[15:8]  ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.mac.src[39:32] <= avs_s0_writedata[23:16] ;
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.mac.src[47:40] <= avs_s0_writedata[31:24] ;
                end
                4'h4: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.mac.src[7:0]   <= avs_s0_writedata[7:0]   ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.mac.src[15:8]  <= avs_s0_writedata[15:8]  ;
                end
                4'h5: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.ip.src[7:0]    <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.ip.src[15:8]   <= avs_s0_writedata[15:8] ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.ip.src[23:16]  <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.ip.src[31:24]  <= avs_s0_writedata[31:24];
                end
                4'h6: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.ip.dst[7:0]    <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.ip.dst[15:8]   <= avs_s0_writedata[15:8] ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.ip.dst[23:16]  <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.ip.dst[31:24]  <= avs_s0_writedata[31:24];
                end
                4'h7: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.udp.port.dst[7:0]   <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.udp.port.dst[15:8]  <= avs_s0_writedata[15:8] ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.udp.port.src[7:0]   <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.udp.port.src[15:8]  <= avs_s0_writedata[31:24];
                end
//                4'h8: begin
//                    pkt_cnt_ld <= 1'b1;
//                end
                4'h9: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.net.udp.payload_size[7:0]   <= avs_s0_writedata[7:0]  ;
                    if (avs_s0_byteenable[1] == 1'b1) cfg.net.udp.payload_size[15:8]  <= avs_s0_writedata[15:8] ;
                    if (avs_s0_byteenable[2] == 1'b1) cfg.net.udp.payload_size[23:16] <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.net.udp.payload_size[31:24] <= avs_s0_writedata[31:24];
                end
                4'hA: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.trn.typ[7:0]   <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1) cfg.trn.typ[15:8]  <= avs_s0_writedata[15:8];
                end
                4'hB: begin
                    if (avs_s0_byteenable[0] == 1'b1) cfg.trn.id[7:0]   <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1) cfg.trn.id[15:8]  <= avs_s0_writedata[15:8];
                    if (avs_s0_byteenable[2] == 1'b1) cfg.trn.id[23:16] <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) cfg.trn.id[31:24] <= avs_s0_writedata[31:24];
                    pkt_cnt_ld <= 1'b1;
                end
                4'hC: begin
                    if (avs_s0_byteenable[0] == 1'b1) sw_skip_pkt_count[7:0]   <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1) sw_skip_pkt_count[15:8]  <= avs_s0_writedata[15:8];
                    sw_skip_pkt_start <= 1'b1;
                end
                4'hD: begin
                    if (avs_s0_byteenable[0] == 1'b1) hw_skip_pkt_ctrl[7:0]   <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1) hw_skip_pkt_ctrl[15:8]  <= avs_s0_writedata[15:8];
                    if (avs_s0_byteenable[2] == 1'b1) hw_skip_pkt_ctrl[23:16] <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) hw_skip_pkt_ctrl[31:24] <= avs_s0_writedata[31:24];
                end
                4'hE: begin
                    if (avs_s0_byteenable[0] == 1'b1) hw_skip_pkt_period[7:0]   <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1) hw_skip_pkt_period[15:8]  <= avs_s0_writedata[15:8];
                    if (avs_s0_byteenable[2] == 1'b1) hw_skip_pkt_period[23:16] <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1) hw_skip_pkt_period[31:24] <= avs_s0_writedata[31:24];
                    hw_skip_pkt_period_ld <= 1'b1;
                end
                default: ;
            endcase
        end
    end
end



//
// DEBUG section
//

// Simple test data generator
always @ (posedge csi_clock_clk)
begin
    if (!test_gen) begin
        tst_data <= 32'd0;
    end else begin
        if (aso_src0_ready) begin
            if ((state == SINK_0) || ((state == SINK_N) & asi_snk0_valid)) begin
                tst_data <= tst_data + 1;
            end
        end
    end
end

// send count skip udp packets
always @ (posedge csi_clock_clk)
begin
    skip_pkt_start <= sw_skip_pkt_start | hw_skip_pkt[15];
    if (skip_pkt_start) begin
        if (hw_skip_pkt[14] == 1'b0) begin
            skip_pkt_count <= sw_skip_pkt_count;
        end else begin
            skip_pkt_count <= {2'd0, hw_skip_pkt[13:0]};
        end
    end
    if (skip_pkt_start) begin
        skip_pkt_en <= hw_skip_pkt_ctrl[28];
    end else if ((aso_src0_ready & asi_snk0_valid & asi_snk0_eof) && (state == WAIT_EOP) && (skip_pkt_cnt == (skip_pkt_count - 1))) begin
        skip_pkt_en <= 1'b0;
    end
end


// Generate pseudo random data for testing skip udp packets.
reg [15:0] lfsr_q = 0;
reg [15:0] lfsr_c = 0;
reg [15:0] data_c = 0;
reg [15:0] data_out = 0;
wire [15:0] data_in;

assign data_in = data_out;

always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13];
    lfsr_c[1] = lfsr_q[1] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14];
    lfsr_c[2] = lfsr_q[2] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15];
    lfsr_c[3] = lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15];
    lfsr_c[4] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[15];
    lfsr_c[5] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[5] ^ lfsr_q[11] ^ lfsr_q[13] ^ lfsr_q[15];
    lfsr_c[6] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[12] ^ lfsr_q[14];
    lfsr_c[7] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[7] ^ lfsr_q[13] ^ lfsr_q[15];
    lfsr_c[8] = lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[8] ^ lfsr_q[14];
    lfsr_c[9] = lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[9] ^ lfsr_q[15];
    lfsr_c[10] = lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[10];
    lfsr_c[11] = lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[11];
    lfsr_c[12] = lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[12];
    lfsr_c[13] = lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[13];
    lfsr_c[14] = lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[14];
    lfsr_c[15] = lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[15];

    data_c[0] = data_in[0] ^ lfsr_q[15];
    data_c[1] = data_in[1] ^ lfsr_q[14];
    data_c[2] = data_in[2] ^ lfsr_q[13];
    data_c[3] = data_in[3] ^ lfsr_q[12];
    data_c[4] = data_in[4] ^ lfsr_q[11];
    data_c[5] = data_in[5] ^ lfsr_q[10];
    data_c[6] = data_in[6] ^ lfsr_q[9];
    data_c[7] = data_in[7] ^ lfsr_q[8];
    data_c[8] = data_in[8] ^ lfsr_q[7];
    data_c[9] = data_in[9] ^ lfsr_q[6];
    data_c[10] = data_in[10] ^ lfsr_q[5];
    data_c[11] = data_in[11] ^ lfsr_q[4] ^ lfsr_q[15];
    data_c[12] = data_in[12] ^ lfsr_q[3] ^ lfsr_q[14] ^ lfsr_q[15];
    data_c[13] = data_in[13] ^ lfsr_q[2] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15];
    data_c[14] = data_in[14] ^ lfsr_q[1] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14];
    data_c[15] = data_in[15] ^ lfsr_q[0] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[13];
end

always @(posedge csi_clock_clk) begin
    if (hw_skip_pkt_ctrl[30]) begin
        lfsr_q <= hw_skip_pkt_ctrl[15:0];
    end else begin
        lfsr_q <= lfsr_c;
    end

    data_out <= data_c;
end

// Setup period skip udp packets
reg [31:0] hw_skip_pkt_period_cnt = 32'd0;
always @ (posedge csi_clock_clk) begin
    hw_skip_pkt[15] <= 1'b0;
    hw_skip_pkt[14] = hw_skip_pkt_ctrl[29]; //select source skip udp packets
    hw_skip_pkt[13:0] = data_out[13:0] & {{2'd0}, hw_skip_pkt_ctrl[27:16]};

    if (hw_skip_pkt_ctrl[31]) begin
        if (hw_skip_pkt_period_ld || (hw_skip_pkt_period_cnt == 0)) begin
            hw_skip_pkt_period_cnt <= hw_skip_pkt_period;
            if (hw_skip_pkt_period_cnt == 0) begin
                hw_skip_pkt[15] <= 1'b1;
            end
        end else begin
            hw_skip_pkt_period_cnt <= hw_skip_pkt_period_cnt - 1;
        end
    end else begin
        hw_skip_pkt_period_cnt <= 0;
    end
end


endmodule : udp_payload_inserter

