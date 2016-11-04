`timescale 1ns / 1ps

parameter MEM_INST_SIZE = 1024;

module program_loader(
	input CLK,
	input UART_RX,
	input needed,
	output logic[31:0] ins[MEM_INST_SIZE],
	output integer pc
);

logic[7:0] data;
logic valid;
receiver receiver(CLK,UART_RX,data,valid);
logic already_valid = 0;

integer inst_itr = 0;		//[0,MEM_INST_SIZE]
integer shift_itr = 0;		//[0,3]

always_ff @(posedge CLK) begin
	if(needed) begin
		if(valid) begin
			already_valid<=1;
		end
		if(already_valid) begin
			unique case(shift_itr)
				0 : begin
						ins[inst_itr][31:24] <= data;
						shift_itr <= 1;
					end
				1 : begin
						ins[inst_itr][23:16] <= data;
						shift_itr <= 2;
					end
				2 : begin
						ins[inst_itr][15:8] <= data;
						shift_itr <= 3;
					end
				3 : begin
						ins[inst_itr][7:0] <= data;
						if (ins[31:8] == 24'b111111111111111111111111 && data == 8'b11111111) pc <= inst_itr + 1;
						shift_itr <= 0;
						inst_itr <= inst_itr + 1;
					end
			endcase
			already_valid<=0;
		end
	end
end


endmodule
