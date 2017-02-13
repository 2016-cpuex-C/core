`timescale 1ns / 1ps

`include "global.vh"

module CPU_tb;

logic CLK,UART_RX,INITIALIZE,START_EXEC,UART_TX;
logic[7:0] LED;
CPU CPU(.*);

parameter INST_LEN = 4;
logic[31:0] data[INST_LEN] = {
32'b11111111111111111111111111111111,//__DELIMITER
32'b101001_00000_00000_00000000_00000000,//__readi_r
32'b101000_00000_000000000000000000000,//__printc_r
32'b110010_00000000000000000000000000//__EXIT
};
logic[9:0] in;
integer inst_itr;
integer byte_itr;
integer bit_itr;

initial begin
	CLK = 0;
	inst_itr = 0;
	byte_itr = 0;
	INITIALIZE <= 1;
	@(posedge CLK);
	INITIALIZE <= 0;
	repeat(INST_LEN) begin
		byte_itr = 0;
		repeat(4) begin
			unique case (byte_itr)
				0: in = {1'b1,data[inst_itr][31:24],1'b0};
				1: in = {1'b1,data[inst_itr][23:16],1'b0};
				2: in = {1'b1,data[inst_itr][15:8],1'b0};
				3: in = {1'b1,data[inst_itr][7:0],1'b0};
			endcase
			bit_itr = 0;
			repeat(10) begin
				UART_RX = in[bit_itr];
				repeat(T) @(posedge CLK);
				bit_itr = bit_itr + 1;
			end
			byte_itr = byte_itr + 1;
		end
		inst_itr = inst_itr + 1;
	end
	repeat(100) @(posedge CLK);
	START_EXEC = 1;
	repeat(2) @(posedge CLK);
	START_EXEC = 0;
end

always begin
	#33.3ns CLK=~CLK;
end

endmodule