library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;



entity sll_s is
    port(
        a: in datatype; --data from rs1
        b: in datatype; --zero extended lower five bit of rs2 (shamt)
        c: out datatype --data in rd
    );

end entity;

architecture behav of sll_s is
    signal shift: integer := 0;
    signal temp1: datatype;
    begin
        
        shift <= bit_vector2natural(b);
        
        process(a, b, shift)
            variable temp: temparray := (others => (others => '0'));
        begin
    
            if (shift > 31) then
                temp1 <= (others => '0');
                
            else
                temp(0) := a;
                for i in 1 to shift loop
                    temp(i) := temp(i-1)(datasize -2 downto 0) & '0';
                end loop;
                temp1 <= temp(shift);
   
            end if;
        end process;
        c <= temp1;
        
end architecture;