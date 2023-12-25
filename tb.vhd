library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;


entity core_tb is

end core_tb;

architecture Behav of core_tb is

    component core 
        port(
            CLK : in bit;
            RST : in bit;
    
            D_IN : in DataType;
            OP : out OpType6;
            D_OUT : out DataType;
    
            -- memory interface
            MEM_I_ready : in bit;
            MEM_O_cmd : out bit;
            MEM_O_we : out bit;
    
            MEM_O_byteEnable : out bit_vector(1 downto 0);
            MEM_O_addr : out DataType;
            MEM_O_data : out DataType;
            MEM_I_data : in DataType;
            MEM_I_dataReady : in bit    
        );
    end component;

    signal CLK12MHz : bit := '0';
    signal CLKTIME : bit := '0';
    constant CLKTIME_PERIOD : time := 8 ns;
    signal cEng_core : bit := '0';

    signal I_reset : bit := '1';
    signal I_halt : bit := '0';
    signal I_int : bit := '0';
    signal MEM_I_ready : bit := '1';
    signal MEM_I_data : bit_vector(31 downto 0) := (others => '0');
    signal MEM_I_dataReady : bit := '0';

 
    
    signal MEM_O_cmd : bit := '0';
    signal MEM_O_we : bit := '0';
    signal MEM_O_byteEnable : bit_vector(1 downto 0) := (others => '0');
    signal MEM_O_addr : bit_vector(31 downto 0) := (others => '0');
    signal MEM_O_data : bit_vector(31 downto 0) := (others => '0');
    
    signal MEM_I_data_raw : bit_vector(31 downto 0) := (others => '0');
    
    -- Clock period definitions
    constant I_clk_period : time := 5 ns;
    
    
    signal MEM_readyState: integer := 0;
        
        
    -- SOC_CtrState definitions - running off SOC clock domain
    constant SOC_CtlState_Ready : integer :=  0;
        
    -- IMM SOC control states are immediate 1-cycle latency
    -- i.e. BRAM or explicit IO
    constant SOC_CtlState_IMM_WriteCmdComplete : integer := 9;
    constant SOC_CtlState_IMM_ReadCmdComplete : integer := 6;
        
    signal DDR3_DATA: bit_vector(31 downto 0):= (others => '0');
    
    -- Block ram management
    signal MEM_64KB_ADDR : bit_vector(31 downto 0):= (others => '0');
    signal MEM_BANK_ID : bit_vector(15 downto 0):= (others => '0');
    signal MEM_ANY_CS : bit := '0';
    signal MEM_WE : bit := '0';
    
    signal MEM_CS_BRAM_1 : bit := '0';
    signal MEM_CS_BRAM_2 : bit := '0';
    signal MEM_CS_BRAM_3 : bit := '0';
    
    signal mI_wea : bit_vector ( 3 downto 0 ):= (others => '0');
    
    signal MEM_CS_DDR3 : bit := '0';
    
    signal MEM_CS_SYSTEM : bit := '0';
    
    signal MEM_DATA_OUT_BRAM_1: bit_vector(31 downto 0):= (others => '0');
    signal MEM_DATA_OUT_BRAM_2: bit_vector(31 downto 0):= (others => '0');
    signal MEM_DATA_OUT_BRAM_3: bit_vector(31 downto 0):= (others => '0');
   
    
        
        
    signal memcontroller_reset_count: integer := 100000;
        
    signal count12MHz: bit_vector(63 downto 0) := X"0000000000000000";    
        
        
        
    type rom_type is array (0 to 16383) of bit_vector(31 downto 0);
    signal ROM2: rom_type :=(others => X"00000000");    
    signal ROM3: rom_type :=(others => X"00000000");     
    signal ROM: rom_type :=(others => X"00000000");        
    signal d_in : DataType;
    signal d_out : DataType;
    signal opp: Optype6;
    signal count12MHz_stable: bit_vector(63 downto 0) := (others => '0');

