library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_cfs is
  port (
    -- global control --
    clk_i     : in  std_ulogic;
    rstn_i    : in  std_ulogic;

    -- CPU access --
    bus_req_i : in  bus_req_t;
    bus_rsp_o : out bus_rsp_t;

    -- CPU interrupt --
    irq_o     : out std_ulogic;

    -- external IO --
    cfs_in_i  : in  std_ulogic_vector(255 downto 0);
    cfs_out_o : out std_ulogic_vector(255 downto 0)
  );
end neorv32_cfs;

architecture neorv32_cfs_rtl of neorv32_cfs is

  component coprocessor is
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
  end component;

  type cfs_regs_t is array (0 to 15) of std_ulogic_vector(31 downto 0);

  signal cfs_reg_wr  : cfs_regs_t;
  signal cfs_reg_rd  : cfs_regs_t;

  signal key128      : std_ulogic_vector(127 downto 0);
  signal data128     : std_ulogic_vector(127 downto 0);

  signal mode_gift   : std_ulogic;
  signal dec_mode    : std_ulogic;
  signal start_pulse : std_ulogic;

  signal cp_busy     : std_ulogic;
  signal cp_done     : std_ulogic;
  signal cp_result   : std_ulogic_vector(127 downto 0);

  signal done_flag   : std_ulogic;

