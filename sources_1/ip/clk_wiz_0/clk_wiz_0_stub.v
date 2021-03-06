// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4.2 (lin64) Build 1494164 Fri Feb 26 04:18:54 MST 2016
// Date        : Wed Feb 15 05:50:40 2017
// Host        : ispc2016 running 64-bit Ubuntu 14.04.4 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/tansei/Documents/CPUexp/CoreC/CoreC.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku040-ffva1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_in1_p, clk_in1_n, clk_out1, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="clk_in1_p,clk_in1_n,clk_out1,reset,locked" */;
  input clk_in1_p;
  input clk_in1_n;
  output clk_out1;
  input reset;
  output locked;
endmodule
