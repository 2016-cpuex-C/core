
`timescale 1ns / 1ps

parameter FPU_INST = 5;
//add,sub,

module FPU(
	input logic CLK,
	input logic INITIALIZE,
	input logic in_valid,
	input logic[2:0] operator,	//8
	input logic[31:0] a,
	input logic[31:0] b,
	output logic result_valid,
	output logic[31:0] c
);


logic[FPU_INST-1:0] in_valids;
logic in_readies[FPU_INST][2];
logic result_valids[FPU_INST];
logic[31:0] results[FPU_INST];
logic result_ready = 1;
logic RESET = 1;	//active low

//add 0
fpu_add fadd(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[0]),
	.s_axis_a_tready(in_readies[0][0]),
	.s_axis_a_tdata(a),
	.s_axis_b_tvalid(in_valids[0]),
	.s_axis_b_tready(in_readies[0][1]),
	.s_axis_b_tdata(b),
	.m_axis_result_tvalid(result_valids[0]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[0])
);


always_ff @(posedge CLK) begin
	if(INITIALIZE) begin
		in_valids <= 0;
		RESET <= 0;
	end
	else begin
		RESET <= 1;
		if(in_valid) begin
			in_valids[operator] <= 1;
		end
		else begin
			in_valids[operator] <= 0;		//一瞬activeにすればOK
		end

		if(result_valids[operator]) begin
			c <= results[operator];
			result_valid <= 1;
		end
		else begin
			result_valid <= 0;
		end
	end
end

endmodule
