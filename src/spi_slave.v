//-----------------------------------------------------------------------
// Engineer    : Golovachenko Victor
//
// Create Date : 07.07.2018 9:41:31
// Module Name : spi_slave
//
// Description :
// Request write to user register:
// SPI_MOSI bit:  |23.....16|15..          ...0|
//                |msb   lsb|msb            lsb|
//                ------------------------------
//                |  RegAdr |   RegData        |
//                ------------------------------
// SPI_MISO bit:  |          don`t care        |
//                ------------------------------
//
// Request read from user register:
// SPI_MOSI bit:  |23.....16|15..          ...0|
//                |msb   lsb|msb            lsb|
//                ------------------------------
//                |  RegAdr |   don`t care     |
//                ------------------------------
// SPI_MISO bit:  |         |   RegData        |
//                ------------------------------
//
// SPI MODE = 3 (CPOL = 1, CPHA = 1)
// CPOL=1 - the base value of the clock is one (inversion of CPOL=0), i.e.
//          the active state is 0 and idle state is 1.
// CPHA=1 - data are captured on clock's rising edge and data is output on a falling edge.
//-----------------------------------------------------------------------
module spi_slave #(
    parameter RD_OFFSET = 8'd32,
    parameter REG_RD_DATA_WIDTH = 128
)(
    //SPI port
    input  spi_cs_i  ,
    input  spi_clk_i ,
    input  spi_mosi_i,
    output spi_miso_o,

    //User IF
    input [(REG_RD_DATA_WIDTH - 1):0] reg_rd_data,
    output reg [7:0]  reg_wr_addr = 0,
    output reg [15:0] reg_wr_data = 0,
    output reg        reg_wr_en = 0,
    input             reg_clk,
    input             rst
);

// -------------------------------------------------------------------------
localparam CI_SPI_WIDTH = 24;
localparam CI_AWIDTH = 6'd8;


`ifdef SIM_FSM
    enum int unsigned {
        S_IDLE   ,
        S_RCV_ADR,
        S_M2S    ,
        S_M2S_END,
        S_CHK_ADR
    } fsm_cs = S_IDLE;
`else
    localparam S_IDLE    = 0;
    localparam S_RCV_ADR = 1;
    localparam S_M2S     = 2;
    localparam S_M2S_END = 3;
    localparam S_CHK_ADR = 5;
    reg [2:0] fsm_cs = S_IDLE;
`endif

reg [2:0] sr_spi_cs = 3'h7;
reg [2:0] sr_spi_mosi = 0;
reg [2:0] sr_spi_ck = 0;

wire spi_mosi;
reg spi_cs = 1'b1;

(* keep *) reg spi_ck_rising_edge = 1'b0;
(* keep *) reg spi_ck_faling_edge = 1'b0;
(* keep *) reg spi_cs_rising_edge = 1'b0;

reg [(CI_SPI_WIDTH - 1):0] sr_mosi = 0;
reg [15:0] sr_miso = 0;
reg [5:0] cntb = 0; //bit cnt
reg read_en = 1'b0;


//oversample
always @ (posedge reg_clk) begin
    sr_spi_cs <= {sr_spi_cs[1:0], spi_cs_i};
    sr_spi_ck <= {sr_spi_ck[1:0], spi_clk_i};
    sr_spi_mosi <= {sr_spi_mosi[1:0], spi_mosi_i};
end

assign spi_mosi = sr_spi_mosi[2];

always @ (posedge reg_clk) begin
    spi_ck_rising_edge <= (~sr_spi_ck[2]) &   sr_spi_ck[1] ;
    spi_ck_faling_edge <=   sr_spi_ck[2]  & (~sr_spi_ck[1]);
    spi_cs_rising_edge <= (~sr_spi_cs[2]) &   sr_spi_cs[1] ;
    spi_cs <= sr_spi_cs[2];
end

//FSM
always @(posedge reg_clk) begin
    reg_wr_en <= 1'b0;

    if (!spi_cs) begin
        case (fsm_cs)
            S_IDLE : begin
                fsm_cs <= S_RCV_ADR;
            end

            S_RCV_ADR : begin
                if (spi_ck_rising_edge) begin
                    // if (cntb == (CI_AWIDTH)) begin //SPI MODE = 3
                    if (cntb == (CI_AWIDTH-1)) begin //SPI MODE = 0
                        fsm_cs <= S_CHK_ADR;
                    end
                end
            end

            S_CHK_ADR : begin
                if (sr_mosi[7:0] >= RD_OFFSET) begin
                    read_en <= 1'b1; //Detect range of read address
                                     //Can send rxdata to master
                end
                fsm_cs <= S_M2S;
            end

            S_M2S : begin
                if (spi_ck_rising_edge) begin
                    // if (cntb == (CI_SPI_WIDTH)) begin //SPI MODE = 3
                    if (cntb == (CI_SPI_WIDTH-1)) begin //SPI MODE = 0
                        fsm_cs <= S_M2S_END;
                    end
                end
            end

            S_M2S_END : begin
                if (spi_cs_rising_edge) begin
                    reg_wr_addr <= sr_mosi[23:16];
                    reg_wr_data <= sr_mosi[15:0];
                    reg_wr_en <= ~read_en;
                    read_en <= 1'b0;
                    fsm_cs <= S_IDLE; //Go to next packet
                end
            end

        endcase

    end else begin
        fsm_cs <= S_IDLE; read_en <= 1'b0;
    end
end

//Shift reg MISO (Send to Master)
always @(posedge reg_clk) begin
    if (!spi_cs) begin
        if (spi_ck_faling_edge) begin
            // if (read_en && (cntb == (CI_AWIDTH))) begin //SPI MODE = 3
            if (read_en && (cntb == (CI_AWIDTH-1))) begin //SPI MODE = 0
                //Update read data
                sr_miso <= reg_rd_data[(sr_mosi[7:0] * 16) +: 16];
            end else begin
                sr_miso <= {sr_miso[14:0], 1'b0}; //send MSB first
            end
        end
    end
end
assign spi_miso_o = sr_miso[15];

//Shift reg MOSI
always @(posedge reg_clk) begin
    if (!spi_cs) begin
        if (spi_ck_rising_edge) begin
            sr_mosi <= {sr_mosi[23:0], spi_mosi}; //recieve MSB first
        end
    end else begin
        sr_mosi <= 0;
    end
end

//Bit cnt
always @(posedge reg_clk) begin
    if (!spi_cs) begin
        if (spi_ck_faling_edge) begin
            cntb <= cntb + 1'b1;
        end
    end else begin
        cntb <= 0;
    end
end

endmodule