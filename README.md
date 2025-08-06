# I2C-PROTOCOL
I2C PROTOCOL RTL designed in Verilog and verified it with the help of UVM Layered testbench considering all edge cases
I2C Protocol UVM Verification Environment (SystemVerilog + Makefile Automation)
This repository contains a UVM (Universal Verification Methodology) based verification environment for the I2C Protocol Controller. The setup is automated using Makefile scripts for compilation, simulation, waveform viewing, and testcase management using Mentor QuestaSim. The environment is designed to validate I2C protocol compliance, functional correctness, and stress scenarios with scalable testcases.

# Project Documentation
Project Overview
This project provides a verification environment for an I2C Protocol Controller DUT (Device Under Test) using UVM 1.2 methodology. The testbench structure includes standard UVM components like Driver, Monitor, Sequencer, Scoreboard, and Agent. The Makefile-based automation flow simplifies test execution and regression.

Key Features:
UVM-based layered testbench for I2C protocol verification.
Makefile automation for Compile, Simulate, Waveform View.
Dynamic testcase selection through Makefile variables.
Simulation log color coding for quick error/warning spotting.
Generates VCD waveforms and supports GTKWave/QuestaSim waveform viewing.
Extensible for additional testcases (directed/randomized).

Testcases Supported
Test Name Argument	  :    Description
i2c_sanity_test	Basic      Sanity Test for I2C Read/Write
i2c_full_memory_test	     Full Memory Read/Write Functional Test
default	i2c_sanity_test


Skills Demonstrated
UVM-Based Testbench Architecture (Driver, Monitor, Scoreboard).
I2C Protocol Verification (Functional & Protocol Level).
Makefile Automation for Verification Flows.
Debugging with Colored Logs & Waveform Viewing.
Directed & Scalable Testcase Execution.

