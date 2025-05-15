# Gb_eth_switch
This repository contains a Verilog/SystemVerilog implementation of an 4 port gigabit ethernet switch based on Gigabit Media Independent Interface (GMII).
The Ethernet switch is capable of MAC address learning, packet forwarding, arbitration, and frame integrity checking via FCS.

## Features

- MAC address learning using a hash-based MAC table
- Crossbar switch fabric for interconnecting input and output ports
- Round-robin arbitration for output port access
- Frame Check Sequence (FCS) for detecting corrupted packets
- Modular design with separate components for input unit, output unit, crossbar, and MAC logic
- Testbench and simulation results

## Build and Run

Use a Verilog-compatible simulator (such as ModelSim, Vivado Simulator, or Icarus Verilog) to build and run the testbench. The design can also be synthesized and deployed using Vivado for supported FPGA platforms.


## Documentation

[Project Report (PDF)](report/34349_Ethernet_Switch.pdf): Full explanation of the architecture, design decisions, and simulation results.



*This project is intended for academic and research use. Developed for DTU course 34349: FPGA design for Communication Systems Spring 2025*
