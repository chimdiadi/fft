library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity twiddle_rom_tb is
end twiddle_rom_tb;

architecture behav of twiddle_rom_tb is
	signal clk	: std_logic := '0';
	signal arg	: std_logic_vector(2 downto 0) := (others => '0');
	signal q_sin	: std_logic_vector(7 downto 0);
	signal q_cos	: std_logic_vector(7 downto 0);

begin
	dut : entity work.twiddle_rom
	generic map (
		inwidth => 3,
		outwidth => 8
	)
	port map (
		clk => clk,
		arg => arg,
		q_sin => q_sin,
		q_cos => q_cos
	);
	clk <= not clk after 50 ns;

	process
	begin
		wait until rising_edge(clk);
		arg <= std_logic_vector(unsigned(arg) + to_unsigned(1, 3));
	end process;
end behav;
