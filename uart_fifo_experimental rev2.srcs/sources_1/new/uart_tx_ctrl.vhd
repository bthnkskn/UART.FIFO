library ieee;
use ieee.std_logic_1164.all;

entity uart_tx_ctrl is
generic (baud : integer := 19200);

port(send : in std_logic;
     clk : in std_logic;
     transfer_data : in std_logic_vector (7 downto 0);
     ready : out std_logic;
     uart_tx : out std_logic -- cihaz?n tx ine ba?la
     );
end uart_tx_ctrl;

architecture behavioral of uart_tx_ctrl is

constant baud_timer : integer := 100000000/baud;--100mhz clock/baud rate
constant bit_index_max : integer := 10;

type state_type is (rdy, load_bit, send_bit);

signal state: state_type := rdy;
signal timer: integer := 0;
signal txData : std_logic_vector (9 downto 0);
signal bitIndex: integer range 0 to bit_index_max :=0;
signal txBit :std_logic := '1';

begin
process(clk)
begin
if rising_edge(clk) then

case state is
when rdy =>
    if (send) then
    txData <= '1' & transfer_data & '0';
    state <= load_bit;
    end if;
    timer <= 0;
    bitIndex <= 0;
    txBit <= '1';
    
when load_bit =>
    state <= send_bit;
    bitIndex <= bitIndex + 1;
    txBit <= txData(bitIndex);

when send_bit =>
    if (timer = baud_timer) then
    timer <= 0;
    if (bitIndex = bit_index_max) then
    state <= rdy;
    else
    state <= load_bit;
    end if;
    else
    timer <= timer + 1;
    end if;
end case;
end if;
end process;

uart_tx <= txBit;
ready <= '1' when (state <= rdy) else '0';

end behavioral;