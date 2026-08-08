# RTL Design, Verification, and Synthesis of a Parameterized UART

## Project Overview

This project implements a parameterized UART communication controller using Verilog HDL.

The design includes a UART transmitter, UART receiver, baud rate generator, parity handling, framing error detection, functional verification, and RTL synthesis using Xilinx Vivado.

The project was developed as part of a VLSI Internship Major Project with the objective of demonstrating practical RTL design, verification, simulation, and synthesis skills.

## Default Specifications

| Parameter | Value |
|---|---|
| Design Language | Verilog HDL |
| Data Width | 8 bits |
| System Clock | 50 MHz |
| Baud Rate | 9600 bps |
| Stop Bits | 1 |
| Parity | Configurable |
| Simulation Tool | Xilinx Vivado |
| Target | FPGA |

## UART Frame Format

The UART frame consists of:

```text
Idle    Start    Data Bits        Parity       Stop
  1       0      D0 D1 ... D7       P            1
