library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;

entity controller is
    port(
        CLK : in bit;
        RST : in bit;

        D_IN : in DataType;
        OP : out OpType6;
        D_OUT : out DataType;

        ALU_Wait : in bit;
        ALU_MultiCy : in bit;
        OUT_STATE : out bit_vector(6 downto 0));
end controller;

architecture Behav of controller is
begin
    signal state: bit_vector(6 downto 0) := "0000001";
    signal s_state : bit_vector(6 downto 0) := "0000001";

    signal mem_ready : bit;
    signal mem_execute : bit := '0';
    signal mem_dataReady : bit;

    signal mem_cycles : integer := 0;
    signal has_waited : bit = '0';
    process(CLK)
    begin
        if CLK = '1' and CLK'event then
            if RST = '1' then
                state <= "0000001";
            else 
                case state is 
                -- Instruction Fetch
                    when "0000001" =>
                        if mem_cycles = 0 and mem_ready = '1' then
                            mem_execute <= '1';
                            mem_cycles <= 1;

                        elsif mem_cycles = 1 then
                            mem_execute <= '0';
                            mem_cycles <= 2;

                        elsif mem_cycles = 2 then
                            mem_execute <= '0';
                            if mem_dataReady = '1' then
                                mem_cycles <= 0;
                                state <= "0000010"; -- Instruction Decode
                            end if;
                        end if;
                -- Instruction Decode
                    when "0000010" =>
                        has_waited = '0';
                        state <= "0000100"; -- Instruction Execute
                -- Instruction Execute
                    when "0000100" =>
                        if (OP(6 downto 2) = OPCODE_LOAD or OP(6 downto 2) = OPCODE_STORE) then
                            state <= "0001000"; -- MEM
                        else
                            if ALU_Wait = '0' then
                                if ALU_MultiCy = '1' then
                                    if has_waited = '1' then
                                        state <= "0010000"; -- WB
                                    end if;
                                else
                                    state <= "0010000"; -- WB
                                end if;
                                has_waited <= '1';
                            end if;
                        end if;

                -- Memory Access
                    when "0001000" =>
                        if mem_cycles = 0 and mem_ready = '1' then

                            mem_execute <= '1';
                            mem_cycles <= 1;

                        elsif mem_cycles = 1 then
                            mem_execute <= '0';
                            -- if it's a write, go through
                            if OP(6 downto 2) = OPCODE_STORE then
                                mem_cycles <= 0;
                                state <= "0010000"; -- WB
                            elsif mem_dataReady = '1' then
                                -- if read, wait for data
                                mem_cycles <= 0;
                                state <= "0010000"; -- WB
                            end if;
                        end if;

                -- Write Back
                    when "0010000" =>
                        state <= "0000001"; -- Instruction Fetch
                    -- when "0100000" =>
                    -- when "1000000" =>
                    when others =>
                        state <= "0000001";
                end case;
            end if; 
        end if;
    end process;
    OUT_STATE <= state;
end Behav;