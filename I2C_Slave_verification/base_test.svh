class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    tb_env env;
    tr_sequence tr_seq;
    write_sequence write_seq;
    read_sequence read_seq;

    function new(string name = "base_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = tb_env::type_id::create("env", this);
        write_seq = write_sequence::type_id::create("write_seq");
        read_seq = read_sequence::type_id::create("read_seq");
    endfunction

    virtual function void end_of_elaboration();
        `uvm_info("BASE TEST","start",UVM_LOW)
		this.print();
        uvm_factory::get().print();
    endfunction

	virtual function void report_phase(uvm_phase phase);
		uvm_report_server repsvr;
		super.report_phase(phase);
		repsvr=uvm_report_server::get_server();
		if(repsvr.get_severity_count(UVM_FATAL)+repsvr.get_severity_count(UVM_ERROR)>0) begin
			$write("\033[1;91m");
			`uvm_info(get_type_name(),"-------------------------",UVM_LOW)
			`uvm_info(get_type_name(),"---------TEST FAIL-------",UVM_LOW)
			`uvm_info(get_type_name(),"-------------------------",UVM_LOW)
			$write("\033[0m");
		end
		else begin
			$write("\033[1;92m");
			`uvm_info(get_type_name(),"-------------------------",UVM_LOW)
			`uvm_info(get_type_name(),"---------TEST PASS-------",UVM_LOW)
			`uvm_info(get_type_name(),"-------------------------",UVM_LOW)
			$write("\033[1;0m");
		end
	endfunction

endclass 
