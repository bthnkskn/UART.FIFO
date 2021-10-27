library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fifo_experimental is
port(clk: in std_logic;
     RsRx: in std_logic;
     RsTx: out std_logic
);

end uart_fifo_experimental;

architecture behavioral of uart_fifo_experimental is
--state ve signal eklenecek
type state_type is (s_idle, s_fifo_rx_wr, s_fifo_rd_tx, s_uart_transmit);

signal state : state_type :=s_idle;

signal rx_data : std_logic_vector(7 downto 0);
signal rx_parity : std_logic;
signal rx_ready : std_logic := '0';
signal rx_error : std_logic := '0';

signal tx_data : std_logic_vector(7 downto 0);
signal tx_ready : std_logic;
signal tx_send : std_logic;

signal fifo_synchro_rst : std_logic;
signal fifo_wr_en : std_logic;
signal fifo_wr_data : std_logic_vector(7 downto 0);--fifo width kadar
signal s_fifo_full : std_logic;
signal fifo_rd_en : std_logic;
signal fifo_rd_data : std_logic_vector(7 downto 0);--fifo width kadar
signal s_fifo_empty : std_logic;

component uart_rx_ctrl is
generic (baud : integer := 9600);

port(clk : in std_logic;
     rx : in std_logic; --cihaz?n rx ine ba?la
     receive_data : out std_logic_vector (7 downto 0);
     parity : out std_logic;
     ready : out std_logic := '0';
     error : out std_logic := '0'
     );
end component;

component uart_tx_ctrl is
generic (baud : integer := 9600);

port(send : in std_logic;
     clk : in std_logic;
     transfer_data : in std_logic_vector (7 downto 0);
     ready : out std_logic;
     uart_tx : out std_logic -- cihaz?n tx ine ba?la
     );
end component;

component register_based_fifo is
generic(fifo_width: natural :=8; fifo_depth: integer :=2);

port(synchro_rst : in std_logic;
     clk: in std_logic;
     wr_en: in std_logic;
     wr_data: in std_logic_vector(fifo_width-1 downto 0);
     fifo_full: out std_logic;
     rd_en: in std_logic;
     rd_data: out std_logic_vector(fifo_width-1 downto 0);
     fifo_empty:out std_logic
     );
end component;

begin

process(clk) is
begin

if(rising_edge(clk)) then

case state is
when s_idle =>
    if rx_ready = '1' then
    fifo_wr_en <= '0';
    fifo_rd_en <= '0';
    state <= s_fifo_rx_wr;
    end if;
 
when s_fifo_rx_wr =>
    if s_fifo_full = '0' then
        fifo_wr_en <= '1';
        fifo_wr_data <= rx_data;
        state <= s_idle;
    else
    fifo_wr_en <= '0';
    state <= s_fifo_rd_tx;
    end if;
    
when s_fifo_rd_tx =>
    if s_fifo_empty = '0' then
        fifo_rd_en <= '1';
        tx_data <= fifo_rd_data;
        tx_send <= '1';
        state <= s_uart_transmit;
    else
    fifo_rd_en <= '0';
    state <= s_fifo_rx_wr;
    end if;    

when s_uart_transmit =>
    if tx_ready = '1' then
        fifo_wr_en <= '0';
        fifo_rd_en <= '0';
        tx_send <= '0';
        state <= s_fifo_rd_tx;
    end if;       
            
end case;
end if;

end process;

rx: uart_rx_ctrl
port map(clk => clk, rx => RsRx, receive_data => rx_data , parity => rx_parity, ready =>rx_ready , error =>rx_error);

tx: uart_tx_ctrl
port map(clk => clk, uart_tx => RsTx, transfer_data => tx_data , send => tx_send, ready =>tx_ready);

fifo0: register_based_fifo
port map(synchro_rst =>fifo_synchro_rst, clk =>clk, wr_en =>fifo_wr_en, wr_data =>fifo_wr_data, fifo_full =>s_fifo_full, rd_en =>fifo_rd_en, rd_data => fifo_rd_data, fifo_empty => s_fifo_empty);

end behavioral;