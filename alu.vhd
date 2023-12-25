library IEEE;
use IEEE.NUMERIC_STD.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity alu is
    port (
        I_clk : in bit;
        I_en : in bit;
        I_dataA : in DataType;
        I_dataB : in DataType;
        I_dataDwe : in bit;
        I_aluop : in bit_vector (4 downto 0);
        I_aluFunc : in bit_vector (15 downto 0);
        I_PC : in DataType;
        I_dataIMM : in DataType;
        O_dataResult : out DataType;
        O_branchTarget : out DataType;
        O_dataWriteReg : out bit;
        O_lastPC : out DataType;
        O_shouldBranch : out bit;
        O_wait : out bit
    );
end alu;

architecture Behavioral of alu is
    -- The internal register for results of operations. 
    -- 32 bit + carry/overflow
    signal s_aluFunc : bit_vector (15 downto 0) := (others => '0');
    signal s_branchTarget : DataType := (others => '0');

    signal s_result : bit_vector(63 downto 0) := (others => '0');
    -- signal s_resultms : bit_vector(63 downto 0) := (others => '0');
    -- signal s_resultmu : bit_vector(63 downto 0) := (others => '0');
    -- signal s_resultmsu : bit_vector(65 downto 0) := (others => '0'); -- result has 66 bits to accomodate mulhsu with it's additional-bit-fakery
    signal s_shouldBranch : bit := '0';
    signal s_lastPC : DataType := (others => '0');
    signal s_wait : bit := '0';

begin

    process (I_clk, I_en)
    begin
        if I_clk = '1' and I_clk'event then
            if I_en = '0' then
                s_branchTarget <= X"00000000";
                s_result <= X"0000000000000000";

            elsif I_en = '1' then
                s_lastPC <= I_PC;
                O_dataWriteReg <= I_dataDwe;
                s_aluFunc <= I_aluFunc;
                case I_aluop is
                    when OPCODE_OPIMM =>
                        s_wait <= '0';
                        s_shouldBranch <= '0';
                        case I_aluFunc(2 downto 0) is
                            when F3_OPIMM_ADDI =>
                                s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_dataA) + bit_vector2integer(I_dataIMM), 32);

                            when F3_OPIMM_XORI =>
                                s_result(31 downto 0) <= I_dataA xor I_dataIMM;

                            when F3_OPIMM_ORI =>
                                s_result(31 downto 0) <= I_dataA or I_dataIMM;

                            when F3_OPIMM_ANDI =>
                                s_result(31 downto 0) <= I_dataA and I_dataIMM;

                            when F3_OPIMM_SLTI =>
                                if bit_vector2integer(I_dataA) < bit_vector2integer(I_dataIMM) then
                                    s_result(31 downto 0) <= X"00000001";
                                else
                                    s_result(31 downto 0) <= X"00000000";
                                end if;

                            when F3_OPIMM_SLTIU =>
                                if bit_vector2natural(I_dataA) < bit_vector2natural(I_dataIMM) then
                                    s_result(31 downto 0) <= X"00000001";
                                else
                                    s_result(31 downto 0) <= X"00000000";
                                end if;

                            when F3_OPIMM_SLLI =>
                                s_result(31 downto 0) <= I_dataA & bit_vector(bit_vector2natural(I_dataIMM(4 downto 0)) downto 0);
--                                s_result(31 downto 0) <= X"DEADBEEF";
                            when F3_OPIMM_SRLI =>
                                case I_aluFunc(9 downto 3) is
                                    when F7_OPIMM_SRLI =>
                                        s_result(31 downto 0) <= bit_vector(bit_vector2natural(unsigned(I_dataIMM(4 downto 0)) downto 0)) & I_dataA;
--s_result(31 downto 0) <= X"DEADBEEF";
                                    when F7_OPIMM_SRAI =>
                                        s_result(31 downto 0) <= bit_vector(bit_vector2natural(signed(I_dataIMM(4 downto 0)) downto 0)) & I_dataA;
