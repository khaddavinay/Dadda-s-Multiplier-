library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;


entity MAC is
	port (
		A: in std_logic_vector(7 downto 0);
		B: in std_logic_vector(7 downto 0);
		Acc: in std_logic_vector(15 downto 0);
		P: out std_logic_vector(15 downto 0);
		Cout: out std_logic
	);
end entity MAC;

architecture Struct of MAC is

-- signal declarations
signal pp: std_logic_vector(63 downto 0);
signal stage_2_s: std_logic_vector(11 downto 0);
signal stage_2_c: std_logic_vector(11 downto 0);
signal stage_3_s: std_logic_vector(17 downto 0);
signal stage_3_c: std_logic_vector(17 downto 0);
signal stage_4_s: std_logic_vector(11 downto 0);
signal stage_4_c: std_logic_vector(11 downto 0);
signal final_s: std_logic_vector(13 downto 0);
signal final_c: std_logic_vector(13 downto 0);
signal term1: std_logic_vector(15 downto 0);
signal term2: std_logic_vector(15 downto 0);

-- component declarations
component AND8 is
	port (
		A: in std_logic_vector(7 downto 0);
		b: in std_logic;
		prod: out std_logic_vector(7 downto 0)
	);
end component AND8;

component halfAdder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end component halfAdder;

component fullAdder is
	port (
		a: in std_logic;
		b: in std_logic;
		cin: in std_logic;
		s: out std_logic;
		cout: out std_logic
	);
end component fullAdder;

component brentKung16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		C: in std_logic;
		S: out std_logic_vector(15 downto 0);
		Cout: out std_logic
	);
end component brentKung16;

begin

-- Get all the partial products so that they are available simultaneously
partialproducts : for i in 0 to 7 generate
	pp_i: AND8 port map (A => A, b=>B(i), prod => pp((8*i + 7) downto 8*i));
end generate partialproducts;
	
-- We use the Dadda reduction scheme
-- Stage 1
HA_1_1: halfAdder port map (a => Acc(5), b => pp(5), s => stage_2_s(0), c => stage_2_c(0));
FA_1_1: fullAdder port map (a => Acc(6), b => pp(6), cin => pp(13), s => stage_2_s(1), cout => stage_2_c(1));
HA_1_2: halfAdder port map (a => pp(20), b => pp(27), s => stage_2_s(6), c => stage_2_c(6));
FA_1_2: fullAdder port map (a => Acc(7), b => pp(7), cin => pp(14), s => stage_2_s(2), cout => stage_2_c(2));
FA_1_3: fullAdder port map (a => pp(21), b => pp(28), cin => pp(35), s => stage_2_s(7), cout => stage_2_c(7));
HA_1_3: halfAdder port map (a => pp(42), b => pp(49), s => stage_2_s(10), c => stage_2_c(10));
FA_1_4: fullAdder port map (a => pp(15), b => pp(22), cin => pp(29), s => stage_2_s(3), cout => stage_2_c(3));
FA_1_5: fullAdder port map (a => pp(36), b => pp(43), cin => pp(50), s => stage_2_s(8), cout => stage_2_c(8));
HA_1_4: halfAdder port map (a => pp(57), b => Acc(8), s => stage_2_s(11), c => stage_2_c(11));
FA_1_6: fullAdder port map (a => pp(23), b => pp(30), cin => pp(37), s => stage_2_s(4), cout => stage_2_c(4));
FA_1_7: fullAdder port map (a => pp(44), b => pp(51), cin => pp(58), s => stage_2_s(9), cout => stage_2_c(9));
FA_1_8: fullAdder port map (a => pp(31), b => pp(38), cin => pp(45), s => stage_2_s(5), cout => stage_2_c(5));

