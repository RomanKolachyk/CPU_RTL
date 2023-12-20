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
        MEM_I_dataReady : in bit;

        
        ALU_Wait : in bit;
        ALU_MultiCy : in bit;
        OUT_STATE : out bit_vector(6 downto 0));
    );
end core;

architecture Behav of core is 
    -- TODO PC_UNIT
    component pc_unit
        port (

        );
    end component;

    component controller
        port (
            CLK : in bit;
            RST : in bit;
    
            D_IN : in DataType;
            OP : out OpType6;
            D_OUT : out DataType;
    
            ALU_Wait : in bit;
            ALU_MultiCy : in bit;
            OUT_STATE : out bit_vector(6 downto 0)
            );
    end component;

    component decoder
        port (

        );
    end component;

    component alu is
        port (
            op: in optype4;
            a: in datatype;
            b: in datatype;
            result: out datatype;
            f3: in func3type;
            f7: in func7type    
        );
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
            Q_OUT: out DataType);
            );
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
            MEM_I_dataReady : in bit);
    end component;

    signal state: bit_vector(6 downto 0) := (others => '0');
    signal pcop: bit_vector(1 downto 0);
    signal in_pc: AddrType;

    signal aluFunc: bit_vector(15 downto 0);
    signal memOp: OpType4;
    signal branchTarget: AddrType := (others => '0');
    signal instruction: DataType := (others => '0');
    signal data: DataType := (others => '0');
    signal dataDwe: bit := '0';
    signal Op: Optype6 := (others => '0');
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
begin
    mem_controller_instance : mem_controller port map(
        CLK => CLK,
        RST => RST,
        OUT_READY => memctl_ready,
        EXECUTE => memctl_execute,
        W_ENABLE => memctl_dataWe
        ADDR => memctl_address,
        IN_DATA => memctl_in_data,
        SIGN_EXTEND => memctl_signExtend,
        OUT_DATA => memctl_out_data,
        OUT_DATA_READY => memctl_dataReady

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

    );

    controller_instance : controller port map(
        I_clk => core_clock,
        I_reset => I_reset,
        I_halt => should_halt,
        I_aluop => aluop,

        I_int => lint_int,
        O_int_ack => lint_reset,
        I_int_enabled => int_enabled,
        I_int_mem_data => lint_int_data,
        O_idata => int_idata,
        O_set_idata => int_set_idata,
        O_set_ipc => PCintVec,
        O_set_irpc => int_set_irpc,
        O_instTick => csru_instRetTick,
        I_misalignment => misalign_hint,
        I_ready => memctl_ready,
        O_execute => memctl_execute,
        I_dataReady => memctl_dataReady,
        I_aluWait => alu_wait,
        I_aluMultiCy => alutobemulticycle,
        O_state => state

    );

    decoder_instance : decoder port map(

    );

    alu_instance : alu port map(
    );

    register_file_instance : register_file port map(
    );

end Behav;