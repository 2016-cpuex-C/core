`timescale 1ns / 1ps

module fpu_cmp(
	input logic aclk,
	input logic aresetn,
	input logic data_valid,
	input logic[31:0] a_data,
	input logic[31:0] b_data,
	input logic[2:0] op_data,
	output logic[31:0] c_data,	//return value =  c_data[0]
	output logic c_valid
);
integer a;
integer b;
logic exec_t;
always_ff @(posedge aclk) begin
	if(aresetn) begin
		c_data <= 0;
		c_valid <= 0;
		exec_t <= 0;
	end
	else if(data_valid) begin
		if(!exec_t) begin
			a <= a_data;
			b <= b_data;
			exec_t <= 1;
		end
		else begin
			unique case (op_data)
				3'b000 : begin	//EQ
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 1;
					end
					else begin
						c_data[0] <= (a == b);
					end
				end
				3'b001 : begin	//NE
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 0;
					end
					else begin
						c_data[0] <= (a != b);
					end
				end
				3'b010 : begin	//LE
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 1;
					end
					else begin
						c_data[0] <= (a <= b);
					end
				end
				3'b011 : begin	//GE
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 1;
					end
					else begin
						c_data[0] <= (a >= b);
					end
				end
				3'b100 : begin	//LT
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 0;
					end
					else begin
						c_data[0] <= (a < b);
					end
				end
				3'b101 : begin	//GT
					if( !(|a_data[30:0]) && !(|b_data[30:0]) ) begin
						c_data[0] <= 0;
					end
					else begin
						c_data[0] <= (a > b);
					end
				end
				default : begin
				end
			endcase
			exec_t <= 0;
			c_valid <= 1;
		end
	end
	else begin
		c_valid <= 0;
	end
end
endmodule
