`timescale 1ns / 1ps



module EthCRC32(

	input wire clk,
	input wire [7:0]DataIn, 	//received data nibble from eth phy
	input wire DataValid, 		//received data valid from eth phy
	input wire EndOfPacket, 		//received data valid from eth phy
	input wire StartOfPacket, 		//received data valid from eth phy
	input wire Sync,
	output wire CRCErr,


	output reg DataOutSoF = 0,
	output reg DataOutEoF = 0,
	output reg DataOutValid = 0,
	output reg [7 :0]DataOut = 0,




	output  reg [31:0]crc32 = 0,
	output  reg crc32_Ready = 0

);



reg StartOfPacketD0 = 0;


reg EndOfPacketD0 = 0;
reg EndOfPacketD1 = 0;
reg EndOfPacketD2 = 0;
reg DataValidD0 = 0;



reg [31:0]receiver_reg32=32'b0;
wire [7:0]w_rbyte;
wire [7:0]w_rrbyte;



reg endSync = 0;



always @(posedge clk)
begin





	DataValidD0   <= DataValid;
	EndOfPacketD1 <= EndOfPacketD0;
	EndOfPacketD2<= EndOfPacketD1;
	endSync <= EndOfPacketD1&!EndOfPacketD2;




end



//catch incoming nibles into 32bit reg
//LSB (Least Significant Bit) goes first

always @(posedge clk)

	begin
	if(DataValid) receiver_reg32 <= {  DataIn, receiver_reg32[31:8]};

	if(DataValid) StartOfPacketD0<=StartOfPacket;
	if(DataValid) EndOfPacketD0<=EndOfPacket;


	DataOutSoF <= StartOfPacketD0;
	DataOutEoF <= EndOfPacketD0;
	DataOut <= receiver_reg32[31:24];


	end






assign w_rbyte = receiver_reg32[31:24];

//reverse bits

assign w_rrbyte = {w_rbyte[0],w_rbyte[1],w_rbyte[2],w_rbyte[3],w_rbyte[4],w_rbyte[5],w_rbyte[6],w_rbyte[7]};




reg [31:0]crc32_=32'hFFFFFFFF;

always @(posedge clk)
	if (endSync ||  Sync) crc32_ <= 32'hFFFFFFFF;
	else if(DataValidD0)
	begin
		crc32_ <= nextCRC32_D8( w_rrbyte , crc32_ );
	end





//reverse bits of CRC32
integer i;
always @*
begin
	for ( i=0; i < 32; i=i+1 )
		//crc32[i] = ~crc32_[i];
		crc32[i] =  ~crc32_[31-i];



end






reg [31:0]crc32_0 = 0;
reg [31:0]crc32_1 = 0;
reg [31:0]crc32_2 = 0;
reg [31:0]crc32_3 = 0;

reg TestCRCA = 0;
reg TestCRCB = 0;
reg TestCRCC = 0;
reg TestCRCD = 0;

reg [31:0]crc32OutSerial;
reg [3 :0]crc32OutSerialValid;


always @(posedge clk)
begin


		if(DataValidD0)crc32_3 <= crc32_2;
		if(DataValidD0)crc32_2 <= crc32_1;
		if(DataValidD0)crc32_1 <= crc32_0;
		if(DataValidD0)crc32_0 <= crc32;

		/////////

		if(DataValidD0) TestCRCA<=(w_rbyte==crc32  [7:0] );
		if(DataValidD0) TestCRCB<=(w_rbyte==crc32_0[15:8 ] )&&TestCRCA;
		if(DataValidD0) TestCRCC<=(w_rbyte==crc32_1[23:16] )&&TestCRCB;
		if(DataValidD0) TestCRCD<=!((w_rbyte==crc32_2[31:24] )&&TestCRCC);



  DataOutValid<=DataValidD0;
  crc32_Ready <= EndOfPacketD0&~EndOfPacketD1;

end

assign CRCErr = TestCRCD;







  // polynomial: (0 1 2 4 5 7 8 10 11 12 16 22 23 26 32)
  // data width: 8
  // convention: the first serial bit is D[7]
  function [31:0] nextCRC32_D8;

    input [7:0] Data;
    input [31:0] crc;
    reg [7:0] d;
    reg [31:0] c;
    reg [31:0] newcrc;
  begin
    d = Data;
    c = crc;

    newcrc[0] = d[6] ^ d[0] ^ c[24] ^ c[30];
    newcrc[1] = d[7] ^ d[6] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[30] ^ c[31];
    newcrc[2] = d[7] ^ d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31];
    newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[27] ^ c[31];
    newcrc[4] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30];
    newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
    newcrc[6] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
    newcrc[7] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];
    newcrc[8] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
    newcrc[9] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29];
    newcrc[10] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29];
    newcrc[11] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
    newcrc[12] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30];
    newcrc[13] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31];
    newcrc[14] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31];
    newcrc[15] = d[7] ^ d[5] ^ d[4] ^ d[3] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31];
    newcrc[16] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[24] ^ c[28] ^ c[29];
    newcrc[17] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[25] ^ c[29] ^ c[30];
    newcrc[18] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[26] ^ c[30] ^ c[31];
    newcrc[19] = d[7] ^ d[3] ^ c[11] ^ c[27] ^ c[31];
    newcrc[20] = d[4] ^ c[12] ^ c[28];
    newcrc[21] = d[5] ^ c[13] ^ c[29];
    newcrc[22] = d[0] ^ c[14] ^ c[24];
    newcrc[23] = d[6] ^ d[1] ^ d[0] ^ c[15] ^ c[24] ^ c[25] ^ c[30];
    newcrc[24] = d[7] ^ d[2] ^ d[1] ^ c[16] ^ c[25] ^ c[26] ^ c[31];
    newcrc[25] = d[3] ^ d[2] ^ c[17] ^ c[26] ^ c[27];
    newcrc[26] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30];
    newcrc[27] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31];
    newcrc[28] = d[6] ^ d[5] ^ d[2] ^ c[20] ^ c[26] ^ c[29] ^ c[30];
    newcrc[29] = d[7] ^ d[6] ^ d[3] ^ c[21] ^ c[27] ^ c[30] ^ c[31];
    newcrc[30] = d[7] ^ d[4] ^ c[22] ^ c[28] ^ c[31];
    newcrc[31] = d[5] ^ c[23] ^ c[29];
    nextCRC32_D8 = newcrc;
  end
  endfunction

endmodule
