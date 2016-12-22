`timescale 1ns / 1ps


module CPU_top(
	input logic CLK_P,
	input logic CLK_N,
	input logic UART_RX,
	input logic INITIALIZE,
	input logic START_EXEC,
//	input logic RESTART_EXEC,
	output logic[7:0] LED,
	output logic UART_TX
);

logic CLK;
logic reset = 0;
logic locked;
//IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(CLK));
clk_wiz_0 genclk(
	.clk_in1_p(CLK_P),
	.clk_in1_n(CLK_N),
	.clk_out1(CLK),
	.reset(reset),
	.locked(locked)
//	.*
);


CPU CPU(.*);

endmodule
