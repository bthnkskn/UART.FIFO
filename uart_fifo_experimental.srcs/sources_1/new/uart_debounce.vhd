--slow clock generation genenariton for debouncing
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clk_ena_dbc_btn is

port(clk: in std_logic;
     slow_clk_ena: out std_logic
);

end clk_ena_dbc_btn;

architecture behavioral of clk_ena_dbc_btn is

signal counter: std_logic_vector(27 downto 0):= (others => '0');

begin

process(clk)
begin
if(rising_edge(clk)) then
    counter <= counter + x"0000001";
    if(counter >= x"003D08F") then
    counter <= (others => '0');
    end if;
end if;
end process;
    slow_clk_ena <= '1' when counter <= x"003D08F" else '0';
end behavioral;

--DFF w/ clk ena for debouncing

library ieee;
use ieee.std_logic_1164.all;
entity dff_debouncing_button is
port(clk: in std_logic;
     clk_ena: in std_logic;
     D: in std_logic;
     Q: out std_logic:= '0'
);
end dff_debouncing_button;
architecture behavioral of dff_debouncing_button is
begin
process(clk)
begin
if(rising_edge(clk)) then
    if(clk_ena = '1') then
    Q <= D;
    end if;
end if;
end process;
end behavioral;

--main code for debouncing

library ieee;
use ieee.std_logic_1164.all;

entity btn_debounce is
port(btn: in std_logic;
     clk: in std_logic;
     debounced_btn: out std_logic
);

end btn_debounce;

architecture behavioral of btn_debounce is

signal slow_clk_ena: std_logic;
signal Q1,Q2,Q2_BAR,Q0: std_logic;

begin

clk_ena_gen: entity work.clk_ena_dbc_btn port map (clk=>clk, slow_clk_ena=>slow_clk_ena);

debounce_ff0: entity work.dff_debouncing_button port map (clk=>clk,clk_ena=>slow_clk_ena,D=>btn,Q=>Q0);

debounce_ff1: entity work.dff_debouncing_button port map (clk=>clk,clk_ena=>slow_clk_ena,D=>Q0,Q=>Q1);

debounce_ff2: entity work.dff_debouncing_button port map (clk=>clk,clk_ena=>slow_clk_ena,D=>Q1,Q=>Q2);
Q2_BAR <= not Q2;
debounced_btn <= Q1 and Q2_BAR;
end behavioral;