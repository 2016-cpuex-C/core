`timescale 1ns / 1ps

//parameter T=2604;

module loopback_top(
	input logic CLK_P,
	input logic CLK_N,
	input logic UART_RX,
	output logic UART_TX
);
logic CLK;
IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(CLK));

logic[7:0] in,out;
logic valid,ready;

receiver receiver(CLK,UART_RX,in,valid);
loopback loopback(CLK,in,valid,done,ready,out);
sender sender(CLK,out,ready,done,UART_TX);

endmodule
