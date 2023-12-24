library ieee;
use ieee.numeric_std.all;

library work;
use work.cpu_defs_pack.all;
use work.bit_vector_natural_pack.all;

entity core is 
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

        
        -- ALU_Wait : in bit;
        -- ALU_MultiCy : in bit;
        -- OUT_STATE : out bit_vector(6 downto 0)
    );
end core;

architecture Behav of core is 
    -- TODO PC_UNIT
    component pc_unit
        port (
            I_clk : in  bit;
            I_nPC : in  DataType;
            I_nPCop : in PcuOpType;
            O_PC : out DataType);
    end component;

    component controller
        port (
            CLK : in bit;
            RST : in bit;
    
            OP : in OpType6;
    
            ALU_Wait : in bit;
            ALU_MultiCy : in bit;
            OUT_STATE : out bit_vector(6 downto 0));
    end component;

    component ID
        port (
            I_CLK : in bit;
            I_EN : in bit;
            I_DATAINST : in InstrType;    -- Instruction to be decoded
            O_SELRS1 : out RegAddrType;   -- Selection out for regrs1
            O_SELRS2 : out RegAddrType;    -- Selection out for regrs2
            O_SELD : out RegAddrType;     -- Selection out for regD
            O_DATAIMM : out DataType;     -- Immediate value out
            O_REGDWE : out bit;                        -- RegD wrtite enable
            O_ALUOP : out OpType6;        -- ALU opcode
            O_ALUFUNC : out FuncType;    -- ALU function
            O_MEMOP : out bit_vector(4 downto 0);      -- Memory operation 
            O_MULTYCYALU : out bit                    -- is this a multi-cycle alu op?    
        );
    end component;

    component alu is
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
        O_wait : out bit);
    end component;

    component register_file
        port (
            CLK: in bit;
            ENABLE: in bit;
            W_ENABLE: in bit;
            D_IN: in DataType;
            SEL_RS1: in RegAddrType;
            SEL_RS2: in RegAddrType;
            SEL_RD: in RegAddrType;
            Q_OUT_A: out DataType;
            Q_OUT_B: out DataType);
    end component;

    component mem_controller
        port (
            CLK : in bit;
            RST : in bit;
            OUT_READY : out bit;
            EXECUTE : in bit;
            W_ENABLE : in bit;
            ADDR : in AddrType;
            IN_DATA : in DataType;
            I_dataByteEn : in bit_vector(1 downto 0);
            SIGN_EXTEND : in bit;
            OUT_DATA : out DataType;
            OUT_DATA_READY : out bit;
    
            MEM_I_ready : in bit;
            MEM_O_cmd : out bit;
            MEM_O_we : out bit;
            MEM_O_byteEnable : out bit_vector (1 downto 0);
            MEM_O_addr : out DataType;
            MEM_O_data : out DataType;
            MEM_I_data : in DataType;
            MEM_I_dataReady : in bit);
    end component;

    signal state: bit_vector(6 downto 0) := (others => '0');
    signal pcop: bit_vector(1 downto 0);
    signal in_pc: AddrType;
    signal PC : AddrType := (others => '0');

    signal aluFunc: bit_vector(15 downto 0);
    signal memOp: OpType4;
    signal branchTarget: AddrType := (others => '0');
    signal instruction: DataType := (others => '0');
    signal data: DataType := (others => '0');
    signal dataDwe: bit := '0';
    signal aluOp: Optype6 := (others => '0');
    signal dataIMM : DataType := (others => '0');
    signal SEL_RS1 : RegAddrType := (others => '0');
    signal SEL_RS2 : RegAddrType := (others => '0');
    signal SEL_D : RegAddrType := (others => '0');
    
    signal memctl_ready : bit;
    signal memctl_execute : bit := '0';
    signal memctl_dataWe : bit;
    signal memctl_address : AddrType;
    signal memctl_in_data : DataType;
    signal memctl_dataByteEn : bit_vector(1 downto 0);
    signal memctl_out_data : DataType := (others => '0');
    signal memctl_dataReady : bit := '0';
    signal memctl_size : bit_vector(1 downto 0);
    signal memctl_signExtend : bit := '0';

    signal core_clock : bit := '0';

    signal reg_en : bit := '0';
    signal reg_we : bit := '0';
    signal en_alu : bit := '0';
    signal en_decode : bit := '0';

    signal dataResult : DataType := (others => '0');
    signal dataWriteReg : bit := '0';
    signal lastPC_alu : DataType := (others => '0');
    signal shouldBranch : bit := '0';
    signal alutobemulticycle : bit := '0';


    signal reg_write_data : DataType := (others => '0');
    signal dataA : DataType := (others => '0');
    signal dataB : DataType := (others => '0');

    signal alu_wait : bit := '0';

    signal alu_output: DataType := (others => '0');
