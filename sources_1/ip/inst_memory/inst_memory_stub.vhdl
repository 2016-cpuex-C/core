-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4.2 (lin64) Build 1494164 Fri Feb 26 04:18:54 MST 2016
-- Date        : Mon Feb  6 19:47:57 2017
-- Host        : ispc2016 running 64-bit Ubuntu 14.04.4 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/tansei/Documents/CPUexp/CoreC/CoreC.srcs/sources_1/ip/inst_memory/inst_memory_stub.vhdl
-- Design      : inst_memory
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku040-ffva1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity inst_memory is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end inst_memory;

architecture stub of inst_memory is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[15:0],dina[31:0],douta[31:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_1,Vivado 2015.4.2";
begin
end;
