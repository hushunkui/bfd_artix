-------------------------------------------------------------------------
-- author: Golovachenko Viktor
--
-- Managment Interface (MDIO,MDC)
--
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_mdio is
generic (
    G_DIV : integer:=2;
    G_DBG : string:="OFF";
    G_SIM : string:="OFF"
);
port (
    --------------------------------------
    usr_start : in  std_logic;
    usr_dir    : in  std_logic;
    usr_aphy  : in  std_logic_vector(4 downto 0);
    usr_areg  : in  std_logic_vector(4 downto 0);
    usr_txd   : in  std_logic_vector(15 downto 0);
    usr_rxd   : out std_logic_vector(15 downto 0);
    usr_done  : out std_logic;
    usr_busy  : out std_logic;

    --Eth PHY (Managment Interface)
    p_out_mdio_t   : out    std_logic;
    p_out_mdio     : out    std_logic;
    p_in_mdio      : in     std_logic;
    p_out_mdc      : out    std_logic;

    --------------------------------------
    dbg_o : out std_logic_vector(31 downto 0);

    --------------------------------------
    clk : in std_logic;
    rst : in std_logic
);
end entity eth_mdio;

architecture behavioral of eth_mdio is

constant PREAMBLE : natural:=32;

type TEth_fsm_mdio is (
S_IDLE,
S_TX_PREAMBLE,
S_TX_LD_DONE,
S_TX_CTRL,
S_DATA,
S_EXIT
);
signal fsm_cs: TEth_fsm_mdio;

signal clkdiv        : integer range 0 to G_DIV-1;

signal mdio_done     : std_logic:='0';
signal txd           : std_logic_vector(15 downto 0):=(others=>'0');
signal mdio_rxd      : std_logic_vector(15 downto 0):=(others=>'0');
signal mdio_busy     : std_logic:='0';

signal bitcnt        : unsigned(5 downto 0):=(others=>'0');

signal txld            : std_logic:='0';
signal txen            : std_logic:='0';
signal sr_txd          : std_logic_vector(15 downto 0):=(others=>'0');
signal rxen            : std_logic:='0';
signal sr_rxd          : std_logic_vector(15 downto 0):=(others=>'0');
signal sr_en           : std_logic:='0';

signal mdc             : std_logic:='0';
signal mdc_falling_edge: std_logic;
signal mdc_rising_edge : std_logic;
signal mdio_i          : std_logic;


begin --architecture end behavioral;


---------------------------------------------
process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            fsm_cs <= S_IDLE;

            mdio_done <= '0';
            rxen <= '0';
            txen <= '0';
            txld <= '0';
            txd <= (others=>'0');
            mdio_busy <= '0';
        else
            if mdc_falling_edge='1' then
                case fsm_cs is
                    --------------------------------------
                    when S_IDLE =>
                        mdio_done<='0';
                        mdio_busy<='0';
                        if usr_start = '1' then
                            mdio_busy<='1';
                            txld <= '1';
                            txd <= (others => '1');
                            fsm_cs <= S_TX_PREAMBLE;
                        end if;

                    when S_TX_PREAMBLE =>
                        if (bitcnt = TO_UNSIGNED(PREAMBLE-1, bitcnt'length)) then
                            txld <= '1';
                            txd(15 downto 14) <= "01";      --Start
                            txd(13)           <=not usr_dir;--opcode(1);--"10" -Read
                            txd(12)           <=    usr_dir;--opcode(0);--"01" -Write
                            txd(11 downto 7)  <= usr_aphy;
                            txd(6 downto 2)   <= usr_areg;
                            txd(1 downto 0)   <= "10";       --TA
                            fsm_cs <= S_TX_LD_DONE;
                        else
                            txen <= '1';
                            txld <= '0';
                        end if;

                    --------------------------------------
                    when S_TX_LD_DONE =>
                        txld <= '0';
                        fsm_cs <= S_TX_CTRL;

                    when S_TX_CTRL =>
                        if (bitcnt = TO_UNSIGNED(15, bitcnt'length)) then
                            txen <= usr_dir;
                            rxen <= not usr_dir;
                            txld <= '0';
                            fsm_cs <= S_DATA;

                        elsif (bitcnt = TO_UNSIGNED(14, bitcnt'length)) then
                            txen <= usr_dir;
                            txld <= usr_dir;
                            txd <= usr_txd;

                        elsif (bitcnt = TO_UNSIGNED(13, bitcnt'length)) then
                            txen <= usr_dir;
                        end if;

                    --------------------------------------
                    when S_DATA =>
                        if (bitcnt = TO_UNSIGNED(15, bitcnt'length)) then
                            txen<='0';
                            rxen<='0';
                            fsm_cs <= S_EXIT;
                        end if;

                    --------------------------------------
                    when S_EXIT =>
                        if (bitcnt = TO_UNSIGNED(15, bitcnt'length)) then
                            mdio_done<='1';
                            fsm_cs<=S_IDLE;
                        end if;
                end case;
            end if;
        end if;
    end if;
end process;

--MDC
process(clk) begin
    if rising_edge(clk) then
        if (clkdiv = (G_DIV-1) or (rst = '1')) then
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if (clkdiv /= (G_DIV-1) or (rst = '1')) then
            sr_en<='0';
        else
            sr_en <= '1';
        end if;

        if sr_en='1' then
            mdc <= not mdc;
        end if;
    end if;
end process;
mdc_falling_edge <= sr_en and mdc; --falling edge mdc clk
mdc_rising_edge <= sr_en and not mdc; --rising edge mdc clk

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            bitcnt <= (others => '0');
        else
            if (mdc_falling_edge = '1') then
                if (fsm_cs=S_IDLE) or
                    (fsm_cs=S_TX_PREAMBLE and bitcnt=TO_UNSIGNED(PREAMBLE-1, bitcnt'length)) or
                    ((fsm_cs=S_TX_CTRL or fsm_cs=S_DATA or fsm_cs=S_EXIT) and bitcnt=TO_UNSIGNED(15, bitcnt'length)) then
                    bitcnt<=(others=>'0');
                else
                    if fsm_cs=S_TX_PREAMBLE or fsm_cs=S_TX_CTRL or fsm_cs=S_DATA or fsm_cs=S_EXIT then
                        bitcnt<=bitcnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if (mdc_falling_edge = '1') then
            if txld = '1' then
                sr_txd <= txd;
            else
                sr_txd <= sr_txd(sr_txd'length-2 downto 0) & '1';
            end if;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if (mdc_rising_edge = '1' and rxen = '1') then
            sr_rxd <= sr_rxd(sr_rxd'length-2 downto 0) & mdio_i;
        end if;
    end if;
end process;

usr_rxd <= sr_rxd;
usr_done <= mdio_done;
usr_busy <= mdio_busy;


--Managment Interface
p_out_mdio <= sr_txd(15);
p_out_mdc <= mdc;
mdio_i <= p_in_mdio;
p_out_mdio_t <= txen;


end architecture behavioral;