begin
    core_clock <= CLK;

    mem_controller_instance : mem_controller port map(
        CLK => CLK,
        RST => RST,
        OUT_READY => memctl_ready,
        EXECUTE => memctl_execute,
        W_ENABLE => memctl_dataWe,
        ADDR => memctl_address,
        IN_DATA => memctl_in_data,
        I_dataByteEn => memctl_dataByteEn,
        SIGN_EXTEND => memctl_signExtend,
        OUT_DATA => memctl_out_data,
        OUT_DATA_READY => memctl_dataReady,

        MEM_I_ready => MEM_I_ready, 
        MEM_O_cmd => MEM_O_cmd,
        MEM_O_we => MEM_O_we,
        MEM_O_byteEnable => MEM_O_byteEnable,
        MEM_O_addr => MEM_O_addr,
        MEM_O_data => MEM_O_data,
        MEM_I_data => MEM_I_data,
        MEM_I_dataReady => MEM_I_dataReady
    );

    pc_unit_instance : pc_unit port map(
        I_clk => core_clock, 
        I_nPC => in_pc,
        I_nPCop => pcop,
        O_PC => PC
    );

    controller_instance : controller port map(
        CLK => core_clock,
        RST => RST,
        OP => aluop,
        ALU_Wait => ALU_WAIT,
        ALU_MultiCy => alutobemulticycle,
        OUT_STATE => state
    );

    decoder_instance : ID port map(
        I_CLK => core_clock,
        I_EN => en_decode,
        I_DATAINST => instruction,
        O_SELRS1 => SEL_RS1,
        O_SELRS2 => SEL_RS2,
        O_SELD => SEL_D,
        O_DATAIMM => dataIMM,
        O_REGDWE => dataDwe,
        O_ALUOP => aluop,
        O_ALUFUNC => alufunc,
        O_MEMOP  => memop,
        O_MULTYCYALU => alutobemulticycle
    );

    alu_instance : alu port map(
        I_clk => core_clock,
        I_en => en_alu,
        I_dataA => dataA,
        I_dataB => dataB,
        I_dataDwe => dataDwe,
        I_aluop => aluop(6 downto 2),
        I_aluFunc => alufunc,
        I_PC => pc,
        I_dataIMM => dataImm,
        -- I_clear => misalign_int,
        O_dataResult => dataResult,
        O_branchTarget => branchTarget,
        O_dataWriteReg => dataWriteReg,
        O_lastPC => lastPC_alu,
        O_shouldBranch => shouldBranch,
        O_wait => alu_wait
    );

    register_file_instance : register_file port map(
        CLK => core_clock,
        ENABLE => reg_en,
        W_ENABLE => reg_we,
        D_IN => reg_write_data,
        SEL_RS1 => SEL_RS1,
        SEL_RS2 => SEL_RS2,
        SEL_RD => SEL_D,
        Q_OUT_A => dataA,
        Q_OUT_B => dataB
    );

end Behav;