----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/14/2019 02:53:19 PM
-- Design Name: 
-- Module Name: pong - Behavioral
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

entity pong is
    Port ( clk : in STD_LOGIC;--pixel clock at frequency of VGA mode being used
           button: in STD_LOGIC; --resetelünk vele
           gameon: in STD_LOGIC;
           gameon_led: out STD_LOGIC;
           left_player_button_up: in STD_LOGIC;
           left_player_button_down: in STD_LOGIC;
           right_player_button_up: in STD_LOGIC;
           right_player_button_down: in STD_LOGIC;
           H : out STD_LOGIC; --horiztonal sync pulse
           V : out STD_LOGIC; --vertical sync pulse
           RGB : out STD_LOGIC_VECTOR (11 downto 0)); 
end pong;

architecture Behavioral of pong is

component clk_wiz_0
port
 (
  clk_out1          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;

signal clk_sig : std_logic;
constant h_front_porch:	INTEGER := 16;
constant h_sync_time:	INTEGER := 96;
constant v_front_porch:	INTEGER := 10;
constant v_sync_time:	INTEGER := 2;
constant h_addr_time:	INTEGER := 640;
constant v_addr_time:	INTEGER := 480;
signal h_count : unsigned(9 downto 0) := (others => '0');
signal v_count : unsigned(9 downto 0) := (others => '0');


constant h_max: INTEGER := 800;
constant v_max: INTEGER := 525;
signal h_position: INTEGER range 0 to 800 := 0; --our position x
signal v_position: INTEGER range 0 to 525 := 0; --our position y
signal H_sig : std_logic := '1';
signal V_sig : std_logic := '1';
signal pixel_x: INTEGER range 0 to 640:= 0; --window size x
signal pixel_y: INTEGER range 0 to 480 := 0; --window size y


--paddles:
constant left_paddle_x: INTEGER := 25;
constant right_paddle_x: INTEGER := 615;
signal left_paddle_y: INTEGER := 240;
signal right_paddle_y: INTEGER := 240;

--paddles size:
constant paddle_half_width: INTEGER := 5;
constant paddle_half_height: INTEGER := 30;
constant left_paddle_startx: INTEGER := left_paddle_x - paddle_half_width;
constant left_paddle_endx: INTEGER := left_paddle_x + paddle_half_width;
constant right_paddle_startx: INTEGER := right_paddle_x - paddle_half_width;
constant right_paddle_endx: INTEGER := right_paddle_x + paddle_half_width;
signal left_paddle_starty: INTEGER := left_paddle_y - paddle_half_height;
signal left_paddle_endy: INTEGER := left_paddle_y + paddle_half_height;
signal right_paddle_starty: INTEGER := right_paddle_y - paddle_half_height;
signal right_paddle_endy: INTEGER := right_paddle_y + paddle_half_height;

--color:
signal RGB_sig : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');

--ball:
signal ball_x: INTEGER range -100 to 640 := 320;
signal ball_y: INTEGER range -100 to 480 := 240;
signal ball_speed_x: INTEGER range -100 to 100 := 1;
signal ball_speed_y: INTEGER range -100 to 100 := 3;
signal reset_ball: STD_LOGIC := '0';
signal reset_counter: INTEGER range 0 to 101 := 0;
signal enable_ball_counter: STD_LOGIC := '0';

--field:
constant fieldup_x: INTEGER := 320;
constant fieldup_y: INTEGER := 15;
constant fielddown_x: INTEGER := 320;
constant fielddown_y: INTEGER := 475;
constant field_half_width: INTEGER := 320;
constant field_half_height: INTEGER := 1;
constant fieldup_startx: INTEGER := fieldup_x - field_half_width;
constant fieldup_endx: INTEGER := fieldup_x + field_half_width;
constant fielddown_startx: INTEGER := fielddown_x - field_half_width;
constant fielddown_endx: INTEGER := fielddown_x + field_half_width;
constant fieldup_starty: INTEGER := fieldup_y - field_half_height;
constant fieldup_endy: INTEGER := fieldup_y + field_half_height;
constant fielddown_starty: INTEGER := fielddown_y - field_half_height;
constant fielddown_endy: INTEGER := fielddown_y + field_half_height;

--lifebars:
constant lifeleft_x: INTEGER := 160;
constant lifeleft_y: INTEGER := 7;
constant liferight_x: INTEGER := 480;
constant liferight_y: INTEGER := 7;
constant life_half_width: INTEGER := 15;
constant life_half_height: INTEGER := 3;
constant lifeleft_startx: INTEGER := lifeleft_x - life_half_width;
signal lifeleft_endx: INTEGER := lifeleft_x + life_half_width;
constant liferight_startx: INTEGER := liferight_x - life_half_width;
signal liferight_endx: INTEGER := liferight_x + life_half_width;
constant lifeleft_starty: INTEGER := lifeleft_y - life_half_height;
constant lifeleft_endy: INTEGER := lifeleft_y + life_half_height;
constant liferight_starty: INTEGER := liferight_y - life_half_height;
constant liferight_endy: INTEGER := liferight_y + life_half_height;

--gameover:
signal color_win_left: STD_LOGIC := '0';
signal color_lose_left: STD_LOGIC := '0';
signal color_win_right: STD_LOGIC := '0';
signal color_lose_right: STD_LOGIC := '0';

--random:
signal lfsr: signed(9 downto 0) := "1011011101";
signal lfsr2: signed(9 downto 0) := "0101100110";

type states is(Start, Game_On, Left_Out, Right_Out, Left_Win, Right_Win);
signal State : states := Start;

begin
PROCESS(clk_sig)
begin
if (clk_sig'event and clk_sig = '1') then
    
    if (h_count = h_max - 1) then
        h_count <= to_unsigned(0, h_count'length);
        if (v_count = v_max - 1) then
            v_count <= to_unsigned(0, v_count'length);
        else
            v_count <= v_count + 1;
        end if;
    else
        h_count <= h_count + 1;
    end if;
    
    if (h_count = h_addr_time + h_front_porch) then
        H_sig <= '0';
    elsif (h_count = h_addr_time + h_front_porch + h_sync_time) then
        H_sig <= '1';
    else
        H_sig <= H_sig;
    end if;
    
    if (v_count = v_addr_time + v_front_porch) then
        V_sig <= '0';
    elsif (v_count = v_addr_time + v_front_porch + v_sync_time) then
        V_sig <= '1';
    else
        V_sig <= V_sig;
    end if;
    
    --random number generator
    lfsr <= lfsr(8 downto 0) & (lfsr(9) XNOR lfsr(6));
    lfsr2 <= lfsr2(8 downto 0) & (lfsr2(9) XNOR lfsr2(6));
    
    case State is        
        when Start =>
            
            if (gameon = '1') then
                gameon_led <= '1';
                State <= Game_On;
            end if;
            
        when Game_On =>
            
            if (enable_ball_counter = '1') then
                if (button = '1') then
                    State <= Start;
                end if;
                
                if (ball_x - 4 < 4 and ball_y > fieldup_y and ball_y < fielddown_y) then
                    State <= Left_Out;
                elsif (ball_x + 4 > 636 and ball_y > fieldup_y and ball_y < fielddown_y) then
                    State <= Right_Out;
                end if;
            end if;

        when Left_Out =>
        
            if (lifeleft_startx = lifeleft_endx) then
                State <= Right_Win;
            else
                State <= Game_On;
            end if;
            
        when Right_Out =>
        
            if (liferight_startx = liferight_endx) then
                State <= Left_Win;
            else
                State <= Game_On;
            end if;
            
        when Left_Win =>
            
            State <= Start;
        when Right_Win =>
            
            State <= Start;        
    end case;
    
    if (State = Start) then
        ball_x <= 320;
        ball_y <= 240;
        
        if (to_integer(lfsr(9 downto 7)) = 0) then
            ball_speed_x <= 1;
        else
            ball_speed_x <= to_integer(lfsr(9 downto 7));
        end if;
        
        if (to_integer(lfsr2(9 downto 7)) = 0) then
            ball_speed_y <= 3;
        else
            ball_speed_y <= to_integer(lfsr2(9 downto 7));
        end if;
        
        liferight_endx <= liferight_x + life_half_width;
        lifeleft_endx <= lifeleft_x + life_half_width;
        left_paddle_y <= 240;
        right_paddle_y <= 240;
        
    elsif (State = Game_On) then
        color_win_left <= '0';
        color_lose_left <= '0';
        color_win_right <= '0';
        color_lose_right <= '0';
        --ball movement
        if (h_count = 640-1 and v_count = 480-1) then
            enable_ball_counter <= '1';
        else
            enable_ball_counter <= '0';
        end if;
        
        if (enable_ball_counter = '1') then
            --left player paddle move
            if (left_player_button_up = '1') then
                if (left_paddle_starty < fieldup_endy or left_paddle_endy = fieldup_endy) then
                    left_paddle_y <= left_paddle_y;
                else
                    left_paddle_y <= left_paddle_y - 4;
                end if;
            elsif (left_player_button_down = '1') then
                if (left_paddle_endy = fielddown_starty) then
                    left_paddle_y <= left_paddle_y;
                else
                    left_paddle_y <= left_paddle_y + 4;
                end if;
            end if;
            
            --right player paddle move
            if (right_player_button_up = '1') then
                if (right_paddle_starty < fieldup_endy or right_paddle_endy = fieldup_endy) then
                    right_paddle_y <= right_paddle_y;
                else
                    right_paddle_y <= right_paddle_y - 4;
                end if;
            elsif (right_player_button_down = '1') then
                if (right_paddle_endy = fielddown_starty) then
                    right_paddle_y <= right_paddle_y;
                else
                    right_paddle_y <= right_paddle_y + 4;
                end if;
            end if;
            -- ball position
            if (ball_x + 4 > right_paddle_startx and ball_y + 4 > right_paddle_starty
                and ball_y - 4 < right_paddle_endy) then
                ball_x <= right_paddle_startx - 4;
                
            elsif (ball_x - 4 < left_paddle_endx and ball_y + 4 > left_paddle_starty
                and ball_y - 4 < left_paddle_endy) then
                ball_x <= left_paddle_endx + 4;

            elsif (ball_y - 4 < fieldup_endy) then
                ball_x <= ball_x;
                
            elsif (ball_y + 4 > fielddown_starty) then
                ball_x <= ball_x;
                
            else
                ball_x <= ball_x + ball_speed_x;
            end if;
            
            if (ball_x + 4 > right_paddle_startx and ball_y + 4 > right_paddle_starty
                and ball_y - 4 < right_paddle_endy) then
                ball_y <= ball_y;
                
            elsif (ball_x - 4 < left_paddle_endx and ball_y + 4 > left_paddle_starty
                and ball_y - 4 < left_paddle_endy) then
                ball_y <= ball_y;
                
            elsif (ball_y - 4 < fieldup_endy) then
                ball_y <= fieldup_endy + 4;
                
            elsif (ball_y + 4 > fielddown_starty) then
                ball_y <= fielddown_starty - 4;
                
            else
                ball_y <= ball_y + ball_speed_y;
            end if;
            
            --ballspeed
            if (ball_x + 4 > right_paddle_startx and ball_y + 4 > right_paddle_starty
                and ball_y - 4 < right_paddle_endy) then
                ball_speed_y <= ball_speed_y;
                
            elsif (ball_x - 4 < left_paddle_endx and ball_y + 4 > left_paddle_starty
                and ball_y - 4 < left_paddle_endy) then
                ball_speed_y <= ball_speed_y;

            elsif (ball_y - 4 < fieldup_endy) then
                ball_speed_y <= -ball_speed_y;
                
            elsif (ball_y + 4 > fielddown_starty) then
                ball_speed_y <= -ball_speed_y;
            end if;
                
            
            if (ball_x + 4 > right_paddle_startx and ball_y + 4 > right_paddle_starty
                and ball_y - 4 < right_paddle_endy) then
                ball_speed_x <= -ball_speed_x;

            elsif (ball_x - 4 < left_paddle_endx and ball_y + 4 > left_paddle_starty
                and ball_y - 4 < left_paddle_endy) then
                ball_speed_x <= -ball_speed_x;
                
            elsif (ball_y - 4 < fieldup_endy) then
                ball_speed_x <= ball_speed_x;
                
            elsif (ball_y + 4 > fielddown_starty) then
                ball_speed_x <= ball_speed_x;
            end if;
                
            
        end if;
        
    elsif (State = Left_Out) then
        --left lifebar change
        lifeleft_endx <= lifeleft_endx-6;
        ball_x <= 320;
        ball_y <= 240;
        
        if (to_integer(lfsr(9 downto 7)) = 0) then
            ball_speed_x <= 1;
        else
            ball_speed_x <= to_integer(lfsr(9 downto 7));
        end if;
        
        if (to_integer(lfsr2(9 downto 7)) = 0) then
            ball_speed_y <= 3;
        else
            ball_speed_y <= to_integer(lfsr2(9 downto 7));
        end if;
        
    elsif (State = Right_Out) then
        --right lifebar change
        liferight_endx <= liferight_endx-6;
        ball_x <= 320;
        ball_y <= 240;
        
        if (to_integer(lfsr(9 downto 7)) = 0) then
            ball_speed_x <= 1;
        else
            ball_speed_x <= to_integer(lfsr(9 downto 7));
        end if;
        
        if (to_integer(lfsr2(9 downto 7)) = 0) then
            ball_speed_y <= 3;
        else
            ball_speed_y <= to_integer(lfsr2(9 downto 7));
        end if;
        
    elsif (State = Left_Win) then
        color_win_left <= '1';
        color_lose_right <= '1';
        gameon_led <= '0';
        
    elsif (State = Right_Win) then
        color_win_right <= '1';
        color_lose_left <= '1';
        gameon_led <= '0';
    end if;

    -- kirajzolas
    if (v_count < v_addr_time and h_count < h_addr_time) then
        -- paddle

        if ((h_count >= left_paddle_startx) and (h_count <= left_paddle_endx))
            and ((v_count>= left_paddle_starty) and (v_count <= left_paddle_endy)) then
            if (color_win_left = '1') then
                RGB_sig <= "000011110000";
            elsif (color_lose_left = '1') then
                RGB_sig <= "111100000000";
            else
                RGB_sig <= "111111111111";
            end if;
        elsif ((h_count >= right_paddle_startx) and (h_count <= right_paddle_endx))
            and ((v_count >= right_paddle_starty) and (v_count <= right_paddle_endy)) then
            if (color_win_right = '1') then
                RGB_sig <= "000011110000";
            elsif (color_lose_right = '1') then
                RGB_sig <= "111100000000";
            else
                RGB_sig <= "111111111111";
            end if;
        -- kozepvonal
        elsif h_count = h_addr_time/2 then
            RGB_sig <= "111111111111";
        -- ball
        elsif (v_count >= ball_y - 2 and v_count <= ball_y + 2) and (h_count >= ball_x - 2 and h_count <= ball_x + 2) then
            RGB_sig <= "111111111111";
        elsif (v_count >= ball_y - 3 and v_count <= ball_y + 3) and (h_count >= ball_x - 1 and h_count <= ball_x + 1) then
            RGB_sig <= "111111111111";
        elsif (v_count >= ball_y - 1 and v_count <= ball_y + 1) and (h_count >= ball_x - 3 and h_count <= ball_x + 3) then
            RGB_sig <= "111111111111";
        --field
        elsif ((((h_count >= fielddown_startx) and (h_count <= fielddown_endx))
            and ((v_count>= fielddown_starty) and (v_count <= fielddown_endy)))
            or (((h_count >= fieldup_startx) and (h_count <= fieldup_endx))
            and ((v_count >= fieldup_starty) and (v_count <= fieldup_endy)))) then
            RGB_sig <= "111111111111";
        --lifebars
        elsif ((((h_count >= liferight_startx) and (h_count <= liferight_endx))
            and ((v_count>= liferight_starty) and (v_count <= liferight_endy)))
            or (((h_count >= lifeleft_startx) and (h_count <= lifeleft_endx))
            and ((v_count >= lifeleft_starty) and (v_count <= lifeleft_endy)))) then
            RGB_sig <= "111111110000";
        -- background
        else
            RGB_sig <= (others => '0');
        end if;
            
    end if;
                   
end if;
END PROCESS;



H <= H_sig;
V <= V_sig;
RGB <= RGB_sig;


my_clk : clk_wiz_0
   port map ( 
   clk_out1 => clk_sig,
   clk_in1 => clk
 );
 
end Behavioral;