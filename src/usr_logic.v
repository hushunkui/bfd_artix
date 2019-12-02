//
// author: Golovachenko Viktor
//

`include "fpga_reg.v"

module usr_logic #(
    parameter SIM = 0
) (
    output [0:0] test_gpio,
    output reg [31:0] reg_ctrl = 0,

//AXI interface
    input  [31:0]  s_axi_awaddr ,
    input  [2:0]   s_axi_awprot ,
    output         s_axi_awready,
    input          s_axi_awvalid,
    input  [31:0]  s_axi_wdata  ,
    input  [3:0]   s_axi_wstrb  ,
    input          s_axi_wvalid ,
    output         s_axi_wready ,
    output [1:0]   s_axi_bresp  ,
    output         s_axi_bvalid ,
    input          s_axi_bready ,

    input  [31:0]  s_axi_araddr ,
    input  [2:0]   s_axi_arprot ,
    output         s_axi_arready,
    input          s_axi_arvalid,
    output [31:0]  s_axi_rdata  ,
    output         s_axi_rvalid ,
    output [1:0]   s_axi_rresp  ,
    input          s_axi_rready ,

    input s_axi_resetn,
    input s_axi_clk
);

localparam USER_ADR_WIDTH = 4;
localparam ADDR_LSB = 2;
localparam ADDR_MSB = ADDR_LSB + USER_ADR_WIDTH;

wire [ADDR_MSB:0] reg_addr ;
wire [31:0] reg_addr_;
wire [31:0] reg_wdata;
reg  [31:0] reg_rdata = 32'h0;
wire        reg_wr;
wire        reg_rd;

wire [31:0] firmware_date;
wire [31:0] firmware_time;

reg [31:0] reg_test0 = 32'h0;
reg [31:0] reg_test1 = 32'h0;


//----------------------------------------
//AXI interface
//----------------------------------------
axi4lite_ctrl m_axi4lite (
//user part
    .reg_addr      (reg_addr_ ),
    .reg_wdata     (reg_wdata),
    .reg_wr        (reg_wr   ),
    .reg_rdata     (reg_rdata),
    .reg_rd        (reg_rd   ),

//AXI interface
    .s_axi_awaddr  (s_axi_awaddr ),
    .s_axi_awprot  (s_axi_awprot ),
    .s_axi_awready (s_axi_awready),
    .s_axi_awvalid (s_axi_awvalid),
    .s_axi_wdata   (s_axi_wdata  ),
    .s_axi_wstrb   (s_axi_wstrb  ),
    .s_axi_wvalid  (s_axi_wvalid ),
    .s_axi_wready  (s_axi_wready ),
    .s_axi_bresp   (s_axi_bresp  ),
    .s_axi_bvalid  (s_axi_bvalid ),
    .s_axi_bready  (s_axi_bready ),

    .s_axi_araddr  (s_axi_araddr ),
    .s_axi_arprot  (s_axi_arprot ),
    .s_axi_arready (s_axi_arready),
    .s_axi_arvalid (s_axi_arvalid),
    .s_axi_rdata   (s_axi_rdata  ),
    .s_axi_rvalid  (s_axi_rvalid ),
    .s_axi_rresp   (s_axi_rresp  ),
    .s_axi_rready  (s_axi_rready ),

    .s_axi_resetn  (s_axi_resetn),
    .s_axi_clk     (s_axi_clk)
);

assign reg_addr = reg_addr_[ADDR_MSB:0];

//user reg write
always @(posedge s_axi_clk) begin
    if (!s_axi_resetn) begin
        reg_ctrl <= 0;
        reg_test0 <= 0;
        reg_test1 <= 0;
    end else begin
        if (reg_wr) begin
            if (reg_addr == `UREG_CTRL)  begin reg_ctrl <= reg_wdata; end
            if (reg_addr == `UREG_TEST0) begin reg_test0 <= reg_wdata; end
            if (reg_addr == `UREG_TEST1) begin reg_test1 <= reg_wdata; end
        end
    end
end

//user reg read
always @(posedge s_axi_clk) begin
    if (reg_rd) begin
        if (reg_addr == `UREG_FIRMWARE_DATE) begin reg_rdata <= firmware_date; end
        if (reg_addr == `UREG_FIRMWARE_TIME) begin reg_rdata <= firmware_time; end
        if (reg_addr == `UREG_CTRL )         begin reg_rdata <= reg_ctrl; end
        if (reg_addr == `UREG_TEST0)         begin reg_rdata <= reg_test0; end
        if (reg_addr == `UREG_TEST1)         begin reg_rdata <= reg_test1; end
    end
end


firmware_rev m_firmware_rev (
   .firmware_date (firmware_date),
   .firmware_time (firmware_time)
);


//----------------------------------------
//user logic
//----------------------------------------

assign test_gpio[0] = reg_test0[0];


endmodule
