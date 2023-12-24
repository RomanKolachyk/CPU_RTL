


library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity ID is
    port (
        I_CLK : in bit;
        I_EN : in bit;
        I_DATAINST : in InstrType;    -- Instruction to be decoded
        O_SELRS1 : out RegAddrType;   -- Selection out for regrs1
        O_SELRS2 : out RegAddrType    -- Selection out for regrs2
        O_SELD : out RegAddrType;     -- Selection out for regD
        O_DATAIMM : out DataType;     -- Immediate value out
        O_REGDWE : out bit;                        -- RegD wrtite enable
        O_ALUOP : out OpType6;        -- ALU opcode
        O_ALUFUNC : out FuncType;    -- ALU function
        O_MEMOP : out bit_vector(4 downto 0);      -- Memory operation 
        O_MULTYCYALU : out bit;                    -- is this a multi-cycle alu op?
    );
end ID;

architecture Behavioral of ID is
begin
    O_MULTYCYALU <= S_MULTICY;

    -- Register selects for reads are async
    O_selRS1 <= I_DATAINST(R1_START downto R1_END);
    O_selRS2 <= I_DATAINST(R2_START downto R2_END);

    process (I_CLK, I_EN)
    begin
        
        if CLK = '1' and CLK'event then
            if I_EN = '1' then

                O_SELD <= I_DATAINST(RD_START downto RD_END);

                O_ALUOP <= I_DATAINST(OPCODE_START downto OPCODE_END);

                O_ALUFUNC <= "000000" & I_DATAINST(FUNCT7_START downto FUNCT7_END) & I_DATAINST(FUNCT3_START downto FUNCT3_END);

                case I_DATAINST(OPCODE_START downto OPCODE_END_2) is

                    when OPCODE_LUI =>
                        s_multicy <= '0';
                        O_regDwe <= '1';
                        O_memOp <= "00000";
                        O_dataIMM <= I_DATAINST(IMM_U_START downto IMM_U_END) & "000000000000";

                    when OPCODE_AUIPC =>
                        s_multicy <= '0';
                        O_regDwe <= '1';
                        O_memOp <= "00000";
                        O_dataIMM <= I_DATAINST(IMM_U_START downto IMM_U_END) & "000000000000";

                    when OPCODE_JAL =>
                        s_multicy <= '0';
                        if I_DATAINST(RD_START downto RD_END) = "00000" then
                            O_regDwe <= '0';
                        else
                            O_regDwe <= '1';
                        end if;
                        O_memOp <= "00000";
                        if I_DATAINST(IMM_U_START) = '1' then
                            O_dataIMM <= "111111111111" & I_DATAINST(19 downto 12) & I_DATAINST(20) & I_DATAINST(30 downto 21) & '0';
                        else
                            O_dataIMM <= "000000000000" & I_DATAINST(19 downto 12) & I_DATAINST(20) & I_DATAINST(30 downto 21) & '0';
                        end if;

                    when OPCODE_JALR =>
                        s_multicy <= '0';
                        if I_dataInst(RD_START downto RD_END) = "00000" then
                            O_regDwe <= '0';
                        else
                            O_regDwe <= '1';
                        end if;
                        O_memOp <= "00000";
                        if I_dataInst(IMM_U_START) = '1' then
                            O_dataIMM <= X"FFFF" & "1111" & I_dataInst(IMM_I_START downto IMM_I_END);
                        else
                            O_dataIMM <= X"0000" & "0000" & I_dataInst(IMM_I_START downto IMM_I_END);
                        end if;

                    when OPCODE_OPIMM =>
                        s_multicy <= '0';
                        O_regDwe <= '1';
                        O_memOp <= "00000";
                        if I_dataInst(IMM_U_START) = '1' then
                            O_dataIMM <= X"FFFF" & "1111" & I_dataInst(IMM_I_START downto IMM_I_END);
                        else
                            O_dataIMM <= X"0000" & "0000" & I_dataInst(IMM_I_START downto IMM_I_END);
                        end if;

                    when OPCODE_OP =>
                    O_memOp <= "00000";
                    if (I_dataInst(FUNCT7_START downto FUNCT7_END) = F7_OP_M_EXT) then
                        s_multicy <= '1';
                    else
                        s_multicy <= '0';
                    end if;
                    s_int <= '0';
                    O_regDwe <= '1';

                    when OPCODE_LOAD =>
                        s_multicy <= '0';
                        if I_dataInst(1 downto 0) = "11" then
                            O_regDwe <= '1';
                            O_memOp <= "10" & I_dataInst(FUNCT3_START downto FUNCT3_END);
                            if I_dataInst(IMM_U_START) = '1' then
                                O_dataIMM <= X"FFFF" & "1111" & I_dataInst(IMM_I_START downto IMM_I_END);
                            else
                                O_dataIMM <= X"0000" & "0000" & I_dataInst(IMM_I_START downto IMM_I_END);
                            end if;
                        else
                            O_memOp <= "00000";
                            O_regDwe <= '0';
                            O_dataIMM <= I_dataInst(IMM_I_START downto IMM_S_B_END) & "0000000";
                        end if;   

                    when OPCODE_STORE =>
                        s_multicy <= '0';
                        O_regDwe <= '1';
                        O_memOp <= "11" & I_dataInst(FUNCT3_START downto FUNCT3_END);
                        if I_dataInst(IMM_U_START) = '1' then
                            O_dataIMM <= X"FFFF" & "1111" & I_dataInst(IMM_S_A_START downto IMM_S_A_END) & I_dataInst(IMM_S_B_START downto IMM_S_B_END);
                        else
                            O_dataIMM <= X"0000" & "0000" & I_dataInst(IMM_S_A_START downto IMM_S_A_END) & I_dataInst(IMM_S_B_START downto IMM_S_B_END);
                        end if;

                    when OPCODE_BRANCH =>
                        s_multicy <= '0';
                        O_regDwe <= '1';
                        O_memOp <= "00000";
                        if I_dataInst(IMM_U_START) = '1' then
                            O_dataIMM <= X"FFFF" & "1111" & I_dataInst(7) & I_dataInst(30 downto 25) & I_dataInst(11 downto 8) & '0';
                        else
                            O_dataIMM <= X"0000" & "0000" & I_dataInst(7) & I_dataInst(30 downto 25) & I_dataInst(11 downto 8) & '0';
                        end if;

                        when others =>
                        s_multicy <= '0';
                        O_memOp <= "00000";
                        O_regDwe <= '0';
                        O_dataIMM <= I_dataInst(IMM_I_START downto IMM_S_B_END) & "0000000";
                end case;
            elsif I_int_ack = '1' then
                s_int <= '0';
            end if;
        end if;
    end process;

end Behavioral;





