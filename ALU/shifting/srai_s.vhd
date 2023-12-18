library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity srai_s is
    port(
        a: in datatype; --data form rs1
        b: in datatype; --zero extended lower five bit of rs2 (shamt)
        c: out datatype --data in rd
    );

end entity;

architecture behav of srai_s is
    signal shift: integer;

    begin
        
        shift <= bit_vector2natural(b);
        
        process(a, b)
            variable temp: datatype;
        begin
            if (a(datasize - 1) = '0') then
                if (shift > 31) then
                    c <= (others => '0');
                else --(others => '0') & a[31 downto shift];
                    for i in 1 to shift loop
                        temp := '0' & a(datasize-2 downto 0);
                    end loop;
                    c <= temp;
                end if;
                                            
            else
                if (shift > 31) then
                    c <= (others => '1');
                
                else
                    for i in 1 to shift loop
                        temp := '1' & a(datasize - 2 downto 0);
                    end loop;
                    
                    c <= temp;
                end if;
            end if;
        end process;
end architecture;