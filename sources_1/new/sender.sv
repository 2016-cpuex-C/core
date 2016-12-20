`timescale 1ns / 1ps

`include "global.vh"

module counter_output(
	input CLK,
	input RST,
	output logic[13:0] cntCLK,	//CLK
	output logic[3:0] cntT		//id
);
always_ff @(posedge CLK) begin
	if(RST) begin
		cntCLK<=0;
		cntT<=0;
	end
	else begin
		cntCLK<=cntCLK+1;
		if(cntCLK==T-10) begin
			cntCLK<=0;
			cntT<=cntT+1;
		end
	end
end
endmodule

module sender(
	input logic CLK,
	input logic[7:0] as,
	input logic ready,			//can output
	output logic done=1,			//complete sending
	output logic OUT
);
logic proceeding=0;
logic RST=0;
logic[13:0] cntCLK;
logic[3:0] cntT;
logic[9:0] vals;
counter_output counter(.*);
always_ff @(posedge CLK) begin
	if(~proceeding && ready) begin
		proceeding<=1;
		done<=0;
		RST<=1;
		vals<={1'b1,as,1'b0};
	end
	else if(proceeding) begin
		RST<=0;
	 	if(cntCLK==0) begin
			case (cntT)
				0: OUT<=vals[0];
				1: OUT<=vals[1];
				2: OUT<=vals[2];
				3: OUT<=vals[3];
				4: OUT<=vals[4];
				5: OUT<=vals[5];
				6: OUT<=vals[6];
				7: OUT<=vals[7];
				8: OUT<=vals[8];
				9: OUT<=vals[9];
				10:begin
					proceeding<=0;
				   end
			endcase
		end
	end
	else begin
		done<=1;
		OUT<=1;
	end
end
endmodule