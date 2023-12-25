library IEEE;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.numeric_bit.all;   

library work;
use work.cpu_defs_pack.all;

package bit_vector_natural_pack is


    function bit_vector2natural(constant A: bit_vector)
        return integer;
    
    function bit_vector2integer(constant A: bit_vector)
        return integer;

    function natural2bit_vector(constant A :integer;
     constant data_width : natural)
        return bit_vector;

    function integer2bit_vector(constant A :integer;
    constant data_width : natural)
        return bit_vector;
    
    function zero_extend(constant imm: Imm12Type) return bit_vector;
    function sign_extend(constant imm: Imm12Type) return bit_vector;
    function zero_extend8(constant imm: Imm8Type) return bit_vector;
    function sign_extend8(constant imm: Imm8Type) return bit_vector;    
    function zero_extend16(constant imm: Imm16Type) return bit_vector;
    function sign_extend16(constant imm: Imm16Type) return bit_vector;    
    function sign_extend20(constant imm: Imm20Type) return bit_vector;    
    
    function EXEC_SLL (
        constant A : in DataType;
        constant N : in natural) return DataType;

    function EXEC_SRL (
        constant A : in DataType;
        constant N : in natural) return DataType; 

    function EXEC_SRA (
        constant A : in DataType;
        constant N : in natural) return DataType;

end bit_vector_natural_pack;
    
package body bit_vector_natural_pack is

    function EXEC_SLL (
            constant A : in DataType;
            constant N : in natural) return DataType is
        begin
            return bit_vector(shift_left(unsigned(A), N));
    end EXEC_SLL;

    function EXEC_SRL (
            constant A : in DataType;
            constant N : in natural) return DataType is
        begin
            return bit_vector(shift_right(unsigned(A), N));        
    end EXEC_SRL;

    function EXEC_SRA (
            constant A : in DataType;
            constant N : in natural) return DataType is
        begin
            return bit_vector(shift_right(signed(A), N));
    end EXEC_SRA;

    function bit_vector2natural(constant A: bit_vector)
        return integer is
        begin
            return to_integer(unsigned(A));
    end bit_vector2natural;

    function bit_vector2integer(constant A: bit_vector)
        return integer is
        begin
            return to_integer(signed(A));
    end bit_vector2integer;

    function natural2bit_vector(constant A :integer;
    constant data_width : natural)
        return bit_vector is
        begin
            return bit_vector(to_unsigned(A, data_width));
    end natural2bit_vector;

    function integer2bit_vector(constant A :integer;
    constant data_width : natural)
        return bit_vector is
        begin
            return bit_vector(to_signed(A, data_width));
    end integer2bit_vector;

     function zero_extend(constant imm: Imm12Type) return bit_vector is
         variable i: bit_vector (31 downto 0);
         begin
             i := B"00000000000000000000" & imm;
             return i;                
     end zero_extend;

    function sign_extend(constant imm: Imm12Type) return bit_vector is
        variable i: bit_vector (31 downto 0);
        begin
            if imm(imm'left) = '1' then
                i := B"11111111111111111111" & imm;
            else 
                i := B"00000000000000000000" & imm;
            end if;
            return i;               
    end sign_extend;
    
    
    function zero_extend8(constant imm: Imm8Type) return bit_vector is
         variable i: bit_vector (31 downto 0);
         begin
             i := B"000000000000000000000000" & imm;
             return i;                
     end zero_extend8;
         
    function sign_extend8(constant imm: Imm8Type) return bit_vector is
        variable i: bit_vector (31 downto 0);
        begin
            if imm(imm'left) = '1' then
                i := B"111111111111111111111111" & imm;
            else 
                i := B"000000000000000000000000" & imm;
            end if;
            return i;               
    end sign_extend8;
      
    function zero_extend16(constant imm: Imm16Type) return bit_vector is 
         variable i: bit_vector (31 downto 0);
         begin
             i := B"0000000000000000" & imm;
             return i;                
     end zero_extend16;
     
    function sign_extend16(constant imm: Imm16Type) return bit_vector is
        variable i: bit_vector (31 downto 0);
        begin
            if imm(imm'left) = '1' then
                i := B"1111111111111111" & imm;
            else 
                i := B"0000000000000000" & imm;
            end if;
            return i;               
    end sign_extend16;
    
    function sign_extend20(constant imm: Imm20Type) return bit_vector is
        variable i: bit_vector (31 downto 0);
        begin
            if imm(imm'left) = '1' then
                i := B"111111111111" & imm;
            else 
                i := B"000000000000" & imm;
            end if;
            return i;               
    end sign_extend20;  

end bit_vector_natural_pack;        