--Stage 2
HA_2_1: halfAdder port map (a => Acc(3), b => pp(3), s => stage_3_s(0), c => stage_3_c(0));
FA_2_1: fullAdder port map (a => Acc(4), b => pp(4), cin => pp(11), s => stage_3_s(1), cout => stage_3_c(1));
HA_2_2: halfAdder port map (a => pp(18), b => pp(25), s => stage_3_s(10), c => stage_3_c(10));
FA_2_2: fullAdder port map (a => stage_2_s(0), b => pp(12), cin => pp(19), s => stage_3_s(2), cout => stage_3_c(2));
FA_2_3: fullAdder port map (a => pp(26), b => pp(33), cin => pp(40), s => stage_3_s(11), cout => stage_3_c(11));
FA_2_4: fullAdder port map (a => stage_2_s(1), b => stage_2_c(0), cin => stage_2_s(6), s => stage_3_s(3), cout => stage_3_c(3));
FA_2_5: fullAdder port map (a => pp(34), b => pp(41), cin => pp(48), s => stage_3_s(12), cout => stage_3_c(12));
FA_2_6: fullAdder port map (a => stage_2_s(2), b => stage_2_c(1), cin => stage_2_s(7), s => stage_3_s(4), cout => stage_3_c(4));
FA_2_7: fullAdder port map (a => stage_2_s(10), b => stage_2_c(6), cin => pp(56), s => stage_3_s(13), cout => stage_3_c(13));
FA_2_8: fullAdder port map (a => stage_2_s(3), b => stage_2_c(2), cin => stage_2_s(8), s => stage_3_s(5), cout => stage_3_c(5));
FA_2_9: fullAdder port map (a => stage_2_c(7), b => stage_2_s(11), cin => stage_2_c(10), s => stage_3_s(14), cout => stage_3_c(14));
FA_2_10: fullAdder port map (a => stage_2_s(4), b => stage_2_c(3), cin => stage_2_s(9), s => stage_3_s(6), cout => stage_3_c(6));
FA_2_11: fullAdder port map (a => stage_2_c(8), b => Acc(9), cin => stage_2_c(11), s => stage_3_s(15), cout => stage_3_c(15));
FA_2_12: fullAdder port map (a => stage_2_c(4), b => Acc(10), cin => stage_2_s(5), s => stage_3_s(7), cout => stage_3_c(7));
FA_2_13: fullAdder port map (a => stage_2_c(9), b => pp(52), cin => pp(59), s => stage_3_s(16), cout => stage_3_c(16));
FA_2_14: fullAdder port map (a => pp(39), b => pp(46), cin => pp(53), s => stage_3_s(8), cout => stage_3_c(8));
FA_1_15: fullAdder port map (a => stage_2_c(5), b => Acc(11), cin => pp(60), s => stage_3_s(17), cout => stage_3_c(17));
FA_2_16: fullAdder port map (a => pp(47), b => pp(54), cin => pp(61), s => stage_3_s(9), cout => stage_3_c(9));

--Stage 3
HA_3_1: halfAdder port map (a => Acc(2), b => pp(2), s => stage_4_s(0), c => stage_4_c(0));
FA_3_1: fullAdder port map (a => stage_3_s(0), b => pp(10), cin => pp(17), s => stage_4_s(1), cout => stage_4_c(1));
FA_3_2: fullAdder port map (a => stage_3_s(1), b => stage_3_c(0), cin => stage_3_s(10), s => stage_4_s(2), cout => stage_4_c(2));
FA_3_3: fullAdder port map (a => stage_3_s(2), b => stage_3_c(1), cin => stage_3_s(11), s => stage_4_s(3), cout => stage_4_c(3));
FA_3_4: fullAdder port map (a => stage_3_s(3), b => stage_3_c(2), cin => stage_3_s(12), s => stage_4_s(4), cout => stage_4_c(4));
FA_3_5: fullAdder port map (a => stage_3_s(4), b => stage_3_c(3), cin => stage_3_s(13), s => stage_4_s(5), cout => stage_4_c(5));
FA_3_6: fullAdder port map (a => stage_3_s(5), b => stage_3_c(4), cin => stage_3_s(14), s => stage_4_s(6), cout => stage_4_c(6));
FA_3_7: fullAdder port map (a => stage_3_s(6), b => stage_3_c(5), cin => stage_3_s(15), s => stage_4_s(7), cout => stage_4_c(7));
FA_3_8: fullAdder port map (a => stage_3_s(7), b => stage_3_c(6), cin => stage_3_s(16), s => stage_4_s(8), cout => stage_4_c(8));
FA_3_9: fullAdder port map (a => stage_3_s(8), b => stage_3_c(7), cin => stage_3_s(17), s => stage_4_s(9), cout => stage_4_c(9));
FA_3_10: fullAdder port map (a => stage_3_s(9), b => stage_3_c(8), cin => Acc(12), s => stage_4_s(10), cout => stage_4_c(10));
FA_3_11: fullAdder port map (a => stage_3_c(9), b => pp(55), cin => pp(62), s => stage_4_s(11), cout => stage_4_c(11));

