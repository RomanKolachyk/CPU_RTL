library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity adder is 
    port(
         a: in datatype;
         b: in datatype;
         neg: in bit;
         c: out datatype    );

end adder;

architecture behav of adder is

    signal a_int, b_int, c_int, carry_int: datatype;
begin
    process(a, b)
    begin
        if(neg = '1') then  
            b_int <= not b;

        else 
            b_int <= b;

        end if;
    end process;

    a_int <= a;
    
    adder0: entity work.adder_full(behav)
        port map(
            a => a_int(0),
            b => b_int(0),
            carry_in => neg,
            c => c_int(0),
            carry_out =>  carry_int(1)
        );

    adders1to30: for i in 1 to datasize-2 generate
        adderi : entity work.adder_full(behav)
            port map(
                a => a_int(i),
                b => b_int(i),
                carry_in => carry_int(i),
                c => c_int(i),
                carry_out => c_int(i+1)
            );
    end generate;

    adder31: entity work.adder_full(behav)
        port map(
            a => a_int(datasize - 1),
            b => b_int(datasize - 1),
            carry_in => carry_int(datasize - 1),
            c => c_int(datasize - 1),
            carry_out => carry_int(0)
        );

    c <= c_int;

end behav;