//
//author: Romashko Dmitry
//
`timescale 1ns / 1ps
module mac_rgmii_tb(
    output  LINK_UP,
    output reg [7:0] rgmii_rx_data_o = 0,
    output reg rgmii_rx_sof_o = 0,
    output reg rgmii_rx_eof_o = 0,
    output reg rgmii_rx_den_o = 0
);

reg clk = 1;
always #20 clk = ~clk; //25MHz

reg rxc = 1;
always #4 rxc = ~rxc; //125MHz
task tick;
    begin
        @(posedge rxc);#0;
    end
endtask

initial begin
    forever begin
        #100000;
        $display("%d us", $time/1000);
    end
end

reg rx_ctl = 0;
reg [3:0] rxd = 4'hD;


function [31:0] BitReverse;
    input [31:0] in;
    integer i;
    reg [31:0] result;
    begin
        for (i = 0; i < 32; i = i + 1)
            result[i] = in[31-i];
        BitReverse = result;
    end
endfunction

reg [31:0] tx_crc = -1;
wire [31:0] tx_crc_corr = BitReverse(~tx_crc);

function[31:0]  NextCRC;
    input[7:0]      D;
    input[31:0]     C;
    reg[31:0]       NewCRC;
    begin
    NewCRC[0]=C[24]^C[30]^D[1]^D[7];//^D[3]; // add ^D[3] for generate error
    NewCRC[1]=C[25]^C[31]^D[0]^D[6]^C[24]^C[30]^D[1]^D[7];
    NewCRC[2]=C[26]^D[5]^C[25]^C[31]^D[0]^D[6]^C[24]^C[30]^D[1]^D[7];
    NewCRC[3]=C[27]^D[4]^C[26]^D[5]^C[25]^C[31]^D[0]^D[6];
    NewCRC[4]=C[28]^D[3]^C[27]^D[4]^C[26]^D[5]^C[24]^C[30]^D[1]^D[7];
    NewCRC[5]=C[29]^D[2]^C[28]^D[3]^C[27]^D[4]^C[25]^C[31]^D[0]^D[6]^C[24]^C[30]^D[1]^D[7];
    NewCRC[6]=C[30]^D[1]^C[29]^D[2]^C[28]^D[3]^C[26]^D[5]^C[25]^C[31]^D[0]^D[6];
    NewCRC[7]=C[31]^D[0]^C[29]^D[2]^C[27]^D[4]^C[26]^D[5]^C[24]^D[7];
    NewCRC[8]=C[0]^C[28]^D[3]^C[27]^D[4]^C[25]^D[6]^C[24]^D[7];
    NewCRC[9]=C[1]^C[29]^D[2]^C[28]^D[3]^C[26]^D[5]^C[25]^D[6];
    NewCRC[10]=C[2]^C[29]^D[2]^C[27]^D[4]^C[26]^D[5]^C[24]^D[7];
    NewCRC[11]=C[3]^C[28]^D[3]^C[27]^D[4]^C[25]^D[6]^C[24]^D[7];
    NewCRC[12]=C[4]^C[29]^D[2]^C[28]^D[3]^C[26]^D[5]^C[25]^D[6]^C[24]^C[30]^D[1]^D[7];
    NewCRC[13]=C[5]^C[30]^D[1]^C[29]^D[2]^C[27]^D[4]^C[26]^D[5]^C[25]^C[31]^D[0]^D[6];
    NewCRC[14]=C[6]^C[31]^D[0]^C[30]^D[1]^C[28]^D[3]^C[27]^D[4]^C[26]^D[5];
    NewCRC[15]=C[7]^C[31]^D[0]^C[29]^D[2]^C[28]^D[3]^C[27]^D[4];
    NewCRC[16]=C[8]^C[29]^D[2]^C[28]^D[3]^C[24]^D[7];
    NewCRC[17]=C[9]^C[30]^D[1]^C[29]^D[2]^C[25]^D[6];
    NewCRC[18]=C[10]^C[31]^D[0]^C[30]^D[1]^C[26]^D[5];
    NewCRC[19]=C[11]^C[31]^D[0]^C[27]^D[4];
    NewCRC[20]=C[12]^C[28]^D[3];
    NewCRC[21]=C[13]^C[29]^D[2];
    NewCRC[22]=C[14]^C[24]^D[7];
    NewCRC[23]=C[15]^C[25]^D[6]^C[24]^C[30]^D[1]^D[7];
    NewCRC[24]=C[16]^C[26]^D[5]^C[25]^C[31]^D[0]^D[6];
    NewCRC[25]=C[17]^C[27]^D[4]^C[26]^D[5];
    NewCRC[26]=C[18]^C[28]^D[3]^C[27]^D[4]^C[24]^C[30]^D[1]^D[7];
    NewCRC[27]=C[19]^C[29]^D[2]^C[28]^D[3]^C[25]^C[31]^D[0]^D[6];
    NewCRC[28]=C[20]^C[30]^D[1]^C[29]^D[2]^C[26]^D[5];
    NewCRC[29]=C[21]^C[31]^D[0]^C[30]^D[1]^C[27]^D[4];
    NewCRC[30]=C[22]^C[31]^D[0]^C[28]^D[3];
    NewCRC[31]=C[23]^C[29]^D[2];
    NextCRC=NewCRC;
    end
endfunction


task SendByte;
    input [7:0] byte;
    input dbg;
    begin
        @(negedge rxc);
        #2;
        rx_ctl = 1'b1;
        rxd = byte[3:0];
        #4;
        rx_ctl = dbg; //set 1'b0 for generate error
        rxd = byte[7:4];
        tx_crc = NextCRC(byte, tx_crc);
    end
endtask

task SendPreamble;
    begin
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'hD5, 1'b1);
        tx_crc = -1;
    end
endtask

task SendString;
    input [1023:0] str;
    integer i;
    begin
        for (i = 0; i < 128; i = i + 1)
            if (str[(127 - i)*8 +: 8] != 0)
                SendByte(str[(127 - i)*8 +: 8], 1'b1);
    end
endtask

task SendWord;
    input [31:0] word;
    begin
        SendByte(word[24 +: 8], 1'b1);
        SendByte(word[16 +: 8], 1'b1);
        SendByte(word[8  +: 8], 1'b1);
        SendByte(word[0  +: 8], 1'b1);
    end
endtask

task SendMAC;
    input [47:0] mac;
    begin
        SendByte(mac[40 +: 8], 1'b1);
        SendByte(mac[32 +: 8], 1'b1);
        SendByte(mac[24 +: 8], 1'b1);
        SendByte(mac[16 +: 8], 1'b1);
        SendByte(mac[8  +: 8], 1'b1);
        SendByte(mac[0  +: 8], 1'b1);
    end
endtask


task SendCRC;
    input dbg;
    reg [31:0] crc;
    begin
        #0.1;
        crc = tx_crc_corr + dbg;
        SendByte(crc[0  +: 8], 1'b1);
        SendByte(crc[8  +: 8], 1'b1);
        SendByte(crc[16 +: 8], 1'b1);
        SendByte(crc[24 +: 8], 1'b1);
        #4; rx_ctl = 0; $display("MAC_CRC: (%X)", crc); //add vicg
        @(posedge rxc);
        // rx_ctl = 0; //romashko
        rxd = 4'hD;
    end
endtask


task SendTestCRC;
    begin
        SendPreamble();
        SendMAC(48'hFFFF_FFFF_FFFF);
        SendMAC(48'h0102_0304_0506);
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord({8'd192, 8'd168, 8'd1, 8'd204});
        SendWord({8'd192, 8'd168, 8'd1, 8'd104});
        // UDP header
        SendWord({16'd3956, 16'd51112}); // src port, dst port
        SendWord(32'h0000_0000);  // incorrect size!
        // UDP payload
        SendWord(32'h0000_0000);
        SendWord(32'h8300_0000); // packet format = payload, EI
        // block_id64
        SendWord(32'h01020304);
        SendWord(32'h05060708);
        // packet_id32
        SendWord(32'h00000001);
        // payload
        SendByte(8'h11, 1'b1);
        // CRC32
        SendCRC(1'b0);
    end
endtask

task SendARPPacket;
    input [47:0] mac_dst;
    input [47:0] mac_src;
    input [31:0] ip_src;
    input [31:0] ip_tgt;
    begin
        SendPreamble();
        SendMAC(mac_dst);
        SendMAC(mac_src);
        // Ethertype ARP
        SendByte(8'h08, 1'b1);
        SendByte(8'h06, 1'b1);
        // HTYPE 1
        SendByte(8'h00, 1'b1);
        SendByte(8'h01, 1'b1);
        // PTYPE 0x0800
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // HLEN 6
        SendByte(8'h06, 1'b1);
        // PLEN 4
        SendByte(8'h04, 1'b1);
        // OPER 0x0001 (request)
        SendByte(8'h00, 1'b1);
        SendByte(8'h01, 1'b1);
        SendMAC(mac_src); // Sender hardware address
        SendWord(ip_src); // Sender protocol address
        SendMAC(48'h0) ;// Target hardware address
        SendWord(ip_tgt); // Target protocol address
        // 18 bytes padding
        repeat (18) SendByte(8'h00, 1'b1);
        SendCRC(1'b1);
    end
endtask



task SendTestPacket;
    input [47:0] mac_dst;
    input [47:0] mac_src;
    input err;
    integer a;
    begin
        a = 0;
        SendPreamble();
        SendMAC(mac_dst);
        SendMAC(mac_src);
        // Ethertype
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // payload
        // repeat (28) SendByte(8'h00, 1'b1);
        // // zero padding
        // repeat (18) SendByte(8'h00, 1'b1);

        repeat (28+18) begin
            SendByte(a, 1'b1);
            a = a + 1;
        end
        SendCRC(err);
    end
endtask


task SendGVCP_Ack;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord({8'd192, 8'd168, 8'd1, 8'd204});
        SendWord({8'd192, 8'd168, 8'd1, 8'd104});
        // UDP header
        SendWord({16'd3956, 16'd51111}); // src port, dst port
        SendWord(32'h0020_0000);
        // UDP payload
        SendWord(32'h00000001); // READREG_ACK
        SendWord(32'h0004AAAA); // length, request id
        SendWord(32'h00000990); // returned value
        // padding
        SendByte(0, 1'b1);  SendByte(0, 1'b1); SendByte(0, 1'b1);
        SendByte(0, 1'b1);  SendByte(0, 1'b1); SendByte(0, 1'b1);
        SendCRC(1'b0);
    end
endtask


task SendGVSP_ImagePayload;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord({8'd192, 8'd168, 8'd1, 8'd204});
        SendWord({8'd192, 8'd168, 8'd1, 8'd104});
        // UDP header
        SendWord({16'd3956, 16'd51112}); // src port, dst port
        SendWord(32'h0000_0000); // incorrect size
        // UDP payload
        SendWord(32'h0000AABB); // block id
        SendWord(32'h03000001); // packet format = payload, packet_id=1
        SendString("01234567890123456789"); // payload
        SendCRC(1'b0);
    end
endtask


task SendGVSP_ImagePayloadEI;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord({8'd192, 8'd168, 8'd1, 8'd204});
        SendWord({8'd192, 8'd168, 8'd1, 8'd104});
        // UDP header
        SendWord({16'd3956, 16'd51112}); // src port, dst port
        SendWord(32'h0000_0000); // incorrect size
        // UDP payload
        SendWord(32'h0000_0000);
        SendWord(32'h8300_0000);
        // block_id64
        SendWord(32'h0102_0304);
        SendWord(32'h0506_0708);
        // packet_id32
        SendWord(32'h0000_0001);
        SendString("01234567890123456789"); // payload
        SendCRC(1'b0);
    end
endtask


task SendGVSP_ImagePayloadEI_1byte;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord({8'd192, 8'd168, 8'd1, 8'd204});
        SendWord({8'd192, 8'd168, 8'd1, 8'd104});
        // UDP header
        SendWord({16'd3956, 16'd51112}); // src port, dst port
        SendWord(32'h0000_0000); // incorrect size
        // UDP payload
        SendWord(32'h0000_0000);
        SendWord(32'h8300_0000);
        // block_id64
        SendWord(32'h0102_0304);
        SendWord(32'h0506_0708);
        // packet_id32
        SendWord(32'h0000_0001);
        SendString("0"); // payload 1 byte
        SendCRC(1'b0);
    end
endtask



task SendTestUDP;
    input [47:0] mac_dst;
    input [47:0] mac_src;
    input [31:0] ip_dst;
    input [31:0] ip_src;
    input [15:0] udp_port_src;
    input [15:0] udp_port_dst;
    begin
        SendPreamble();
        SendMAC(mac_dst);
        SendMAC(mac_src);
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);
        // IPv4 header
        SendWord(32'h4500_0000);
        SendWord(32'h0000_0000);
        SendWord(32'h0011_0000);
        SendWord(ip_dst);
        SendWord(ip_src);
        // UDP header
        SendWord({udp_port_src, udp_port_dst}); // src port, dst port
        SendWord(32'h0000_0000);  // incorrect size!
        // UDP payload
        SendWord(32'h0000_0000);
        SendWord(32'h8300_0000); // packet format = payload, EI
        // block_id64
        SendWord(32'h01020304);
        SendWord(32'h05060708);
        // packet_id32
        SendWord(32'h00000001);
        // payload
        SendByte(8'h11, 1'b1);
        // CRC32
        SendCRC(1'b0);
    end
endtask


reg uart_rxd = 1;

task SendUARTByte;
    input [7:0] byte;
    reg [7:0] shr;
    begin
        uart_rxd = 0;
        shr = byte;
        #8681;
        repeat (8) begin
            uart_rxd = shr[0];
            shr = shr >> 1;
            #8681;
        end
        uart_rxd = 1;
        #8681;
        // #8681;
    end
endtask


task SendCRC_tt;
    input dbg;
    reg [31:0] crc;
    begin
        #0.1;
        crc = tx_crc_corr + dbg;
        SendByte(8'h44, 1'b1);
        SendByte(8'h21, 1'b1);
        #4; rx_ctl = 0;
        @(posedge rxc);
        // rx_ctl = 0; //romashko
        rxd = 4'hD;
    end
endtask

task SendTestPKT;
    begin
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'h55, 1'b1);
        SendByte(8'hD5, 1'b1);

        SendByte(8'hFF, 1'b1);
        SendByte(8'hFF, 1'b1);
        SendByte(8'hFF, 1'b1);
        SendByte(8'hFF, 1'b1);
        SendByte(8'hFF, 1'b1);
        SendByte(8'hFF, 1'b1);

        SendByte(8'h04, 1'b1);
        SendByte(8'h92, 1'b1);
        SendByte(8'h26, 1'b1);
        SendByte(8'h3E, 1'b1);

        SendByte(8'hB3, 1'b1);
        SendByte(8'h63, 1'b1);
        SendByte(8'h08, 1'b1);
        SendByte(8'h06, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h01, 1'b1);
        SendByte(8'h08, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h06, 1'b1);
        SendByte(8'h04, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h01, 1'b1);

        SendByte(8'h04, 1'b1);
        SendByte(8'h92, 1'b1);
        SendByte(8'h26, 1'b1);
        SendByte(8'h3e, 1'b1);

        SendByte(8'hb3, 1'b1);
        SendByte(8'h63, 1'b1);
        SendByte(8'hc0, 1'b1);
        SendByte(8'ha8, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h11, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'hc0, 1'b1);
        SendByte(8'ha8, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h01, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h00, 1'b1);
        SendByte(8'h00, 1'b1);

        SendByte(8'h69, 1'b1);
        SendByte(8'h9c, 1'b1);
        SendByte(8'h6d, 1'b1);
        SendByte(8'h3b, 1'b1);

        #0.1;
        SendByte(8'h1c, 1'b1);
        SendByte(8'hdf, 1'b1);
        SendByte(8'h44, 1'b1);
        SendByte(8'h21, 1'b1);
        #4; rx_ctl = 0;
        @(posedge rxc);
        // rx_ctl = 0; //romashko
        rxd = 4'hD;
    end
endtask

reg [7:0] usr_tx_tdata = 0;
reg       usr_tx_tvalid = 1'b0;
reg       usr_tx_tlast = 1'b0;
reg rst = 1'b0;

wire pll0_locked;


wire mac_gtx_clk;
wire mac_gtx_clk90;

wire txc;
wire tx_ctl;
wire [3:0] txd;

reg [7:0] mac_tx_tdata = 0;
reg       mac_tx_tvalid = 0;
reg       mac_tx_sof = 0;
reg       mac_tx_eof = 0;
wire       mac_tx_rq;
wire [0:0] mac_tx_ack;
wire [0:0] mac_tx_tuser;
wire       mac_tx_tlast;

wire [7:0] mac_rx_data;
wire       mac_rx_valid;
wire       mac_rx_sof;
wire       mac_rx_eof;
wire       mac_rx_err;

wire [7:0] dbg_rgmii_rx_data;
wire       dbg_rgmii_rx_den;
wire       dbg_rgmii_rx_sof;
wire       dbg_rgmii_rx_eof;

reg start = 0;

wire clk200M;
wire clk125M;
wire clk375M;
wire clk125M_p90;


initial begin
    // $dumpfile("icarus/dump.fst");
    // $dumpvars;

    usr_tx_tdata = 0;
    usr_tx_tvalid = 1'b0;
    usr_tx_tlast = 1'b0;

    start = 1'b0;

    rst = 1'b0;
    #500;
    rst = 1'b1;
    #100;
    rst = 1'b0;

    @(posedge pll0_locked);

    // #6_000;
    // SendARPPacket(48'hFFFF_FFFF_FFFF, 48'hE091_F5B4_06B0, 32'hC0A80101, 32'hC0A80120);
    #1_000;

    SendARPPacket(48'hC0A8_0505_0505, 48'hC0A8_0505_0505, 32'hC0A80507, 32'hC0A80507);
    #1000;
    SendARPPacket(48'hC0A8_0505_0505, 48'hC0A8_0505_0505, 32'hC0A80507, 32'hC0A80507);
    #1000;
    SendARPPacket(48'hC0A8_0505_0505, 48'hC0A8_0505_0505, 32'hC0A80507, 32'hC0A80507);
    #1000;

    // SendTestPacket(48'hFFFF_FFFF_FFFF, 48'hC0A8_0505_0505, 1'b0);
    // #1_000;
    // SendTestPacket(48'hC0A8_0505_0505, 48'h0102_0304_0506, 1'b0);
    // #1_000;
    // SendTestPacket(48'hCCCC_CCCC_CCCC, 48'h0102_0304_0506, 1'b0);
    // #100;
    // SendTestPacket(48'hAAAA_FFFF_BBBB, 48'h0102_0304_0506, 1'b1);
    // #100;

    SendTestUDP(48'hC0A8_0505_0505, 48'h0102_0304_0506, 32'hC0A80507, 32'hC0A80507, 16'h4d2, 16'h4d2);
    #1000;

    @(posedge clk125M);
    start = 1'b1;
    #5_000;
    @(posedge clk125M);
    start = 1'b0;
    #5_000;
    // @(posedge rxc);
    // usr_tx_tdata = 0;
    // usr_tx_tvalid = 1'b1;
    // usr_tx_tlast = 1'b0;
    // repeat (64) begin
    //     @(posedge rxc);
    //     usr_tx_tdata = 0;
    //     usr_tx_tvalid = 1'b1;
    //     usr_tx_tlast = 1'b0;
    // end
    // @(posedge rxc);
    // usr_tx_tvalid = 1'b1;
    // usr_tx_tlast = 1'b1;
    // @(posedge rxc);
    // usr_tx_tvalid = 1'b0;
    // usr_tx_tlast = 1'b0;

    // #30_000;
    // SendGVCP_Ack();
    // #10_000;
    // SendGVSP_ImagePayload();
    // #10_000;
    // SendGVSP_ImagePayloadEI();
    // #10_000;
    // SendGVSP_ImagePayloadEI_1byte();
    // #10_000;

    // $display("\007");
    // $finish;

//    @(posedge clk125M);
//     mac_tx_tdata <= ttt[0];
//     mac_tx_tvalid <= 1'b1;
//     mac_tx_sof <= 1'b0;
//     mac_tx_eof <= 1'b0;

//     @(posedge mac_tx_ack[0]);
//     mac_tx_tdata <= ttt[0];
//     mac_tx_tvalid <= 1'b1;
//     mac_tx_sof <= 1'b1;
//     mac_tx_eof <= 1'b0;

//     for (k=1; k < 53; k++) begin
//         @(posedge clk125M);
//         mac_tx_tdata <= ttt[k];
//         mac_tx_tvalid <= 1'b1;
//         mac_tx_sof <= 1'b0;
//         mac_tx_eof <= 1'b0;

//     @(posedge clk125M);
//     mac_tx_tdata <= ttt[53];
//     mac_tx_tvalid <= 1'b1;
//     mac_tx_sof <= 1'b0;
//     mac_tx_eof <= 1'b1;

//     @(posedge clk125M);
//     mac_tx_tdata <= ttt[53];
//     mac_tx_tvalid <= 1'b0;
//     mac_tx_sof <= 1'b0;
//     mac_tx_eof <= 1'b0;

end


reg [7:0] ucnt = 0;
always @ (posedge clk125M) begin
    if (start & mac_tx_ack[0]) begin
        if (ucnt != 55) begin
            ucnt <= ucnt + 1;
        end

        case (ucnt)
            8'd0 : begin mac_tx_tdata <= 8'hC0; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b1; mac_tx_eof <= 1'b0; end
            8'd1 : begin mac_tx_tdata <= 8'hA8; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd2 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd3 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd4 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd5 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd6 : begin mac_tx_tdata <= 8'hC0; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd7 : begin mac_tx_tdata <= 8'hA8; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd8 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd9 : begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd10: begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd11: begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd12: begin mac_tx_tdata <= 8'h08; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd13: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd14: begin mac_tx_tdata <= 8'h45; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd15: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd16: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd17: begin mac_tx_tdata <= 8'h28; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd18: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd19: begin mac_tx_tdata <= 8'h01; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd20: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd21: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd22: begin mac_tx_tdata <= 8'h80; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd23: begin mac_tx_tdata <= 8'h11; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd24: begin mac_tx_tdata <= 8'hAF; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd25: begin mac_tx_tdata <= 8'h65; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd26: begin mac_tx_tdata <= 8'hC0; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd27: begin mac_tx_tdata <= 8'hA8; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd28: begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd29: begin mac_tx_tdata <= 8'h07; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd30: begin mac_tx_tdata <= 8'hC0; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd31: begin mac_tx_tdata <= 8'hA8; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd32: begin mac_tx_tdata <= 8'h05; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd33: begin mac_tx_tdata <= 8'h07; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd34: begin mac_tx_tdata <= 8'h04; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd35: begin mac_tx_tdata <= 8'hD2; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd36: begin mac_tx_tdata <= 8'h04; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd37: begin mac_tx_tdata <= 8'hD2; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd38: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd39: begin mac_tx_tdata <= 8'h14; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd40: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd41: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd42: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd43: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd44: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd45: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd46: begin mac_tx_tdata <= 8'h01; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd47: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd48: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd49: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd50: begin mac_tx_tdata <= 8'h01; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd51: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd52: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
            8'd53: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b1; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b1; end
            default: begin mac_tx_tdata <= 8'h00; mac_tx_tvalid <= 1'b0; mac_tx_sof <= 1'b0; mac_tx_eof <= 1'b0; end
        endcase
    end
end

clk25_wiz0 pll0(
    .clk_out1(clk200M),//(clk125M),
    .clk_out2(clk125M),//(clk125M_p90),
    .clk_out3(clk375M),
    .clk_out4(clk125M_p90),
    .locked(pll0_locked),
    .clk_in1(clk),
    .reset(rst)
);



// mac_rgmii mac2(
//     .status_o(),
//     // .dbg_mac_rx_fr_good(),
//     // .dbg_fifo_rd(),
//     // .fifo_status(),

//     .phy_rxd   (rxd   ),
//     .phy_rx_ctl(rx_ctl),
//     .phy_rxc   (rxc   ),
//     .phy_txd   (txd   ),
//     .phy_tx_ctl(tx_ctl),
//     .phy_txc   (txc   ),

//     .mac_rx_data_o  (mac_rx_tdata),
//     .mac_rx_valid_o (mac_rx_tvalid),
//     .mac_rx_sof_o   (),
//     .mac_rx_eof_o   (mac_rx_tlast),
//     .mac_rx_ok_o    (),
//     .mac_rx_bd_o    (mac_rx_tuser),
//     .mac_rx_er_o    (),
//     .mac_rx_clk_o   (mac_rx_clk),

//     .mac_tx_tdata (8'd0),
//     .mac_tx_tvalid(1'b0),
//     .mac_tx_sof  (1'b0),
//     .mac_tx_eof  (1'b0),
//     .mac_tx_clk_90(mac_gtx_clk90),
//     .mac_tx_clk  (mac_gtx_clk),

//     .rst(~pll0_locked) //(1'b0) //
// );

CustomGMAC_Wrap  mac(

    .clk375(clk375M),
    .clk125(clk125M),

    .RXC   (rxc   ),
    .RX_CTL(rx_ctl),
    .RXD   (rxd   ),

    .CLK_TX(txc   ),
    .TX_CTL(tx_ctl),
    .TXDATA(txd   ),

    .MODE(),
    .LINK_UP(LINK_UP),

    .DataIn0(mac_tx_tdata),
    .ValIn0(mac_tx_tvalid),
    .SoFIn0(mac_tx_sof),
    .EoFIn0(mac_tx_eof),
    .ReqIn0(start) ,//mac_tx_tvalid),

    .ReqConfirm(mac_tx_ack),

    .dbg_rgmii_rx_data(dbg_rgmii_rx_data),
    .dbg_rgmii_rx_den(dbg_rgmii_rx_den),
    .dbg_rgmii_rx_sof(dbg_rgmii_rx_sof),
    .dbg_rgmii_rx_eof(dbg_rgmii_rx_eof),

    .Remote_MACOut(),//output [47:0]
    .Remote_IP_Out(),//output [31:0]
    .RemotePortOut(),//output [15:0]
    .SOF_OUT(mac_rx_sof),
    .EOF_OUT(mac_rx_eof),
    .ENA_OUT(mac_rx_valid),
    .ERR_OUT(mac_rx_err),
    .DATA_OUT(mac_rx_data),
    .InputCRC_ErrorCounter()//output [31 :0]
);



// test_tx #(
//     .TEST_DATA_WIDTH(8)
// ) test_tx (
//     .mac_tx_tdata (mac_tx_tdata ),
//     .mac_tx_tvalid(mac_tx_tvalid),
//     .mac_tx_sof  (mac_tx_sof  ),
//     .mac_tx_eof  (mac_tx_eof  ),
//     .mac_tx_rq   (mac_tx_rq   ),
//     .mac_tx_ack  (mac_tx_ack[0]),

//     .start(start),
//     .pkt_size(16'd512),
//     .pause_size(16'd128),

//     .clk(clk125M),
//     .rst(rst)
// );


// reg [7:0] rgmii_rx_data = 0;
// reg       rgmii_rx_den = 0;
// reg       rgmii_rx_sof = 0;
// reg       rgmii_rx_eof = 0;

// reg [7:0] sr0_rgmii_rx_data = 0;
// reg [7:0] sr1_rgmii_rx_data = 0;
// reg [7:0] sr2_rgmii_rx_data = 0;
// reg [7:0] sr3_rgmii_rx_data = 0;
// //reg [7:0] rgmii_rx_data_o = 0;

// reg sr0_rgmii_rx_den = 0;
// reg sr1_rgmii_rx_den = 0;
// reg sr2_rgmii_rx_den = 0;
// reg sr3_rgmii_rx_den = 0;
// reg sr4_rgmii_rx_den = 0;
// reg sr5_rgmii_rx_den = 0;
// reg sr6_rgmii_rx_den = 0;
// reg sr7_rgmii_rx_den = 0;
// reg sr8_rgmii_rx_den = 0;
// reg sr9_rgmii_rx_den = 0;
// reg sr10_rgmii_rx_den = 0;
// reg sr11_rgmii_rx_den = 0;
// //reg rgmii_rx_den_o = 0;

// reg sr0_rgmii_rx_sof  = 0;
// reg sr1_rgmii_rx_sof  = 0;
// reg sr2_rgmii_rx_sof  = 0;
// reg sr3_rgmii_rx_sof  = 0;
// reg sr4_rgmii_rx_sof  = 0;
// reg sr5_rgmii_rx_sof  = 0;
// reg sr6_rgmii_rx_sof  = 0;
// reg sr7_rgmii_rx_sof  = 0;
// reg sr8_rgmii_rx_sof  = 0;
// reg sr9_rgmii_rx_sof  = 0;
// reg sr10_rgmii_rx_sof = 0;
// reg sr11_rgmii_rx_sof = 0;

// always @ (posedge clk125M) begin
//     rgmii_rx_data <= dbg_rgmii_rx_data;
//     rgmii_rx_den <= dbg_rgmii_rx_den;
//     rgmii_rx_sof <= dbg_rgmii_rx_sof;
//     rgmii_rx_eof <= dbg_rgmii_rx_eof;

//     sr0_rgmii_rx_data <= rgmii_rx_data;
//     sr1_rgmii_rx_data <= sr0_rgmii_rx_data;
//     sr2_rgmii_rx_data <= sr1_rgmii_rx_data;
//     sr3_rgmii_rx_data <= sr2_rgmii_rx_data;
//     rgmii_rx_data_o <= sr3_rgmii_rx_data;

//     sr0_rgmii_rx_den <= rgmii_rx_den;
//     sr1_rgmii_rx_den <= sr0_rgmii_rx_den;
//     sr2_rgmii_rx_den <= sr1_rgmii_rx_den;
//     sr3_rgmii_rx_den <= sr2_rgmii_rx_den;
//     sr4_rgmii_rx_den <= sr3_rgmii_rx_den;
//     sr5_rgmii_rx_den <= sr4_rgmii_rx_den;
//     sr6_rgmii_rx_den <= sr5_rgmii_rx_den;
//     sr7_rgmii_rx_den <= sr6_rgmii_rx_den;
//     sr8_rgmii_rx_den <= sr7_rgmii_rx_den;
//     sr9_rgmii_rx_den <= sr8_rgmii_rx_den;
//     sr10_rgmii_rx_den <= sr9_rgmii_rx_den;
//     sr11_rgmii_rx_den <= sr10_rgmii_rx_den;
//     rgmii_rx_den_o <= sr11_rgmii_rx_den & rgmii_rx_den;

//     sr0_rgmii_rx_sof <= rgmii_rx_sof;
//     sr1_rgmii_rx_sof <= sr0_rgmii_rx_sof;
//     sr2_rgmii_rx_sof <= sr1_rgmii_rx_sof;
//     sr3_rgmii_rx_sof <= sr2_rgmii_rx_sof;
//     sr4_rgmii_rx_sof <= sr3_rgmii_rx_sof;
//     sr5_rgmii_rx_sof <= sr4_rgmii_rx_sof;
//     sr6_rgmii_rx_sof <= sr5_rgmii_rx_sof;
//     sr7_rgmii_rx_sof <= sr6_rgmii_rx_sof;
//     sr8_rgmii_rx_sof <= sr7_rgmii_rx_sof;
//     sr9_rgmii_rx_sof <= sr8_rgmii_rx_sof;
//     sr10_rgmii_rx_sof <= sr9_rgmii_rx_sof;
//     sr11_rgmii_rx_sof <= sr10_rgmii_rx_sof;
//     rgmii_rx_sof_o <= sr11_rgmii_rx_sof;

//     rgmii_rx_eof_o <= rgmii_rx_eof;
// end

// eth_txfifo eth0_txfifo (
//     .s_axis_tready(),  // output wire s_axis_tready
//     .s_axis_tdata(rgmii_rx_data_o),    // input wire [7 : 0] s_axis_tdata
//     .s_axis_tvalid(rgmii_rx_den_o),  // input wire s_axis_tvalid
//     .s_axis_tuser({rgmii_rx_sof_o}),    // input wire [0 : 0] s_axis_tuser
//     .s_axis_tlast(rgmii_rx_eof_o),    // input wire s_axis_tlast

//     .m_axis_tready(mac_tx_ack[0]),  // input wire m_axis_tready
//     .m_axis_tdata(mac_tx_tdata),    // output wire [7 : 0] m_axis_tdata
//     .m_axis_tvalid(mac_tx_tvalid),  // output wire m_axis_tvalid
//     .m_axis_tuser(mac_tx_tuser),    // output wire [0 : 0] m_axis_tuser
//     .m_axis_tlast(mac_tx_tlast),    // output wire m_axis_tlast

//     .wr_rst_busy(),      // output wire wr_rst_busy
//     .rd_rst_busy(),      // output wire rd_rst_busy
//     .s_aclk(clk125M),                // input wire s_aclk
//     .s_aresetn(LINK_UP)          // input wire s_aresetn
// );

// assign mac_tx_eof = mac_tx_tlast & mac_tx_tvalid & mac_tx_ack[0];
// assign mac_tx_sof = mac_tx_tuser[0] & mac_tx_tvalid & mac_tx_ack[0];

endmodule
