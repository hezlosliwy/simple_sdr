library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;
entity axis_fsource is
  generic (
    FILE_NAME           : string  := "file.in";
    DATA_WIDTH_IN_BYTES : integer := 1
  );
  port (
    rst       : in std_logic;
    clk       : in std_logic;
    out_valid : out std_logic;
    out_ready : in std_logic;
    out_data  : out std_logic_vector(DATA_WIDTH_IN_BYTES * 8 - 1 downto 0);
    eof       : out std_logic
  );
end entity;

architecture rtl of axis_fsource is
  signal f_open         : std_logic;
  signal available_data : integer;
  signal out_valid_int  : std_logic;
  signal eof_int        : std_logic;
begin

  out_valid <= out_valid_int;
  eof <= eof_int;
  process (clk)
    type INTF is file of character;
    file in_file     : INTF;
    variable in_data : character;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        out_valid_int      <= '0';
        out_data       <= (others => '0');
        eof_int            <= '0';
        f_open         <= '0';
        available_data <= 0;
      elsif ((out_valid_int = '1' and out_ready = '1') or out_valid_int = '0') and eof_int = '0' then
        if f_open = '0' and eof_int = '0' then
          file_open(in_file, FILE_NAME, read_mode);
          f_open <= '1';
        end if;
        for i in DATA_WIDTH_IN_BYTES - 1 downto 0 loop
          if not endfile(in_file) then
            read(in_file, in_data);
            out_data((i + 1) * 8 - 1 downto i * 8) <= std_logic_vector(to_unsigned(character'pos(in_data), 8));
            out_valid_int                              <= '1';
          else
            out_data((i + 1) * 8 - 1 downto 0) <= (others => 'U');
            file_close(in_file);
            out_valid_int <= '0';
            eof_int       <= '1';
            exit;
          end if;
        end loop;
      end if;
    end if;
  end process;

end architecture;