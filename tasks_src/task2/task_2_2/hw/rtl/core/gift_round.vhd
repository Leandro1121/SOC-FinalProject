library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gift_pkg.all;

entity gift_round is
  port (
    decrypt_i : in  std_ulogic;
    rc_i      : in  std_ulogic_vector(5 downto 0);
    rk_u_i    : in  word32_t;
    rk_v_i    : in  word32_t;
    s0_i      : in  word32_t;
    s1_i      : in  word32_t;
    s2_i      : in  word32_t;
    s3_i      : in  word32_t;
    s0_o      : out word32_t;
    s1_o      : out word32_t;
    s2_o      : out word32_t;
    s3_o      : out word32_t
  );
end gift_round;

architecture rtl of gift_round is
begin
  process(decrypt_i, rc_i, rk_u_i, rk_v_i, s0_i, s1_i, s2_i, s3_i)
    variable a0, a1, a2, a3 : word32_t;
    variable b0, b1, b2, b3 : word32_t;
    variable sc             : std_ulogic_vector(127 downto 0);
  begin
    if decrypt_i = '0' then
      sc := gift_subcells_fwd(s0_i, s1_i, s2_i, s3_i);
      a0 := sc(127 downto 96);
      a1 := sc(95 downto 64);
      a2 := sc(63 downto 32);
      a3 := sc(31 downto 0);

      b0 := gift_perm0_fwd(a0);
      b1 := gift_perm1_fwd(a1);
      b2 := gift_perm2_fwd(a2);
      b3 := gift_perm3_fwd(a3);

      s0_o <= b0;
      s1_o <= b1 xor rk_u_i;
      s2_o <= b2 xor rk_v_i;
      s3_o <= b3 xor gift_rc_word(rc_i);
    else
      a0 := s0_i;
      a1 := s1_i xor rk_u_i;
      a2 := s2_i xor rk_v_i;
      a3 := s3_i xor gift_rc_word(rc_i);

      b0 := gift_perm0_inv(a0);
      b1 := gift_perm1_inv(a1);
      b2 := gift_perm2_inv(a2);
      b3 := gift_perm3_inv(a3);

      sc := gift_subcells_inv(b0, b1, b2, b3);
      s0_o <= sc(127 downto 96);
      s1_o <= sc(95 downto 64);
      s2_o <= sc(63 downto 32);
      s3_o <= sc(31 downto 0);
    end if;
  end process;
end rtl;