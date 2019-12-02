--
-- author: Golovachenko Viktor
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vicg_common_pkg.all;

entity sata_scrambler is
generic(
  G_INIT_VAL : integer:=16#FFFF#
);
port(
    p_in_SOF      : in    std_logic;
    p_in_en       : in    std_logic;
    p_out_result  : out   std_logic_vector(31 downto 0);

    p_in_clk      : in    std_logic;
    p_in_rst      : in    std_logic
);
end entity sata_scrambler;

architecture behavioral of sata_scrambler is

signal srambler : std_logic_vector(31 downto 0) := (others=>'0');

begin --architecture behavioral

process(p_in_rst,p_in_clk)
begin
    if p_in_rst='1' then
        srambler<=(others=>'0');
    elsif rising_edge(p_in_clk) then
        if p_in_SOF='1' then
            srambler <= srambler32_0(std_logic_vector(TO_UNSIGNED(G_INIT_VAL, 16)));
        else
            if p_in_en='1' then
                srambler <= srambler32_0(srambler(31 downto 16));
            end if;
        end if;
    end if;
end process;

p_out_result<=srambler;

end architecture behavioral;
