# Parameterized UART RTL Design, Verification and Synthesis

## 1. Project Overview

This project implements a parameterized UART (Universal Asynchronous Receiver/Transmitter) using Verilog HDL.

The UART is designed for:

- Data Width: 8 bits
- System Clock: 50 MHz
- Baud Rate: 9600 bps
- Stop Bits: 1
- Optional Parity
- FPGA Target: Xilinx Vivado

The project follows a complete RTL development flow:

```text
UART Specification
       ↓
RTL Design
       ↓
Functional Verification
       ↓
Behavioral Simulation
       ↓
Waveform Analysis
       ↓
RTL Synthesis
       ↓
Timing & Resource Analysis
2. Tools Used
Verilog HDL
Xilinx Vivado
Vivado Simulator
Xilinx Design Constraints (XDC)
3. Project Architecture

The UART is divided into independent RTL blocks.

                    +----------------------+
                    |    UART TOP MODULE   |
                    +----------+-----------+
                               |
          +--------------------+--------------------+
          |                    |                    |
          v                    v                    v
 +----------------+   +----------------+   +----------------+
 | Baud Generator |   | UART           |   | UART           |
 |                |   | Transmitter    |   | Receiver       |
 | 50 MHz → 9600  |   |                |   |                |
 | TX Enable      |   | Start Bit      |   | Start Detect   |
 | RX Enable      |   | Data Bits      |   | Data Sampling  |
 +----------------+   | Stop Bit       |   | Stop Bit       |
                      | Busy           |   | Data Output    |
                      +----------------+   +-------+--------+
                                                    |
                                                    v
                                           +----------------+
                                           | Error Detection|
                                           |                |
                                           | Parity Error   |
                                           | Framing Error  |
                                           +----------------+
4. Repository Structure
Parameterized-UART-RTL-Design/
│
├── 01_Project_report/
├── 02_handwritten_notes/
│
├── 03_rtl_source_code/
│   ├── baud_rate_generator.v
│   ├── uart_transmitter_block.v
│   ├── uart_receiver_block.v
│   ├── error_detection_2.v
│   └── uart_top_module.v
│
├── 04_testbench/
│   └── uart_tb.v
│
├── 05_constraints/
│   └── uart_constraints.xdc
│
├── 06_behavioural_simulation_screenshots/
│
├── 07_verification_screenshots/
│
├── 08_synthesis_reports/
│
└── README.md
5. RTL Design

The UART consists of five main RTL modules.

Baud Rate Generator

baud_rate_generator.v

Generates the required transmitter and receiver clock enables from the 50 MHz system clock.

50 MHz System Clock
        ↓
Baud Rate Generator
        ↓
TX Clock Enable
RX Clock Enable
UART Transmitter

uart_transmitter_block.v

Converts parallel data into a serial UART frame.

Idle → Start → Data Bits → Parity → Stop → Idle

The transmitter also generates the tx_busy signal during transmission.

UART Receiver

uart_receiver_block.v

The receiver:

Detects the start bit
Samples incoming data
Reconstructs the received byte
Samples optional parity
Samples the stop bit
Generates rx_done
Error Detection

error_detection_2.v

Checks the received UART frame for:

Parity error
Framing error

A framing error occurs when the expected HIGH stop bit is received as LOW.

Top Module

uart_top_module.v

Connects the baud generator, transmitter, receiver and error detection blocks into one complete UART.

6. UART Frame Format

The UART frame used by the design is:

        1 Bit       8 Bits       Optional       1 Bit
       Start         Data         Parity         Stop
         ↓            ↓             ↓             ↓
       ┌───┬───────────────────┬───────────┬───────┐
       │ 0 │ D0 D1 D2 D3 D4... │  Parity   │   1   │
       └───┴───────────────────┴───────────┴───────┘

Data is transmitted LSB first.

7. Functional Verification

A self-checking Verilog testbench is included:

04_testbench/uart_tb.v

The testbench verifies:

Reset functionality
Single-byte transmission
Multiple-byte transmission
Receiver data validation
Random data transmission
Back-to-back packet transfer
Parity error detection
Framing error detection
UART frame injection
Receiver sampling
Baud-rate timing

Normal communication is tested using loopback:

        UART Transmitter
               |
               | tx_serial
               v
        UART Receiver
               |
               v
           data_out

For error testing, UART frames are directly injected into the receiver to test invalid parity and stop-bit conditions.

8. Behavioral Simulation

The complete UART was simulated using Xilinx Vivado.

The simulation verifies:

UART transmission
UART reception
Baud timing
Receiver sampling
tx_busy
rx_done
Error flags
Behavioral Simulation

Baud Rate Timing

Serial Transmission

Data Reception

Receiver Sampling

9. Error Verification
Parity Error

An intentionally incorrect parity bit is injected into the receiver.

The receiver detects the invalid parity condition and asserts:

parity_error = 1

Framing Error

An invalid stop bit is injected into the receiver.

The receiver detects the invalid stop condition and asserts:

framing_error = 1

10. Verification Results

The testbench automatically compares expected and received data and reports PASS or FAIL.

Expected Data
      ↓
UART Transmission
      ↓
UART Reception
      ↓
Received Data
      ↓
Automatic Comparison
      ↓
PASS / FAIL

This provides self-checking functional verification rather than relying only on visual waveform inspection.

11. RTL Synthesis

After successful simulation, the UART RTL was synthesized using Xilinx Vivado.

The synthesis flow was used to analyze:

RTL structure
FPGA resource utilization
LUT count
Register count
Timing
Critical paths
RTL Schematic

Technology Schematic

12. Synthesis Results
LUT Utilization

Register Utilization

Resource Utilization

13. Timing Analysis

Timing reports were generated using Vivado.

The analysis includes:

Setup timing
Hold timing
Critical path
Clock timing
Maximum operating frequency
Timing Summary

Setup and Hold Timing

The timing results are used to verify that the UART can operate correctly with the target 50 MHz system clock.

14. Key Learning Outcomes

Through this project, I implemented and verified:

Parameterized RTL design
UART transmitter and receiver
FSM-based control logic
Baud-rate generation
Serial data transmission and reception
Parity and framing error detection
Self-checking verification
UART frame injection
Behavioral simulation
RTL synthesis
FPGA timing analysis
Resource utilization analysis
15. Conclusion

This project demonstrates a complete RTL-to-synthesis workflow for a reusable parameterized UART controller.

The design was developed using modular Verilog RTL, verified using a self-checking testbench, simulated using Vivado, and synthesized to analyze timing and FPGA resource utilization.

The project provides practical experience in RTL design, functional verification, simulation, debugging and FPGA synthesis.
