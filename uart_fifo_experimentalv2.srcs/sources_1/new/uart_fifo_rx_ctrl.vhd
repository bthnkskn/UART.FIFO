library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fifo_rx_ctrl is
    generic(
        baud : integer := 9600
    );
    
    port(
        RsRx : in std_logic;
        clk : in std_logic;
        rx_rd_en : in std_logic;
        rx_rst : in std_logic;
        rx_rd_data : out std_logic_vector(7 downto 0);
        rx_empty :out std_logic
    );

end uart_fifo_rx_ctrl;

architecture behavioral of uart_fifo_rx_ctrl is

signal fifo_wr_data : std_logic_vector(7 downto 0);--fifo width kadar
signal s_rx_fifo_full, s_rx_fifo_not_full : std_logic;
signal rx_ready :std_logic;
signal rx_parity : std_logic := '0';
signal rx_error : std_logic := '0';

component uart_rx_ctrl is
generic (baud : integer);

port(clk : in std_logic;
     rx : in std_logic; --cihaz?n rx ine ba?la
     receive_data : out std_logic_vector (7 downto 0);
     parity : out std_logic;
     ready : out std_logic := '0';
     error : out std_logic := '0'
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

rx: uart_rx_ctrl generic map(baud => 9600)
port map(clk => clk, rx => RsRx, receive_data => fifo_wr_data, 
            parity => rx_parity, ready =>rx_ready , error =>rx_error);

rx_fifo: register_based_fifo
port map(synchro_rst =>rx_rst, clk =>clk, wr_en =>rx_ready,
            wr_data =>fifo_wr_data, fifo_full =>s_rx_fifo_full, rd_en =>rx_rd_en, 
            rd_data => rx_rd_data, fifo_empty => rx_empty);
            
s_rx_fifo_not_full <= not s_rx_fifo_full;

end behavioral;