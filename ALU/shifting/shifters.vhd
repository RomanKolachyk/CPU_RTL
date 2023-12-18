library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity shifters is
    port(
        a: in datatype;
        b: in datatype;
        c: out datatype;
        op: in optype4;
        f3: in func3type;
        f7: in func7type
    );
end entity;

architecture behav of shifters is
    signal sll_temp, srl_temp, sra_temp, slli_temp, srli_temp, srai_temp: datatype := (others => '0');

    begin
    
        sll_s: entity work.sll_s(behav)
            port map(
                a => a,
                b => b,
                c => sll_temp
            );
                      
        srl_s: entity work.srl_s(behav)
            port map(
                a => a,
                b => b,
                c => srl_temp
            );
            
        sra_s: entity work.sra_s(behav)
            port map(
                a => a,
                b => b,
                c => sra_temp
            );
            
        slli_s: entity work.slli_s(behav)
            port map(
                a => a,
                b => b,
                c => slli_temp
            );
            
        srli_s: entity work.srli_s(behav)
            port map(
                a => a,
                b => b,
                c => srli_temp
            );
            
        srai_s: entity work.srai_s(behav)
            port map(
                a => a,
                b => b,
                c => srai_temp
            );
        
        
--        process(a ,b)
--      begin
            --if (op = opcode_op) and (f3 = f3_op_sll) and (f7 = f7_op_sll) then
            c <= sll_temp when ((op = opcode_op) and (f3 = f3_op_sll) and (f7 = f7_op_sll)) else

--           elsif (op = opcode_op) and (f3 = f3_op_srl) and (f7 = f7_op_srl) then
            srl_temp when ((op = opcode_op) and (f3 = f3_op_srl) and (f7 = f7_op_srl)) else

--            elsif (op = opcode_op) and (f3 = f3_op_sra) and (f7 = f7_op_sra) then
            sra_temp when (op = opcode_op) and (f3 = f3_op_sra) and (f7 = f7_op_sra) else

--            elsif (op = opcode_opimm) and (f3 = f3_opimm_slli) and (f7 = f7_opimm_slli) then
            slli_temp when (op = opcode_opimm) and (f3 = f3_opimm_slli) and (f7 = f7_opimm_slli) else

--            elsif (op = opcode_opimm) and (f3 = f3_opimm_srli) and (f7 = f7_opimm_srli) then
            srli_temp when (op = opcode_opimm) and (f3 = f3_opimm_srli) and (f7 = f7_opimm_srli) else

--            elsif (op = opcode_opimm) and (f3 = f3_opimm_srai) and (f7 = f7_opimm_srai) then
            srai_temp when (op = opcode_opimm) and (f3 = f3_opimm_srai) and (f7 = f7_opimm_srai);

--            else
--              assert false report "error in shifters" severity warning;
            
--          end if;
            
--      end process;        

end architecture;