begin

    process(CLK12MHz)
    begin
        if CLK12Mhz = '1' and CLK12Mhz'event then
            count12MHz <= natural2bit_vector(bit_vector2natural(count12MHz) + 1, 64);
        end if;
    end process;

    process (cEng_core)
    begin
    if cEng_core = '1' and cEng_core'event then
        count12MHz_stable <= count12MHz;
    end if;
    end process;
    


 	-- The O_we signal can sustain too long. Clamp it to only when O_cmd is active.
    MEM_WE <= MEM_O_cmd and MEM_O_we;
    
    -- "Local" BRAM banks are 64KB. To address inside we need lower 16b
    MEM_64KB_ADDR <= X"0000" & MEM_O_addr(15 downto 0);
    MEM_BANK_ID <= MEM_O_addr(31 downto 16);

    MEM_CS_BRAM_1 <= '1' when (MEM_BANK_ID = X"0000") else '0'; -- 0x0000ffff bank 64KB
    MEM_CS_BRAM_2 <= '1' when (MEM_BANK_ID = X"0001") else '0'; -- 0x0001ffff bank 64KB
    MEM_CS_BRAM_3 <= '1' when (MEM_BANK_ID = X"0002") else '0'; -- 0x0002ffff bank 64KB
    
    MEM_CS_DDR3 <= '1' when (MEM_BANK_ID(15 downto 12) = X"1") else '0'; -- 0x1******* ddr3 bank 256MB
    
    -- if any CS line is active, this is 1
    MEM_ANY_CS <= MEM_CS_BRAM_1 or MEM_CS_BRAM_2 or MEM_CS_BRAM_3;
    
    -- select the correct data to send to cpu
    MEM_I_data_raw <= 
                  MEM_DATA_OUT_BRAM_1 when MEM_CS_BRAM_1 = '1' 
                  else MEM_DATA_OUT_BRAM_2 when MEM_CS_BRAM_2 = '1' 
                  else MEM_DATA_OUT_BRAM_3 when MEM_CS_BRAM_3 = '1'; 
                  
    MEM_DATA_OUT_BRAM_1 <= ROM(bit_vector2natural( MEM_64KB_ADDR(15 downto 2)and "01" & X"fff" ));--and "00"&X"03F" )));
    MEM_DATA_OUT_BRAM_2 <= ROM2(bit_vector2natural( MEM_64KB_ADDR(15 downto 2)and "01" & X"fff"));--and "00"&X"03F" )));
    MEM_DATA_OUT_BRAM_3 <= ROM3(bit_vector2natural( MEM_64KB_ADDR(15 downto 2)and "01" & X"fff" ));--and "00"&X"03F" )));

    MEM_I_data  <= MEM_I_data_raw; 

        
               
                   
    CLKTIME_clk: process
    begin
        CLKTIME <= '0';
        wait for CLKTIME_period/2;
        CLKTIME <= '1';
        wait for CLKTIME_period/2;
    end process;
        
    CLK12MHZ <= CLKTIME;

    core_instance: core port map (
        CLK => cEng_core,
        RST => I_reset,

        D_IN => d_in,
        OP => opp,
        D_OUT => d_out,

        -- memory interface
        MEM_I_ready => MEM_I_ready, 
        MEM_O_cmd => MEM_O_cmd,
        MEM_O_we => MEM_O_we, 

        MEM_O_byteEnable => MEM_O_byteEnable, 
        MEM_O_addr => MEM_O_addr, 
        MEM_O_data => MEM_O_data, 
        MEM_I_data => MEM_I_data, 
        MEM_I_dataReady => MEM_I_dataReady );
        
        


    MEM_proc: process(cEng_core)
    begin
        if cEng_core = '1' and cEng_core'event then
                        
            if MEM_readyState = SOC_CtlState_Ready then
                if MEM_O_cmd = '1' then
                                                                       
                    
                    MEM_I_ready <= '0';
                    MEM_I_dataReady  <= '0';
                    if MEM_O_we = '1' then
                         
                        MEM_readyState <= SOC_CtlState_IMM_WriteCmdComplete;
                        if (MEM_CS_BRAM_1 = '1') then
                            ROM(bit_vector2natural( MEM_64KB_ADDR(15 downto 2))) <= MEM_O_data;
                        end if;
                        if (MEM_CS_BRAM_2 = '1') then
                            ROM2(bit_vector2natural( MEM_64KB_ADDR(15 downto 2))) <= MEM_O_data;
                        end if;
                        if (MEM_CS_BRAM_3 = '1') then
                            ROM3(bit_vector2natural( MEM_64KB_ADDR(15 downto 2))) <= MEM_O_data;
                        end if;
                    else                        
                        MEM_readyState <= SOC_CtlState_IMM_ReadCmdComplete; 
                    end if;
                    
                end if;
            elsif MEM_readyState >= 1 then

                if MEM_readyState = SOC_CtlState_IMM_ReadCmdComplete then
                    MEM_I_ready <= '1';
                    MEM_I_dataReady <= '1'; 
                    MEM_readyState <= SOC_CtlState_Ready;  
                    
                elsif MEM_readyState = SOC_CtlState_IMM_WriteCmdComplete then
                    MEM_I_ready <= '1';
                    MEM_I_dataReady  <= '0'; 
                    MEM_readyState <= SOC_CtlState_Ready;
          
            end if;
            
         
        end if;
    end if;
  end process;
   
    stim_proc: process
    begin        
        wait for 20 ns;    
        memcontroller_reset_count <= 0;
        I_reset <= '0';
        wait;  
    end process;

end Behav;