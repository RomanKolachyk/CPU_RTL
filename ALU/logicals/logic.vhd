library ieee;

use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity logic is
    port (
        a: in datatype;
        b: in datatype;
        c: out datatype;
        op: in optype4;
        f3: in func3type;
        f7: in func7type      
    ) ;
end entity;

architecture behav of logic is

    signal xor_temp, or_temp, and_temp, ori_temp, andi_temp, xori_temp: datatype:= (others => '0');

        begin
            
            or_l: entity work.gates(or_l)
                port map(
                    a => a,
                    b => b,
                    c => or_temp
                );

            and_l: entity work.gates(and_l)
                port map(
                    a => a,
                    b => b,
                    c => and_temp
                );
            
            xor_l: entity work.gates(xor_l)
                port map(
                    a => a,
                    b => b,
                    c => xor_temp
                );
            
            ori_l: entity work.gatesimm(ori_l)
                port map(
                    a => a,
                    b => b,
                    c => ori_temp
                );
                
            andi_l: entity work.gatesimm(andi_l)
                port map(
                    a => a,
                    b => b,
                    c => andi_temp
                );
                
            xori_l: entity work.gatesimm(xori_l)
                port map(
                    a => a,
                    b => b,
                    c => xori_temp
                );
            
            
            --process(a, b, op, f3, f7)
            --begin
                --if ((op = opcode_op) and (f3 = f3_op_xor) and (f7 = f7_op_xor)) then
                    c <= xor_temp when ((op = opcode_op) and (f3 = f3_op_xor) and (f7 = f7_op_xor)) else 
                      
                --elsif ((op = opcode_op) and (f3 = f3_op_and) and (f7 = f7_op_and)) then
                    and_temp when ((op = opcode_op) and (f3 = f3_op_and) and (f7 = f7_op_and))else
                
                --elsif ((op = opcode_op) and (f3 = f3_op_or) and (f7 = f7_op_or)) then
                    or_temp when ((op = opcode_op) and (f3 = f3_op_or) and (f7 = f7_op_or)) else
                    
                --elsif ((op = opcode_opimm) and (f3 = f3_opimm_xori)) then
                    xori_temp when ((op = opcode_opimm) and (f3 = f3_opimm_xori)) else
                    
                --elsif ((op = opcode_opimm) and (f3 = f3_opimm_ori)) then
                    ori_temp when ((op = opcode_opimm) and (f3 = f3_opimm_ori)) else
                    
                --elsif ((op = opcode_opimm) and (f3 = f3_opimm_andi)) then
                    andi_temp when ((op = opcode_opimm) and (f3 = f3_opimm_andi));   
                
                --elsif (op = opcode_op) and (f3 = f3_op_not) and (f7 = f7_op_not) then
                --  c <= xor_int;
                              
                --else
                  --  assert false report "error in logic architecture" severity warning;
    
                --end if;
            
            --end process;
                        
end architecture;