----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2020 10:40:30 PM
-- Design Name: 
-- Module Name: uart_recproctrans_top - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity uart_recproctrans_top is
    port(clk: in std_logic;
         RsTx: out std_logic;
         RsRx: in std_logic
        );
end uart_recproctrans_top;

architecture Behavioral of uart_recproctrans_top is

type state_type is (RX_RDY, RX_WAIT, TX_SEND_DATA);

signal state   : state_type := RX_RDY;

signal tx_transmission_done : std_logic;
signal tx_transmission_active: std_logic;
signal tx_data_ready: std_logic;
signal tx_data: std_logic_vector (7 downto 0):= (others => '0');

signal rx_data_ready: std_logic;
signal rx_data     : std_logic_vector (7 downto 0):= (others => '0');

signal fifo_wr_en : std_logic;
signal fifo_rd_en : std_logic;
signal fifo_full : std_logic;
signal fifo_empty : std_logic;

component UART_tx_ctrl is
  generic (
    g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
  port (
    clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;

component UART_rx_ctrl is
  generic (
    g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
  port (
    clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;

component fifo_generator_0 IS
  PORT (
    clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
end component;

begin
process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when RX_RDY => 
	               if rx_data_ready = '1' then 
	                   state <= RX_WAIT; 
	               else
	                   state <= RX_RDY;
	               end if;
	   
                when RX_WAIT =>
	               if fifo_full = '0' then
	                   fifo_wr_en <= '1';
	                   fifo_rd_en <= '0';
	                   state <= TX_SEND_DATA;
                   end if;
       
--                 elsif fifo_full = '1' then
--                     fifo_wr_en <= '0';  
--                     state <= TX_SEND_DATA;
--                 end if; 	               	              	
	  
                when TX_SEND_DATA =>
                   if fifo_empty = '0' then
                       fifo_wr_en <= '0';
                       fifo_rd_en <= '1';
	                   tx_data_ready <= '1';                   
	               end if;
	               
	               if tx_transmission_done = '1' then
	                   fifo_rd_en <= '0';	
	                   state <= RX_RDY;
	               end if;
--	               if fifo_empty = '1' and tx_transmission_done = '1' then
--	                   state <= RX_RDY;
--                   end if;		
end case;
end if;
end process;
--    when RX_RDY => 
--	   if (not rx_data_ready) then state <= RX_WAIT; end if;
	   
--    when RX_WAIT =>
--	   if (rx_data_ready) then 
--	       fifo_wr_en <= '0';
--           fifo_rd_en <= '0';
--           fifo_rst <= '1';
--	       state <= RX_DATARDY;
--           wait until rising_edge(clk);
--	   end if;	
	
--	wait until rising_edge(clk);    
--    when RX_DATARDY =>
--       fifo_rst <= '0';
--       wait until rising_edge(clk);
--       wait until rising_edge(clk);
--       wait until rising_edge(clk);
       
--       wait until rising_edge(clk);
--       while(fifo_full = '0') loop
--           fifo_wr_en <= '1';
--           fifo_data <= rx_data;
--           wait until rising_edge(clk);
--       end loop;
          
----       if fifo_full = '0' then
----            fifo_wr_en <= '1';
----            fifo_data <= rx_data;
----       end if;
       
--       if fifo_full = '1' then
--            fifo_wr_en <= '0';  
--            state <= TX_WAIT_DATA;
--            wait until rising_edge(clk); 
--       end if;
    
--    wait until rising_edge(clk);            
--	when TX_WAIT_DATA => 
--	   if fifo_full = '1' then 
--	       state <= TX_SEND_DATA;
--	       wait until rising_edge(clk); 
--	   end if;
	
--	wait until rising_edge(clk);    
--    when TX_SEND_DATA =>
--       for i in 0 to fifo_data_cnt'length-1 loop
--           fifo_rd_en <= '1';
--           tx_data <= fifo_data;
--	       tx_data_ready <= '1';
--           wait until rising_edge(clk);
--       end loop;
       
--       wait until rising_edge(clk);
--       fifo_rst <= '1';
--       wait until rising_edge(clk);
       
--       fifo_rst <= '0';
--       wait until rising_edge(clk);
--       wait until rising_edge(clk);
--       wait until rising_edge(clk);
--	   state <= TX_SEND_WAIT;
	   
----     fifo_rd_en <= '1';
----	   tx_data <= fifo_data;
----	   tx_data_ready <= '1';
----	   fifo_rst <= '1';
----	   state <= TX_SEND_WAIT;
	   
--    when TX_SEND_WAIT =>	
--	   if tx_transmission_done = '1' and fifo_full = '0' then state <= RX_RDY; 
--	   end if;
		
--end case;
--end if;


TX : UART_tx_ctrl
port map(clk => clk, o_TX_Serial => RsTx, i_TX_Byte => tx_data, i_TX_DV=> tx_data_ready, o_TX_Done=> tx_transmission_done, o_TX_Active => tx_transmission_active);

RX : UART_rx_ctrl
port map(clk => clk, i_RX_Serial => RsRx, o_RX_Byte => rx_data, o_RX_DV => rx_data_ready);

FIFO_1 : fifo_generator_0
port map(clk => clk, din=>rx_data, wr_en=>fifo_wr_en, rd_en=>fifo_rd_en, dout=>tx_data ,full=>fifo_full,empty=>fifo_empty);

end Behavioral;
