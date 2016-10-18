`timescale 1ns / 1ps

parameter T=2604;

module CPU_tb;

logic CLK,UART_RX,INITIALIZE,START_EXEC,UART_TX;
CPU CPU(.*);

logic[7:0] data[8];
logic[9:0] in;
integer inst_itr;
integer bit_itr;

initial begin
	CLK = 0;
	inst_itr = 0;
	data[0] = 8'b01010011;
	data[1] = 8'b11010011;
	data[2] = 8'b01010011;
	data[3] = 8'b11110111;
	data[4] = 8'b00000000;
	data[5] = 8'b01010011;
	data[6] = 8'b01010011;
	data[7] = 8'b01010111;
	repeat(8) begin
		in = {1'b1,data[inst_itr],1'b0};
		bit_itr = 0;
		repeat(10) begin
			UART_RX = in[bit_itr];
			repeat(T) @(posedge CLK);
			bit_itr = bit_itr + 1;
		end
		inst_itr = inst_itr + 1;
	end
	repeat(10) @(posedge CLK);
end

always begin
	#1ns CLK=~CLK;
end

endmodule