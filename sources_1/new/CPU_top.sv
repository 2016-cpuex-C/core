`timescale 1ns / 1ps

//parameter T=2604;

module CPU_top(
	input logic CLK_P,
	input logic CLK_N,
	input logic UART_RX,
	input logic INITIALIZE,
	input logic START_EXEC,
//	input logic RESTART_EXEC,
	output logic[0:0] LED,
	output logic UART_TX
);
logic CLK;
IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(CLK));

CPU CPU(.*);

endmodule
