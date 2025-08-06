#!/bin/bash

gvim -p trans1.svh tr_sequence.svh tb_sequencer.svh tb_driver.svh tb_monitor.svh tb_scoreboard.svh tb_agent.svh tb_environment.svh
gvim -p base_test.svh 
gvim -p top.sv design.sv makefile dut_interface.sv 

