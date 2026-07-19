# RTL Design & Functional Verification of an IEEE 1149.1 JTAG Boundary Scan Architecture for a 4×4 Multiplier
<p align="center">

![Verilog](https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge)
![IEEE1149.1](https://img.shields.io/badge/Standard-IEEE%201149.1-green?style=for-the-badge)
![Vivado](https://img.shields.io/badge/Simulation-Vivado-red?style=for-the-badge)
![Yosys](https://img.shields.io/badge/Synthesis-Yosys-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

</p>

---

## Project Overview

This project presents the **RTL design and functional verification** of an **IEEE 1149.1 JTAG Boundary Scan architecture** integrated with a **4×4 unsigned multiplier** to demonstrate **basic Design-for-Testability (DFT)** principles.

The design includes a complete **Test Access Port (TAP) Controller**, **Instruction Register**, **Instruction Decoder**, **Boundary Scan Register**, **Boundary Scan Cells**, and **Bypass Register**, enabling structural testing and boundary scan operations through a standard JTAG interface.

The project was developed using **Verilog HDL**, functionally verified with **Vivado XSim**, and synthesized using the **Yosys Open-Source Synthesis Suite**.

---

# RTL Architecture

<p align="center">
<img src="screenshots/01_rtl_elaborated_design.png" width="950">
</p>

---

# Key Features

- ✔ IEEE 1149.1 compliant TAP Controller
- ✔ Boundary Scan Register (BSR)
- ✔ Boundary Scan Cell (BSC)
- ✔ Instruction Register (IR)
- ✔ Instruction Decoder
- ✔ Bypass Register
- ✔ EXTEST Instruction
- ✔ SAMPLE/PRELOAD Instruction
- ✔ BYPASS Instruction
- ✔ Wrapped 4×4 Multiplier DUT
- ✔ Modular RTL Design
- ✔ Self-checking Verilog Testbenches
- ✔ RTL Synthesis using Yosys
- ✔ Functional Verification
- ✔ Waveform Debugging

---

# Supported JTAG Instructions

| Instruction | Opcode | Function |
|------------|--------|----------|
| EXTEST | `000` | Drives DUT inputs through Boundary Scan Register |
| SAMPLE/PRELOAD | `001` | Captures functional data and preloads scan chain |
| BYPASS | `111` | Selects the one-bit bypass register |

---

# Repository Structure

```text
IEEE-1149.1-JTAG-DFT-for-4x4-Multiplier
│
├── rtl/
├── testbench/
├── synthesis/
├── screenshots/
├── README.md
├── LICENSE
└── .gitignore
```

---

# RTL Modules

| Module | Description |
|---------|-------------|
| TAP Controller | Implements the IEEE 1149.1 TAP finite-state machine |
| Instruction Register | Captures, shifts and updates JTAG instructions |
| Instruction Decoder | Decodes EXTEST, SAMPLE/PRELOAD and BYPASS instructions |
| Boundary Scan Cell | Single IEEE 1149.1 compliant boundary scan cell |
| Boundary Scan Register | Chains boundary scan cells around DUT I/O |
| Bypass Register | One-bit scan bypass path |
| Multiplier | 4×4 unsigned combinational multiplier |
| JTAG Top | Integrates all JTAG components |

---

# Verification

Every RTL module was verified using **self-checking Verilog testbenches**.

| Module | Verification Status |
|---------|--------------------|
| Multiplier | ✅ Passed |
| Boundary Scan Cell | ✅ Passed |
| Boundary Scan Register | ✅ Passed |
| Instruction Register | ✅ Passed |
| Instruction Decoder | ✅ Passed |
| TAP Controller | ✅ Passed |
| Bypass Register | ✅ Passed |
| Complete JTAG Top | ✅ Passed |

---

# Top-Level Verification

<p align="center">

<img src="screenshots/02_jtag_top_waveform.png" width="1000">

</p>

The top-level waveform demonstrates:

- Functional multiplier operation
- Boundary Scan operation
- Instruction execution
- JTAG interface activity
- Integrated DUT verification

---

# TAP Controller Verification

<p align="center">

<img src="screenshots/03_tap_controller_waveform.png" width="900">

</p>

The TAP Controller was verified for the complete IEEE 1149.1 state transition sequence:

- Test-Logic-Reset
- Run-Test/Idle
- Select-DR-Scan
- Capture-DR
- Shift-DR
- Update-DR
- Capture-IR
- Shift-IR
- Update-IR

---

# RTL Synthesis

RTL synthesis was successfully completed using the **Yosys Open Source Synthesis Suite**.

### Synthesis Flow

- RTL Parsing
- Hierarchy Check
- Process Conversion
- Logic Optimization
- FSM Optimization
- Technology Mapping
- Netlist Generation

---

# Synthesis Report

<p align="center">

<img src="screenshots/04_yosys_synthesis_report.png" width="750">

</p>

The synthesized design successfully maps all JTAG components into synthesizable RTL, confirming the implementation is synthesis-ready.

---

# Tools Used

- Verilog HDL
- Xilinx Vivado (Simulation & RTL Elaboration)
- Yosys Open Source Synthesis Suite
- Git
- GitHub

---

## Technologies & Skills

- Verilog HDL
- RTL Design
- Functional Verification
- Testbench Development
- IEEE 1149.1 JTAG
- TAP Controller
- Boundary Scan Register (BSR)
- Boundary Scan Cells (BSC)
- Instruction Register (IR)
- Instruction Decoder
- Bypass Register
- Scan Chain
- Basic DFT
- RTL Simulation
- Waveform Debugging
- RTL Synthesis
- Vivado
- Yosys

---

# Future Improvements

- IDCODE Instruction
- CLAMP Instruction
- HIGHZ Instruction
- OpenSTA Timing Analysis
- ATPG Compatibility
- MBIST Integration
- Scan Compression
- Standard Cell Technology Mapping

---

# Author

**Snehanjali**

B.Tech Student | Aspiring Design Verification (DV) Engineer

---

