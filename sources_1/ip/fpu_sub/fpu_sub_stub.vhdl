-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4.2 (lin64) Build 1494164 Fri Feb 26 04:18:54 MST 2016
-- Date        : Sun Feb  5 15:52:58 2017
-- Host        : ispc2016 running 64-bit Ubuntu 14.04.4 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/tansei/Documents/CPUexp/CoreC/CoreC.srcs/sources_1/ip/fpu_sub/fpu_sub_stub.vhdl
-- Design      : fpu_sub
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku040-ffva1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu_sub is
  Port ( 
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tready : out STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid : in STD_LOGIC;
    s_axis_b_tready : out STD_LOGIC;
    s_axis_b_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in STD_LOGIC;
    m_axis_result_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end fpu_sub;

architecture stub of fpu_sub is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,aresetn,s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[31:0],s_axis_b_tvalid,s_axis_b_tready,s_axis_b_tdata[31:0],m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[31:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "floating_point_v7_1_1,Vivado 2015.4.2";
begin
end;
