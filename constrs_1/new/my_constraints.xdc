set_property PACKAGE_PIN AK17           [get_ports CLK_P]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports CLK_P]
set_property ODT RTT_48                 [get_ports CLK_P]
create_clock -period 3.333              [get_ports CLK_P]

set_property PACKAGE_PIN AK16           [get_ports CLK_N]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports CLK_N]
set_property ODT RTT_48                 [get_ports CLK_N]

set_property PACKAGE_PIN G25     [get_ports UART_RX]
set_property IOSTANDARD LVCMOS18 [get_ports UART_RX]
set_property PACKAGE_PIN K26     [get_ports UART_TX]
set_property IOSTANDARD LVCMOS18 [get_ports UART_TX]


# CPU reset, being pushed, then (re)start  *loading* !!
set_property PACKAGE_PIN AN8      [get_ports INITIALIZE] 
set_property IOSTANDARD  LVCMOS18 [get_ports INITIALIZE]

#turn on a LED while loading?

# center button, load a program -> (push) -> then start to execute the program.
set_property PACKAGE_PIN AE10     [get_ports START_EXEC]
set_property IOSTANDARD  LVCMOS18 [get_ports START_EXEC]

#restart exec?


#for debugging
set_property PACKAGE_PIN AP8      [get_ports LED[0]]
set_property IOSTANDARD  LVCMOS18 [get_ports LED[0]]
