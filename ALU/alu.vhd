library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.cpu_defs_pack.all;

entity alu is   
    port(
        op: in optype4;
        a: in datatype;
        b: in datatype;
        result: out datatype;
        f3: in func3type;
        f7: in func7type
    );
end alu;

architecture Behavioral of alu is

    signal add_temp, sub_temp, logic_temp, shift_temp, compare_temp : datatype := (others => '0');
begin
    addition: entity work.adder_vl(behav)
        port map(
            a => a,
            b => b,
            c => add_temp,
            neg => '0'
        );
        
    subtraction: entity work.adder_vl(behav)
        port map(
            a =>a,
            b =>b, 
            c => sub_temp,
            neg => '1'
        );
        
    logic: entity work.logic(behav)
        port map(
            a => a,
            b => b,
            c => logic_temp,
            op => op,
            f3 => f3,
            f7 => f7
        );
    
    shifts: entity work.shifters(behav)
        port map(
            a => a,
            b => b,
            c => shift_temp,
            op => op,
            f3 => f3,
            f7 => f7
        );
    
    compares: entity work.compare(behav)
        port map(
            a => a,
            b => b,
            c => compare_temp,
            op => op,
            f3 => f3,
            f7 => f7
        );
        
    
    result <= add_temp when ((op = opcode_op) and (f3 = f3_op_add) and (f7 = f7_op_add)) or ((op = opcode_opimm) and (f3 = f3_opimm_addi)) else
        sub_temp when ((op = opcode_op) and (f3 = f3_op_sub) and (f7 = f7_op_sub)) else
        logic_temp when ((op = opcode_op) and (f3 = f3_op_or) and (f7 = f7_op_or)) or ((op = opcode_op) and (f3 = f3_op_and) and (f7 = f7_op_and)) or ((op = opcode_op) and (f3 = f3_op_xor) and (f7 = f7_op_xor)) or ((op = opcode_opimm) and (f3 = f3_opimm_ori)) or ((op = opcode_opimm) and (f3 = f3_opimm_andi)) or ((op = opcode_opimm) and (f3 = f3_opimm_xori)) else
        shift_temp when ((op = opcode_op) and (f3 = f3_op_sll) and (f7 = f7_op_sll)) or ((op = opcode_op) and (f3 = f3_op_srl) and (f7 = f7_op_srl)) or ((op = opcode_op) and (f3 = f3_op_sra) and (f7 = f7_op_sra)) or ((op = opcode_opimm) and (f3 = f3_opimm_slli)) or ((op = opcode_opimm) and (f3 = f3_opimm_srli)) or ((op = opcode_opimm) and (f3 = f3_opimm_srai)) else  
        compare_temp when ((op = opcode_op) and (f3 = f3_op_sltu) and (f7 = f7_op_sltu)) or ((op = opcode_op) and (f3 = f3_op_slt) and (f7 = f7_op_slt)) or ((op = opcode_opimm) and (f3 = f3_opimm_slti)) or ((op = opcode_opimm) and (f3 = f3_opimm_sltiu));
        --assert false "error in alu" severity warning;
end Behavioral;
