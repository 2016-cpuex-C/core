
`timescale 1ns / 1ps

parameter FPU_INST = 7;
typedef enum logic [2:0] {
NEG,ADD,SUB,MUL,
DIV,CMP,SQRT
} inst_type;

module FPU(
	input logic CLK,
	input logic INITIALIZE,
	input logic in_valid,
	input logic[2:0] operator,	//8
	input logic[2:0] subop,		// for CMP
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

fpu_add fadd(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[ADD]),
	.s_axis_a_tready(in_readies[ADD][0]),
	.s_axis_a_tdata(a),
	.s_axis_b_tvalid(in_valids[ADD]),
	.s_axis_b_tready(in_readies[ADD][1]),
	.s_axis_b_tdata(b),
	.m_axis_result_tvalid(result_valids[ADD]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[ADD])
);

fpu_sub fsub(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[SUB]),
	.s_axis_a_tready(in_readies[SUB][0]),
	.s_axis_a_tdata(a),
	.s_axis_b_tvalid(in_valids[SUB]),
	.s_axis_b_tready(in_readies[SUB][1]),
	.s_axis_b_tdata(b),
	.m_axis_result_tvalid(result_valids[SUB]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[SUB])
);

fpu_mul fmul(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[MUL]),
	.s_axis_a_tready(in_readies[MUL][0]),
	.s_axis_a_tdata(a),
	.s_axis_b_tvalid(in_valids[MUL]),
	.s_axis_b_tready(in_readies[MUL][1]),
	.s_axis_b_tdata(b),
	.m_axis_result_tvalid(result_valids[MUL]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[MUL])
);

fpu_div fdiv(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[DIV]),
	.s_axis_a_tready(in_readies[DIV][0]),
	.s_axis_a_tdata(a),
	.s_axis_b_tvalid(in_valids[DIV]),
	.s_axis_b_tready(in_readies[DIV][1]),
	.s_axis_b_tdata(b),
	.m_axis_result_tvalid(result_valids[DIV]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[DIV])
);

fpu_sqrt fsqrt(
	.aclk(CLK),
	.aresetn(RESET),
	.s_axis_a_tvalid(in_valids[SQRT]),
	.s_axis_a_tready(in_readies[SQRT][0]),
	.s_axis_a_tdata(a),
	.m_axis_result_tvalid(result_valids[SQRT]),
	.m_axis_result_tready(result_ready),
	.m_axis_result_tdata(results[SQRT])
);

fpu_neg fneg(
	.aclk(CLK),
	.aresetn(RESET),
	.a_valid(in_valids[NEG]),
	.a_data(a),
	.c_valid(result_valids[NEG]),
	.c_data(results[NEG])
);

fpu_cmp fcmp(
	.aclk(CLK),
	.aresetn(RESET),
	.data_valid(in_valids[CMP]),
	.a_data(a),
	.b_data(b),
	.op_data(subop),
	.c_valid(result_valids[CMP]),
	.c_data(results[CMP])
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
