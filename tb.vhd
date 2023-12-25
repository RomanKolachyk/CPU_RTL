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
    signal ROM: rom_type:=(  
        -- X"00000097",     --auipc	ra,0x0
          X"14408093",     --addi    ra,ra,324 # 10000230 <_trap_handler>
          X"00002197",     --auipc    gp,0x2
          X"f0818193",     --addi    gp,gp,-248 # 10002000 <test_A1_data>
          X"00002117",     --auipc    sp,0x2
          X"f1010113",     --addi    sp,sp,-240 # 10002010 <begin_signature>
          X"00002097",     --auipc    ra,0x2
          X"f1808093",     --addi    ra,ra,-232 # 10002020 <test_A1_res_exc>
          X"00500293",     --li    t0,5
          X"00600313",     --li    t1,6
          X"0001a203",     --lw    tp,0(gp)
          X"00412023",     --sw    tp,0(sp)
          X"0011a203",     --lw    tp,1(gp)
          X"00412223",     --sw    tp,4(sp)
          X"0021a203",     --lw    tp,2(gp)
          X"00412423",     --sw    tp,8(sp)
          X"0031a203",     --lw    tp,3(gp)
          X"00412623",     --sw    tp,12(sp)
          X"00002197",     --auipc    gp,0x2
          X"ecc18193",     --addi    gp,gp,-308 # 10002004 <test_A2_data>
          X"00002117",     --auipc    sp,0x2
          X"ef810113",     --addi    sp,sp,-264 # 10002038 <test_A2_res>
          X"00002097",     --auipc    ra,0x2
          X"f1008093",     --addi    ra,ra,-240 # 10002058 <test_A2_res_exc>
          X"00500293",     --li    t0,5
          X"00600313",     --li    t1,6
          X"00019203",     --lh    tp,0(gp)
          X"00412023",     --sw    tp,0(sp)
          X"00119203",     --lh    tp,1(gp)
          X"00412223",     --sw    tp,4(sp)
          X"00219203",     --lh    tp,2(gp)
          X"00412423",     --sw    tp,8(sp)
          X"00319203",     --lh    tp,3(gp)
          X"00412623",     --sw    tp,12(sp)
          X"0001d203",     --lhu    tp,0(gp)
          X"00412823",     --sw    tp,16(sp)
          X"0011d203",     --lhu    tp,1(gp)
          X"00412a23",     --sw    tp,20(sp)
          X"0021d203",     --lhu    tp,2(gp)
          X"00412c23",     --sw    tp,24(sp)
          X"0031d203",     --lhu    tp,3(gp)
          X"00412e23",     --sw    tp,28(sp)
          X"00002117",     --auipc    sp,0x2
          X"ee010113",     --addi    sp,sp,-288 # 10002078 <test_B1_res>
          X"00002097",     --auipc    ra,0x2
          X"ee808093",     --addi    ra,ra,-280 # 10002088 <test_B1_res_exc>
          X"00000313",     --li    t1,0
          X"9999a2b7",     --lui    t0,0x9999a
          X"99928293",     --addi    t0,t0,-1639 # 99999999 <_end+0x89997795>
          X"00512023",     --sw    t0,0(sp)
          X"00512223",     --sw    t0,4(sp)
          X"00512423",     --sw    t0,8(sp)
          X"00512623",     --sw    t0,12(sp)
          X"00612023",     --sw    t1,0(sp)
          X"00410113",     --addi    sp,sp,4
          X"006120a3",     --sw    t1,1(sp)
          X"00410113",     --addi    sp,sp,4
          X"00612123",     --sw    t1,2(sp)
          X"00410113",     --addi    sp,sp,4
          X"006121a3",     --sw    t1,3(sp)
          X"00002117",     --auipc    sp,0x2
          X"ec010113",     --addi    sp,sp,-320 # 100020a0 <test_B2_res>
          X"00002097",     --auipc    ra,0x2
          X"ec808093",     --addi    ra,ra,-312 # 100020b0 <test_B2_res_exc>
          X"00000313",     --li    t1,0
          X"9999a2b7",     --lui    t0,0x9999a
          X"99928293",     --addi    t0,t0,-1639 # 99999999 <_end+0x89997795>
          X"00512023",     --sw    t0,0(sp)
          X"00512223",     --sw    t0,4(sp)
          X"00512423",     --sw    t0,8(sp)
          X"00512623",     --sw    t0,12(sp)
          X"00611023",     --sh    t1,0(sp)
          X"00410113",     --addi    sp,sp,4
          X"006110a3",     --sh    t1,1(sp)
          X"00410113",     --addi    sp,sp,4
          X"00611123",     --sh    t1,2(sp)
          X"00410113",     --addi    sp,sp,4
          X"006111a3",     --sh    t1,3(sp)
          X"02c0006f",     --j    10000258 <test_end>
          X"004f0f13",     --addi    t5,t5,4
          X"003f7f13",     --andi    t5,t5,3
          X"01e0a023",     --sw    t5,0(ra)
          X"01e0a223",     --sw    t5,4(ra)
          X"00808093",     --addi    ra,ra,8
          X"30200073",     --mret
        others => X"00000000");
     
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

    -- process (cEng_core)
    -- begin
    -- if cEng_core = '1' and cEng_core'event then
    --     count12MHz_stable <= count12MHz;
    -- end if;
    -- end process;
    

--    process (cEng_core)
--    begin
--    if cEng_core = '1' and cEng_core'event then
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
--    end if;
--    end process;
        
               
                   
    CLKTIME_clk: process
    begin
        CLKTIME <= '0';
        wait for CLKTIME_period/2;
        CLKTIME <= '1';
        wait for CLKTIME_period/2;
    end process;
        
    CLK12MHZ <= CLKTIME;

    core_instance: core port map (
        CLK => CLK12MHz,
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
        
        


    MEM_proc: process(CLK12MHz)
    begin
        if CLK12MHz = '1' and CLK12MHz'event then
                        
            if MEM_readyState = SOC_CtlState_Ready then
                if MEM_O_cmd = '1' then
                                                                       
                    
                    MEM_I_ready <= '0';
                    MEM_I_dataReady  <= '0';
                    if MEM_O_we = '1' then
                         
                        MEM_readyState <= SOC_CtlState_IMM_WriteCmdComplete;
                        if (MEM_CS_BRAM_1 = '1') then
                            ROM(bit_vector2natural( MEM_64KB_ADDR(15 downto 2))) <= MEM_O_data;
                            report integer'image(bit_vector2natural( MEM_64KB_ADDR(15 downto 2)));
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