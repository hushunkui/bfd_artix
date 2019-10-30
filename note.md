* ETHA
----------------------------------
RXDA   - rgmii_rxd[3:0] - B15_L8_P, B15_L8_N, B15_L10_P, B15_L10_N
RX_DVA - rgmii_rx_ctl[0] - B15_L6_N
RXCA   - rgmii_rxc[0] - B15_L11_P (IO_L11P_T1_SRCC_15 pin D13)

TXDA   - rgmii_txd[3:0] - B15_L3_P, B15_L3_N, B15_L5_P, B15_L5_N
TX_DVA - rgmii_tx_ctl[0] - B15_L7_P
TXCA   - rgmii_txc[0] - B15_L7_N

----------------------------------
RXDB   - rgmii_rxd[7:4] - B15_L18_N, B15_L18_P, B15_L17_N, B15_L17_P
RX_DVB - rgmii_rx_ctl[1] - B15_L12_P
RXCB   - rgmii_rxc[1] - B15_L12_N (IO_L12N_T1_MRCC_1 pin D14)???

TXDB   - rgmii_txd[7:4] - B15_L15_P, B15_L9_N, B15_L9_N, B15_L9_P
TX_DVB - rgmii_tx_ctl[1] - B15_L16_P
TXCB   - rgmii_txc[1] - B15_L16_N

----------------------------------
RXDC   - rgmii_rxd[11:8] - B15_L23_P, B15_L23_N, B14_L4_P, B14_L4_N
RX_DVC - rgmii_rx_ctl[2] - RX_DVC
RXCC   - rgmii_rxc[2] - B15_L13_N (IO_L13N_T2_MRCC_15 pin D15)???

TXDC   - rgmii_txd[11:8] - B15_L19_Pviv, B15_L19_N, B15_L24_P, B15_L24_N
TX_DVC - rgmii_tx_ctl[2] - B15_L21_P
TXCC   - rgmii_txc[2] - B15_L21_N

----------------------------------
RXDD   - rgmii_rxd[15:12] - B14_L16_N, B14_L18_N, B14_L18_P, B14_L17_N
RX_DVD - rgmii_rx_ctl[3] - B14_L17_P
RXCD   - rgmii_rxc[3] - B14_L20_P (IO_L20P_T3_A08_D24_14 pin U14)

TXDD   - rgmii_txd[15:12] - B14_L10_P, B14_L15_N, B14_L15_P, B14_L7_P
TX_CTLD - rgmii_tx_ctl[3] - B14_L16_P
TXCD   - rgmii_txc[3] - B14_L10_N
