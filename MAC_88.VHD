library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;


entity MAC_88 is
	port (
		A: in std_logic_vector(7 downto 0);
		B: in std_logic_vector(7 downto 0);
		Acc: in std_logic_vector(15 downto 0);
		P: out std_logic_vector(15 downto 0);
		Cout: out std_logic
	);
end entity MAC_88;

architecture obvious of MAC_88 is

--signals used in the design
-- partial product calculation
signal pp: std_logic_vector(63 downto 0);
--stage-1---------------------------------------------------------------
signal first_c: std_logic_vector(11 downto 0);
signal first_s: std_logic_vector(11 downto 0);
--stage-2---------------------------------------------------------------
signal second_c:std_logic_vector(17 downto 0);
signal second_s:std_logic_vector(17 downto 0);
--stage-3---------------------------------------------------------------
signal third_c:std_logic_vector(11 downto 0);
signal third_s:std_logic_vector(11 downto 0);
--stage-4---------------------------------------------------------------
signal fourth_c:std_logic_vector(13 downto 0);
signal fourth_s:std_logic_vector(13 downto 0);
-------------------------final outputs----------------------------------
signal final_1:std_logic_vector(15 downto 0);
signal final_2:std_logic_vector(15 downto 0);
------------------------------------------------------------------------
-- component declarations
component AND8 is
	port (
		A: in std_logic_vector(7 downto 0);
		b: in std_logic;
		prod: out std_logic_vector(7 downto 0)
	);
end component AND8;

component half_adder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end component half_adder;

component full_adder is
	port (
		a: in std_logic;
		b: in std_logic;
		cin: in std_logic;
		s: out std_logic;
		cout: out std_logic
	);
end component full_adder;

component brent_kung_adder is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		C: in std_logic;
		S: out std_logic_vector(15 downto 0);
		Cout: out std_logic
	);
end component brent_kung_adder;

begin

--calculation of partial products using the 8*8 and gate
partial products: for i in 0 to 7 generate
pp_i: AND8 port map(A=>A,B=>B(i),prod=>pp(8*i+7 downto 8*i));

---------------Dadda multiplication scheme implementation--------------------------------

-- We use the Dadda reduction scheme
-- Stage 1
HA_1_1: half_adder port map (a => Acc(5), b => pp(5), s => first_s(0), c => first_c(0));
FA_1_1: full_adder port map (a => Acc(6), b => pp(6), cin => pp(13), s => first_s(1), cout => first_c(1));
HA_1_2: half_adder port map (a => pp(20), b => pp(27), s => first_s(6), c => first_c(6));
FA_1_2: full_adder port map (a => Acc(7), b => pp(7), cin => pp(14), s => first_s(2), cout => first_c(2));
FA_1_3: full_adder port map (a => pp(21), b => pp(28), cin => pp(35), s => first_s(7), cout => first_c(7));
HA_1_3: half_adder port map (a => pp(42), b => pp(49), s => first_s(10), c => first_c(10));
FA_1_4: full_adder port map (a => pp(15), b => pp(22), cin => pp(29), s => first_s(3), cout => first_c(3));
FA_1_5: full_adder port map (a => pp(36), b => pp(43), cin => pp(50), s => first_s(8), cout => first_c(8));
HA_1_4: half_adder port map (a => pp(57), b => Acc(8), s => first_s(11), c => first_c(11));
FA_1_6: full_adder port map (a => pp(23), b => pp(30), cin => pp(58), s => first_s(9), cout => first_c(9));
FA_1_8: full_adder port map (a => pp(31), b => pp(38), cin => pp(45), s => first_s(5), cout => first_c(5));

