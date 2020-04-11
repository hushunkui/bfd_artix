#ifndef __FPGA_REG_H__
#define __FPGA_REG_H__
//
// author: Golovachenko Viktor
//
#define FPGA_FIRMWARE_UPDATE  0x56
#define FPGA_FIRMWARE_GOLDEN  0xCB

//----------------------------------------
//USER SPI interface
//----------------------------------------
#define FPGA_REG_COUNT        (64)
#define FPGA_REG_DWIDTH       (16) //Data Width
#define FPGA_REG_AWIDTH       (8)  //Address Width

#define FPGA_WR_OFFSET        (0)
#define FPGA_RD_OFFSET        (32)
#define FPGA_REG_TEST_ARRAY_COUNT (2)

// address map spi registers (WR)
#define FPGA_WREG_TEST_ARRAY            (FPGA_WR_OFFSET + 0) //array(2 x 16bit)
#define FPGA_WREG_ETHPHY_RST            (FPGA_WR_OFFSET + 3) //16bit
    #define FPGA_WREG_ETHPHY_RST_PHY0_BIT            (0)
    #define FPGA_WREG_ETHPHY_RST_PHY1_BIT            (1)
    #define FPGA_WREG_ETHPHY_RST_PHY2_BIT            (2)
    #define FPGA_WREG_ETHPHY_RST_PHY3_BIT            (3)
#define FPGA_WREG_ETHPHY_MDIO_CLK_O     (FPGA_WR_OFFSET + 4) //16bit - valid bit(0)
#define FPGA_WREG_ETHPHY_MDIO_DATA_O    (FPGA_WR_OFFSET + 5) //16bit - valid bit(0)
#define FPGA_WREG_ETHPHY_MDIO_DIR_O     (FPGA_WR_OFFSET + 6) //16bit - valid bit(0)

// address map spi registers (RD)
#define FPGA_RREG_FIRMWARE_DATE         (FPGA_RD_OFFSET + 0) //32bit
#define FPGA_RREG_FIRMWARE_TIME         (FPGA_RD_OFFSET + 2) //32bit
#define FPGA_RREG_FIRMWARE_TYPE         (FPGA_RD_OFFSET + 4) //16bit
#define FPGA_RREG_DEVICE_TEMP           (FPGA_RD_OFFSET + 5) //16bit : device temperature
#define FPGA_RREG_TEST_ARRAY            (FPGA_RD_OFFSET + 7) //array(2 x 16bit)
#define FPGA_RREG_MAC_LINK              (FPGA_RD_OFFSET + 9) //16bit
    #define FPGA_RREG_MAC_LINK_ETH0_BIT              (0) //
    #define FPGA_RREG_MAC_LINK_ETH1_BIT              (1) //
    #define FPGA_RREG_MAC_LINK_ETH2_BIT              (2) //
    #define FPGA_RREG_MAC_LINK_ETH3_BIT              (3) //
#define FPGA_RREG_MAC0_RXERR            (FPGA_RD_OFFSET + 10) //32bit
#define FPGA_RREG_MAC1_RXERR            (FPGA_RD_OFFSET + 12) //32bit
#define FPGA_RREG_MAC2_RXERR            (FPGA_RD_OFFSET + 14) //32bit
#define FPGA_RREG_MAC3_RXERR            (FPGA_RD_OFFSET + 16) //32bit
#define FPGA_RREG_ETHPHY_RST            (FPGA_RD_OFFSET + 18) //16bit
    #define FPGA_RREG_ETHPHY_RST_PHY0_BIT            (0)
    #define FPGA_RREG_ETHPHY_RST_PHY1_BIT            (1)
    #define FPGA_RREG_ETHPHY_RST_PHY2_BIT            (2)
    #define FPGA_RREG_ETHPHY_RST_PHY3_BIT            (3)
#define FPGA_RREG_ETHPHY_MDIO_CLK_O     (FPGA_RD_OFFSET + 19) //16bit - valid bit(0)
#define FPGA_RREG_ETHPHY_MDIO_DATA_O    (FPGA_RD_OFFSET + 20) //16bit - valid bit(0)
#define FPGA_RREG_ETHPHY_MDIO_DIR_O     (FPGA_RD_OFFSET + 21) //16bit - valid bit(0)
#define FPGA_RREG_ETHPHY_MDIO_DATA_I    (FPGA_RD_OFFSET + 22) //16bit
#define FPGA_RREG_AURORA_STATUS         (FPGA_RD_OFFSET + 23) //16bit
    #define FPGA_RREG_AURORA_CHANNEL_UP_BIT          (0)


//----------------------------------------
//USER JTAG MASTER interface
//----------------------------------------
#define UREG_FIRMWARE_DATE        0x00
#define UREG_FIRMWARE_TIME        0x04
#define UREG_CTRL                 0x08
    #define UREG_CTRL_DMA_TX_TEST_START_BIT    0  //
    // assign aurora_control_pwd = reg_ctrl[16];
    // assign gt_rst = reg_ctrl[4];
    // assign aurora_rst = reg_ctrl[5];
    // assign artix_eth_num = reg_ctrl[10:8];
    // assign zynq_eth_num = reg_ctrl[13:12];
    // assign aurora_control_pwd = reg_ctrl[16];
#define UREG_TEST0                0x0C
#define UREG_TEST1                0x10
#define UREG_STATUS_AURORA        0x14
#define UREG_STATUS_ETH           0x18
#define UREG_CNTERR_ETH0          0x1C
#define UREG_CNTERR_ETH1          0x20
#define UREG_CNTERR_ETH2          0x24
#define UREG_CNTERR_ETH3          0x28
#define UREG_ETHPHY_MDIO_CLK_O    0x2C
#define UREG_ETHPHY_MDIO_DATA_O   0x30
#define UREG_ETHPHY_MDIO_DATA_I   0x34
#define UREG_ETHPHY_MDIO_DIR_O    0x38
#define UREG_ETHPHY_RST           0x3C
#define UREG_AURORA_O_CTL_0       0x40
#define UREG_AURORA_O_CTL_1       0x44
#define UREG_AURORA_I_CTL_0       0x48
#define UREG_ETHPHY_TEST_PRM      0x4C
    #define UREG_ETHPHY_TEST_PRM_PKT_SIZE_OFFSET    0
    #define UREG_ETHPHY_TEST_PRM_PKT_SIZE_MASK      0xFFFF
    #define UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_OFFSET  16
    #define UREG_ETHPHY_TEST_PRM_PAUSE_SIZE_MASK    0xFF
    #define UREG_ETHPHY_TEST_PRM_PKT_COUNT_OFFSET   24
    #define UREG_ETHPHY_TEST_PRM_PKT_COUNT_MASK     0xFF

#define UREG_DEVICE_TEMP          0x50



#endif // __FPGA_REG_H__
