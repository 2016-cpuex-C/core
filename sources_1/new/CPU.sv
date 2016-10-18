`timescale 1ns / 1ps

//parameter T=2604;

module CPU(
	input logic CLK,
	input logic UART_RX,
	input logic INITIALIZE,
	input logic START_EXEC,
//	input logic RESTART_EXEC,
	output logic[0:0] LED,
	output logic UART_TX
);

parameter MEM_SIZE = 1024;
parameter MEM_INST_SIZE = 1024;

logic[31:0] regi[32];
logic[31:0] regf[32];
logic[31:0] memory[MEM_SIZE];
logic[31:0] memory_inst[MEM_INST_SIZE];
integer pc;


parameter MODE_INITIAL = 0;
parameter MODE_LOADER = 1;
parameter MODE_EXEC = 2;

integer mode = MODE_INITIAL;
logic need_program_load = 0;

program_loader program_loader(CLK,UART_RX,need_program_load,memory_inst,pc);

logic finished = 0;

always_ff @(posedge CLK) begin
	if (INITIALIZE) begin
		mode <= MODE_INITIAL;
	end
	else if (mode == MODE_INITIAL) begin
		mode <= MODE_LOADER;
		regi[28] <= MEM_SIZE/2;
		LED[0] <= 0;
	end
	else if (mode == MODE_LOADER) begin
		need_program_load <= 1;
		if (START_EXEC) begin
			mode <= MODE_EXEC;
			need_program_load <= 0;
		end
	end
	else if (mode == MODE_EXEC) begin
		LED[0] <= 1;
	end
end

endmodule
