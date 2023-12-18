library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity gates is
    port(
        a: in datatype;
        b: in datatype;
        c: out datatype
    );
end entity;

architecture or_l of gates is 
begin
    process (a,b)
    begin 
        c <= a or b;
    end process;
    
end architecture;

architecture and_l of gates is
begin
    process(a ,b)
    begin
        c <= a and b;
    end process;
    
end architecture;

architecture xor_l of gates is 
begin
    process(a, b)
    begin
        c <= a xor b;
    end process;
    
end architecture;