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
        Q_OUT: out DataType);
end register_file;

-- 32 bit register with Reset and Enable 
entity REG_G is
    generic( N : natural );
    port(
        D_IN : in bit_vector( 31 downto 0 );
        RST : in bit;
        ENABLE: in bit;
        CLK : in bit;
        Q_OUT : out bit_vector( 31 downto 0 ));
end REG_G;
    

architecture RTL_REG_G of REG_G is
begin
    process (CLK)
    begin
        if CLK = '1' and CLK'event then
            if RST = '1' then
                Q_OUT <= (others => '0');
            elsif ENABLE = '1‘ then
                Q_OUT <= D_IN;
            end if;
        end if;
    end process;
end RTL_REG_G;

architecture Behav of register_file is

begin
    signal regs: RegType := (others => X"00000000");
    signal dataOut: DataType := (others => '0');
    -- signal
    process(CLK)
    begin
        if CLK = '1' and CLK'event then 
            if ENABLE = '1' then
                dataOut <= regs(bit_vector2natural(SEL_RS1));
                if W_ENABLE = '1' then
                    regs(bit_vector2natural(SEL_RD)) <= D_IN;
                end if;
            end if;
        end if;
    end process;

    Q_OUT <= dataOut when SEL_RS1 /= "00000" else X"00000000";
end Behav;