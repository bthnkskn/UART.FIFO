library ieee;
use ieee.std_logic_1164.all;

entity uart_rx_ctrl is
generic (baud : integer := 9600);

port(clk : in std_logic;
     rx : in std_logic; --cihaz?n rx ine ba?la
     receive_data : out std_logic_vector (7 downto 0);
     parity : out std_logic;
     ready : out std_logic := '0';
     error : out std_logic := '0'
     );
end uart_rx_ctrl;

architecture behavioral of uart_rx_ctrl is

constant baud_timer : integer := 100000000/baud; --100mhz clock/baud rate
type state_type is (rdy, start, receive, waiting, check);

signal state: state_type := rdy;
signal timer : integer :=0;
signal bitIndex : integer range 0 to 8 := 0;
signal rxdata : std_logic_vector(8 downto 0);

begin
process(clk)
begin

if rising_edge(clk) then

case state is
when rdy =>
    if rx = '0' then
    state <= start;
    bitIndex <= 0;
    end if;

when start =>
    if timer = baud_timer/2 then
    state <=waiting;
    timer <= 0;
    error <= '0';
    ready <= '0';
    else 
    timer <= timer+1;
    end if;
    
when waiting =>
    if(timer = baud_timer) then
    timer <= 0;
    if (ready = '1') then
    state <= rdy;
    else
    state <= receive;
    end if;
    else
    timer <= timer + 1;
    end if;
    

when receive =>
    rxdata(bitIndex) <= rx;
    bitIndex <= bitIndex + 1;
    if (bitIndex = 8) then
    state <= check;
    else
    state <= waiting;
    end if;

when check =>
    if (xor rxdata(7 downto 0) = rxdata(8)) then
    ready <= '1';
    state <= waiting;
    receive_data <= rxdata(7 downto 0);
    parity <= rxdata(8);
    else
    ready <= '1';
    receive_data(7 downto 0)<= (others => '-');
    error <= '1';
    state <= rdy;
    end if;

end case;
end if;
end process;
end behavioral;