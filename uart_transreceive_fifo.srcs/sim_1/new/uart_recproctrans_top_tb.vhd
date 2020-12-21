----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2020 09:32:38 AM
-- Design Name: 
-- Module Name: uart_recproctrans_top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity uart_recproctrans_top_tb is
end uart_recproctrans_top_tb;

architecture Behavioral of uart_recproctrans_top_tb is
signal clk_tb : std_logic:= '0';
signal rx_tb : std_logic:= '1';
signal tx_tb : std_logic;

component uart_recproctrans_top is
    port(clk: in std_logic;
         RsRx: in std_logic;
         RsTx: out std_logic
        );
end component;

constant c_BIT_PERIOD : time := 8680 ns;

  procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;
  
--  procedure UART_READ_BYTE (
--    signal o_data_out       : out std_logic_vector(7 downto 0);
--     out_serial : in std_logic) is
--  begin
 
--    for ii in 0 to 7 loop
--      o_data_out(ii) <= out_serial;
--      wait for c_BIT_PERIOD;
--    end loop;  -- ii
    
--  end UART_READ_BYTE;

begin
UUT: uart_recproctrans_top port map (clk => clk_tb,RsRx => rx_tb, RsTx =>tx_tb);

clk_tb <= not clk_tb after 50 ns;

process
begin

wait until rising_edge(clk_tb);
    UART_WRITE_BYTE(X"FF", rx_tb);
end process;

end Behavioral;
