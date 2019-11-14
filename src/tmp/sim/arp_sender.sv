//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 10.10.2017 9:49:44
// Module Name : arp_sender
//
// Description :
//
//------------------------------------------------------------------------

module arp_sender
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,

    // slave interface
    input           avs_s0_write     ,
    input           avs_s0_read      ,
    input   [2:0]   avs_s0_address   ,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata ,
    output  [31:0]  avs_s0_readdata  ,

    // source interface
    input              aso_src0_ready        ,
    output reg [31:0]  aso_src0_data         = 32'd0,
    output reg         aso_src0_valid        = 1'b0,
    output reg         aso_src0_startofpacket= 1'b0,
    output reg         aso_src0_endofpacket  = 1'b0,
    output reg [1:0]   aso_src0_empty        = 2'd0
);

localparam [15:0]   MAC_TYPE_ARP       = 16'h0806;

localparam [15:0]   HARDWARE_TYPE      = 16'h1;
localparam [15:0]   PROTOCOL_TYPE      = 16'h0800;

localparam [7:0]    HARDWARE_LEN       = 8'd6;
localparam [7:0]    PROTOCOL_LEN       = 8'd4;

localparam [15:0]   OPERATION_REQ      = 16'd1;
localparam [15:0]   OPERATION_REPLY    = 16'd2;


enum int unsigned {
IDLE ,
SEND_1,
SEND_2,
SEND_3,
SEND_4,
SEND_5,
SEND_6,
SEND_7,
SEND_8,
SEND_9,
SEND_10,
SEND_END,
PAUSE
} state = IDLE;

reg             go_bit    = 1'b0;

reg    [31:0]   ip_src  = 32'd0;
reg    [31:0]   ip_dst  = 32'd0;
reg    [47:0]   mac_src = 48'd0;
reg    [47:0]   mac_dst = 48'd0;


reg    [15:0]   pause_val = 16'd0;
reg    [15:0]   pause_cnt = 16'd0;


