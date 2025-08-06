class full_memory_test extends base_test;

	`uvm_component_utils(full_memory_test);

	function new(string name="full_memory_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info("FULL MEMORY TEST","TEST STARTED\n",UVM_LOW)
		phase.raise_objection(this);
		bytes=1;
		rep_start=1;
		for(int i=0;i<128;i++) begin
			write_seq.opt(1,i);
			write_seq.start(env.agt.sequencer);
			if(i==127) rep_start=0;
			read_seq.start(env.agt.sequencer);
		end
		phase.drop_objection(this);
	endtask


endclass
