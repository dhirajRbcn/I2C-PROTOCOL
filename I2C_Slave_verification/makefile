TOP = top
WAVE = dump
test_name = sanity_test
all: clean compile simulate

clean:
	$(shell rm -r work)

compile:
	#vlog  +define+UVM_NO_DPI +define+QUESTA +incdir+~/tools/mentor/questa/2023.1/questasim/verilog_src/uvm-1.1d/src ~/tools/mentor/questa/2023.1/questasim/verilog_src/uvm-1.1d/src/uvm_pkg.sv -writetoplevels questa.tops $(TOP).sv 
	vlog -sv -O0 +acc \
+define+UVM_NO_DPI +define+QUESTA \
-writetoplevels questa.tops $(TOP).sv


simulate:
	vsim -f questa.tops -sv_seed random +UVM_TESTNAME=$(test_name) -batch -do "-voptargs=+acc -synciovcd file $(WAVE).vcd; vcd add -r /*; run -all; exit" | perl -pe 'use Term::ANSIColor; s/(.*SCOREBOARD.*)/color("bold ansi28").$$1.color("reset")/ge; s/(.*TEST STARTED.*)/color("bold ansi14").$$1.color("reset")/ge; s/(UVM_WARNING.*)/color("bold red").$$1.color("reset")/ge;  s/(.*START.*CONDITION.*)/color("bold bright_yellow").$$1.color("reset")/ge;  s/(.*STOP.*CONDITION.*)/color("bold red").$$1.color("reset")/ge; s/(.*DRIVER.*)/color("bold blue").$$1.color("reset")/ge; s/(.*MONITOR.*)/color("bold blue").$$1.color("reset")/ge; s/(UVM_ERROR.*)/color("bold red").$$1.color("reset")/ge; s/(UVM_FATAL.*)/color("bold bright_red").$$1.color("reset")/ge; '
	#vsim -f questa.tops -sv_seed random +col=$(col) +VERBOSITY=$(VERBOSITY) -voptargs=+acc -syncio -batch -do "-voptargs=+acc -synciovcd file $(WAVE).vcd; vcd add -r /*; run -all; exit"
	
view: 
	vcd2wlf $(WAVE).vcd $(WAVE).wlf
	vsim $(WAVE).wlf

help:
	@echo -n "make all TEST=names  VERBOSITY=number  col=number  write_pkt=number  read_pkt=number  \nTEST AVAILABLE:\n\ti2c_sanity_test\n\i2c_full_memory_test\n\\tdefault:i2c_sanity_test\n"
