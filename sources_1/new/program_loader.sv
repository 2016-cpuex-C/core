`timescale 1ns / 1ps

parameter MEM_INST_SIZE = 1<<14;

module program_loader(
	input CLK,
	input UART_RX,
	input needed,
	input INITIALIZE,
//	output logic[31:0] ins[MEM_INST_SIZE],
	output integer pc_init,
	output logic[15:0] write_addr,
	output logic[31:0] write_data,
	output logic write_enable
//	output logic[7:0] LED
);

logic[7:0] data;
logic valid;
receiver receiver(CLK,UART_RX,data,valid);
logic already_valid = 0;

integer inst_itr = 0;		//[0,MEM_INST_SIZE]
integer shift_itr = 0;		//[0,4]

always_ff @(posedge CLK) begin
	if(INITIALIZE) begin
		already_valid <= 0;
		inst_itr <= 0;
		shift_itr <= 0;
		write_enable <= 0;
//		LED <= 0;
	end
	else if(needed) begin
		if(valid) begin
			already_valid<=1;
		end
		if(already_valid) begin
			unique case(shift_itr)
				0 : begin
						write_addr <= inst_itr;
						write_data[31:24] <= data;
						if(&data) begin
							pc_init <= inst_itr + 1;
//							LED[inst_itr + 1] <= 1;
						end
						shift_itr <= 1;
					end
				1 : begin
						write_data[23:16] <= data;
						shift_itr <= 2;
					end
				2 : begin
						write_data[15:8] <= data;
						shift_itr <= 3;
					end
				3 : begin
						write_data[7:0] <= data;
						shift_itr <= 4;
					end
			endcase
			already_valid<=0;
			write_enable<=0;
		end
		else begin
			if(shift_itr == 4) begin
				write_enable <= 1;
				shift_itr <= 0;
				inst_itr <= inst_itr + 1;
			end
			else write_enable <= 0;
		end
	end
end


endmodule
