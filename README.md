# fpga-digital-systems-lab

A progressive FPGA/HDL project built up from first-principles digital logic to a working custom 8-bit CPU and a DSP filter block, implemented in Verilog/SystemVerilog and deployed on real hardware (Digilent Basys 3 / Xilinx Artix-7).

## Overview

This repository documents the design, verification, and hardware bring-up of a set of digital systems, each built on top of the last:

- **Combinational & sequential logic** — logic gates, multiplexers, decoders, a ripple-carry adder, counters, and clock dividers, each with a self-checking testbench.
- **FPGA bring-up** — mapping simple designs onto the Basys 3 board via Vivado and board constraints, going from simulation to physical switches/LEDs.
- **PWM generator** — a parameterized pulse-width-modulation module with configurable duty cycle and frequency.
- **UART** — a full-duplex serial transmitter and receiver (start/data/stop-bit framing) with a PC-to-FPGA loopback demo.
- **tiny8 — a minimal 8-bit CPU** — a small custom processor with an ALU, register file, program counter, and instruction ROM, executing a hand-written instruction sequence in simulation and on hardware.
- **Intro DSP block** — a moving-average / FIR-style filter operating on sampled data, verified against expected output vectors.
- **Integrated top-level demo** — a single design that ties the above blocks together (e.g. UART command selects between PWM/CPU/DSP demos).

The goal is depth over breadth: each block is simulated, verified with a testbench, and (where applicable) run on physical hardware with measured results, rather than left as an unfinished sketch.

## Hardware & Toolchain

| Component | Choice |
|---|---|
| FPGA board | Digilent Basys 3 (Xilinx/AMD Artix-7, XC7A35T) |
| HDL | Verilog / SystemVerilog |
| Toolchain | AMD (Xilinx) Vivado Design Suite |
| Board I/O used | Slide switches, LEDs, push buttons, 7-segment display, USB-JTAG (programming), USB-UART (serial) |

## Repository Structure

```
rtl/           Synthesizable RTL, organized by subsystem
  gates/       Basic combinational logic (AND/OR/XOR, mux, decoder, adder)
  seq/         Counters, clock dividers, registers
  pwm/         Parameterized PWM module
  uart/        UART TX/RX
  cpu/         tiny8 CPU (ALU, register file, control, instruction memory)
  dsp/         Moving-average / FIR filter block
  top/         Integrated top-level design
tb/            Self-checking testbenches, one per rtl/ subsystem
constraints/   Basys 3 .xdc pin and timing constraints
scripts/       Simulation / build helper scripts
bitstreams/    Selected milestone .bit files for programming the board
results/       Waveforms, resource-utilization reports, verification data (expected vs. actual)
docs/          Architecture notes, design decisions, lessons learned
media/         Photos, demo videos, diagrams
```

## Getting Started

1. Install [AMD Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html) (the free WebPACK edition supports the Basys 3).
2. Clone this repository.
3. Simulate a module: open the corresponding files under `rtl/<subsystem>/` and `tb/<subsystem>/` in Vivado (or your simulator of choice) and run the testbench.
4. Build for hardware: add the relevant RTL and the `.xdc` constraints under `constraints/` to a Vivado project, run synthesis → implementation → generate bitstream.
5. Program the board: connect the Basys 3 over USB and load the bitstream via Vivado's Hardware Manager (or use a saved `.bit` file from `bitstreams/`).

## Roadmap

- [ ] Combinational logic: gates, mux, decoder, ripple-carry adder
- [ ] Sequential logic: counter, clock divider
- [ ] First FPGA bitstream (switches → LEDs)
- [ ] Parameterized PWM module
- [ ] UART transmitter
- [ ] UART receiver + PC↔FPGA loopback
- [ ] tiny8 CPU: ALU + register file
- [ ] tiny8 CPU: fetch/decode/execute, running a test program in simulation
- [ ] tiny8 CPU running on FPGA hardware
- [ ] DSP moving-average/FIR block
- [ ] Integrated top-level showcase design

## Status

Early stage — repository structure defined; RTL modules are in active development. See commit history and `docs/` for design notes as they land.
