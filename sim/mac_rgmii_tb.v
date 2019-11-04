`timescale 1ns / 1ps
module mac_rgmii_tb();

reg sysclk_p = 1;
always #2.5 sysclk_p = ~sysclk_p;
wire sysclk_n = ~sysclk_p;

reg rxc = 1;
always #4 rxc = ~rxc;
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
    NewCRC[0]=C[24]^C[30]^D[1]^D[7];
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
    begin
        @(negedge rxc);
        #2;
        rx_ctl = 1;
        rxd = byte[3:0];
        #4;
        rxd = byte[7:4];
        tx_crc = NextCRC(byte, tx_crc);
    end
endtask

task SendPreamble;
    begin
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'h55);
        SendByte(8'hD5);
        tx_crc = -1;
    end
endtask

task SendString;
    input [1023:0] str;
    integer i;
    begin
        for (i = 0; i < 128; i = i + 1)
            if (str[(127 - i)*8 +: 8] != 0)
                SendByte(str[(127 - i)*8 +: 8]);
    end
endtask

task SendWord;
    input [31:0] word;
    begin
        SendByte(word[24 +: 8]);
        SendByte(word[16 +: 8]);
        SendByte(word[8  +: 8]);
        SendByte(word[0  +: 8]);
    end
endtask

task SendMAC;
    input [47:0] mac;
    begin
        SendByte(mac[40 +: 8]);
        SendByte(mac[32 +: 8]);
        SendByte(mac[24 +: 8]);
        SendByte(mac[16 +: 8]);
        SendByte(mac[8  +: 8]);
        SendByte(mac[0  +: 8]);
    end
endtask


task SendCRC;
    reg [31:0] crc;
    begin
        #0.1;
        crc = tx_crc_corr;
        SendByte(crc[0  +: 8]);
        SendByte(crc[8  +: 8]);
        SendByte(crc[16 +: 8]);
        SendByte(crc[24 +: 8]);
        @(posedge rxc);
        rx_ctl = 0;
        rxd = 4'hD;
    end
endtask


task SendTestCRC;
    begin
        SendPreamble();
        SendMAC(48'hFFFF_FFFF_FFFF);
        SendMAC(48'h0102_0304_0506);
        SendByte(8'h08);
        SendByte(8'h00);
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
        SendByte(8'h11);
        // CRC32
        SendCRC();
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
        SendByte(8'h08);
        SendByte(8'h06);
        // HTYPE 1
        SendByte(8'h00);
        SendByte(8'h01);
        // PTYPE 0x0800
        SendByte(8'h08);
        SendByte(8'h00);
        // HLEN 6
        SendByte(8'h06);
        // PLEN 4
        SendByte(8'h04);
        // OPER 0x0001 (request)
        SendByte(8'h00);
        SendByte(8'h01);
        SendMAC(mac_src); // Sender hardware address
        SendWord(ip_src); // Sender protocol address
        SendMAC(48'h0) ;// Target hardware address
        SendWord(ip_tgt); // Target protocol address
        // 18 bytes padding
        repeat (18) SendByte(8'h00);
        SendCRC();
    end
endtask



task SendTestPacket;
    input [47:0] mac_dst;
    input [47:0] mac_src;
    begin
        SendPreamble();
        SendMAC(mac_dst);
        SendMAC(mac_src);
        // Ethertype
        SendByte(8'h08);
        SendByte(8'h00);
        // payload
        repeat (28) SendByte(8'h00);
        // zero padding
        repeat (18) SendByte(8'h00);
        SendCRC();
    end
endtask


task SendGVCP_Ack;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08);
        SendByte(8'h00);
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
        SendByte(0);  SendByte(0); SendByte(0);
        SendByte(0);  SendByte(0); SendByte(0);
        SendCRC();
    end
endtask


task SendGVSP_ImagePayload;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08);
        SendByte(8'h00);
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
        SendCRC();
    end
endtask


task SendGVSP_ImagePayloadEI;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08);
        SendByte(8'h00);
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
        SendCRC();
    end
endtask


task SendGVSP_ImagePayloadEI_1byte;
    begin
        SendPreamble();
        SendMAC(48'h0012_3456_7890);
        SendMAC(48'h001D_BA17_1DE7);
        // Ethertype
        SendByte(8'h08);
        SendByte(8'h00);
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
        SendCRC();
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


initial begin
    $dumpfile("icarus/dump.fst");
    $dumpvars;
    // $dumpvars(0, mac_top.udp_gvcp.rx_payload_buffer_byteA[0]);
    // $dumpvars(0, mac_top.udp_gvcp.rx_payload_buffer_byteB[0]);
    // $dumpvars(0, mac_top.udp_gvcp.rx_payload_buffer_byteC[0]);
    // $dumpvars(0, mac_top.udp_gvcp.rx_payload_buffer_byteD[0]);

    #2_000;
    SendARPPacket(48'hFFFF_FFFF_FFFF, 48'hE091_F5B4_06B0, 32'hC0A80101, 32'hC0A80120);
    #1_000;

    SendTestPacket(48'hFFFF_FFFF_FFFF, 48'h0102_0304_0506);
    #1_000;
    SendGVCP_Ack();
    #100;


    // SendUARTByte(8'h0A);
    // SendUARTByte(8'h15);
    // SendUARTByte(8'h80);
    // SendUARTByte(8'h90);

    // SendUARTByte(8'h0C);
    // SendUARTByte(8'h80);
    // SendUARTByte(8'h98);

    // SendUARTByte(8'hD0);
    // SendUARTByte(8'hD1);
    // SendUARTByte(8'hD2);
    // SendUARTByte(8'hD3);

    #30_000;
    SendGVCP_Ack();
    #10_000;
    SendGVSP_ImagePayload();
    #10_000;
    SendGVSP_ImagePayloadEI();
    #10_000;
    SendGVSP_ImagePayloadEI_1byte();
    #10_000;

    $display("\007");
    $finish;
end

wire txc;
wire tx_ctl;
wire [3:0] txd;

mac_rgmii mac(
    .eth_status_o(),

    .phy_rxd   (rxd   ),
    .phy_rx_ctl(rx_ctl),
    .phy_rxc   (rxc   ),

    .mac_rx_data_o (),
    .mac_rx_valid_o(),
    .mac_rx_sof_o  (),
    .mac_rx_eof_o  (),
    .mac_rx_clk_o  (),

    .phy_txd   (txd   ),
    .phy_tx_ctl(tx_ctl),
    .phy_txc   (txc   ),

    .mac_tx_data (8'd0),
    .mac_tx_valid(1'b0),
    .mac_tx_sof  (1'b0),
    .mac_tx_eof  (1'b0),
    .mac_tx_clk_90(1'b0),
    .mac_tx_clk  (1'b0)
);

endmodule