--Stage 2
HA_2_1: half_adder port map (a => Acc(3), b => pp(3), s => second_s(0), c => second_c(0));
FA_2_1: full_adder port map (a => Acc(4), b => pp(4), cin => pp(11), s => second_s(1), cout => second_c(1));
HA_2_2: half_adder port map (a => pp(18), b => pp(25), s => second_s(10), c => second_c(10));
FA_2_2: full_adder port map (a => first_s(0), b => pp(12), cin => pp(19), s => second_s(2), cout => second_c(2));
FA_2_3: full_adder port map (a => pp(26), b => pp(33), cin => pp(40), s => second_s(11), cout => second_c(11));
FA_2_4: full_adder port map (a => first_s(1), b => first_c(0), cin => first_s(6), s => second_s(3), cout => second_c(3));
FA_2_5: full_adder port map (a => pp(34), b => pp(41), cin => pp(48), s => second_s(12), cout => second_c(12));
FA_2_6: full_adder port map (a => first_s(2), b => first_c(1), cin => first_s(7), s => second_s(4), cout => second_c(4));
FA_2_7: full_adder port map (a => first_s(10), b => first_c(6), cin => pp(56), s => second_s(13), cout => second_c(13));
FA_2_8: full_adder port map (a => first_s(3), b => first_c(2), cin => first_s(8), s => second_s(5), cout => second_c(5));
FA_2_9: full_adder port map (a => first_c(7), b => first_s(11), cin => first_c(10), s => second_s(14), cout => second_c(14));
FA_2_10: full_adder port map (a => first_s(4), b => first_c(3), cin => first_s(9), s => second_s(6), cout => second_c(6));
FA_2_11: full_adder port map (a => first_c(8), b => Acc(9), cin => first_c(11), s => second_s(15), cout => second_c(15));
FA_2_12: full_adder port map (a => first_c(4), b => Acc(10), cin => first_s(5), s => second_s(7), cout => second_c(7));
FA_2_13: full_adder port map (a => first_c(9), b => pp(52), cin => pp(59), s => second_s(16), cout => second_c(16));
FA_2_14: full_adder port map (a => pp(39), b => pp(46), cin => pp(53), s => second_s(8), cout => second_c(8));
FA_1_15: full_adder port map (a => first_c(5), b => Acc(11), cin => pp(60), s => second_s(17), cout => second_c(17));
FA_2_16: full_adder port map (a => pp(47), b => pp(54), cin => pp(61), s => second_s(9), cout => second_c(9));

--Stage 3
HA_3_1: half_adder port map (a => Acc(2), b => pp(2), s => third_s(0), c => third_c(0));
FA_3_1: full_adder port map (a => second_s(0), b => pp(10), cin => pp(17), s => third_s(1), cout => third_c(1));
FA_3_2: full_adder port map (a => second_s(1), b => second_c(0), cin => second_s(10), s => third_s(2), cout => third_c(2));
FA_3_3: full_adder port map (a => second_s(2), b => second_c(1), cin => second_s(11), s => third_s(3), cout => third_c(3));
FA_3_4: full_adder port map (a => second_s(3), b => second_c(2), cin => second_s(12), s => third_s(4), cout => third_c(4));
FA_3_5: full_adder port map (a => second_s(4), b => second_c(3), cin => second_s(13), s => third_s(5), cout => third_c(5));
FA_3_6: full_adder port map (a => second_s(5), b => second_c(4), cin => second_s(14), s => third_s(6), cout => third_c(6));
FA_3_7: full_adder port map (a => second_s(6), b => second_c(5), cin => second_s(15), s => third_s(7), cout => third_c(7));
FA_3_8: full_adder port map (a => second_s(7), b => second_c(6), cin => second_s(16), s => third_s(8), cout => third_c(8));
FA_3_9: full_adder port map (a => second_s(8), b => second_c(7), cin => second_s(17), s => third_s(9), cout => third_c(9));
FA_3_10: full_adder port map (a => second_s(9), b => second_c(8), cin => Acc(12), s => third_s(10), cout => third_c(10));
FA_3_11: full_adder port map (a => second_c(9), b => pp(55), cin => pp(62), s => third_s(11), cout => third_c(11));

