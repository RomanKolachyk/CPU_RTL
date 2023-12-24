library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity register_file is
    port(
        CLK: in bit;
        ENABLE: in bit;
        W_ENABLE: in bit;
        D_IN: in DataType;
        SEL_RS1: in RegAddrType;
        SEL_RS2: in RegAddrType;
        SEL_RD: in RegAddrType;
        Q_OUT_A: out DataType;
        Q_OUT_B: out DataType);
end register_file;

-- 32 bit register with Reset and Enable 

architecture Behav of register_file is
    signal regs: RegType := (others => X"00000000");
    signal dataAOut: DataType := (others => '0');
    signal dataBOut: DataType := (others => '0');
begin
    -- signal
    process(CLK)
    begin
        if CLK = '1' and CLK'event then 
            if ENABLE = '1' then
                dataAOut <= regs(bit_vector2natural(SEL_RS1));
                dataBOut <= regs(bit_vector2natural(SEL_RS2));
                if W_ENABLE = '1' then
                    regs(bit_vector2natural(SEL_RD)) <= D_IN;
                end if;
            end if;
        end if;
    end process;

    Q_OUT_A <= dataAOut when SEL_RS1 /= "00000" else X"00000000";
    Q_OUT_B <= dataBOut when SEL_RS2 /= "00000" else X"00000000";

    end Behav;