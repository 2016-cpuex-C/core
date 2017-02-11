`timescale 1ns / 1ps
module output_manager(
	input CLK,
	input INITIALIZE,
	input logic[7:0] send_queue[512],
	input logic[8:0] queue_t,
	output logic[8:0] queue_s,
	output UART_TX
//	output logic[7:0] LED
);
logic[7:0] data;
logic ready = 0;
logic done;
logic done_justnow;
sender sender(CLK,data,ready,done,done_justnow,UART_TX);

always_ff @(posedge CLK) begin
	if(INITIALIZE) begin
		queue_s <= 0;
		ready <= 0;
//		LED <= 0;
	end
	else begin
//		LED[queue_s] <= 1;
		if(done_justnow) begin
			queue_s <= queue_s + 1;
//			LED[6]<=1;
		end
		else if(done && queue_s != queue_t) begin
			data <= send_queue[queue_s];
			ready<=1;
//			LED[7]<=1;
		end
		else begin
			ready<=0;
		end
	end
end

endmodule