`timescale 1ns / 1ps

parameter MEM_INPUT_SIZE = 1024;
parameter LOG_MEM_INPUT_SIZE = 10;

module input_loader(
	input CLK,
	input UART_RX,
	input INITIALIZE,
	output logic[LOG_MEM_INPUT_SIZE:0] queue_t,		//done: [0,queue_t)
	output logic[31:0] mem_input[MEM_INPUT_SIZE]
//	output logic[7:0] LED
);

logic[7:0] data;
logic valid;
receiver receiver(CLK,UART_RX,data,valid);
logic already_valid = 0;

integer shift_itr = 0;		//[0,3]

always_ff @(posedge CLK) begin
	if(INITIALIZE) begin
		already_valid <= 0;
		queue_t <= 0;
		shift_itr <= 0;
//		LED <= 0;
	end
	else begin
		if(valid) begin
			already_valid<=1;
		end
		if(already_valid) begin
			unique case(shift_itr)
				0 : begin
						mem_input[queue_t][31:24] <= data;
						shift_itr <= 1;
					end
				1 : begin
						mem_input[queue_t][23:16] <= data;
						shift_itr <= 2;
					end
				2 : begin
						mem_input[queue_t][15:8] <= data;
						shift_itr <= 3;
					end
				3 : begin
						mem_input[queue_t][7:0] <= data;
						shift_itr <= 0;
						queue_t <= queue_t + 1;
					end
			endcase
			already_valid<=0;
		end
	end
end

endmodule
