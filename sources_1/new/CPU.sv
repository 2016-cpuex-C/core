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
parameter MEM_INST_SIZE = 1<<14;

logic signed [31:0] regi[32];
logic[31:0] regf[32];
logic[31:0] memory[MEM_SIZE];

//logic[31:0] ins[MEM_INST_SIZE];
logic[15:0] write_addr;
logic[31:0] write_data;
logic write_enable;
logic[15:0] read_addr;
logic[31:0] read_data;

inst_memory inst_memory(
	.addra(write_addr),
	.clka(CLK),
	.dina(write_data),
	.wea(write_enable),
	.addrb(read_addr),
	.clkb(CLK),
	.doutb(read_data)
);


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
SQRT,MOVE,NEG,ADD,
ADDI,SUB,SUBI,MULT,
MULTI,DIV,DIVI,MOVS,
NEGS,ADDS,SUBS,MULS,
DIVS,SRL,SLL,LI,
LA,LWL,LWR,LSL,
LSR,SW,SS,BEQ,
BNE,BLT,BGT,CEQS,
CLES,CLTS,J,JR,
JAL,JALR,SRLI,SLLI,
PRINTC,READI,READF,BEQI,
AND,OR,XOR,ANDI,
ORI,XORI,EXIT,SWAP,
SWAPS,SELECT,SELECTS,CMP,
CMPI,CMPS,CVTSW,CVTWS,
MADDS,BNEI,BLTI,BGTI
} inst_type;

integer if_t = 0;
integer exec_t = 0;
integer mode = MODE_INITIAL;
logic need_program_load = 0;
//program_loader program_loader(CLK,UART_RX,need_program_load,INITIALIZE,ins,pc_init);
program_loader program_loader(
	.CLK(CLK),
	.UART_RX(UART_RX),
	.needed(need_program_load),
	.INITIALIZE(INITIALIZE),
//	.ins(ins),
	.pc_init(pc_init),
	.write_addr(write_addr),
	.write_data(write_data),
	.write_enable(write_enable)
);

logic[7:0] send_queue[512];
logic[8:0] queue_s,queue_t;
output_manager oman(CLK,INITIALIZE,send_queue,queue_t,  queue_s,UART_TX);

parameter MEM_INPUT_SIZE = 1024;
parameter LOG_MEM_INPUT_SIZE = 10;

logic[LOG_MEM_INPUT_SIZE:0] input_valid_num;	//mem_input[0 ~ input_valid_num) is valid
logic[31:0] mem_input[MEM_INPUT_SIZE];
logic need_input_load = 0;
input_loader iload(
	.CLK(CLK),
	.UART_RX(UART_RX),
	.INITIALIZE(INITIALIZE),
	.needed(need_input_load),
	.queue_t(input_valid_num),
	.mem_input(mem_input)
);
logic[LOG_MEM_INPUT_SIZE:0] input_read_num;		//next read index

logic fpu_in_valid = 0;
logic[2:0] fpu_operator;
logic[2:0] fpu_subop;
logic[31:0] fpu_a,fpu_b,fpu_c;
logic fpu_result_valid;
FPU fpu(
	.CLK(CLK),
	.INITIALIZE(INITIALIZE),
	.in_valid(fpu_in_valid),
	.operator(fpu_operator),
	.subop(fpu_subop),
	.a(fpu_a),
	.b(fpu_b),

	.result_valid(fpu_result_valid),
	.c(fpu_c)
);

logic[31:0] ir;
logic[5:0] inst_id;
logic[4:0] r1,r2,r3,r4;
logic signed [15:0] i1,i2,i3;
logic signed [4:0] is2,is3;
typedef enum logic [2:0] {
	EQ,NE,LE,GE,LT,GT
} cmp_p_type;

logic[2:0] cmp_p;


logic finished = 0;



always_ff @(posedge CLK) begin
	if (INITIALIZE) begin
		LED[7:0] <= 0;
		queue_t <= 0;
		if_t <= 0;
		exec_t <= 0;
		mode <= MODE_INITIAL;
		need_program_load <= 0;
		need_input_load <= 0;
		input_read_num <= 0;
		fpu_in_valid <= 0;
		
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
					if(pc_init <= 2) LED[pc_init] <= 1;
//					LED[pc_init] <= 1;
					mode <= MODE_IF;
					need_program_load <= 0;
					need_input_load <= 1;
				end
			end
			MODE_IF : begin
