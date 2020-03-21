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
#define FPGA_REG_TEST_ARRAY_COUNT (4)

// address map spi registers (WR)
#define FPGA_WREG_TEST_ARRAY            (FPGA_WR_OFFSET + 8) //array(4 x 16bit)


// address map spi registers (RD)
#define FPGA_RREG_FIRMWARE_DATE         (FPGA_RD_OFFSET + 0) //32bit
#define FPGA_RREG_FIRMWARE_TIME         (FPGA_RD_OFFSET + 2) //32bit

#define FPGA_RREG_FIRMWARE_TYPE         (FPGA_RD_OFFSET + 4) //16bit

#define FPGA_RREG_TEST_ARRAY            (FPGA_RD_OFFSET + 8) //array(4 x 16bit)


//----------------------------------------
//USER JTAG MASTER interface
//----------------------------------------
#define UREG_FIRMWARE_DATE    0x00
#define UREG_FIRMWARE_TIME    0x04
#define UREG_CTRL             0x08
#define UREG_TEST0            0x0C
#define UREG_TEST1            0x10

#define UREG_STATUS_AURORA    0x14
#define UREG_STATUS_ETH       0x18

#define UREG_CNTERR_ETH0      0x1C
#define UREG_CNTERR_ETH1      0x20
#define UREG_CNTERR_ETH2      0x24
#define UREG_CNTERR_ETH3      0x28

#define UREG_ETHPHY_MDIO_CLK_O    0x2C
#define UREG_ETHPHY_MDIO_DATA_O   0x30
#define UREG_ETHPHY_MDIO_DATA_I   0x34
#define UREG_ETHPHY_MDIO_DIR_O    0x38

#define UREG_ETHPHY_RST       0x3C

#define UREG_AURORA_O_CTL_0   0x40
#define UREG_AURORA_O_CTL_1   0x44
#define UREG_AURORA_I_CTL_0   0x48

#define UREG_ETHPHY_TEST_PRM  0x4C


#endif // __FPGA_REG_H__
