`timescale 1ns / 1ps

//parameter T=2604;

module counter_input(
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
		if(cntCLK==T) begin
			cntCLK<=0;
			cntT<=cntT+1;
		end
	end
end
endmodule

module receiver(
	input CLK,
	input IN,
	output logic[7:0] as,
	output logic valid=0
);
logic proceeding=0;
logic RST=0;
logic[13:0] cntCLK;
logic[3:0] cntT;
logic[9:0] vals;
logic latched_IN;
counter_input counter(.*);
always_ff @(posedge CLK) begin
	latched_IN <= IN;
	if(~proceeding && ~latched_IN) begin
		proceeding<=1;
		RST<=1;
	end
	else if(proceeding) begin
		RST<=0;
	 	if(cntCLK==T/3) begin
			case (cntT)
				0: vals[0]<=latched_IN;
				1: vals[1]<=latched_IN;
				2: vals[2]<=latched_IN;
				3: vals[3]<=latched_IN;
				4: vals[4]<=latched_IN;
				5: vals[5]<=latched_IN;
				6: vals[6]<=latched_IN;
				7: vals[7]<=latched_IN;
				8: vals[8]<=latched_IN;
				9: begin
					vals[9]<=latched_IN;
					proceeding<=0;
					valid<=1;
					as<=vals[8:1];
				   end
			endcase
		end
	end
	else if(valid) valid<=0;
end
endmodule