-- Stage 4
HA_4_1: halfAdder port map (a => Acc(1), b => pp(1), s => final_s(0), c => final_c(0));
FA_4_1: fullAdder port map (a => stage_4_s(0), b => pp(9), cin => pp(16), s => final_s(1), cout => final_c(1));
FA_4_2: fullAdder port map (a => stage_4_s(1), b => stage_4_c(0), cin => pp(24), s => final_s(2), cout => final_c(2));
FA_4_3: fullAdder port map (a => stage_4_s(2), b => stage_4_c(1), cin => pp(32), s => final_s(3), cout => final_c(3));
FA_4_4: fullAdder port map (a => stage_4_s(3), b => stage_4_c(2), cin => stage_3_c(10), s => final_s(4), cout => final_c(4));
FA_4_5: fullAdder port map (a => stage_4_s(4), b => stage_4_c(3), cin => stage_3_c(11), s => final_s(5), cout => final_c(5));
FA_4_6: fullAdder port map (a => stage_4_s(5), b => stage_4_c(4), cin => stage_3_c(12), s => final_s(6), cout => final_c(6));
FA_4_7: fullAdder port map (a => stage_4_s(6), b => stage_4_c(5), cin => stage_3_c(13), s => final_s(7), cout => final_c(7));
FA_4_8: fullAdder port map (a => stage_4_s(7), b => stage_4_c(6), cin => stage_3_c(14), s => final_s(8), cout => final_c(8));
FA_4_9: fullAdder port map (a => stage_4_s(8), b => stage_4_c(7), cin => stage_3_c(15), s => final_s(9), cout => final_c(9));
FA_4_10: fullAdder port map (a => stage_4_s(9), b => stage_4_c(8), cin => stage_3_c(16), s => final_s(10), cout => final_c(10));
FA_4_11: fullAdder port map (a => stage_4_s(10), b => stage_4_c(9), cin => stage_3_c(17), s => final_s(11), cout => final_c(11));
FA_4_12: fullAdder port map (a => stage_4_s(11), b => stage_4_c(10), cin => Acc(13), s => final_s(12), cout => final_c(12));
FA_4_13: fullAdder port map (a => Acc(14), b => stage_4_c(11), cin => pp(63), s => final_s(13), cout => final_c(13));


-- Fast Adder
term1 <= (Acc(15) & final_s(13 downto 0) & Acc(0));
term2 <= (final_c(13 downto 0) & pp(8) & pp(0));

FastAdd: brentKung16 port map (A => term1, B => term2, C => '0', S => P, Cout => Cout);

end architecture Struct;

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity AND8 is
	port (
		A: in std_logic_vector(7 downto 0);
		b: in std_logic;
		prod: out std_logic_vector(7 downto 0)
	);
end entity AND8;

architecture trivial of AND8 is

begin

indiv_pp : for i in 0 to 7 generate
	prod(i) <= A(i) and b;
end generate indiv_pp;
	
end architecture trivial;

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity halfAdder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end entity halfAdder;

architecture obvious of halfAdder is

begin

	s <= a xor b;
	c <= a and b;

end architecture obvious;

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity fullAdder is
	port (
		a: in std_logic;
		b: in std_logic;
		cin: in std_logic;
		s: out std_logic;
		cout: out std_logic
	);
end entity fullAdder;

architecture Arch of fullAdder is

component halfAdder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end component halfAdder;

signal intc1: std_logic;
signal intc2: std_logic;
signal ints1: std_logic;

begin

HA1: halfAdder port map (a => a, b => b, s => ints1, c => intc1);
HA2: halfAdder port map (a => cin, b => ints1, s => s, c => intc2);

cout <= intc1 or intc2;
	
end architecture Arch;


-- simple gates with trivial architectures
--last digit of my roll no is 2
library IEEE;
use IEEE.std_logic_1164.all;
entity andgate is
port (A, B: in std_logic;
prod: out std_logic);
end entity andgate;
architecture trivial of andgate is
begin
prod <= A AND B;
end architecture trivial;

library IEEE;
use IEEE.std_logic_1164.all;
entity xorgate is
port (A, B: in std_logic;
uneq: out std_logic);
end entity xorgate;
architecture trivial of xorgate is
begin
uneq <= A XOR B;
end architecture trivial;

library IEEE;
use IEEE.std_logic_1164.all;
entity abcgate is
port (A, B, C: in std_logic;
abc: out std_logic);
end entity abcgate;
architecture trivial of abcgate is
begin
abc <= A OR (B AND C);
end architecture trivial;

-- A + C.(A+B) with a trivial architecture
library IEEE;
use IEEE.std_logic_1164.all;
entity Cin_map_G is
port(A, B, Cin: in std_logic;
Bit0_G: out std_logic);
end entity Cin_map_G;
architecture trivial of Cin_map_G is
begin
Bit0_G <= (A AND B) OR (Cin AND (A OR B));
end architecture trivial;


library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.all;

entity brentKung16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		C: in std_logic;
		S: out std_logic_vector(15 downto 0);
		Cout: out std_logic
	);
end entity brentKung16;

architecture struct of brentKung16 is

component andgate is
port (A, B: in std_logic;
	prod: out std_logic
	);
