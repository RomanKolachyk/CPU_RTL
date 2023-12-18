library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity srl_s is
    port(
        a: in datatype; --data form rs1
        b: in datatype; --zero extended lower five bit of rs2 (shamt)
        c: out datatype --data in rd
    );

end entity;

architecture behav of srl_s is
    signal shift: bit_vector (4 downto 0);
    signal t1, t2, t3, t4, t5 : datatype := (others => '0');
    --signal test: temparray;
    
    begin
        
        shift <= b(4 downto 0);
        
        t1 <= ('0' & a(datasize-1 downto 1)) when (shift(0) = '1') else a;
        t2 <= (B"00" & t1(datasize-2 downto 1)) when (shift(1) = '1') else t1;
        t3 <= (B"0000" & t2(datasize-4 downto 1)) when (shift(2) = '1') else t2;     
        t4 <= (B"00000000" & t3(datasize-8 downto 1)) when (shift(3) = '1') else t3;
        t5 <= (B"0000000000000000" & t4(datasize-16 downto 1)) when (shift(4) = '1') else t4;
        
        c <= t5;
        
--        process(a, b)
--  --          variable temp_shift : temparray:= (others => (others => '0'));
--        begin
            
            
--            if (shift(0) = '1') then
--                t1 <= ('0' & temp(datasize-1 downto 1));
--            else
--                t1 <= temp;
--            end if;    
            
--            if (shift(1) = '1') then
--                t2 <= (B"00" & t1(datasize-2 downto 1));
--            else
--                t2 <= t1;
--            end if;
            
--            if (shift(2) = '1') then
--                t3 <= (B"0000" & t2(datasize-4 downto 1));
--            else
--                t3 <= t2;
--            end if;
            
--            if (shift(3) = '1') then
--                t4 <= (B"00000000" & t3(datasize-8 downto 1));
--            else
--                t4 <= t3;
--            end if;
            
--            if (shift(4) = '1') then
--                t5 <= (B"0000000000000000" & t4(datasize-16 downto 1));
--            else
--                t5 <= t4;
--            end if;
--            if (shift > 31) then
--                temp1 <= (others => '0');
            
--            else
                
--            c <= t5;
--                temp_shift(0) := a;
--                for i in 1 to shift loop
--                    temp_shift(i) := B"0" & temp_shift(i-1)(datasize-1 downto 1);
--                end loop;
--                --c <= (others => '0') & a[31 downt shift];
--                temp1 <= temp_shift(shift);
--            end if;
--        end process;
end architecture;