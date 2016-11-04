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


parameter MODE_INITIAL = 0;
parameter MODE_LOADER = 1;
parameter MODE_IF = 2;
parameter MODE_ID = 3;
parameter MODE_EX = 4;
parameter MODE_MEM = 5;
parameter MODE_WB = 6;
//typedef enum logic [5:0] {
//	MOVE  = 6'b000001,
//	NEG   = 6'b000010,
//	ADD   = 6'b000011,
//	ADDI  = 6'b000100,
//} inst_type;
parameter[5:0]
 MOVE  = 6'b000001,
 NEG   = 6'b000010,
 ADD   = 6'b000011,
 ADDI  = 6'b000100,
 READI = 6'b101001;

integer exec_t = 0;
integer mode = MODE_INITIAL;
logic need_program_load = 0;

program_loader program_loader(CLK,UART_RX,need_program_load,ins,pc);

logic[7:0] in_data;
logic valid;
logic[7:0] out_data;
logic ready;
logic done;
receiver receiver(CLK,UART_RX,in_data,valid);
sender sender(CLK,out_data,ready,done,UART_TX);

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
			end
			MODE_LOADER : begin
				need_program_load <= 1;
				if (START_EXEC) begin
					mode <= MODE_EXEC;
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
						
					end
				endcase
			end
			
		endcase
	end
end

endmodule
