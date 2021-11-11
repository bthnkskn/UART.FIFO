library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fifo_experimental_tb is
end uart_fifo_experimental_tb;

architecture behavioral of uart_fifo_experimental_tb is

constant tb_bit_period : time := 52080ns;

signal tb_clock : std_logic := '0';
signal tb_tx : std_logic;
signal tb_rx : std_logic := '1';

component uart_fifo_experimental is
    port(clk: in std_logic;
         RsRx : in std_logic;
         RsTx :out std_logic
        );
end component;

procedure uart_byte_write(
    input_data : in std_logic_vector(7 downto 0);
    signal output_serial : out std_logic) is
    begin
    
    output_serial <= '0';
    
    wait for tb_bit_period;
    
    for ii in 0 to 7 loop
        output_serial <= input_data(ii);
        wait for tb_bit_period;
    end loop;
    
    output_serial <= '1';
    wait for tb_bit_period;
end uart_byte_write;

begin

UUT: uart_fifo_experimental port map(clk => tb_clock,RsRx =>tb_rx ,RsTx =>tb_tx);    

tb_clock <= not tb_clock after 5ns;

process is
begin
wait until rising_edge(tb_clock);
uart_byte_write(X"A5" , tb_rx);
wait until rising_edge(tb_clock);

end process;
end behavioral; 