//
// check packet state machine
//

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if (csi_clock_reset) begin
        state <= IDLE;
        pause_cnt <= 16'd0;

        aso_src0_data         <= 32'd0;
        aso_src0_valid        <= 1'b0;
        aso_src0_startofpacket<= 1'b0;
        aso_src0_endofpacket  <= 1'b0;
        aso_src0_empty        <= 2'd0;

    end else begin
        case (state)

            IDLE: begin // data[0]  = mac_dst[47:16];
                if (go_bit) begin
                    if (aso_src0_ready) begin

                        aso_src0_data         <= {4{8'hFF}};
                        aso_src0_valid        <= 1'b1;
                        aso_src0_startofpacket<= 1'b1;
                        aso_src0_endofpacket  <= 1'b0;
                        aso_src0_empty        <= 2'd0;

                        state <= SEND_1;

                    end
                end
            end

            SEND_1: begin // data[1]  = {mac_dst[15:0], mac_src[47:32]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {{2{8'hFF}}, mac_src[47:32]};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_2;

                end
            end

            SEND_2: begin // data[2]  = mac_src[31:0];
                if (aso_src0_ready) begin

                    aso_src0_data         <= mac_src[31:0];
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_3;

                end
            end

            SEND_3:  begin // data[3]  = {MAC_TYPE_ARP, HARDWARE_TYPE};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {MAC_TYPE_ARP, HARDWARE_TYPE};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_4;

                end
            end

            SEND_4: begin // data[4]  = {PROTOCOL_TYPE, {HARDWARE_LEN, PROTOCOL_LEN}};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {PROTOCOL_TYPE, {HARDWARE_LEN, PROTOCOL_LEN}};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_5;

                end
            end

            SEND_5: begin // data[5]  = {OPERATION, MAC_SRC[47:32]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {OPERATION_REQ, mac_src[47:32]};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_6;

                end
            end

            SEND_6: begin // data[6]  = {MAC_SRC[31:0]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= mac_src[31:0];
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_7;

                end
            end

            SEND_7: begin // data[7]  = {IP_SRC[31:0]};;
                if (aso_src0_ready) begin

                    aso_src0_data         <= ip_src[31:0];
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_8;

                end
            end

            SEND_8: begin // data[8]  = {MAC_DST[47:16]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {4{8'h00}};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_9;

                end
            end

            SEND_9: begin // data[9]  =  {MAC_DST[15:0], IP_DST[31:16]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {{2{8'h00}}, ip_dst[31:16]};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    state <= SEND_10;
                end
            end

            SEND_10: begin // data[10]  =  {IP_DST[15:0]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {ip_dst[15:0], {2{8'h00}}};
                    aso_src0_valid        <= 1'b1;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b1;
                    aso_src0_empty        <= 2'd1;

                    state <= SEND_END;

                end
            end

            SEND_END: begin // data[11]  =  {IP_DST[15:0]};
                if (aso_src0_ready) begin

                    aso_src0_data         <= {4{8'h00}};
                    aso_src0_valid        <= 1'b0;
                    aso_src0_startofpacket<= 1'b0;
                    aso_src0_endofpacket  <= 1'b0;
                    aso_src0_empty        <= 2'd0;

                    if (pause_val == 16'd0) begin
                        state <= IDLE;
                    end else begin
                        state <= PAUSE;
                    end

                end
            end

            PAUSE: begin
                if (pause_cnt == pause_val) begin
                    pause_cnt <= 16'd0;
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



//
// slave interface machine
//
assign avs_s0_readdata = (avs_s0_address == 4'h0) ? ({pause_val, {15{1'b0}}, go_bit}) :
                         (avs_s0_address == 4'h1) ? (mac_dst[47:16]) :
                         (avs_s0_address == 4'h2) ? ({{16{1'b0}}, mac_dst[15:0]}) :
                         (avs_s0_address == 4'h3) ? (mac_src[47:16]) :
                         (avs_s0_address == 4'h4) ? ({{16{1'b0}}, mac_src[15:0]}) :
                         (avs_s0_address == 4'h5) ? (ip_src) :
                         (ip_dst);

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if (csi_clock_reset) begin
        go_bit <= 1'b0;
        mac_dst <= 48'd0;
        mac_src <= 48'd0;
        ip_src  <= 16'd0;
        ip_dst  <= 16'd0;
        pause_val <= 16'd0;

    end else if (avs_s0_write) begin

        case (avs_s0_address)
            2'h0: begin
                if(avs_s0_byteenable[0] == 1'b1) begin
                    go_bit <= avs_s0_writedata[0];
                end
                if(avs_s0_byteenable[2] == 1'b1) pause_val[0 +: 8] <= avs_s0_writedata[16 +: 8];
                if(avs_s0_byteenable[3] == 1'b1) pause_val[8 +: 8] <= avs_s0_writedata[24 +: 8];
            end
            4'h1: begin
                if(avs_s0_byteenable[0] == 1'b1) mac_dst[23:16] <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) mac_dst[31:24] <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1) mac_dst[39:32] <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1) mac_dst[47:40] <= avs_s0_writedata[31:24];
            end
            4'h2: begin
                if(avs_s0_byteenable[0] == 1'b1) mac_dst[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) mac_dst[15:8]  <= avs_s0_writedata[15:8];
            end
            4'h3: begin
                if(avs_s0_byteenable[0] == 1'b1) mac_src[23:16] <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) mac_src[31:24] <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1) mac_src[39:32] <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1) mac_src[47:40] <= avs_s0_writedata[31:24];
            end
            4'h4: begin
                if(avs_s0_byteenable[0] == 1'b1) mac_src[7:0]   <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) mac_src[15:8]  <= avs_s0_writedata[15:8];
            end
            4'h5: begin
                if(avs_s0_byteenable[0] == 1'b1) ip_src[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) ip_src[15:8]   <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1) ip_src[23:16]  <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1) ip_src[31:24]  <= avs_s0_writedata[31:24];
            end
            4'h6: begin
                if(avs_s0_byteenable[0] == 1'b1) ip_dst[7:0]    <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1) ip_dst[15:8]   <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1) ip_dst[23:16]  <= avs_s0_writedata[23:16];
                if(avs_s0_byteenable[3] == 1'b1) ip_dst[31:24]  <= avs_s0_writedata[31:24];
            end
            default: ;
        endcase

    end
end


endmodule
