library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gift_pkg.all;

entity gift128_core is
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
end gift128_core;

architecture rtl of gift128_core is
  signal s0_r, s1_r, s2_r, s3_r : word32_t;
  signal s0_n, s1_n, s2_n, s3_n : word32_t;
  signal rk_u, rk_v             : word32_array40_t;
  signal active_r               : std_ulogic;
  signal done_r                 : std_ulogic;
  signal dec_r                  : std_ulogic;
  signal round_r                : integer range 0 to 39;
  signal result_r               : std_ulogic_vector(127 downto 0);

  signal rk_u_cur, rk_v_cur : word32_t;
  signal rc_cur             : std_ulogic_vector(5 downto 0);
  signal rk_idx             : integer range 0 to 39;
begin
  rk_idx   <= round_r when dec_r = '0' else (39 - round_r);
  rk_u_cur <= rk_u(rk_idx);
  rk_v_cur <= rk_v(rk_idx);
  rc_cur   <= GIFT_RC(rk_idx);

  u_round: entity work.gift_round
    port map (
      decrypt_i => dec_r,
      rc_i      => rc_cur,
      rk_u_i    => rk_u_cur,
      rk_v_i    => rk_v_cur,
      s0_i      => s0_r,
      s1_i      => s1_r,
      s2_i      => s2_r,
      s3_i      => s3_r,
      s0_o      => s0_n,
      s1_o      => s1_n,
      s2_o      => s2_n,
      s3_o      => s3_n
    );

  process(clk_i, rstn_i)
    variable w0, w1, w2, w3, w4, w5, w6, w7 : word16_t;
    variable n0, n1, n2, n3, n4, n5, n6, n7 : word16_t;
    variable bs0, bs1, bs2, bs3             : word32_t;
    variable bout                           : std_ulogic_vector(127 downto 0);
  begin
    if rstn_i = '0' then
      s0_r     <= (others => '0');
      s1_r     <= (others => '0');
      s2_r     <= (others => '0');
      s3_r     <= (others => '0');
      result_r <= (others => '0');
      active_r <= '0';
      done_r   <= '0';
      dec_r    <= '0';
      round_r  <= 0;
      for i in 0 to 39 loop
        rk_u(i) <= (others => '0');
        rk_v(i) <= (others => '0');
      end loop;

    elsif rising_edge(clk_i) then
      done_r <= '0';

      if (start_i = '1') and (active_r = '0') then
        w0 := key_i(127 downto 112);
        w1 := key_i(111 downto 96);
        w2 := key_i(95 downto 80);
        w3 := key_i(79 downto 64);
        w4 := key_i(63 downto 48);
        w5 := key_i(47 downto 32);
        w6 := key_i(31 downto 16);
        w7 := key_i(15 downto 0);

        for i in 0 to 39 loop
          rk_u(i) <= w2 & w3;
          rk_v(i) <= w6 & w7;

          n0 := ror16(w6, 2);
          n1 := ror16(w7, 12);
          n2 := w0;
          n3 := w1;
          n4 := w2;
          n5 := w3;
          n6 := w4;
          n7 := w5;

          w0 := n0;
          w1 := n1;
          w2 := n2;
          w3 := n3;
          w4 := n4;
          w5 := n5;
          w6 := n6;
          w7 := n7;
        end loop;

        -- MSB-side bitslice mapping
        for i in 0 to 31 loop
          bs0(31 - i) := block_i(127 - (4*i));
          bs1(31 - i) := block_i(126 - (4*i));
          bs2(31 - i) := block_i(125 - (4*i));
          bs3(31 - i) := block_i(124 - (4*i));
        end loop;

        s0_r <= bs0;
        s1_r <= bs1;
        s2_r <= bs2;
        s3_r <= bs3;

        result_r <= (others => '0');
        dec_r    <= decrypt_i;
        round_r  <= 0;
        active_r <= '1';

      elsif active_r = '1' then
        if round_r = 39 then
          bout := (others => '0');
          for i in 0 to 31 loop
            bout(127 - (4*i)) := s0_n(31 - i);
            bout(126 - (4*i)) := s1_n(31 - i);
            bout(125 - (4*i)) := s2_n(31 - i);
            bout(124 - (4*i)) := s3_n(31 - i);
          end loop;

          result_r <= bout;
          active_r <= '0';
          done_r   <= '1';
        else
          s0_r    <= s0_n;
          s1_r    <= s1_n;
          s2_r    <= s2_n;
          s3_r    <= s3_n;
          round_r <= round_r + 1;
        end if;
      end if;
    end if;
  end process;

  done_o   <= done_r;
  result_o <= result_r;
end rtl;