-- Stage 4
HA_4_1: half_adder port map (a => Acc(1), b => pp(1), s => fourth_s(0), c => fourth_c(0));
FA_4_1: full_adder port map (a => third_s(0), b => pp(9), cin => pp(16), s => fourth_s(1), cout => fourth_c(1));
FA_4_2: full_adder port map (a => third_s(1), b => third_c(0), cin => pp(24), s => fourth_s(2), cout => fourth_c(2));
FA_4_3: full_adder port map (a => third_s(2), b => third_c(1), cin => pp(32), s => fourth_s(3), cout => fourth_c(3));
FA_4_4: full_adder port map (a => third_s(3), b => third_c(2), cin => second_c(10), s => fourth_s(4), cout => fourth_c(4));
FA_4_5: full_adder port map (a => third_s(4), b => third_c(3), cin => second_c(11), s => fourth_s(5), cout => fourth_c(5));
FA_4_6: full_adder port map (a => third_s(5), b => third_c(4), cin => second_c(12), s => fourth_s(6), cout => fourth_c(6));
FA_4_7: full_adder port map (a => third_s(6), b => third_c(5), cin => second_c(13), s => fourth_s(7), cout => fourth_c(7));
FA_4_8: full_adder port map (a => third_s(7), b => third_c(6), cin => second_c(14), s => fourth_s(8), cout => fourth_c(8));
FA_4_9: full_adder port map (a => third_s(8), b => third_c(7), cin => second_c(15), s => fourth_s(9), cout => fourth_c(9));
FA_4_10: full_adder port map (a => third_s(9), b => third_c(8), cin => second_c(16), s => fourth_s(10), cout => fourth_c(10));
FA_4_11: full_adder port map (a => third_s(10), b => third_c(9), cin => second_c(17), s => fourth_s(11), cout => fourth_c(11));
FA_4_12: full_adder port map (a => third_s(11), b => third_c(10), cin => Acc(13), s => fourth_s(12), cout => fourth_c(12));
FA_4_13: full_adder port map (a => Acc(14), b => third_c(11), cin => pp(63), s => fourth_s(13), cout => fourth_c(13));


-- Fast Adder
final_1 <= (Acc(15) & fourth_s(13 downto 0) & Acc(0));
final_2 <= (fourth_c(13 downto 0) & pp(8) & pp(0));

FastAdd: brent_kung_adder port map (A => final_1, B => final_2, C => '0', S => P, Cout => Cout);

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

entity half_adder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end entity half_adder;

architecture obvious of half_adder is

begin

	s <= a xor b;
	c <= a and b;

end architecture obvious;

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity full_adder is
	port (
		a: in std_logic;
		b: in std_logic;
		cin: in std_logic;
		s: out std_logic;
		cout: out std_logic
	);
end entity full_adder;

architecture Arch of full_adder is

component half_adder is
	port (
		a: in std_logic;
		b: in std_logic;
		s: out std_logic;
		c: out std_logic
	);
end component half_adder;

signal intc1: std_logic;
signal intc2: std_logic;
signal ints1: std_logic;

begin

HA1: half_adder port map (a => a, b => b, s => ints1, c => intc1);
HA2: half_adder port map (a => cin, b => ints1, s => s, c => intc2);

cout <= intc1 or intc2;
	
end architecture Arch;


-------------------defining brent_kung_adder-----------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--------------------------------and ---------------------------------
entity gate3 is
port(A,B:in std_logic;
      pd: out std_logic);
end gate3;
architecture obv1 of gate3 is
begin
pd<= A AND B AFTER 48 ps;
end  obv1;

library IEEE;
use IEEE.std_logic_1164.all;
-----------------------------XOR Gate -----------------------------
entity XOR2 is
port(A,B:in std_logic;
      uneq: out std_logic);
end XOR2;
architecture obv2 of XOR2 is
begin
uneq <= A XOR B AFTER 66 ps;
end  obv2;
------------------------ a+b.c-----------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gate1 is
port(A,B,C:in std_logic;
     abc: out std_logic);
end  gate1;
architecture obv3 of gate1 is
begin
abc<= (A OR( B AND C)) AFTER 76 ps;
end  obv3;
-------------------a.b + c(a+b) ----------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gate2 is
port(A,B,C:in std_logic;
      cout: out std_logic);
end  gate2;
architecture obv4 of gate2 is
begin
cout<= (A AND B) OR (C AND (A OR B)) AFTER 76 ps;
end  obv4;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity brent_kung_adder is
port(A: in STD_LOGIC_VECTOR (15 downto 0);
	B: in STD_LOGIC_VECTOR (15 downto 0);
     C: in std_logic;
     D: out STD_LOGIC_VECTOR (15 downto 0);
	  carry: out std_logic);
end brent_kung_adder;

-----------------------------------------------------------------------------------------
architecture obvious of brent_kung_adder is

	component gate3 is
	port(A,B:in std_logic;
      pd: out std_logic);
	end component gate3;


	component XOR2 is
	port(A,B:in std_logic;
      uneq: out std_logic);
	end component XOR2;


	component gate1 is
	port(A,B,C:in std_logic;
      abc: out std_logic);
	end component gate1;

	component gate2 is
	port(A,B,C:in std_logic;
      cout: out std_logic);
	end component gate2;