begin

  ----------------------------------------------------------------------------
  -- optional external conduits currently unused
  ----------------------------------------------------------------------------
  cfs_out_o <= (others => '0');

  ----------------------------------------------------------------------------
  -- pack local 32-bit CFS regs into 128-bit key/data buses
  ----------------------------------------------------------------------------
  key128  <= cfs_reg_wr(3) & cfs_reg_wr(2) & cfs_reg_wr(1) & cfs_reg_wr(0);
  data128 <= cfs_reg_wr(7) & cfs_reg_wr(6) & cfs_reg_wr(5) & cfs_reg_wr(4);

  mode_gift <= cfs_reg_wr(8)(2);
  dec_mode  <= cfs_reg_wr(8)(4);

  ----------------------------------------------------------------------------
  -- crypto coprocessor instance
  ----------------------------------------------------------------------------
  u_coprocessor: coprocessor
    port map (
      clk_i      => clk_i,
      rstn_i     => rstn_i,
      start_i    => start_pulse,
      mode_i     => mode_gift,
      decrypt_i  => dec_mode,
      key_i      => key128,
      block_i    => data128,
      busy_o     => cp_busy,
      done_o     => cp_done,
      result_o   => cp_result
    );

  ----------------------------------------------------------------------------
  -- generate a one-cycle start pulse when software writes REG[8] with bit0=1
  -- and the coprocessor is idle
  ----------------------------------------------------------------------------
  start_gen: process(clk_i, rstn_i)
  begin
    if (rstn_i = '0') then
      start_pulse <= '0';
    elsif rising_edge(clk_i) then
      start_pulse <= '0';

      if (bus_req_i.stb = '1') and (bus_req_i.rw = '1') then
        if (bus_req_i.addr(15 downto 2) = "00000000001000") then
          if (bus_req_i.data(0) = '1') and (cp_busy = '0') then
            start_pulse <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- bus write/read access
  ----------------------------------------------------------------------------
  bus_access: process(clk_i, rstn_i)
  begin
    if (rstn_i = '0') then
      for i in 0 to 15 loop
        cfs_reg_wr(i) <= (others => '0');
      end loop;
      bus_rsp_o <= rsp_terminate_c;

    elsif rising_edge(clk_i) then
      bus_rsp_o.ack  <= bus_req_i.stb;
      bus_rsp_o.err  <= '0';
      bus_rsp_o.data <= (others => '0');

      if (bus_req_i.stb = '1') then
        if (bus_req_i.rw = '1') then
          case bus_req_i.addr(15 downto 2) is
            when "00000000000000" => cfs_reg_wr(0) <= bus_req_i.data; -- key[31:0]
            when "00000000000001" => cfs_reg_wr(1) <= bus_req_i.data; -- key[63:32]
            when "00000000000010" => cfs_reg_wr(2) <= bus_req_i.data; -- key[95:64]
            when "00000000000011" => cfs_reg_wr(3) <= bus_req_i.data; -- key[127:96]

            when "00000000000100" => cfs_reg_wr(4) <= bus_req_i.data; -- block[31:0]
            when "00000000000101" => cfs_reg_wr(5) <= bus_req_i.data; -- block[63:32]
            when "00000000000110" => cfs_reg_wr(6) <= bus_req_i.data; -- block[95:64]
            when "00000000000111" => cfs_reg_wr(7) <= bus_req_i.data; -- block[127:96]

            when "00000000001000" =>
              -- SW-writable control bits:
              -- bit2 = mode_gift
              -- bit4 = decrypt
              -- bit0 is handled as a pulse by hardware
              -- bit1 and bit3 are status bits only
              cfs_reg_wr(8)(31 downto 5) <= bus_req_i.data(31 downto 5);
              cfs_reg_wr(8)(4)           <= bus_req_i.data(4); -- decrypt
              cfs_reg_wr(8)(3)           <= '0';               -- busy is HW status
              cfs_reg_wr(8)(2)           <= bus_req_i.data(2); -- mode
              cfs_reg_wr(8)(1)           <= '0';               -- done is HW status
              cfs_reg_wr(8)(0)           <= '0';               -- start is pulse only

            when others =>
              null;
          end case;
        else
          case bus_req_i.addr(15 downto 2) is
            when "00000000000000" => bus_rsp_o.data <= cfs_reg_rd(0);
            when "00000000000001" => bus_rsp_o.data <= cfs_reg_rd(1);
            when "00000000000010" => bus_rsp_o.data <= cfs_reg_rd(2);
            when "00000000000011" => bus_rsp_o.data <= cfs_reg_rd(3);

            when "00000000000100" => bus_rsp_o.data <= cfs_reg_rd(4);
            when "00000000000101" => bus_rsp_o.data <= cfs_reg_rd(5);
            when "00000000000110" => bus_rsp_o.data <= cfs_reg_rd(6);
            when "00000000000111" => bus_rsp_o.data <= cfs_reg_rd(7);

            when "00000000001000" => bus_rsp_o.data <= cfs_reg_rd(8);

            when "00000000001001" => bus_rsp_o.data <= cfs_reg_rd(9);
            when "00000000001010" => bus_rsp_o.data <= cfs_reg_rd(10);
            when "00000000001011" => bus_rsp_o.data <= cfs_reg_rd(11);
            when "00000000001100" => bus_rsp_o.data <= cfs_reg_rd(12);

            when others           => bus_rsp_o.data <= (others => '0');
          end case;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- readback and result/status handling
  ----------------------------------------------------------------------------
  status_regs: process(clk_i, rstn_i)
  begin
    if (rstn_i = '0') then
      for i in 0 to 15 loop
        cfs_reg_rd(i) <= (others => '0');
      end loop;
      done_flag <= '0';

    elsif rising_edge(clk_i) then
      -- mirror key/block write registers for debug
      cfs_reg_rd(0) <= cfs_reg_wr(0);
      cfs_reg_rd(1) <= cfs_reg_wr(1);
      cfs_reg_rd(2) <= cfs_reg_wr(2);
      cfs_reg_rd(3) <= cfs_reg_wr(3);

      cfs_reg_rd(4) <= cfs_reg_wr(4);
      cfs_reg_rd(5) <= cfs_reg_wr(5);
      cfs_reg_rd(6) <= cfs_reg_wr(6);
      cfs_reg_rd(7) <= cfs_reg_wr(7);

      -- clear done when a new operation starts
      if (start_pulse = '1') then
        done_flag <= '0';
      end if;

      -- latch result when crypto finishes
      if (cp_done = '1') then
        done_flag <= '1';

        cfs_reg_rd(9)  <= cp_result(31 downto 0);
        cfs_reg_rd(10) <= cp_result(63 downto 32);
        cfs_reg_rd(11) <= cp_result(95 downto 64);
        cfs_reg_rd(12) <= cp_result(127 downto 96);
      end if;

      -- control/status readback
      cfs_reg_rd(8) <= (others => '0');
      cfs_reg_rd(8)(1) <= done_flag;
      cfs_reg_rd(8)(2) <= cfs_reg_wr(8)(2); -- mode
      cfs_reg_rd(8)(3) <= cp_busy;          -- busy
      cfs_reg_rd(8)(4) <= cfs_reg_wr(8)(4); -- decrypt
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- interrupt when operation completed
  ----------------------------------------------------------------------------
  irq_o <= done_flag;

end neorv32_cfs_rtl;