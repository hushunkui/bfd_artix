/* ������ �������� ������ ����� ������ Ethernrt. ���� ������� ������ ������������� clk125
��� ���������� ����� 1gbit ���������� Ethernet  ���������� ���� ������ RXC =125 ���, ����� ������� �� ���������
25 ��� (100 MBit ) ��� 2.5 ��� (10 ����). ������� ��������� �������� ������� ������������� � ������������� �����
������� ����� � ������� ����������.
*/
module EthLinkAnalyser200
(
	input clk200,
	input clkRXC,
	output LINK_UP
);

	reg [3:0] State=1'b0;
	reg Start=1'b0;
	reg ACLR=1'b0;
	reg Compare=1'b0;
	reg CompareD=1'b0;
	reg [3:0] REG200=1'b0;
	reg [3:0] REGRXC=1'b0;
	reg [4:0] Result=1'b0;
	reg LinkUp=1'b0;

always @ (posedge clk200)
begin
State<=State+1'b1;
if (State >4'b01010)Start<=1'b0; else Start<=1'b1;
if (State==4'b01101)Compare<=1'b1; else Compare<=1'b0;
if (State==4'b01110)ACLR <=1'b1; else ACLR <=1'b0;
CompareD<=Compare;
if (Compare)Result<=REG200-REGRXC;
if (CompareD)
	begin
		if((Result<=5'b00111))LinkUp<=1'b1; else LinkUp<=1'b0;
	end
end

always @ (posedge clk200 or posedge ACLR)
begin
if (ACLR) REG200<=1'b0;
	else if (Start) REG200<=REG200+1'b1;
end


always @ (posedge clkRXC or posedge ACLR)
begin
if (ACLR) REGRXC<=1'b0;
	else if (Start) REGRXC<=REGRXC+1'b1;
end

	assign LINK_UP = LinkUp;

endmodule
