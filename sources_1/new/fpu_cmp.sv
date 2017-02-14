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
logic signed [31:0] a;
logic signed [31:0] b;
logic exec_t;
always_ff @(posedge aclk) begin
	if(!aresetn) begin
		c_data <= 0;
		c_valid <= 0;
		exec_t <= 0;
	end
	else if(data_valid) begin
		if(!(|a_data[30:0])) begin	//is0
			a<=0;
		end
		else if (a_data[31]) begin	//minus
			a[31]<=a_data[31];
			a[30:0]<=~a_data[30:0];
		end
		else begin					//plus
			a<=a_data;
		end

		if(!(|b_data[30:0])) begin	//is0
			b<=0;
		end
		else if (b_data[31]) begin	//minus
			b[31]<=b_data[31];
			b[30:0]<=~b_data[30:0];
		end
		else begin					//plus
			b<=b_data;
		end
		exec_t <= 1;
	end
	else if(exec_t) begin
		unique case (op_data)
			3'b000 : begin	//EQ
				c_data[0] <= (a == b);
			end
			3'b001 : begin	//NE
				c_data[0] <= (a != b);
			end
			3'b010 : begin	//LE
				c_data[0] <= (a <= b);
			end
			3'b011 : begin	//GE
				c_data[0] <= (a >= b);
			end
			3'b100 : begin	//LT
				c_data[0] <= (a < b);
			end
			3'b101 : begin	//GT
				c_data[0] <= (a > b);
			end
			default : begin
			end
		endcase
		exec_t <= 0;
		c_valid <= 1;
	end
	else begin
		c_valid <= 0;
	end
end
endmodule
