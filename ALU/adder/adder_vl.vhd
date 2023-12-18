library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity adder_vl is 
    port(
         a: in datatype;
         b: in datatype;
         neg: in bit;
         c: out datatype
     );
end adder_vl;

architecture Behav of adder_vl is

begin
    
    process(a, b, neg)
        variable carry : bit;
    begin
        carry := neg;
        
        for i in 0 to datasize-1 loop
             c(i) <= carry xor (a(i) xor b(i));
             carry := (a(i) and b(i)) or (carry and (a(i) xor b(i)));
        end loop;
               
   end process;

end Behav;