//				LED[1] <= 1;
//				ir <= ins[pc];
				unique case (if_t)
					0 : begin
						read_addr <= pc;
						if_t <= 1;
					end
					1 : begin
						if_t <= 2;
					end
					2 : begin
						if_t <= 3;
					end
					3 : begin
						ir <= read_data;
						if_t <= 0;
						pc <= pc+1;
						mode <= MODE_ID;
					end
				endcase
			end
			MODE_ID : begin
				inst_id <= ir[31:26];
				r1 <= ir[25:21];
				r2 <= ir[20:16];
				r3 <= ir[15:11];
				r4 <= ir[10:6];
				i1 <= ir[25:10];
				i2 <= ir[20:5];
				i3 <= ir[15:0];
				is2 <= ir[20:16];
				is3 <= ir[15:11];
				cmp_p <= ir[10:8];
//				l1 <= ir[25:10];
//				l2 <= ir[20:5];
//				l3 <= ir[15:0];
				mode <= MODE_EX;
			end
			MODE_EX : begin
				case (inst_id)
					SQRT : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_operator <= 6;	//SQRT
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
					SRL : begin
						if(regi[r3] >= 32) regi[r1] <= 0;
						else regi[r1] <= (regi[r2] >> regi[r3]);
						mode <= MODE_IF;
					end
					SLL : begin
						regi[r1] <= (regi[r2] << regi[r3]);
						mode <= MODE_IF;
					end
					LI : begin
						if(i2==16'b00000000_00000001) LED[3] <= 1;
						else LED[4] <= 1;
						regi[r1] <= i2;
						mode <= MODE_IF;
					end
					LA : begin
//						regi[r1] <= ins[i2];
						unique case (if_t)
							0 : begin
								read_addr <= i2;
								if_t <= 1;
							end
							1 : begin
								if_t <= 2;
							end
							2 : begin
								if_t <= 3;
							end
							3 : begin
								regi[r1] <= read_data;
								if_t <= 0;
								mode <= MODE_IF;
							end
						endcase
					end
					LWL : begin			//same as LA
//						regi[r1] <= ins[i2];
						unique case (if_t)
							0 : begin
								read_addr <= i2;
								if_t <= 1;
							end
							1 : begin
								if_t <= 2;
							end
							2 : begin
								if_t <= 3;
							end
							3 : begin
								regi[r1] <= read_data;
								if_t <= 0;
								mode <= MODE_IF;
							end
						endcase
					end
					LWR : begin
						regi[r1] <= memory[regi[r2] + i3];
						mode <= MODE_IF;
					end
					LSL : begin
//						regf[r1] <= ins[i2];
						unique case (if_t)
							0 : begin
								read_addr <= i2;
								if_t <= 1;
							end
							1 : begin
								if_t <= 2;
							end
							2 : begin
								if_t <= 3;
							end
							3 : begin
								regf[r1] <= read_data;
								if_t <= 0;
								mode <= MODE_IF;
							end
						endcase
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
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r1];
								fpu_b <= regf[r2];
								fpu_operator <= 5;	//CMP
								fpu_subop <= 3'b000;	//EQ
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									if(fpu_c[0]) begin
										pc <= i3;
									end
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					CLES : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r1];
								fpu_b <= regf[r2];
								fpu_operator <= 5;	//CMP
								fpu_subop <= 3'b010;	//LE
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									if(fpu_c[0]) begin
										pc <= i3;
									end
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					CLTS : begin
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r1];
								fpu_b <= regf[r2];
								fpu_operator <= 5;	//CMP
								fpu_subop <= 3'b100;	//LT
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									if(fpu_c[0]) begin
										pc <= i3;
									end
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end

					J : begin
						pc <= i1;
						mode <= MODE_IF;
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
						regi[31] <= pc;
						pc <= regi[r1];
						mode <= MODE_IF;
					end
					SRLI : begin
						if(i3 >= 32) regi[r1] <= 0;
						else regi[r1] <= (regi[r2] >> i3);
						mode <= MODE_IF;
					end
					SLLI : begin
						regi[r1] <= (regi[r2] << i3);
						mode <= MODE_IF;
					end
