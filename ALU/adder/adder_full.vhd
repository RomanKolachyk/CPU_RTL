library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity adder_full is
    port(
        a: in bit;
        b: in bit;
        carry_in: in bit;
        c: out bit;
        carry_out: out bit
    );
end entity adder_full;

architecture behav of adder_full is

signal z1, z2: bit;
    
    begin
        z1 <= a and b;
        z2 <= a xor b;

        c <= z2 xor carry_in;
        carry_out <= z1 or (z2 and carry_in);

end behav;