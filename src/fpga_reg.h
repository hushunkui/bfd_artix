//
// author: Golovachenko Viktor
//

//user register map:
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

#define UREG_ETHPHY_MDIO_O    0x2C
    #define UREG_ETHPHY_MDIO_O_CLK_BIT         0
    #define UREG_ETHPHY_MDIO_O_DATA_BIT        1
    #define UREG_ETHPHY_MDIO_O_DIR_BIT         2
#define UREG_ETHPHY_MDIO_I    0x30
    #define UREG_ETHPHY_MDIO_I_DATA_BIT        0

#define UREG_ETHPHY_RST       0x34

#define UREG_AURORA_O_CTL_0   0x38
#define UREG_AURORA_O_CTL_1   0x3C
#define UREG_AURORA_I_CTL_0   0x40
