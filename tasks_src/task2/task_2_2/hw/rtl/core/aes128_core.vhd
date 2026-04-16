library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aes128_core is
  port (
    clk_i      : in  std_ulogic;
    rstn_i     : in  std_ulogic;
    start_i    : in  std_ulogic;
    decrypt_i  : in  std_ulogic;
    key_i      : in  std_ulogic_vector(127 downto 0);
    block_i    : in  std_ulogic_vector(127 downto 0);
    done_o     : out std_ulogic;
    result_o   : out std_ulogic_vector(127 downto 0)
  );
end aes128_core;

architecture rtl of aes128_core is

  subtype byte_t is std_ulogic_vector(7 downto 0);
  type byte_array_16_t  is array (0 to 15) of byte_t;
  type byte_array_176_t is array (0 to 175) of byte_t;
  type lut256_t is array (0 to 255) of byte_t;
  type rcon_t is array (0 to 9) of byte_t;

  constant sbox_c : lut256_t := (
    x"63",x"7c",x"77",x"7b",x"f2",x"6b",x"6f",x"c5",x"30",x"01",x"67",x"2b",x"fe",x"d7",x"ab",x"76",
    x"ca",x"82",x"c9",x"7d",x"fa",x"59",x"47",x"f0",x"ad",x"d4",x"a2",x"af",x"9c",x"a4",x"72",x"c0",
    x"b7",x"fd",x"93",x"26",x"36",x"3f",x"f7",x"cc",x"34",x"a5",x"e5",x"f1",x"71",x"d8",x"31",x"15",
    x"04",x"c7",x"23",x"c3",x"18",x"96",x"05",x"9a",x"07",x"12",x"80",x"e2",x"eb",x"27",x"b2",x"75",
    x"09",x"83",x"2c",x"1a",x"1b",x"6e",x"5a",x"a0",x"52",x"3b",x"d6",x"b3",x"29",x"e3",x"2f",x"84",
    x"53",x"d1",x"00",x"ed",x"20",x"fc",x"b1",x"5b",x"6a",x"cb",x"be",x"39",x"4a",x"4c",x"58",x"cf",
    x"d0",x"ef",x"aa",x"fb",x"43",x"4d",x"33",x"85",x"45",x"f9",x"02",x"7f",x"50",x"3c",x"9f",x"a8",
    x"51",x"a3",x"40",x"8f",x"92",x"9d",x"38",x"f5",x"bc",x"b6",x"da",x"21",x"10",x"ff",x"f3",x"d2",
    x"cd",x"0c",x"13",x"ec",x"5f",x"97",x"44",x"17",x"c4",x"a7",x"7e",x"3d",x"64",x"5d",x"19",x"73",
    x"60",x"81",x"4f",x"dc",x"22",x"2a",x"90",x"88",x"46",x"ee",x"b8",x"14",x"de",x"5e",x"0b",x"db",
    x"e0",x"32",x"3a",x"0a",x"49",x"06",x"24",x"5c",x"c2",x"d3",x"ac",x"62",x"91",x"95",x"e4",x"79",
    x"e7",x"c8",x"37",x"6d",x"8d",x"d5",x"4e",x"a9",x"6c",x"56",x"f4",x"ea",x"65",x"7a",x"ae",x"08",
    x"ba",x"78",x"25",x"2e",x"1c",x"a6",x"b4",x"c6",x"e8",x"dd",x"74",x"1f",x"4b",x"bd",x"8b",x"8a",
    x"70",x"3e",x"b5",x"66",x"48",x"03",x"f6",x"0e",x"61",x"35",x"57",x"b9",x"86",x"c1",x"1d",x"9e",
    x"e1",x"f8",x"98",x"11",x"69",x"d9",x"8e",x"94",x"9b",x"1e",x"87",x"e9",x"ce",x"55",x"28",x"df",
    x"8c",x"a1",x"89",x"0d",x"bf",x"e6",x"42",x"68",x"41",x"99",x"2d",x"0f",x"b0",x"54",x"bb",x"16"
  );

  constant inv_sbox_c : lut256_t := (
    x"52",x"09",x"6a",x"d5",x"30",x"36",x"a5",x"38",x"bf",x"40",x"a3",x"9e",x"81",x"f3",x"d7",x"fb",
    x"7c",x"e3",x"39",x"82",x"9b",x"2f",x"ff",x"87",x"34",x"8e",x"43",x"44",x"c4",x"de",x"e9",x"cb",
    x"54",x"7b",x"94",x"32",x"a6",x"c2",x"23",x"3d",x"ee",x"4c",x"95",x"0b",x"42",x"fa",x"c3",x"4e",
    x"08",x"2e",x"a1",x"66",x"28",x"d9",x"24",x"b2",x"76",x"5b",x"a2",x"49",x"6d",x"8b",x"d1",x"25",
    x"72",x"f8",x"f6",x"64",x"86",x"68",x"98",x"16",x"d4",x"a4",x"5c",x"cc",x"5d",x"65",x"b6",x"92",
    x"6c",x"70",x"48",x"50",x"fd",x"ed",x"b9",x"da",x"5e",x"15",x"46",x"57",x"a7",x"8d",x"9d",x"84",
    x"90",x"d8",x"ab",x"00",x"8c",x"bc",x"d3",x"0a",x"f7",x"e4",x"58",x"05",x"b8",x"b3",x"45",x"06",
    x"d0",x"2c",x"1e",x"8f",x"ca",x"3f",x"0f",x"02",x"c1",x"af",x"bd",x"03",x"01",x"13",x"8a",x"6b",
    x"3a",x"91",x"11",x"41",x"4f",x"67",x"dc",x"ea",x"97",x"f2",x"cf",x"ce",x"f0",x"b4",x"e6",x"73",
    x"96",x"ac",x"74",x"22",x"e7",x"ad",x"35",x"85",x"e2",x"f9",x"37",x"e8",x"1c",x"75",x"df",x"6e",
    x"47",x"f1",x"1a",x"71",x"1d",x"29",x"c5",x"89",x"6f",x"b7",x"62",x"0e",x"aa",x"18",x"be",x"1b",
    x"fc",x"56",x"3e",x"4b",x"c6",x"d2",x"79",x"20",x"9a",x"db",x"c0",x"fe",x"78",x"cd",x"5a",x"f4",
    x"1f",x"dd",x"a8",x"33",x"88",x"07",x"c7",x"31",x"b1",x"12",x"10",x"59",x"27",x"80",x"ec",x"5f",
    x"60",x"51",x"7f",x"a9",x"19",x"b5",x"4a",x"0d",x"2d",x"e5",x"7a",x"9f",x"93",x"c9",x"9c",x"ef",
    x"a0",x"e0",x"3b",x"4d",x"ae",x"2a",x"f5",x"b0",x"c8",x"eb",x"bb",x"3c",x"83",x"53",x"99",x"61",
    x"17",x"2b",x"04",x"7e",x"ba",x"77",x"d6",x"26",x"e1",x"69",x"14",x"63",x"55",x"21",x"0c",x"7d"
  );

  constant rcon_c : rcon_t := (
    x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1b", x"36"
  );

  signal done_r   : std_ulogic;
  signal result_r : std_ulogic_vector(127 downto 0);

  function slv8_to_int(x : byte_t) return integer is
  begin
    return to_integer(unsigned(x));
  end function;

  function xtime(x : byte_t) return byte_t is
    variable ux : unsigned(7 downto 0);
    variable r  : unsigned(7 downto 0);
  begin
    ux := unsigned(x);
    r  := shift_left(ux, 1);
    if ux(7) = '1' then
      r := r xor to_unsigned(16#1b#, 8);
    end if;
    return std_ulogic_vector(r);
  end function;

  function gf_mul(a : byte_t; b : byte_t) return byte_t is
    variable aa : byte_t := a;
    variable bb : unsigned(7 downto 0) := unsigned(b);
    variable rr : byte_t := (others => '0');
  begin
    while bb /= 0 loop
      if bb(0) = '1' then
        rr := rr xor aa;
      end if;
      aa := xtime(aa);
      bb := shift_right(bb, 1);
    end loop;
    return rr;
  end function;

  function vec128_to_bytes(v : std_ulogic_vector(127 downto 0)) return byte_array_16_t is
    variable b : byte_array_16_t;
  begin
    for i in 0 to 15 loop
      b(i) := v(127 - i*8 downto 120 - i*8);
    end loop;
    return b;
  end function;

  function bytes_to_vec128(b : byte_array_16_t) return std_ulogic_vector is
    variable v : std_ulogic_vector(127 downto 0);
  begin
    for i in 0 to 15 loop
      v(127 - i*8 downto 120 - i*8) := b(i);
    end loop;
    return v;
  end function;

  function sub_word(w : byte_array_16_t) return byte_array_16_t is
    variable r : byte_array_16_t := w;
  begin
    r(0) := sbox_c(slv8_to_int(w(0)));
    r(1) := sbox_c(slv8_to_int(w(1)));
    r(2) := sbox_c(slv8_to_int(w(2)));
    r(3) := sbox_c(slv8_to_int(w(3)));
    return r;
  end function;

  function key_expansion_128(key : std_ulogic_vector(127 downto 0)) return byte_array_176_t is
    variable rk   : byte_array_176_t;
    variable k    : byte_array_16_t;
    variable temp : byte_array_16_t;
    variable bytes_generated : integer := 16;
    variable rcon_idx        : integer := 0;
    variable t               : byte_t;
  begin
    k := vec128_to_bytes(key);

    for i in 0 to 15 loop
      rk(i) := k(i);
    end loop;

    while bytes_generated < 176 loop
      for i in 0 to 3 loop
        temp(i) := rk(bytes_generated - 4 + i);
      end loop;

      if (bytes_generated mod 16) = 0 then
        t := temp(0);
        temp(0) := temp(1);
        temp(1) := temp(2);
        temp(2) := temp(3);
        temp(3) := t;

        temp(0) := sbox_c(slv8_to_int(temp(0)));
        temp(1) := sbox_c(slv8_to_int(temp(1)));
        temp(2) := sbox_c(slv8_to_int(temp(2)));
        temp(3) := sbox_c(slv8_to_int(temp(3)));

        temp(0) := temp(0) xor rcon_c(rcon_idx);
        rcon_idx := rcon_idx + 1;
      end if;

      for i in 0 to 3 loop
        rk(bytes_generated) := rk(bytes_generated - 16) xor temp(i);
        bytes_generated := bytes_generated + 1;
      end loop;
    end loop;

    return rk;
  end function;

  function add_round_key(state : byte_array_16_t; rk : byte_array_176_t; offset : integer) return byte_array_16_t is
    variable s : byte_array_16_t := state;
  begin
    for i in 0 to 15 loop
      s(i) := s(i) xor rk(offset + i);
    end loop;
    return s;
  end function;

  function sub_bytes(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
  begin
    for i in 0 to 15 loop
      s(i) := sbox_c(slv8_to_int(s(i)));
    end loop;
    return s;
  end function;

  function inv_sub_bytes(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
  begin
    for i in 0 to 15 loop
      s(i) := inv_sbox_c(slv8_to_int(s(i)));
    end loop;
    return s;
  end function;

  function shift_rows(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
    variable t : byte_t;
  begin
    t := s(1);  s(1) := s(5);  s(5) := s(9);  s(9) := s(13); s(13) := t;
    t := s(2);  s(2) := s(10); s(10) := t;    t := s(6);  s(6) := s(14); s(14) := t;
    t := s(15); s(15) := s(11); s(11) := s(7); s(7) := s(3); s(3) := t;
    return s;
  end function;

  function inv_shift_rows(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
    variable t : byte_t;
  begin
    t := s(13); s(13) := s(9);  s(9) := s(5);  s(5) := s(1);  s(1) := t;
    t := s(2);  s(2) := s(10);  s(10) := t;    t := s(6);  s(6) := s(14); s(14) := t;
    t := s(3);  s(3) := s(7);   s(7) := s(11); s(11) := s(15); s(15) := t;
    return s;
  end function;

  function mix_columns(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
    variable a0, a1, a2, a3 : byte_t;
  begin
    for c in 0 to 3 loop
      a0 := s(4*c + 0);
      a1 := s(4*c + 1);
      a2 := s(4*c + 2);
      a3 := s(4*c + 3);

      s(4*c + 0) := gf_mul(a0, x"02") xor gf_mul(a1, x"03") xor a2 xor a3;
      s(4*c + 1) := a0 xor gf_mul(a1, x"02") xor gf_mul(a2, x"03") xor a3;
      s(4*c + 2) := a0 xor a1 xor gf_mul(a2, x"02") xor gf_mul(a3, x"03");
      s(4*c + 3) := gf_mul(a0, x"03") xor a1 xor a2 xor gf_mul(a3, x"02");
    end loop;
    return s;
  end function;

  function inv_mix_columns(state : byte_array_16_t) return byte_array_16_t is
    variable s : byte_array_16_t := state;
    variable a0, a1, a2, a3 : byte_t;
  begin
    for c in 0 to 3 loop
      a0 := s(4*c + 0);
      a1 := s(4*c + 1);
      a2 := s(4*c + 2);
      a3 := s(4*c + 3);

      s(4*c + 0) := gf_mul(a0, x"0e") xor gf_mul(a1, x"0b") xor gf_mul(a2, x"0d") xor gf_mul(a3, x"09");
      s(4*c + 1) := gf_mul(a0, x"09") xor gf_mul(a1, x"0e") xor gf_mul(a2, x"0b") xor gf_mul(a3, x"0d");
      s(4*c + 2) := gf_mul(a0, x"0d") xor gf_mul(a1, x"09") xor gf_mul(a2, x"0e") xor gf_mul(a3, x"0b");
      s(4*c + 3) := gf_mul(a0, x"0b") xor gf_mul(a1, x"0d") xor gf_mul(a2, x"09") xor gf_mul(a3, x"0e");
    end loop;
    return s;
  end function;

  function aes128_encrypt_block(key : std_ulogic_vector(127 downto 0);
                                blk : std_ulogic_vector(127 downto 0)) return std_ulogic_vector is
    variable state : byte_array_16_t;
    variable rk    : byte_array_176_t;
  begin
    state := vec128_to_bytes(blk);
    rk    := key_expansion_128(key);

    state := add_round_key(state, rk, 0);

    for round in 1 to 9 loop
      state := sub_bytes(state);
      state := shift_rows(state);
      state := mix_columns(state);
      state := add_round_key(state, rk, 16*round);
    end loop;

    state := sub_bytes(state);
    state := shift_rows(state);
    state := add_round_key(state, rk, 160);

    return bytes_to_vec128(state);
  end function;

  function aes128_decrypt_block(key : std_ulogic_vector(127 downto 0);
                                blk : std_ulogic_vector(127 downto 0)) return std_ulogic_vector is
    variable state : byte_array_16_t;
    variable rk    : byte_array_176_t;
  begin
    state := vec128_to_bytes(blk);
    rk    := key_expansion_128(key);

    state := add_round_key(state, rk, 160);

    for round in 9 downto 1 loop
      state := inv_shift_rows(state);
      state := inv_sub_bytes(state);
      state := add_round_key(state, rk, 16*round);
      state := inv_mix_columns(state);
    end loop;

    state := inv_shift_rows(state);
    state := inv_sub_bytes(state);
    state := add_round_key(state, rk, 0);

    return bytes_to_vec128(state);
  end function;

begin

  process(clk_i, rstn_i)
  begin
    if rstn_i = '0' then
      done_r   <= '0';
      result_r <= (others => '0');
    elsif rising_edge(clk_i) then
      done_r <= '0';

      if start_i = '1' then
        if decrypt_i = '0' then
          result_r <= aes128_encrypt_block(key_i, block_i);
        else
          result_r <= aes128_decrypt_block(key_i, block_i);
        end if;
        done_r <= '1';
      end if;
    end if;
  end process;

  done_o   <= done_r;
  result_o <= result_r;

end rtl;