end component andgate;

component xorgate is
	port (
		A: in std_logic;
		B: in std_logic;
		uneq: out std_logic
	);
end component xorgate;

component abcgate is
	port (
		A: in std_logic;
		B: in std_logic;
		C: in std_logic;
		abc: out std_logic
	);
end component abcgate;

component Cin_map_G is
	port (
		A: in std_logic;
		B: in std_logic;
		Cin: in std_logic;
		Bit0_G: out std_logic
	);
end component Cin_map_G;

signal p0, g0, intC: std_logic_vector(15 downto 0);
signal p1, g1: std_logic_vector(7 downto 0);
signal p2, g2: std_logic_vector(3 downto 0);
signal p3, g3: std_logic_vector(1 downto 0);
signal p4, g4: std_logic;

begin
-- Stage 0
Stage0 : for i in 0 to 15 generate
	p0_all: xorgate port map (
		A => A(i), B => B(i), uneq => p0(i)
	);
	zerothG : if (i = 0) generate
		g0_0: Cin_map_G port map (
			A => A(0), B => B(0), Cin => C, Bit0_G => g0(0) 
		);
	end generate zerothG;
	otherG: if (i > 0) generate
		g0_rest: andgate port map (
			A => A(i), B => B(i), prod => g0(i)
		);
	end generate otherG;
end generate Stage0;

-- Stage 1

Stage1 : for i in 0 to 7 generate
	p1_all: andgate port map (
		A => p0(2*i), B => p0(2*i + 1), prod => p1(i)
	);
	g1_all: abcgate port map (
		A => g0(2*i + 1), B => g0(2*i), C => p0(2*i + 1), abc => g1(i)
	);
end generate Stage1;

-- Stage 2
	
Stage2 : for i in 0 to 3 generate
	p2_all: andgate port map (
		A => p1(2*i), B => p1(2*i + 1), prod => p2(i)
	);
	g2_all: abcgate port map (
		A => g1(2*i + 1), B => g1(2*i), C => p1(2*i + 1), abc => g2(i)
	);
end generate Stage2;

-- Stage 3

Stage3 : for i in 0 to 1 generate
	p3_all: andgate port map (
		A => p2(2*i), B => p2(2*i + 1), prod => p3(i)
	);
	g3_all: abcgate port map (
		A => g2(2*i + 1), B => g2(2*i), C => p2(2*i + 1), abc => g3(i)
	);
end generate Stage3;

-- Stage 4
	p4_all: andgate port map(A => p3(0), B => p3(1), prod => p4);
	g4_all: abcgate port map(A => g3(1), B => g3(0), C => p3(1), abc => g4);

--------------------------------------------------------------------------------
-- Calculate all carries
--------------------------------------------------------------------------------
-- intC(i) is the internal carry generated by the ith bit
C_0: intC(0) <= g0(0);
C_1: intC(1) <= g1(0);
C_2: abcgate port map(A => g0(2), B=> p0(2), C => intC(1), abc => intC(2));
C_3: intC(3) <= g2(0); 
C_4: abcgate port map(A => g0(4), B=> p0(4), C => intC(3), abc => intC(4));
C_5: abcgate port map(A => g1(2), B=> p1(2), C => intC(3), abc => intC(5));
C_6: abcgate port map(A => g0(6), B=> p0(6), C => intC(5), abc => intC(6));
C_7: intC(7) <= g3(0);
C_8: abcgate port map(A => g0(8), B=> p0(8), C => intC(7), abc => intC(8));
C_9: abcgate port map(A => g1(4), B=> p1(4), C => intC(7), abc => intC(9));
C_10: abcgate port map(A => g0(10), B=> p0(10), C => intC(9), abc => intC(10));
C_11: abcgate port map(A => g2(2), B=> p2(2), C => intC(7), abc => intC(11));
C_12: abcgate port map(A => g0(12), B=> p0(12), C => intC(11), abc => intC(12));
C_13: abcgate port map(A => g1(6), B=> p1(6), C => intC(11), abc => intC(13));
C_14: abcgate port map(A => g0(14), B=> p0(14), C => intC(13), abc => intC(14));
C_15: intC(15) <= g4;
Cout <= intC(15);
--------------------------------------------------------------------------------
-- Calculate all Sums
--------------------------------------------------------------------------------
SUMs : for i in 0 to 15 generate
	zerothS : if (i = 0) generate
		S_0: xorgate port map (A => p0(i), B => C, uneq => S(i));
	end generate zerothS;
	otherG: if (i > 0) generate
		S_rest: xorgate port map (A => p0(i), B => intC(i-1), uneq => S(i));
	end generate otherG;
end generate SUMs;

end architecture struct;