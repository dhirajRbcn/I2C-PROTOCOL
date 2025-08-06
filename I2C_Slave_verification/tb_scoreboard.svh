class tb_scoreboard extends uvm_scoreboard;
	
	reg [8-1 : 0] mem [0 : (1<<8)-1];
    
    `uvm_component_utils(tb_scoreboard)
    uvm_analysis_imp#(trans1, tb_scoreboard) item_collected_export;

    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction
  
    // write
    virtual function void write(trans1 pkt);
		if(!pkt.target_addr[0]) begin
			mem[pkt.mem_addr]=pkt.data_write;
			`uvm_info("SCOREBOARD",$sformatf("WRITE OPERATION SUCCESSFULLY DONE mem[%d]=%d",pkt.mem_addr,pkt.mem_data),UVM_MEDIUM); 
		end
		else begin
			if(pkt.data_read===mem[pkt.mem_addr]) begin
				`uvm_info("SCOREBOARD",$sformatf("READ OPERATION SUCCESSFULLY DONE "),UVM_MEDIUM); 
				`uvm_info("SCOREBOARD",$sformatf("At Memory Address : %d ",pkt.mem_addr),UVM_MEDIUM);
				`uvm_info("SCOREBOARD",$sformatf("Expexcted Data : %d    Actual Data : %d",pkt.data_read,mem[pkt.mem_addr]),UVM_MEDIUM); 
			end
			else begin
				`uvm_error("SCOREBOARD",$sformatf("READ OPERATION NOT SUCCESSFULLY DONE")); 
				`uvm_error("SCOREBOARD",$sformatf("At Memory Address : %d ",pkt.mem_addr));
				`uvm_error("SCOREBOARD",$sformatf("Expexcted Data : %d    Actual Data : %d",pkt.data_read,mem[pkt.mem_addr])); 
			end	

		end
    endfunction

    // run phase
    virtual task run_phase(uvm_phase phase);
        //scoreboard logic ---  
    endtask

endclass

/*
`include "sb_predictor.svh"
`include "sb_comparator.svh"

class tb_scoreboard extends uvm_scoreboard;
	
	`uvm_component_utils(tb_scoreboard)
	
	uvm_analysis_export #(trans1) axp_in;
	uvm_analysis_export #(trans1) axp_out;
	sb_predictor prd;
	sb_comparator cmp;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		axp_in = new("axp_in", this);
		axp_out = new("axp_out", this);
		prd = sb_predictor::type_id::create("prd", this);
		cmp	= sb_comparator::type_id::create("cmp", this);
	endfunction
	
	function void connect_phase( uvm_phase phase );
		axp_in.connect(prd.analysis_export);
		axp_out.connect(cmp.axp_out);
		prd.results_ap.connect(cmp.axp_in);
	endfunction

endclass
*/
