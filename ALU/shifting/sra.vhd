library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity sra_s is
    port(
        a: in datatype; --data form rs1
        b: in datatype; --zero extended lower five bit of rs2 (shamt)
        c: out datatype --data in rd
    );

end entity;

architecture behav of sra_s is
    signal shift: bit_vector(4 downto 0);
    signal t1, t2, t3, t4, t5: datatype;

    begin
        
        shift <= b(4 downto 0);
        
        
                t1 <= (a(datasize-1) & a(datasize-1 downto 1)) when (shift(0) = '1') else a;
                t2 <= (a(datasize-1) &a(datasize-1) & t1(datasize-1 downto 2)) when (shift(1) = '1') else t1;
                t3 <= (a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) & t2(datasize-1 downto 4)) when (shift(2) = '1') else t2;     
                t4 <= (a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) & t3(datasize-1 downto 8)) when (shift(3) = '1') else t3;
                t5 <= (a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) &a(datasize-1) & t4(datasize-1 downto 16)) when (shift(4) = '1') else t4;
                
        c <= t5;
--                if (shift > 31) then
--                    c <= (others => '0');
--                else --(others => '0') & a[31 downto shift];
--                    for i in 1 to shift loop
--                        temp := '0' & a(datasize-2 downto 0);
--                    end loop;
--                    c <= temp;
--                end if;
                                            
--            else
--                if (shift > 31) then
--                    c <= (others => '1');
                
--                else
--                    for i in 1 to shift loop
--                        temp := '1' & a(datasize - 2 downto 0);
--                    end loop;
                    
--                    c <= temp;
--                end if;
--            end if;
--     end process;
end architecture;