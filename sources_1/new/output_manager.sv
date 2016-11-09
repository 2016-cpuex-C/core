`timescale 1ns / 1ps
module output_manager(
	input CLK,
	input logic[7:0] send_queue[512],
	input logic[8:0] queue_t,
	output logic[8:0] queue_s,
	output UART_TX
);
logic[7:0] data;
logic ready = 0;
logic done_prev = 0;
sender sender(CLK,data,ready,done,UART_TX);
always_ff @(posedge CLK) begin
	done_prev <= done;
	if(!done_prev && done) begin
		queue_s <= queue_s + 1;
	end
	if(done_prev && done && queue_s != queue_t) begin
		data <= send_queue[queue_s];
		ready<=1;
	end
	else if(ready) begin
		ready<=0;
	end
end

endmodule