signal p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,
g0,g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15,g30,g31,g32,g33,g40,g41,g50,
p20,p21,p22,p23,p24,p25,p26,p27,g20,g21,g22,g23,g24,g25,g26,g27,p30,p31,p32,p33,p40,p41,p50,
C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15
:std_logic;
begin


-----------------------------adder implementation---------------------------
pp0: XOR2 port map( A=> A(0), B=>B(0),uneq=>p0);
gg0: gate2 port map( A=> A(0), B=>B(0),C=>C,cout=>g0);

pp1: XOR2 port map( A=> A(1), B=>B(1),uneq=>p1);
gg1: gate3 port map( A=> A(1), B=>B(1),pd=>g1);

pp2: XOR2 port map( A=> A(2), B=>B(2),uneq=>p2);
gg2: gate3 port map( A=> A(2), B=>B(2),pd=>g2);

pp3: XOR2 port map( A=> A(3), B=>B(3),uneq=>p3);
gg3: gate3 port map( A=> A(3), B=>B(3),pd=>g3);

pp4: XOR2 port map( A=> A(4), B=>B(4),uneq=>p4);
gg4: gate3 port map( A=> A(4), B=>B(4),pd=>g4);

pp5: XOR2 port map( A=> A(5), B=>B(5),uneq=>p5);
gg5: gate3 port map( A=> A(5), B=>B(5),pd=>g5);

pp6: XOR2 port map( A=> A(6), B=>B(6),uneq=>p6);
gg6: gate3 port map( A=> A(6), B=>B(6),pd=>g6);

pp7: XOR2 port map( A=> A(7), B=>B(7),uneq=>p7);
gg7: gate3 port map( A=> A(7), B=>B(7),pd=>g7);

pp8: XOR2 port map( A=> A(8), B=>B(8),uneq=>p8);
gg8: gate3 port map( A=> A(8), B=>B(8),pd=>g8);

pp9: XOR2 port map( A=> A(9), B=>B(9),uneq=>p9);
gg9: gate3 port map( A=> A(9), B=>B(9),pd=>g9);

pp10: XOR2 port map( A=> A(10), B=>B(10),uneq=>p10);
gg10: gate3 port map( A=> A(10), B=>B(10),pd=>g10);

pp11: XOR2 port map( A=> A(11), B=>B(11),uneq=>p11);
gg11: gate3 port map( A=> A(11), B=>B(11),pd=>g11);

pp12: XOR2 port map( A=> A(12), B=>B(12),uneq=>p12);
gg12: gate3 port map( A=> A(12), B=>B(12),pd=>g12);

pp13: XOR2 port map( A=> A(13), B=>B(13),uneq=>p13);
gg13: gate3 port map( A=> A(13), B=>B(13),pd=>g13);

pp14: XOR2 port map( A=> A(14), B=>B(15),uneq=>p14);
gg14: gate3 port map( A=> A(14), B=>B(14),pd=>g14);

pp15: XOR2 port map( A=> A(15), B=>B(15),uneq=>p15);
gg15: gate3 port map( A=> A(15), B=>B(15),pd=>g15);

---------------level 2 P -----------------------------------

p2_0: gate3 port map (A=>p0,B=>p1,pd=>p20);
p2_1: gate3 port map (A=>p3,B=>p2,pd=>p21);
p2_2: gate3 port map (A=>p5,B=>p4,pd=>p22);
p2_3: gate3 port map (A=>p7,B=>p6,pd=>p23);
p2_4: gate3 port map (A=>p9,B=>p8,pd=>p24);
p2_5: gate3 port map (A=>p11,B=>p10,pd=>p25);
p2_6: gate3 port map (A=>p13,B=>p12,pd=>p26);
p2_7: gate3 port map (A=>p14,B=>p15,pd=>p27);

-------------------LEVEL 2 G---------------------------------

G2_0: gate1 port map (A=>g1,B=>p1,C=>g0,abc=>g20);
G2_1: gate1 port map (A=>g3,B=>p3,C=>g2,abc=>g21);
G2_2: gate1 port map (A=>g5,B=>p5,C=>g4,abc=>g22);
G2_3: gate1 port map (A=>g7,B=>p7,C=>g6,abc=>g23);
G2_4: gate1 port map (A=>g9,B=>p9,C=>g8,abc=>g24);
G2_5: gate1 port map (A=>g11,B=>p11,C=>g10,abc=>g25);
G2_6: gate1 port map (A=>g13,B=>p13,C=>g12,abc=>g26);
G2_7: gate1 port map (A=>g15,B=>p15,C=>g14,abc=>g27);