s_result(31 downto 0) <= X"DEADBEEF";
                                    when others =>
                                end case;
                            when others =>
                        end case;

                    when OPCODE_OP =>
                            s_wait <= '0';
                            case I_aluFunc(9 downto 0) is
                                when F7_OP_ADD & F3_OP_ADD =>
                                    s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_dataA) + bit_vector2integer(I_dataB), 32);

                                when F7_OP_SUB & F3_OP_SUB =>
                                    s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_dataA) - bit_vector2integer(I_dataB), 32);

                                when F7_OP_SLT & F3_OP_SLT =>
                                    if bit_vector2integer(I_dataA) < bit_vector2integer(I_dataB) then
                                        s_result(31 downto 0) <= X"00000001";
                                    else
                                        s_result(31 downto 0) <= X"00000000";
                                    end if;

                                when F7_OP_SLTU & F3_OP_SLTU =>
                                    if bit_vector2natural(I_dataA) < bit_vector2natural(I_dataB) then
                                        s_result(31 downto 0) <= X"00000001";
                                    else
                                        s_result(31 downto 0) <= X"00000000";
                                    end if;

                                when F7_OP_XOR & F3_OP_XOR =>
                                    s_result(31 downto 0) <= I_dataA xor I_dataB;

                                when F7_OP_OR & F3_OP_OR =>
                                    s_result(31 downto 0) <= I_dataA or I_dataB;

                                when F7_OP_AND & F3_OP_AND =>
                                    s_result(31 downto 0) <= I_dataA and I_dataB;

                                when F7_OP_SLL & F3_OP_SLL =>
                                    s_result(31 downto 0) <= I_dataA & bit_vector(bit_vector2natural(I_dataB(4 downto 0)) downto 0);
--s_result(31 downto 0) <= X"DEADBEEF";
                                when F7_OP_SRL & F3_OP_SRL =>
                                    s_result(31 downto 0) <= bit_vector(bit_vector2natural(unsigned(I_dataB(4 downto 0)) downto 0)) & I_dataA;
--s_result(31 downto 0) <= X"DEADBEEF";
                                when F7_OP_SRA & F3_OP_SRA =>
                                    s_result(31 downto 0) <= bit_vector(bit_vector2natural(signed(I_dataB(4 downto 0)) downto 0)) & I_dataA;
--s_result(31 downto 0) <= X"DEADBEEF";
                                when others =>
                                    s_result <= X"00000000" & X"CDC1FEF1";
                            end case;
                        s_shouldBranch <= '0';

                    when OPCODE_LOAD | OPCODE_STORE =>
                        s_wait <= '0';
                        s_shouldBranch <= '0';
                        s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_dataA) + bit_vector2integer(I_dataIMM), 32);

                    when OPCODE_JALR =>
                        s_wait <= '0';
                        s_branchTarget <= integer2bit_vector(bit_vector2integer(I_dataA) + bit_vector2integer(I_dataIMM), 32) and X"FFFFFFFE"; -- jalr clears the lowest bit
                        s_shouldBranch <= '1';
                        s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_PC) + 4, 32);

                    when OPCODE_JAL =>
                        s_wait <= '0';
                        s_branchTarget <= integer2bit_vector(bit_vector2integer(I_PC) + bit_vector2integer(I_dataIMM), 32);
                        s_shouldBranch <= '1';
                        s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_PC) + 4, 32);

                    when OPCODE_LUI =>
                        s_wait <= '0';
                        s_shouldBranch <= '0';
                        s_result(31 downto 0) <= I_dataIMM;

                    when OPCODE_AUIPC =>
                        s_wait <= '0';
                        s_shouldBranch <= '0';
                        s_result(31 downto 0) <= integer2bit_vector(bit_vector2integer(I_PC) + bit_vector2integer(I_dataIMM), 32);

                    when OPCODE_BRANCH =>
                        s_wait <= '0';
                        s_branchTarget <= integer2bit_vector(bit_vector2integer(I_PC) + bit_vector2integer(I_dataIMM), 32);
                        case I_aluFunc(2 downto 0) is
                            when F3_BRANCH_BEQ =>
                                if I_dataA = I_dataB then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when F3_BRANCH_BNE =>
                                if I_dataA /= I_dataB then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when F3_BRANCH_BLT =>
                                if bit_vector2integer(I_dataA) < bit_vector2integer(I_dataB) then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when F3_BRANCH_BGE =>
                                if bit_vector2integer(I_dataA) >= bit_vector2integer(I_dataB) then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when F3_BRANCH_BLTU =>
                                if bit_vector2natural(I_dataA) < bit_vector2natural(I_dataB) then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when F3_BRANCH_BGEU =>
                                if bit_vector2natural(I_dataA) >= bit_vector2natural(I_dataB) then
                                    s_shouldBranch <= '1';
                                else
                                    s_shouldBranch <= '0';
                                end if;

                            when others =>
                        end case;

                    when others =>
                        s_result <= X"00000000" & X"CDCDFEFE";
                end case;
            end if;
        end if;
    end process;

    O_wait <= s_wait;

    O_dataResult <= s_result(31 downto 0);
    O_shouldBranch <= s_shouldBranch;
    O_branchTarget <= s_branchTarget;
    O_lastPC <= s_lastPC;

end Behavioral;