# fpga-morse-uart

Receives ASCII over UART, echo it back, and output as morse code beeps.

Uses Basys 3 Artix-7 board (XC7A35TCPG236-1).

## Serial Terminal

To test with FPGA, a serial connection is needed.

Find USB serial port with `Device Manager > Ports (COM & LPT) > USB Serial Port (COM?)`

or with PowerShell `Get-PnpDevice -Class "Ports" | Select-Object -Property InstanceId, FriendlyName`

Use [PuTTY](https://www.putty.org/) or other serial terminal with config:
```txt
Serial line:   COM?
Speed (baud):  9600
Data bits:     8
Stop bits:     1
Parity:        None
Flow control:  XON/XOFF
```

## Development

Requirements:
- WSL
- Vivado 2024.1+
- GTKWave (in WSL `apt-get install gtkwave -y`)

Verify Vivado is installed and its binaries (`xilinx/Vivado/2024.1/bin`) are in system path with `vivado -version`.
Also, verify GTKWave is installed on WSL with `wsl -e gtkwave --version`.

### Workflow

```sh
# build bitstream file
./vivado.ps1 build

# simulate specific module testbench and generate waveform
$env:SIM_MODULE='blink'; ./vivado.ps1 simulate

# open waveform in gtkwave via WSL
wsl -e gtkwave build/blink_tb.vcd

# build and upload bitstream to FPGA
./vivado.ps1 program_board
```

Optionally, you can still develop in project mode with the following:

```sh
# create Vivado project
./vivado.ps1 create_project

# open Vivado project in GUI
./vivado.ps1 gui
```

### Icarus Verilog

To speed up development with Verilog, Icarus Verilog can be used in WSL.

```sh
# install dependencies
apt-get install iverilog -y

# build, simulate, and open waveform for module
wsl ./verilog.sh top
```

## References

- [Basys 3 Reference Manual](https://digilent.com/reference/programmable-logic/basys-3/reference-manual)
- [Vivado Design Suite Tcl Command Reference Guide](https://docs.amd.com/r/en-US/ug835-vivado-tcl-commands)
- https://projectf.io/posts/vivado-tcl-build-script/
- [FPGA Prototyping by Verilog Examples by Pong P. Chu (2008)](https://isbnsearch.org/isbn/9780470185322)
- https://digilent.com/reference/basys3/refmanual#seven_segment_display
- https://morsecode.world/american/morse.html
