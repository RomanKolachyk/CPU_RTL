library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity compare is 
    port(
        a: in datatype;
        b: in datatype;
        c: out datatype;
        op: in optype4;
        f3: in func3type;
        f7: in func7type
    );
end entity;

architecture behav of compare is
    signal slt_temp, sltu_temp, slti_temp, sltiu_temp: datatype:= (others => '0');
begin  
    slt: entity work.slt(behav)
    port map(
        a => a,
        b => b,
        c => slt_temp
    );

    sltu: entity work.sltu(behav)
    port map(
            a => a,
            b => b,
            c => sltu_temp
    );

    slti: entity work.slti(behav)
    port map(
        a => a,
        b => b,
        c => slti_temp
    );

    sltiu: entity work.sltiu(behav)
    port map(
        a => a,
        b => b,
        c => sltiu_temp
    );

    process(a, b)
    begin
        if ((op = opcode_op) and (f3 = f3_op_slt) and (f7 = f7_op_slt)) then
            c <= slt_temp;
            
        elsif ((op = opcode_opimm) and (f3 = f3_opimm_slti)) then
            c <= slti_temp;
            
        
        elsif ((op = opcode_op) and (f3 = f3_op_sltu) and (f7 = f7_op_sltu)) then
            c <= sltu_temp;
        
        elsif ((op = opcode_opimm) and (f3 = f3_opimm_sltiu)) then
            c <= sltiu_temp;
            
        else
            assert false report "error in compare" severity warning;
        
        end if;
        
    end process;
    
end architecture;
