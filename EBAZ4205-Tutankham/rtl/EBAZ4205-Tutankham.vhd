---------------------------------------------------------------------------------
--                          Tutankham - EBAZ4205
--                              Code by Ace
--
--                         Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               21/04/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Fire Right
--   LEFT Ctrl   : Fire Left
--   X  	     : Flash Bomb
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Move Up
--   DOWN arrow  : Move Down
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity tutankham_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic; -- pulled up
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	joy         : in std_logic_vector(8 downto 0);
	dipsw       : in std_logic_vector(4 downto 0);
	led         : out std_logic_vector(7 downto 0)
);
end tutankham_ebaz4205;
------------------------------------------------------------------------------
architecture struct of tutankham_ebaz4205 is
 
 signal	clock_48        : std_logic;
 signal	clock_24        : std_logic;
 signal	clock_12        : std_logic;
 signal	clock_9         : std_logic;
 --
 signal video_r         : std_logic_vector(4 downto 0);
 signal video_g         : std_logic_vector(4 downto 0);
 signal video_b         : std_logic_vector(4 downto 0);
 --
 signal video_r_i       : std_logic_vector(5 downto 0);
 signal video_g_i       : std_logic_vector(5 downto 0);
 signal video_b_i       : std_logic_vector(5 downto 0);
 --
 signal video_r_o       : std_logic_vector(5 downto 0);
 signal video_g_o       : std_logic_vector(5 downto 0);
 signal video_b_o       : std_logic_vector(5 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 signal h_blank         : std_logic;
 signal v_blank	        : std_logic;
  --
 signal audio           : std_logic_vector(15 downto 0);
 signal dac_in          : std_logic_vector(15 downto 0);
 signal audio_pwm       : std_logic;
 --
 signal reset           : std_logic;
 --
 signal SW_LEFT         : std_logic;
 signal SW_RIGHT        : std_logic;
 signal SW_UP           : std_logic;
 signal SW_DOWN         : std_logic;
 signal SW_FIRE         : std_logic;
 signal SW_BOMB         : std_logic;
 signal SW_COIN         : std_logic;
 signal P1_START        : std_logic;
 signal P2_START        : std_logic;
 --
 signal START           : std_logic_vector(1 downto 0);
 signal COIN            : std_logic_vector(1 downto 0);
 signal P1_JOYSTICK     : std_logic_vector(3 downto 0);
 signal P2_JOYSTICK     : std_logic_vector(3 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component tutankham_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

reset       <= not I_RESET; -- reset active = '1'  
greenLED    <= '1'; -- turn off leds
redLED      <= '1';
---------------------------------------------------------------------------
Clocks: tutankham_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_48,
        clk_out2  => clock_9  
    );
---------------------------------------------------------------------------
-- Clocks Divide
process (clock_48)
begin
 if rising_edge(clock_48) then
	clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_24)
begin
 if rising_edge(clock_24) then
	clock_12  <= not clock_12;
 end if;
end process;
---------------------------------------------------------------------------
-- Inputs

SW_LEFT    <= joy_BBBBFRLDU(2) when dipsw(0) = '0' else not joy(0);
SW_RIGHT   <= joy_BBBBFRLDU(3) when dipsw(0) = '0' else not joy(1);
SW_UP      <= joy_BBBBFRLDU(0) when dipsw(0) = '0' else not joy(2);
SW_DOWN    <= joy_BBBBFRLDU(1) when dipsw(0) = '0' else not joy(3);
SW_FIRE    <= joy_BBBBFRLDU(4) when dipsw(0) = '0' else not joy(4);
SW_BOMB    <= joy_BBBBFRLDU(8) when dipsw(0) = '0' else not joy(5);
SW_COIN    <= joy_BBBBFRLDU(7) when dipsw(0) = '0' else not joy(6);
P1_START   <= joy_BBBBFRLDU(5) when dipsw(0) = '0' else not joy(7);
P2_START   <= joy_BBBBFRLDU(6) when dipsw(0) = '0' else not joy(8);

P1_JOYSTICK <= not SW_RIGHT & not SW_LEFT & not SW_DOWN & not SW_UP;
P2_JOYSTICK <= not SW_RIGHT & not SW_LEFT & not SW_DOWN & not SW_UP;
START       <= not P2_START & not P1_START;
COIN        <= '0' & not SW_COIN;
---------------------------------------------------------------------------
-- Main

pm : entity work.Tutankham
port map (
reset           => I_RESET,
clk_49m         => clock_48,
coin            => COIN,
start_buttons   => START,
p1_joystick     => P1_JOYSTICK,
p2_joystick     => P2_JOYSTICK,
m_fire1_l       => SW_FIRE,
m_fire1_r       => SW_FIRE,
m_fire2_l       => SW_FIRE,
m_fire2_r       => SW_FIRE,
m_flash1        => SW_BOMB,
m_flash2        => SW_BOMB,
video_hsync     => h_sync,
video_vsync     => v_sync,
video_vblank    => v_blank,
video_hblank    => h_blank,
video_r         => video_r,
video_g         => video_g,
video_b         => video_b,
sound           => audio,
AD              => AD
);
-----------------------------------------------------------------
video_r_i <= video_r & video_r(4);
video_g_i <= video_g & video_g(4);
video_b_i <= video_b & video_b(4);
-----------------------------------------------------------------
-- scan doubler

dblscan: entity work.scandoubler
	port map(
		clk_sys => clock_24,
		scanlines => "00",
		r_in   => video_r_i,
		g_in   => video_g_i,
		b_in   => video_b_i,
		hs_in  => h_sync,
		vs_in  => v_sync,
		r_out  => video_r_o,
		g_out  => video_g_o,
		b_out  => video_b_o,
		hs_out => O_HSYNC,
		vs_out => O_VSYNC
	);
-----------------------------------------------------------------------------
-- vga output

 O_VIDEO_R  <= video_r_o(5 downto 3);
 O_VIDEO_G  <= video_g_o(5 downto 3);
 O_VIDEO_B  <= video_b_o(5 downto 4);
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => clock_9,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- dac

dac_in <= std_logic_vector(unsigned(audio) + to_unsigned(16#8000#, 16)); -- snd convert

    dac : entity work.dac
    generic map(
      msbi_g  => 15
    )
    port  map(
      clk_i   => clock_12,
      res_n_i => I_RESET,
      dac_i   => dac_in,
      dac_o   => audio_pwm
    );

    O_AUDIO_L <= audio_pwm;
    O_AUDIO_R <= audio_pwm;
-------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(11 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;	
-------------------------------------------------------------------------------
end struct;
