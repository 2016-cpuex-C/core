`timescale 1ns / 1ps


module CPU(
	input logic CLK,
	input logic UART_RX,
	input logic INITIALIZE,
	input logic START_EXEC,
//	input logic RESTART_EXEC,
	output logic[7:0] LED,
	output logic UART_TX
);

parameter MEM_SIZE = 1<<17;
parameter MEM_INST_SIZE = 1024;

logic signed [31:0] regi[32];
logic[31:0] regf[32];
logic[31:0] memory[MEM_SIZE];
logic[31:0] ins[MEM_INST_SIZE];
shortint unsigned pc;
integer pc_init;

parameter MODE_INITIAL = 0;
parameter MODE_LOADER = 1;
parameter MODE_IF = 2;
parameter MODE_ID = 3;
parameter MODE_EX = 4;
parameter MODE_MEM = 5;
parameter MODE_WB = 6;
parameter MODE_FINISHED = 7;
typedef enum logic [5:0] {
ZERO,MOVE,NEG,ADD,
ADDI,SUB,SUBI,MULT,
MULTI,DIV,DIVI,MOVS,
NEGS,ADDS,SUBS,MULS,
DIVS,SRL,SLL,LI,
LA,LWL,LWR,LSL,
LSR,SW,SS,BEQ,
BNE,BLT,BGT,CEQS,
CLES,CLTS,J,JR,
JAL,JALR,PRINTI,PRINTF,
PRINTC,READI,READF,SIN,
COS,ATAN,FLOOR,SQRT,
FTOI,ITOF,EXIT
} inst_type;

integer exec_t = 0;
integer mode = MODE_INITIAL;
logic need_program_load = 0;
program_loader program_loader(CLK,UART_RX,need_program_load,INITIALIZE,ins,pc_init);

logic[7:0] send_queue[512];
logic[8:0] queue_s,queue_t;
output_manager oman(CLK,INITIALIZE,send_queue,queue_t,  queue_s,UART_TX,LED);

logic fpu_in_valid = 0;
logic[2:0] fpu_operator;
logic[31:0] fpu_a,fpu_b,fpu_c;
logic fpu_result_valid;
FPU fpu(
	.CLK(CLK),
	.INITIALIZE(INITIALIZE),
	.in_valid(fpu_in_valid),
	.operator(fpu_operator),
	.a(fpu_a),
	.b(fpu_b),

	.result_valid(fpu_result_valid),
	.c(fpu_c)
);

logic[31:0] ir;
logic[5:0] inst_id;
logic[4:0] r1,r2,r3;
logic signed [15:0] i1,i2,i3;

logic finished = 0;



always_ff @(posedge CLK) begin
	if (INITIALIZE) begin
//		LED[7:0] <= 0;
		queue_t <= 0;
		exec_t <= 0;
		mode <= MODE_INITIAL;
		need_program_load <= 0;
		
		regi[29] <= 0;
	end
	else begin
		unique case (mode)
			MODE_INITIAL : begin
				mode <= MODE_LOADER;
			end
			MODE_LOADER : begin
//				LED[0] <= 1;
				need_program_load <= 1;
				if (START_EXEC) begin
					pc <= pc_init;
//					if(pc_init == 2) LED[2] <= 1;
//					LED[pc_init] <= 1;
					mode <= MODE_IF;
					need_program_load <= 0;
				end
			end
			MODE_IF : begin
//				LED[1] <= 1;
				ir <= ins[pc];
				pc <= pc+1;
				mode <= MODE_ID;
			end
			MODE_ID : begin
				inst_id <= ir[31:26];
				r1 <= ir[25:21];
				r2 <= ir[20:16];
				r3 <= ir[15:11];
				i1 <= ir[25:10];
				i2 <= ir[20:5];
				i3 <= ir[15:0];
//				l1 <= ir[25:10];
//				l2 <= ir[20:5];
//				l3 <= ir[15:0];
				mode <= MODE_EX;
			end
			MODE_EX : begin
				case (inst_id)
					ZERO : begin
						mode <= MODE_IF;
					end
					MOVE : begin
						regi[r1] <= regi[r2];
						mode <= MODE_IF;
					end
					NEG : begin
						regi[r1] <= -regi[r2];
						mode <= MODE_IF;
					end
					ADD : begin
						regi[r1] <= regi[r2] + regi[r3];
						mode <= MODE_IF;
					end
					ADDI : begin	// sign?
						regi[r1] <= regi[r2] + i3;
						mode <= MODE_IF;
					end
					SUB : begin
						regi[r1] <= regi[r2] - regi[r3];
						mode <= MODE_IF;
					end
					SUBI : begin	// sign?
						regi[r1] <= regi[r2] - i3;
						mode <= MODE_IF;
					end
					MULT : begin
						regi[r1] <= regi[r2] * regi[r3];
						mode <= MODE_IF;
					end
					MULTI : begin
						regi[r1] <= regi[r2] * i3;
						mode <= MODE_IF;
					end
					DIV : begin
						regi[r1] <= regi[r2] / regi[r3];
						mode <= MODE_IF;
					end
					DIVI : begin
						regi[r1] <= regi[r2] / i3;
						mode <= MODE_IF;
					end
					MOVS : begin
						regf[r1] <= regf[r2];
						mode <= MODE_IF;
					end
					NEGS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_operator <= 0;	//NEG
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					ADDS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 1;	//ADD
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					SUBS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 2;	//SUB
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					MULS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 3;	//MUL
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					DIVS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 4;	//DIV
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					DIVS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 4;	//DIV
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regf[r1] <= fpu_c;
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					SRL : begin
						regi[r1] <= (regi[r2] >>> i3);
						mode <= MODE_IF;
					end
					SLL : begin
						regi[r1] <= (regi[r2] <<< i3);
						mode <= MODE_IF;
					end
					LI : begin
						regi[r1] <= i2;
						mode <= MODE_IF;
					end
					LA : begin
						regi[r1] <= ins[i2];
						mode <= MODE_IF;
//						case (exec_t)
//							0 : begin
//								;
//							end
//							1 : begin
//								mode <= MODE_IF;
//							end
//						endcase
					end
//					LWL : begin
//						regi[r1] <= ins[i2];
//						mode <= MODE_IF;
//					end
					LWR : begin
						regi[r1] <= memory[regi[r2] + i3];
						mode <= MODE_IF;
					end
					LSL : begin
						regf[r1] <= ins[i2];
						mode <= MODE_IF;
					end
					LSR : begin
						regf[r1] <= memory[regi[r2] + i3];
						mode <= MODE_IF;
					end
					SW : begin
						memory[regi[r2] + i3] <= regi[r1];
						mode <= MODE_IF;
					end
					SS : begin
						memory[regi[r2] + i3] <= regf[r1];
						mode <= MODE_IF;
					end
					BEQ : begin
						if (regi[r1] == regi[r2]) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					BNE : begin
						if (regi[r1] != regi[r2]) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					BLT : begin
						if (regi[r1] < regi[r2]) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					BGT : begin
						if (regi[r1] > regi[r2]) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					CEQS : begin
					end
					CLES : begin
					end
					CLTS : begin
					end
					J : begin
					end
					JR : begin
						pc <= regi[r1];
						mode <= MODE_IF;
					end
					JAL : begin
						regi[31] <= pc;
						pc <= i1;
						mode <= MODE_IF;
					end
					JALR : begin
					end
//					READI : begin
//						if(valid);
//					end
					PRINTI : begin
						if(queue_t + 1 == queue_s) ;
						else begin
							case (exec_t)
								0 : begin
									send_queue[queue_t] <= regi[r1][31:24];
//									LED[3] <= 1;
									exec_t <= 1;
								end
								1 : begin
									send_queue[queue_t] <= regi[r1][23:16];
//									LED[4] <= 1;
									exec_t <= 2;
								end
								2 : begin
									send_queue[queue_t] <= regi[r1][15:8];
//									LED[5] <= 1;
									exec_t <= 3;
								end
								3 : begin
									send_queue[queue_t] <= regi[r1][7:0];
//									LED[6] <= 1;
									exec_t <= 0;
									mode <= MODE_IF;
								end
							endcase
							queue_t <= queue_t + 1;
						end
					end
					PRINTF : begin
						if(queue_t + 1 == queue_s) ;
						else begin
							case (exec_t)
								0 : begin
									send_queue[queue_t] <= regf[r1][31:24];
//									LED[3] <= 1;
									exec_t <= 1;
								end
								1 : begin
									send_queue[queue_t] <= regf[r1][23:16];
//									LED[4] <= 1;
									exec_t <= 2;
								end
								2 : begin
									send_queue[queue_t] <= regf[r1][15:8];
//									LED[5] <= 1;
									exec_t <= 3;
								end
								3 : begin
									send_queue[queue_t] <= regf[r1][7:0];
//									LED[6] <= 1;
									exec_t <= 0;
									mode <= MODE_IF;
								end
							endcase
							queue_t <= queue_t + 1;
						end
					end
					EXIT : begin
						mode <= MODE_FINISHED;
					end
					default : begin
						
					end
				endcase
			end
			MODE_FINISHED : begin
//				LED[7] <= 1;
			end
		endcase
	end
end

endmodule
