`timescale 1ns / 1ps

module loopback_top(
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
clk_wiz_0 genclk(CLK_P,CLK_N,CLK);

logic[7:0] in,out;
logic valid,ready;

receiver receiver(CLK,UART_RX,in,valid);
loopback loopback(CLK,in,valid,done,ready,out);
sender sender(CLK,out,ready,done,UART_TX);

endmodule
