library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity mem_controller is
    port(
        CLK : in bit;
        RST : in bit;
        OUT_READY : out bit;
        EXECUTE : in bit;
        W_ENABLE : in bit;
        ADDR : in AddrType;
        IN_DATA : in DataType;
        SIGN_EXTEND : in bit;
        OUT_DATA : out DataType;
        OUT_DATA_READY : out bit;

        MEM_I_ready : in bit;
        MEM_O_cmd : out bit;
        MEM_O_we : out bit;
        MEM_O_byteEnable : bit_vector (1 downto 0);
        MEM_O_addr : out DataType;
        MEM_O_data : out DataType;
        MEM_I_data : in DataType;
        MEM_I_dataReady : in bit
    );
end mem_controller;

architecture Behav of mem_controller is
    signal we : bit := '0';
    signal addr : DataType := X"00000000";
    signal indata : DataType := X"00000000";
    signal outdata : DataType := X"00000000";

    signal byteEnable : bit_vector(1 downto 0) := "11";
    signal cmd : bit := '0';
    signal state : integer := 0;

    signal ready : bit := '0';
begin

    process(CLK, EXECUTE)
    begin
        if CLK = '1' and CLK'event then
            if RST = '1' then
            we <= '0';
            cmd <= '0';
            state <= '0';
            OUT_DATA_READY <= '0';
            elsif state = 0 and EXECUTE = '1' and MEM_I_ready = '1' then
                we <= W_ENABLE;
                addr <= ADDR;
                indata <= IN_DATA;
                byteEnable <= I_dataByteEn;
                cmd <= '1';
                OUT_DATA_READY <= '0';
                outdata <= X"DEADBEEF";
                if W_ENABLE = '0' then
                    state <= 1;-- read
                else
                    state <= 2;-- write
                end if;
            -- READ (state = 1)
            elsif state = 1 then
                cmd <= '0';
                if MEM_I_dataReady = '1' then
                    OUT_DATA_READY <= '1';
                    -- sign extend, if required
                    if SIGN_EXTEND = '1' then
                        if I_dataByteEn = F2_MEM_LS_SIZE_W then
                            outdata <= MEM_I_data;
                        elsif I_dataByteEn = F2_MEM_LS_SIZE_H then
                            outdata <= sign_extend16(MEM_I_data(15 downto 0));
                        elsif I_dataByteEn = F2_MEM_LS_SIZE_B then
                            outdata <= sign_extend8(MEM_I_data(7 downto 0));
                        end if;
                    else
                        outdata <= MEM_I_data;
                    end if;
                    state <= 2;
                end if;
            -- WRITE (state = 2)
            elsif state = 2 then
                cmd <= '0';
                state <= 0;
                OUT_DATA_READY <= '0';    
            end if;
        end if;
    end process;
    OUT_DATA <= outdata;
    OUT_READY <= (MEM_I_ready and not I_execute) when state = 0 else '0';
    
    MEM_O_cmd <= cmd;
    MEM_O_byteEnable <= byteEnable;
    MEM_O_data <= indata;
    MEM_O_addr <= addr;
    MEM_O_we <= we;

end Behav;