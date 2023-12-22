library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity PC is
    Port ( 
        I_clk : in  bit;
        I_nPC : in  DataType;
        I_nPCop : in PcuOpType;
        O_PC : out DataType
    );
end PC;

architecture Behavioral of PC is
    signal current_pc: DataType;
begin

	process (I_clk)
	begin
		if CLK = '1' and CLK'event then
			case I_nPCop is
				when PCU_OP_NOP => 	-- NOP, keep PC the same/halt
				when PCU_OP_INC => 	-- increment
					current_pc <= bit_vector(unsigned(current_pc) + 4); -- 32bit byte addressing
				when PCU_OP_ASSIGN => 	-- set from external input
					current_pc <= I_nPC;
				when PCU_OP_RESET => 	-- Reset
					current_pc <= ADDR_RESET;
				when others =>
			end case;
		end if;
	end process;

	O_PC <= current_pc;
	
end Behavioral;