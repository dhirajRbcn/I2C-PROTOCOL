class sanity_test extends base_test;

	`uvm_component_utils(sanity_test);

	function new(string name="sanity_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info("SANITY TEST","TEST STARTED\n",UVM_LOW)
		phase.raise_objection(this);
		bytes=2;
		rep_start=1;
        write_seq.start(env.agt.sequencer);
		rep_start=0;
        read_seq.start(env.agt.sequencer);
		phase.drop_objection(this);
	endtask


endclass
