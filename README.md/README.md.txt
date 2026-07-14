# IEEE 1149.1 JTAG Boundary Scan DFT

An RTL implementation of the IEEE 1149.1 (JTAG) Boundary Scan architecture in Verilog HDL. This project demonstrates the design, verification, and synthesis of a complete JTAG Test Access Port (TAP) with Boundary Scan support wrapped around a 4×4 multiplier Design Under Test (DUT).

---

## Project Overview

Boundary Scan (IEEE 1149.1) is a Design-for-Testability (DFT) standard that enables testing and debugging of digital integrated circuits without requiring physical access to internal nodes.

This project implements a complete JTAG architecture including:

- 16-State TAP Controller
- Instruction Register (IR)
- Instruction Decoder
- Boundary Scan Register (BSR)
- Boundary Scan Cells
- BYPASS Register
- JTAG Top-Level Integration
- 4×4 Multiplier as the Design Under Test (DUT)

The design has been exhaustively verified using self-checking Verilog testbenches and synthesized using Yosys.

---

## Features

- IEEE 1149.1 compliant TAP Controller
- Complete 16-state TAP finite state machine
- Parameterized Instruction Register
- Instruction Decoder supporting:
  - EXTEST
  - SAMPLE/PRELOAD
  - BYPASS
- Parameterized Boundary Scan Register
- Boundary Scan Cell implementation
- Single-bit BYPASS Register
- Parameterized design for scalability
- Self-checking verification environment
- RTL synthesis using Yosys

---

## Project Architecture

```
                  +-----------------------+
                  |    TAP Controller     |
                  +----------+------------+
                             |
              +--------------+--------------+
              |                             |
      Instruction Register          Data Registers
              |                             |
      Instruction Decoder        +-----------+-----------+
                                 |                       |
                      Boundary Scan Register     BYPASS Register
                                 |
                          4×4 Multiplier DUT
                                 |
                                TDO
```

---

## Repository Structure

```
IEEE-1149.1-JTAG-DFT
│
├── rtl/
│   ├── jtag_top.v
│   ├── tap_controller.v
│   ├── instruction_register.v
│   ├── instruction_decoder.v
│   ├── boundary_scan_cell.v
│   ├── boundary_scan_register.v
│   ├── bypass_register.v
│   └── multiplier_4x4.v
│
├── testbench/
│   ├── tb_jtag_top.v
│   ├── tb_tap_controller.v
│   ├── tb_instruction_register.v
│   ├── tb_instruction_decoder.v
│   ├── tb_boundary_scan_cell.v
│   ├── tb_boundary_scan_register.v
│   ├── tb_bypass_register.v
│   └── tb_multiplier.v
│
├── synthesis/
│   ├── synth_jtag.ys
│   ├── jtag_top_synth.v
│   └── synthesis_report.txt
│
├── scripts/
│   └── *.tcl
│
└── README.md
```

---

## Supported Instructions

| Instruction | Opcode | Description |
|------------|--------|-------------|
| EXTEST | 000 | Drives boundary scan register contents to external pins |
| SAMPLE/PRELOAD | 001 | Samples system signals or preloads test data |
| BYPASS | 111 | Selects the single-bit bypass register |
| Reserved | Others | Default to BYPASS |

---

## TAP Controller States

The implementation includes all 16 IEEE 1149.1 TAP controller states:

- Test-Logic-Reset
- Run-Test/Idle
- Select-DR-Scan
- Capture-DR
- Shift-DR
- Exit1-DR
- Pause-DR
- Exit2-DR
- Update-DR
- Select-IR-Scan
- Capture-IR
- Shift-IR
- Exit1-IR
- Pause-IR
- Exit2-IR
- Update-IR

---

## Verification

Self-checking testbenches have been developed for every RTL module.

### Verified Modules

- Multiplier
- TAP Controller
- Instruction Register
- Instruction Decoder
- Boundary Scan Cell
- Boundary Scan Register
- BYPASS Register
- Complete JTAG Top-Level

Verification includes:

- Functional verification
- Exhaustive multiplier testing
- TAP state transition verification
- Boundary scan operations
- Instruction decoding
- EXTEST operation
- SAMPLE/PRELOAD operation
- BYPASS operation
- Reset verification

All simulations completed successfully with zero functional errors.

---

## Synthesis

The complete RTL design was synthesized using **Yosys Open Synthesis Suite**.

### Synthesis Flow

- RTL Parsing
- Hierarchy Checking
- Process Conversion
- Logic Optimization
- Technology Mapping
- Netlist Generation

Generated Outputs:

- Synthesized Verilog Netlist
- Synthesis Statistics Report

---

## Tools Used

- Verilog HDL
- Vivado Simulator (XSim)
- Yosys Open Synthesis Suite
- Git
- GitHub

---

## Learning Outcomes

Through this project, the following concepts were implemented and verified:

- IEEE 1149.1 Boundary Scan Architecture
- JTAG Protocol
- TAP Controller FSM
- Design-for-Testability (DFT)
- Boundary Scan Testing
- Scan Chain Operation
- RTL Design
- Self-Checking Verification
- RTL Synthesis
- Modular Hardware Design

---

## Future Improvements

- IDCODE Instruction
- CLAMP Instruction
- HIGHZ Instruction
- BSDL File Generation
- Multiple Boundary Scan Cell Types
- Gate-Level Simulation
- Static Timing Analysis
- ATPG Integration

---

## Author

**Snehanjali Dasari**

Electronics and Communication Engineering Student

Interested in:

- Digital Design
- RTL Design
- Design Verification
- Design-for-Testability (DFT)
- Semiconductor Engineering

---

## License

This project is released under the MIT License.