//
// author: Golovachenko Viktor
//
`define FPGA_FIRMWARE_UPDATE  16'h56
`define FPGA_FIRMWARE_GOLDEN  16'hCB

//----------------------------------------
//USER SPI interface
//----------------------------------------
`define FPGA_REG_COUNT        (64)
`define FPGA_REG_DWIDTH       (16) //Data Width
`define FPGA_REG_AWIDTH       (8)  //Address Width

`define FPGA_WR_OFFSET        (0)
`define FPGA_RD_OFFSET        (32)
`define FPGA_REG_TEST_ARRAY_COUNT (4)

// address map spi registers (WR)
`define FPGA_WREG_TEST_ARRAY            (`FPGA_WR_OFFSET + 8) //array(4 x 16bit)


// address map spi registers (RD)
`define FPGA_RREG_FIRMWARE_DATE         (`FPGA_RD_OFFSET + 0) //32bit
`define FPGA_RREG_FIRMWARE_TIME         (`FPGA_RD_OFFSET + 2) //32bit

`define FPGA_RREG_FIRMWARE_TYPE         (`FPGA_RD_OFFSET + 4) //16bit
`define FPGA_RREG_DEVICE_TEMP           (`FPGA_RD_OFFSET + 5) //16bit : device temperature

`define FPGA_RREG_TEST_ARRAY            (`FPGA_RD_OFFSET + 8) //array(4 x 16bit)


//----------------------------------------
//USER JTAG MASTER interface
//----------------------------------------
`define UREG_FIRMWARE_DATE    32'h00
`define UREG_FIRMWARE_TIME    32'h04
`define UREG_CTRL             32'h08
    `define UREG_CTRL_DMA_TX_TEST_START_BIT    0  //
    // assign aurora_control_pwd = reg_ctrl[16];
    // assign gt_rst = reg_ctrl[4];
    // assign aurora_rst = reg_ctrl[5];
    // assign artix_eth_num = reg_ctrl[10:8];
    // assign zynq_eth_num = reg_ctrl[13:12];
    // assign aurora_control_pwd = reg_ctrl[16];

`define UREG_TEST0            32'h0C
`define UREG_TEST1            32'h10

`define UREG_STATUS_AURORA    32'h14
`define UREG_STATUS_ETH       32'h18

`define UREG_CNTERR_ETH0      32'h1C
`define UREG_CNTERR_ETH1      32'h20
`define UREG_CNTERR_ETH2      32'h24
`define UREG_CNTERR_ETH3      32'h28

`define UREG_ETHPHY_MDIO_CLK_O    32'h2C
`define UREG_ETHPHY_MDIO_DATA_O   32'h30
`define UREG_ETHPHY_MDIO_DATA_I   32'h34
`define UREG_ETHPHY_MDIO_DIR_O    32'h38

`define UREG_ETHPHY_RST       32'h3C

`define UREG_AURORA_O_CTL_0   32'h40
`define UREG_AURORA_O_CTL_1   32'h44
`define UREG_AURORA_I_CTL_0   32'h48

`define UREG_ETHPHY_TEST_PRM  32'h4C
    `define UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET    0
    `define UREG_ETHPHY_TEST_PRM_PKT_SIZE_MASK      16'hFFFF
    `define UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET  16
    `define UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_MASK    8'hFF
    `define UREG_ETHPHY_TEST_PRM_PKT_COUNT_OFFSET   24
    `define UREG_ETHPHY_TEST_PRM_PKT_COUNT_MASK     8'hFF

`define UREG_DEVICE_TEMP       32'h50
