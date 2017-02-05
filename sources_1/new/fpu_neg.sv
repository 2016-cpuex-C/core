`timescale 1ns / 1ps

module fpu_neg(
	input logic aclk,
	input logic aresetn,
	input logic[31:0] a_data,
	input logic a_valid,
	output logic[31:0] c_data,
	output logic c_valid
);
always_ff @(posedge aclk) begin
	if(aresetn) begin
		c_data <= 0;
		c_valid <= 0;
	end
	else if(a_valid) begin
		c_data[31] <= ~a_data[31];
		c_data[30:0] <= a_data[30:0];
		c_valid <= 1;
	end
	else begin
		c_valid <= 0;
	end
end
endmodule
