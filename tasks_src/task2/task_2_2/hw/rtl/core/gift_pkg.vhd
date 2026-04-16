library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gift_pkg is
  subtype word32_t is std_ulogic_vector(31 downto 0);
  subtype word16_t is std_ulogic_vector(15 downto 0);
  subtype nibble_t is std_ulogic_vector(3 downto 0);

  type word32_array40_t is array (0 to 39) of word32_t;
  type rc_array40_t is array (0 to 39) of std_ulogic_vector(5 downto 0);
  type sbox_array_t is array (0 to 15) of nibble_t;

  constant GIFT_SBOX_FWD : sbox_array_t := (
    0 => x"1", 1 => x"A", 2 => x"4", 3 => x"C",
    4 => x"6", 5 => x"F", 6 => x"3", 7 => x"9",
    8 => x"2", 9 => x"D", 10 => x"B", 11 => x"7",
    12 => x"5", 13 => x"0", 14 => x"8", 15 => x"E"
  );

  constant GIFT_SBOX_INV : sbox_array_t := (
    0 => x"D", 1 => x"0", 2 => x"8", 3 => x"6",
    4 => x"2", 5 => x"C", 6 => x"4", 7 => x"B",
    8 => x"E", 9 => x"7", 10 => x"1", 11 => x"A",
    12 => x"3", 13 => x"9", 14 => x"F", 15 => x"5"
  );

  constant GIFT_RC : rc_array40_t := (
    0 => "000001", 1 => "000011", 2 => "000111", 3 => "001111",
    4 => "011111", 5 => "111110", 6 => "111101", 7 => "111011",
    8 => "110111", 9 => "101111", 10 => "011110", 11 => "111100",
    12 => "111001", 13 => "110011", 14 => "100111", 15 => "001110",
    16 => "011101", 17 => "111010", 18 => "110101", 19 => "101011",
    20 => "010110", 21 => "101100", 22 => "011000", 23 => "110000",
    24 => "100001", 25 => "000010", 26 => "000101", 27 => "001011",
    28 => "010111", 29 => "101110", 30 => "011100", 31 => "111000",
    32 => "110001", 33 => "100011", 34 => "000110", 35 => "001101",
    36 => "011011", 37 => "110110", 38 => "101101", 39 => "011010"
  );

  function ror16(x : word16_t; n : natural) return word16_t;

  function gift_subcells_fwd(
    s0 : word32_t; s1 : word32_t; s2 : word32_t; s3 : word32_t
  ) return std_ulogic_vector;

  function gift_subcells_inv(
    s0 : word32_t; s1 : word32_t; s2 : word32_t; s3 : word32_t
  ) return std_ulogic_vector;

  function gift_perm0_fwd(x : word32_t) return word32_t;
  function gift_perm1_fwd(x : word32_t) return word32_t;
  function gift_perm2_fwd(x : word32_t) return word32_t;
  function gift_perm3_fwd(x : word32_t) return word32_t;

  function gift_perm0_inv(x : word32_t) return word32_t;
  function gift_perm1_inv(x : word32_t) return word32_t;
  function gift_perm2_inv(x : word32_t) return word32_t;
  function gift_perm3_inv(x : word32_t) return word32_t;

  function gift_rc_word(rc : std_ulogic_vector(5 downto 0)) return word32_t;
end package;

package body gift_pkg is
  type int_array32_t is array (0 to 31) of integer;

  constant P0 : int_array32_t := (
    0,4,8,12,16,20,24,28,3,7,11,15,19,23,27,31,
    2,6,10,14,18,22,26,30,1,5,9,13,17,21,25,29
  );
  constant P1 : int_array32_t := (
    1,5,9,13,17,21,25,29,0,4,8,12,16,20,24,28,
    3,7,11,15,19,23,27,31,2,6,10,14,18,22,26,30
  );
  constant P2 : int_array32_t := (
    2,6,10,14,18,22,26,30,1,5,9,13,17,21,25,29,
    0,4,8,12,16,20,24,28,3,7,11,15,19,23,27,31
  );
  constant P3 : int_array32_t := (
    3,7,11,15,19,23,27,31,2,6,10,14,18,22,26,30,
    1,5,9,13,17,21,25,29,0,4,8,12,16,20,24,28
  );

  function ror16(x : word16_t; n : natural) return word16_t is
    variable y : word16_t;
    variable m : natural := n mod 16;
  begin
    for i in 0 to 15 loop
      y(i) := x((i + m) mod 16);
    end loop;
    return y;
  end function;

  function gift_subcells_apply(
    s0 : word32_t; s1 : word32_t; s2 : word32_t; s3 : word32_t;
    box : sbox_array_t
  ) return std_ulogic_vector is
    variable t0, t1, t2, t3 : word32_t := (others => '0');
    variable n_in  : nibble_t;
    variable n_out : nibble_t;
    variable ret   : std_ulogic_vector(127 downto 0);
  begin
    for i in 0 to 31 loop
      -- Reverse nibble bit ordering for S-box lookup
      n_in(3) := s0(i);
      n_in(2) := s1(i);
      n_in(1) := s2(i);
      n_in(0) := s3(i);

      n_out := box(to_integer(unsigned(n_in)));

      -- Reverse mapping back out as well
      t0(i) := n_out(3);
      t1(i) := n_out(2);
      t2(i) := n_out(1);
      t3(i) := n_out(0);
    end loop;

    ret := t0 & t1 & t2 & t3;
    return ret;
  end function;

  function gift_subcells_fwd(
    s0 : word32_t; s1 : word32_t; s2 : word32_t; s3 : word32_t
  ) return std_ulogic_vector is
  begin
    return gift_subcells_apply(s0, s1, s2, s3, GIFT_SBOX_FWD);
  end function;

  function gift_subcells_inv(
    s0 : word32_t; s1 : word32_t; s2 : word32_t; s3 : word32_t
  ) return std_ulogic_vector is
  begin
    return gift_subcells_apply(s0, s1, s2, s3, GIFT_SBOX_INV);
  end function;

function perm_apply_fwd(x : word32_t; p : int_array32_t) return word32_t is
  variable y : word32_t := (others => '0');
begin
  for i in 0 to 31 loop
    y(p(i)) := x(i);
  end loop;
  return y;
end function;

function perm_apply_inv(x : word32_t; p : int_array32_t) return word32_t is
  variable y : word32_t := (others => '0');
begin
  for i in 0 to 31 loop
    y(i) := x(p(i));
  end loop;
  return y;
end function;

function gift_rc_word(rc : std_ulogic_vector(5 downto 0)) return word32_t is
  variable w : word32_t := (others => '0');
begin
  w(31) := '1';
  w(5 downto 0) := rc;
  return w;
end function;

  function gift_perm0_fwd(x : word32_t) return word32_t is begin return perm_apply_fwd(x, P0); end function;
  function gift_perm1_fwd(x : word32_t) return word32_t is begin return perm_apply_fwd(x, P1); end function;
  function gift_perm2_fwd(x : word32_t) return word32_t is begin return perm_apply_fwd(x, P2); end function;
  function gift_perm3_fwd(x : word32_t) return word32_t is begin return perm_apply_fwd(x, P3); end function;

  function gift_perm0_inv(x : word32_t) return word32_t is begin return perm_apply_inv(x, P0); end function;
  function gift_perm1_inv(x : word32_t) return word32_t is begin return perm_apply_inv(x, P1); end function;
  function gift_perm2_inv(x : word32_t) return word32_t is begin return perm_apply_inv(x, P2); end function;
  function gift_perm3_inv(x : word32_t) return word32_t is begin return perm_apply_inv(x, P3); end function;

end package body;
