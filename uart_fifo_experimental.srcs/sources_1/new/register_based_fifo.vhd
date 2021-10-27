library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_based_fifo is
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
end register_based_fifo;

architecture behavioral of register_based_fifo is
type fifo_data_type is array(0 to fifo_depth-1) of std_logic_vector(fifo_width-1 downto 0);
signal fifo_data: fifo_data_type:= (others =>(others => '0'));

signal wr_index : integer range 0 to fifo_depth-1 :=0;
signal rd_index : integer range 0 to fifo_depth-1 :=0;
signal fifo_word_count : integer range 0 to fifo_depth-1 :=0;
signal s_full :std_logic;
signal s_empty :std_logic;

begin

process(clk) is
begin
if rising_edge(clk) then
    if(synchro_rst = '1') then
    fifo_word_count <= 0;
    wr_index <= 0;
    rd_index <= 0;
    else
        if(wr_en = '1' and rd_en = '0') then   --fifo word control
        fifo_word_count <= fifo_word_count + 1;
        elsif(wr_en = '0' and rd_en = '1') then
        fifo_word_count <= fifo_word_count -1;
        end if;
        
        if(wr_en = '1' and s_full = '0') then  --fifo write index control
            if wr_index = fifo_depth-1 then
            wr_index <= 0;
            else
            wr_index <= wr_index + 1;
            end if;
        end if;
        
        if(rd_en = '1' and s_empty = '0') then --fifo read index control
            if rd_index = fifo_depth-1 then
            rd_index <= 0;
            else
            rd_index <= rd_index + 1;
            end if;
        end if;
        
        if wr_en = '1' then                    --fifo data input on write
        fifo_data(wr_index) <= wr_data;
        end if;
        
    end if;
end if;
end process;

rd_data <= fifo_data(rd_index);
s_full <= '1' when fifo_word_count = fifo_depth else '0';
s_empty <= '1' when fifo_word_count = 0 else '0';

fifo_full <= s_full;
fifo_empty <= s_empty;

end behavioral;