----------------level 3 P and G ----------------------------------------

p3_0: gate3 port map (A=>p21,B=>p20,pd=>p30);
p3_1: gate3 port map (A=>p23,B=>p22,pd=>p31);
p3_2: gate3 port map (A=>p25,B=>p24,pd=>p32);
p3_3: gate3 port map (A=>p27,B=>p26,pd=>p33);



G3_0: gate1 port map (A=>g21,B=>p21,C=>g20,abc=>g30);
G3_1: gate1 port map (A=>g23,B=>p23,C=>g22,abc=>g31);
G3_2: gate1 port map (A=>g25,B=>p25,C=>g24,abc=>g32);
G3_3: gate1 port map (A=>g27,B=>p27,C=>g26,abc=>g33);


----------LEVEL4--------------

p4_0: gate3 port map (A=>p31,B=>p30,pd=>p40);
p4_1: gate3 port map (A=>p33,B=>p32,pd=>p41);

G4_0: gate1 port map (A=>g31,B=>p31,C=>g30,abc=>g40);
G4_1: gate1 port map (A=>g33,B=>p33,C=>g32,abc=>g41);



------------LEVEL5--------------------
p5_0: gate3 port map (A=>p41,B=>p40,pd=>p50);

G5_0: gate1 port map (A=>g41,B=>p41,C=>g40,abc=>g50);

--------------cout-----------------------
L1: gate1 port map (A=>g0,B=>p0,C=>C,abc=>C1);
L2: gate1 port map (A=>g20,B=>p20,C=>C,abc=>C2);
L3: gate1 port map (A=>g2,B=>p2,C=>C2,abc=>C3);
L4: gate1 port map (A=>g30,B=>p30,C=>C,abc=>C4);
L5: gate1 port map (A=>g4,B=>p4,C=>C4,abc=>C5);
L6: gate1 port map (A=>g22,B=>p22,C=>C4,abc=>C6);
L7: gate1 port map (A=>g40,B=>p40,C=>C,abc=>C7);
L8: gate1 port map (A=>g23,B=>p23,C=>C6,abc=>C8);
L9: gate1 port map (A=>g8,B=>p8,C=>C8,abc=>C9);
L10: gate1 port map (A=>g24,B=>p24,C=>C8,abc=>C10);
L11: gate1 port map (A=>g32,B=>p32,C=>C8,abc=>C11);
L12: gate1 port map (A=>g25,B=>p25,C=>C10,abc=>C12);
L13: gate1 port map (A=>g12,B=>p12,C=>C12,abc=>C13);
L14: gate1 port map (A=>g26,B=>p26,C=>C12,abc=>C14);
L15: gate1 port map (A=>g50,B=>p50,C=>C,abc=>C15);

--------------------SUM--------------------------
S0: XOR2 port map( A=>p0, B=>C,uneq=>D(0));
S1: XOR2 port map( A=>p1, B=>C1,uneq=>D(1));
S2: XOR2 port map( A=>p2, B=>C2,uneq=>D(2));
S3: XOR2 port map( A=>p3, B=>C3,uneq=>D(3));
S4: XOR2 port map( A=>p4, B=>C4,uneq=>D(4));
S5: XOR2 port map( A=>p5, B=>C5,uneq=>D(5));
S6: XOR2 port map( A=>p6, B=>C6,uneq=>D(6));
S7: XOR2 port map( A=>p7, B=>C7,uneq=>D(7));
S8: XOR2 port map( A=>p8, B=>C8,uneq=>D(8));
S9: XOR2 port map( A=>p9, B=>C9,uneq=>D(9));
S10: XOR2 port map( A=>p10, B=>C10,uneq=>D(10));
S11: XOR2 port map( A=>p11, B=>C11,uneq=>D(11));
S12: XOR2 port map( A=>p12, B=>C12,uneq=>D(12));
S13: XOR2 port map( A=>p13, B=>C13,uneq=>D(13));
S14: XOR2 port map( A=>p14, B=>C14,uneq=>D(14));
S15: XOR2 port map( A=>p15, B=>C15,uneq=>D(15));
carry <= C15;
end obvious;


