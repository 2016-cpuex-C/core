//parameter T=2604;
// 300M -> T=2604
// 30M -> T=260
// 5M  -> 43
// (written in CPU_top, CPU, receiver, !sender, CPU_tb, loopback_top, loopback)

`ifndef global
	`define global
	localparam T = 43;
`endif