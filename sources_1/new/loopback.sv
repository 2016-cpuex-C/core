`timescale 1ns / 1ps

module loopback(
	input logic CLK,
	input logic[7:0] in,
	input logic valid,
	input logic done,
	output logic ready,
	output logic[7:0] out
);
logic already_valid=0;
always_ff @(posedge CLK) begin
	if(valid) begin
		already_valid<=1;
	end
	if(already_valid && done) begin
		out<=in;
		already_valid<=0;
		ready<=1;
	end
	else if(ready) begin
		ready<=0;
	end
end
endmodule