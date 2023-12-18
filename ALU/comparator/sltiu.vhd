library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity sltiu is
    port(
        a: in datatype; --data from rs1
        b: in datatype; --sign extended imm
        c: out datatype --data in rd 
    );
end entity;

architecture behav of sltiu is
    begin

        process(a,b)
        begin
            if (to_unsigned(bit_vector2natural(a), a'length) < to_unsigned(bit_vector2natural(b), b'length)) then  -- signed less than
                c <= (others => '1');
            else -- signed less than
                c <= (others => '0');
            end if;

        end process;

end architecture;