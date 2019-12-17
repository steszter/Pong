----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2019 02:53:35 PM
-- Design Name: 
-- Module Name: pong_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pong_tb is
--  Port ( );
end pong_tb;

architecture Behavioral of pong_tb is

component pong is
PORT( clk : in STD_LOGIC;
      button: in STD_LOGIC;
      gameon: in STD_LOGIC;
      gameon_led: out STD_LOGIC;
      left_player_button_up: in STD_LOGIC;
      left_player_button_down: in STD_LOGIC;
      right_player_button_up: in STD_LOGIC;
      right_player_button_down: in STD_LOGIC;
      H : out STD_LOGIC; 
      V : out STD_LOGIC; 
      RGB : out STD_LOGIC_VECTOR (11 downto 0));
end component;

signal clk_sig : STD_LOGIC;
signal H_sig : STD_LOGIC;
signal V_sig : STD_LOGIC;
signal RGB_sig : STD_LOGIC_VECTOR(11 downto 0);
signal button_sig: std_logic := '0';
signal gameon_sig: std_logic := '0';
signal gameon_led_sig: std_logic := '0';
signal left_player_button_up_sig: std_logic := '0';
signal left_player_button_down_sig: std_logic := '0';
signal right_player_button_up_sig: std_logic := '0';
signal right_player_button_down_sig: std_logic := '0';

begin

uut: pong PORT MAP(
    clk => clk_sig,
    H => H_sig,
    V => V_sig,
    RGB => RGB_sig,
    button => button_sig,
    gameon => gameon_sig,
    gameon_led => gameon_led_sig,
    left_player_button_up => left_player_button_up_sig,
    left_player_button_down => left_player_button_down_sig,
    right_player_button_up => right_player_button_up_sig,
    right_player_button_down => right_player_button_down_sig
);

stimulus:process
begin
    clk_sig <= '0';
    wait for 5ns;
    clk_sig <= '1';
    wait for 5ns;
    
end process;

end Behavioral;