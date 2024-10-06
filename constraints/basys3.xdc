# XDC constraints for Basys 3 Artix-7 board
# Modified from https://github.com/Digilent/digilent-xdc/blob/master/Basys-3-Master.xdc

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## Clock (100MHz)
set_property -dict { PACKAGE_PIN W5  IOSTANDARD LVCMOS33 } [get_ports {clk_i}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0.0 5.0} [get_ports {clk_i}]

# USB-RS232 Interface
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports {rx_i}]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {tx_o}]

# 7-Segment Display
set_property -dict { PACKAGE_PIN W7  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[0]}]
set_property -dict { PACKAGE_PIN W6  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[1]}]
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[2]}]
set_property -dict { PACKAGE_PIN V8  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[3]}]
set_property -dict { PACKAGE_PIN U5  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[4]}]
set_property -dict { PACKAGE_PIN V5  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[5]}]
set_property -dict { PACKAGE_PIN U7  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_encoded_o[6]}]

set_property -dict { PACKAGE_PIN U2  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_anodes_o[0]}]
set_property -dict { PACKAGE_PIN U4  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_anodes_o[1]}]
set_property -dict { PACKAGE_PIN V4  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_anodes_o[2]}]
set_property -dict { PACKAGE_PIN W4  IOSTANDARD LVCMOS33 } [get_ports {sev_seg_anodes_o[3]}]

# LED 0-7
# set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {x}]

# LED 8-15
# set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {x}]
# set_property -dict { PACKAGE_PIN V3  IOSTANDARD LVCMOS33 } [get_ports {x}]

set_property -dict { PACKAGE_PIN W3  IOSTANDARD LVCMOS33 } [get_ports {morse_done_o}]
set_property -dict { PACKAGE_PIN U3  IOSTANDARD LVCMOS33 } [get_ports {morse_o}]

set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports {rx_done_o}]
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports {tx_done_o}]
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports {uart_fifo_empty_o}]
set_property -dict { PACKAGE_PIN L1  IOSTANDARD LVCMOS33 } [get_ports {uart_fifo_full_o}]

# Center button
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {reset_i}]
