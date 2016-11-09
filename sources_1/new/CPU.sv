`timescale 1ns / 1ps

//parameter T=2604;

module CPU(
	input logic CLK,
	input logic UART_RX,
	input logic INITIALIZE,
	input logic START_EXEC,
//	input logic RESTART_EXEC,
	output logic[0:0] LED,
	output logic UART_TX
);

parameter MEM_SIZE = 1024;
parameter MEM_INST_SIZE = 1024;

logic[31:0] regi[32];
logic[31:0] regf[32];
logic[31:0] memory[MEM_SIZE];
logic[31:0] ins[MEM_INST_SIZE];
integer pc;
integer pc_init;

parameter MODE_INITIAL = 0;
parameter MODE_LOADER = 1;
parameter MODE_IF = 2;
parameter MODE_ID = 3;
parameter MODE_EX = 4;
parameter MODE_MEM = 5;
parameter MODE_WB = 6;
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

program_loader program_loader(CLK,UART_RX,need_program_load,ins,pc_init);

//logic[7:0] in_data;
//logic valid;
//logic[7:0] out_data;
//logic ready;
//logic done;
//receiver receiver(CLK,UART_RX,in_data,valid);
//sender sender(CLK,out_data,ready,done,UART_TX);
logic[7:0] send_queue[512];
logic[8:0] queue_s,queue_t;
output_manager oman(CLK,send_queue,queue_t,  queue_s,UART_TX);


logic[31:0] ir;
logic[5:0] inst_id;
logic[4:0] r1,r2,r3;
logic[15:0] i1,i2,i3;

logic finished = 0;

always_ff @(posedge CLK) begin
	if (INITIALIZE) begin
		mode <= MODE_INITIAL;
	end
	else begin
		unique case (mode)
			MODE_INITIAL : begin
				mode <= MODE_LOADER;
				regi[28] <= MEM_SIZE/2;
				LED[0] <= 0;
				queue_t <= 0;
			end
			MODE_LOADER : begin
				need_program_load <= 1;
				if (START_EXEC) begin
					pc <= pc_init;
					mode <= MODE_IF;
					need_program_load <= 0;
				end
			end
			MODE_IF : begin
	//			LED[0] <= 1;
				ir <= ins[pc];
				pc <= pc+1;
			end
			MODE_ID : begin
				inst_id <= ir[31:26];
				r1 <= ir[25:21];
				r2 <= ir[20:16];
				r3 <= ir[15:11];
//				i1 <= ir[25:10];
				i2 <= ir[20:5];
				i3 <= ir[15:0];
//				l1 <= ir[25:10];
//				l2 <= ir[20:5];
//				l3 <= ir[15:0];
			end
			MODE_EX : begin
				case (inst_id)
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
					

//					READI : begin
//						if(valid);
//					end
					PRINTI : begin
						if(queue_t + 1 == queue_s) ;
						else begin
							case (exec_t)
								0 : begin
									send_queue[queue_t] <= regi[r1][31:24];
									exec_t <= 1;
								end
								1 : begin
									send_queue[queue_t] <= regi[r1][23:16];
									exec_t <= 2;
								end
								2 : begin
									send_queue[queue_t] <= regi[r1][15:8];
									exec_t <= 3;
								end
								3 : begin
									send_queue[queue_t] <= regi[r1][7:0];
									exec_t <= 0;
								end
							endcase
							queue_t <= queue_t + 1;
						end
					end
				endcase
			end
			
		endcase
	end
end

endmodule