/*					PRINTI : begin
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
*/
					PRINTC : begin
						if(queue_t + 1 == queue_s || (&queue_t & !(|queue_s))) ;
						else begin
							send_queue[queue_t] <= regi[r1][7:0];
							if(regi[r1][7:0] == 8'b00000001) LED[5] <= 1;
							else LED[6] <= 1;
							mode <= MODE_IF;
							queue_t <= queue_t + 1;
						end
					end
					READI : begin
						if(input_read_num >= input_valid_num);	//stall
						else begin
							regi[r1] <= mem_input[input_read_num];
							input_read_num <= input_read_num + 1;
							mode <= MODE_IF;
						end
					end
					READF : begin
						if(input_read_num >= input_valid_num);	//stall
						else begin
							regf[r1] <= mem_input[input_read_num];
							input_read_num <= input_read_num + 1;
							mode <= MODE_IF;
						end
					end
					BEQI : begin	//sign?
						if (regi[r1] == is2) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					AND : begin
						regi[r1] <= regi[r2] & regi[r3];
						mode <= MODE_IF;
					end
					OR : begin
						regi[r1] <= regi[r2] | regi[r3];
						mode <= MODE_IF;
					end
					XOR : begin
						regi[r1] <= regi[r2] ^ regi[r3];
						mode <= MODE_IF;
					end
					ANDI : begin
						regi[r1] <= regi[r2] & i3;
						mode <= MODE_IF;
					end
					ORI : begin
						regi[r1] <= regi[r2] | i3;
						mode <= MODE_IF;
					end
					XORI : begin
						regi[r1] <= regi[r2] ^ i3;
						mode <= MODE_IF;
					end
					EXIT : begin
						mode <= MODE_FINISHED;
					end
					SWAP : begin		//???
						regi[r1] <= regi[r2];
						regi[r2] <= regi[r1];
						mode <= MODE_IF;
					end
					SWAPS : begin
						regf[r1] <= regf[r2];
						regf[r2] <= regf[r1];
						mode <= MODE_IF;
					end
					SELECT : begin
						if(|regi[r2]) regi[r1] <= regi[r3];
						else regi[r1] <= regi[r4];
						mode <= MODE_IF;
					end
					SELECTS : begin
						if(|regi[r2]) regf[r1] <= regf[r3];
						else regf[r1] <= regf[r4];
						mode <= MODE_IF;
					end
					CMP : begin
						regi[r1][31:1] <= 0;
						unique case (cmp_p)
							EQ : regi[r1][0] <= (regi[r2] == regi[r3]);
							NE : regi[r1][0] <= (regi[r2] != regi[r3]);
							LE : regi[r1][0] <= (regi[r2] <= regi[r3]);
							GE : regi[r1][0] <= (regi[r2] >= regi[r3]);
							LT : regi[r1][0] <= (regi[r2] <  regi[r3]);
							GT : regi[r1][0] <= (regi[r2] >  regi[r3]);
						endcase
						mode <= MODE_IF;
					end
					CMPI : begin		//sign?
						regi[r1][31:1] <= 0;
						unique case (cmp_p)
							EQ : regi[r1][0] <= (regi[r2] == is3);
							NE : regi[r1][0] <= (regi[r2] != is3);
							LE : regi[r1][0] <= (regi[r2] <= is3);
							GE : regi[r1][0] <= (regi[r2] >= is3);
							LT : regi[r1][0] <= (regi[r2] <  is3);
							GT : regi[r1][0] <= (regi[r2] >  is3);
						endcase
						mode <= MODE_IF;
					end
					CMPS : begin
						regi[r1][31:1] <= 0;
						unique case (exec_t)
							0 : begin
								fpu_a <= regf[r2];
								fpu_b <= regf[r3];
								fpu_operator <= 5;	//CMP
								fpu_subop <= cmp_p;
								fpu_in_valid <= 1;
								exec_t <= 1;
							end
							default : begin
								fpu_in_valid <= 0;
								if(fpu_result_valid) begin
									regi[r1][0] <= fpu_c[0];
									exec_t <= 0;
									mode <= MODE_IF;
								end
								else begin
									exec_t <= exec_t + 1;
								end
							end
						endcase
					end
					CVTSW : begin
						regf[r1] <= regi[r2];
						mode <= MODE_IF;
					end
					CVTWS : begin
						regi[r1] <= regf[r2];
						mode <= MODE_IF;
					end
					MADDS : begin	//delay?
						regf[r1] <= regf[r2] + regf[r3]*regf[r4];
						mode <= MODE_IF;
					end
					BNEI : begin	//sign?
						if (regi[r1] != is2) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					BLTI : begin	//sign?
						if (regi[r1] < is2) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end
					BGTI : begin	//sign?
						if (regi[r1] > is2) begin
							pc <= i3;
						end
						mode <= MODE_IF;
					end

					default : begin
						
					end
				endcase
			end
			MODE_FINISHED : begin
				LED[7] <= 1;
			end
		endcase
	end
end

endmodule
