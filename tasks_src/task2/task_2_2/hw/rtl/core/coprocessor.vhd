library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coprocessor is
  port (
    clk_i      : in  std_ulogic;
    rstn_i     : in  std_ulogic;
    start_i    : in  std_ulogic;
    mode_i     : in  std_ulogic; -- 0=AES, 1=GIFT
    decrypt_i  : in  std_ulogic; -- 0=encrypt, 1=decrypt
    key_i      : in  std_ulogic_vector(127 downto 0);
    block_i    : in  std_ulogic_vector(127 downto 0);
    busy_o     : out std_ulogic;
    done_o     : out std_ulogic;
    result_o   : out std_ulogic_vector(127 downto 0)
  );
end coprocessor;

architecture rtl of coprocessor is

  signal aes_start, gift_start : std_ulogic;
  signal aes_done, gift_done   : std_ulogic;
  signal aes_res, gift_res     : std_ulogic_vector(127 downto 0);
  signal busy_r, done_r        : std_ulogic;
  signal result_r              : std_ulogic_vector(127 downto 0);
  signal mode_latched          : std_ulogic;

begin

  aes_start  <= start_i and (not mode_i);
  gift_start <= start_i and mode_i;

  u_aes: entity work.aes128_core
    port map (
      clk_i     => clk_i,
      rstn_i    => rstn_i,
      start_i   => aes_start,
      decrypt_i => decrypt_i,
      key_i     => key_i,
      block_i   => block_i,
      done_o    => aes_done,
      result_o  => aes_res
    );

  u_gift: entity work.gift128_core
    port map (
      clk_i     => clk_i,
      rstn_i    => rstn_i,
      start_i   => gift_start,
      decrypt_i => decrypt_i,
      key_i     => key_i,
      block_i   => block_i,
      done_o    => gift_done,
      result_o  => gift_res
    );

  process(clk_i, rstn_i)
  begin
    if rstn_i = '0' then
      busy_r       <= '0';
      done_r       <= '0';
      result_r     <= (others => '0');
      mode_latched <= '0';

    elsif rising_edge(clk_i) then
      done_r <= '0';

      if (start_i = '1' and busy_r = '0') then
        busy_r       <= '1';
        mode_latched <= mode_i;
      end if;

      if busy_r = '1' then
        if (mode_latched = '0' and aes_done = '1') then
          busy_r   <= '0';
          done_r   <= '1';
          result_r <= aes_res;
        elsif (mode_latched = '1' and gift_done = '1') then
          busy_r   <= '0';
          done_r   <= '1';
          result_r <= gift_res;
        end if;
      end if;
    end if;
  end process;

  busy_o   <= busy_r;
  done_o   <= done_r;
  result_o <= result_r;

end rtl;