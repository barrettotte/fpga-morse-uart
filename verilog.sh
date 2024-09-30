#!/bin/bash
# Use Icarus Verilog and GTKWave for quick and easy Verilog testing.
# Assumes that the target module has a testbench of the same name ending in '_tb'
#
# ex: ./verilog.sh top

set -e

if [ $# -eq 0 ]; then
  echo "Usage: $0 <module>"
  exit 1
fi

target_module=$1
tb_module="${target_module}_tb"

src_dir=./rtl
test_dir=./tb

build_dir=./build/iverilog
mkdir -p "$build_dir"

vvp_file="$build_dir/$tb_module.vvp"
waveform="$build_dir/$tb_module.vcd"

# compile testbench
echo "Compiling module $tb_module to $vvp_file"
iverilog "$test_dir/$tb_module.v" -I "$src_dir" -I "$test_dir" -o "$vvp_file"

# simulate the testbench
echo "Simulating $tb_module and outputting to $waveform"
sim_result=$(vvp "$vvp_file")
echo "$sim_result"

# exit if assertion failed
if echo "$sim_result" | grep -q 'ASSERTION FAILED'; then
  echo "Assertion failed during simulation of $tb_module"
  exit 2
fi
mv "$tb_module.vcd" "$waveform"

# open waveform (with optional .gtkw file)
gtkw_file="$build_dir/$tb_module.gtkw"

if [ -f "$gtkw_file" ]; then
  echo "Opening $waveform with $gtkw_file"
  gtkwave "$waveform" "$gtkw_file"
else
  echo "Opening $waveform"
  gtkwave "$waveform"
fi
