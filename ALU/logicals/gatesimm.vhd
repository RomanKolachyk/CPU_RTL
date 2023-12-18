library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity gatesimm is
    port(
        a: in datatype;
        b: in datatype;
        c: out datatype
    );
end entity;

architecture andi_l of gatesimm is
begin
    c <= a and b;
        
end architecture;

architecture ori_l of gatesimm is
begin
    c <= a or b;
        
end architecture;

architecture xori_l of gatesimm is
begin
    c <= a xor b;
        
end architecture;