//
// author: Golovachenko Viktor
//

module axi4lite_ctrl (
//user part
    output  [31:0] reg_addr  ,
    output  [31:0] reg_wdata ,
    output         reg_wr    ,
    input   [31:0] reg_rdata ,
    output         reg_rd    ,

//AXI interface
    input  [31:0] s_axi_awaddr  ,
    input  [2:0]  s_axi_awprot  ,
    output        s_axi_awready ,
    input         s_axi_awvalid ,
    input  [31:0] s_axi_wdata   ,
    input  [3:0]  s_axi_wstrb   ,
    input         s_axi_wvalid  ,
    output        s_axi_wready  ,
    output [1:0]  s_axi_bresp   ,
    output        s_axi_bvalid  ,
    input         s_axi_bready  ,

    input  [31:0] s_axi_araddr  ,
    input  [2:0]  s_axi_arprot  ,
    output        s_axi_arready ,
    input         s_axi_arvalid ,
    output [31:0] s_axi_rdata   ,
    output        s_axi_rvalid  ,
    output [1:0]  s_axi_rresp   ,
    input         s_axi_rready  ,

    input s_axi_resetn,
    input s_axi_clk
);


reg        axi_awready = 1'b0;
reg [31:0] axi_awaddr = 0;
reg        axi_wready = 1'b0;
reg        axi_bvalid = 1'b0;
reg [1:0]  axi_bresp = 0;

reg        axi_arready = 1'b0;
reg [31:0] axi_araddr = 0;
reg [31:0] axi_rdata = 0;
reg [1:0]  axi_rresp = 0;
reg        axi_rvalid = 1'b0;

wire reg_rd_int;


//----------------------------------------
//AXI interface
//----------------------------------------
//axi write
always @(posedge s_axi_clk) begin
    if (!s_axi_resetn) begin
        axi_awready <= 1'b0;
        axi_wready <= 1'b0;
        axi_bvalid <= 1'b0;
        axi_awaddr <= 0;
    end else begin
        if ((!axi_awready) && (s_axi_awvalid) && (s_axi_wvalid)) begin
            axi_awready <= 1'b1;
            axi_awaddr <= s_axi_awaddr;
            axi_wready <= 1'b1;
        end else begin
            axi_awready <= 1'b0;
            axi_wready <= 1'b0;
        end

        if ((axi_awready) && (s_axi_awvalid) && (s_axi_wvalid) && (!axi_bvalid)) begin
            axi_bvalid <= 1'b1;
            axi_bresp  <= 0; //'OKAY' response
        end else begin
            if ((axi_bvalid) && (s_axi_bready)) begin
                axi_bvalid <= 1'b0;
            end
        end
    end
end

assign s_axi_awready = axi_awready;
assign s_axi_wready  = axi_wready;
assign s_axi_bresp   = axi_bresp;
assign s_axi_bvalid  = axi_bvalid;

//axi read
always @(posedge s_axi_clk) begin
    if (!s_axi_resetn) begin
        axi_arready <= 1'b0;
        axi_rvalid <= 1'b0;
        axi_araddr <= 0;
    end else begin
        if ((!axi_arready) && (s_axi_arvalid)) begin
            axi_arready <= 1'b1;
            axi_araddr  <= s_axi_araddr;
        end else begin
            axi_arready <= 1'b0;
        end

        if ((axi_arready) && (s_axi_arvalid) && (!axi_rvalid)) begin
            axi_rvalid <= 1'b1;
            axi_rresp  <= 0; //'OKAY' response
        end else begin
            if ((axi_rvalid) && (s_axi_rready)) begin
                axi_rvalid <= 1'b0;
            end
        end
    end
end

assign s_axi_arready = axi_arready;
assign s_axi_rdata   = reg_rdata;
assign s_axi_rresp   = axi_rresp;
assign s_axi_rvalid  = axi_rvalid;


assign reg_addr = (reg_rd_int) ? axi_araddr : axi_awaddr;
assign reg_wdata = s_axi_wdata;
assign reg_wr = (axi_wready & s_axi_wvalid & axi_awready & s_axi_awvalid & |s_axi_wstrb);
assign reg_rd = reg_rd_int;
assign reg_rd_int = (axi_arready & s_axi_arvalid & ~axi_rvalid);


endmodule
