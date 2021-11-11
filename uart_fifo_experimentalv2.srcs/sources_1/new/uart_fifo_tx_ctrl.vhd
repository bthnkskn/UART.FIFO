library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_fifo_tx_ctrl is
    generic(
        baud : integer := 9600
    );
    port(
        clk : in std_logic;
        tx_rst : in std_logic;
        tx_wr_data : in std_logic_vector(7 downto 0);
        tx_wr_en : in std_logic;
        RsTx : out std_logic;
        tx_full : out std_logic
    );
    

end uart_fifo_tx_ctrl;

architecture behavioral of uart_fifo_tx_ctrl is

signal fifo_rd_data : std_logic_vector(7 downto 0);--fifo width kadar
signal s_tx_fifo_empty, s_tx_fifo_not_empty : std_logic;
signal tx_ready : std_logic;
signal tx_done : std_logic;


component uart_tx_ctrl is
generic (baud : integer);

port(send : in std_logic;
     clk : in std_logic;
     transfer_data : in std_logic_vector (7 downto 0);
     ready : out std_logic;
     uart_tx : out std_logic; -- cihaz?n tx ine ba?la
     tx_done : out std_logic
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

tx: uart_tx_ctrl generic map(baud => 9600)
port map(clk => clk, uart_tx => RsTx, transfer_data => fifo_rd_data, 
            send => s_tx_fifo_not_empty, ready =>tx_ready, tx_done => tx_done);

tx_fifo: register_based_fifo
port map(synchro_rst =>tx_rst, clk =>clk, wr_en =>tx_wr_en, 
            wr_data =>tx_wr_data, fifo_full =>tx_full, rd_en =>tx_done,
            rd_data => fifo_rd_data, fifo_empty => s_tx_fifo_empty);

s_tx_fifo_not_empty <= not s_tx_fifo_empty;
end behavioral;