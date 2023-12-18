library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity slti is
    port(
        a: in datatype; --data form rs1
        b: in datatype; --sign extended imm
        c: out datatype --data in rd
    );
end entity;

architecture behav of slti is
    begin

        process(a,b)
        begin
            if (a < b) then  -- signed less than
                c <= (others => '1');
            else
                c <= (others => '0');
            end if;

        end process;

end architecture;