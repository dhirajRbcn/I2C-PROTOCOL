class tb_monitor extends uvm_monitor;

    event start;
	bit transaction=0;
    // Virtual Interface
    virtual dut_inf v_inf;
    uvm_analysis_port #(trans1) item_collected_port;
    // Placeholder to capture transaction information.
    trans1 trans_collected;

    `uvm_component_utils(tb_monitor)

    // new - constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dut_inf)::get(this, "", "v_inf", v_inf))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".v_inf"});
		trans_collected = trans1::type_id::create("trans_collected");
		trans_collected.tb_addr_data=0;
    endfunction

    // run phase
    virtual task run_phase(uvm_phase phase);
		forever begin
    		trans1 trans_collected;
        	trans_collected = trans1::type_id::create("trans_collected");
			//monitor logic...
			monitor();
        	
		end
    endtask

//store the slave target address
	virtual task target();
		trans_collected.tb_count=0;
		repeat(8) begin
			@(posedge v_inf.scl);
			trans_collected.target_addr[~trans_collected.tb_count[2:0]]=v_inf.sda;
			trans_collected.tb_count+=1;
		end
		`uvm_info("MONITOR",$sformatf("TARGET ADDRESS :%d",trans_collected.target_addr),UVM_MEDIUM);	
		trans_collected.tb_count=0;
	endtask

//check ack received or not
	virtual task rec_ack();
		@(posedge v_inf.scl);
		if(!v_inf.sda) begin `uvm_info("MONITOR",$sformatf("ACKNOWLEDGE RECEIVED"),UVM_MEDIUM); end
		else begin `uvm_info("MONITOR",$sformatf("ACKNOWLEDGE NOT RECEIVED"),UVM_MEDIUM); end
	endtask
//during write target_addr[0]==0;
	virtual task write();
			trans_collected.tb_count=0;
			repeat(8) begin
				@(posedge v_inf.scl);
				trans_collected.data_write[~trans_collected.tb_count[2:0]]=v_inf.sda;
				trans_collected.tb_count+=1;
			end
			if(!trans_collected.tb_addr_data) begin 
				`uvm_info("MONITOR",$sformatf("MEMORY ADDRESS :%d",trans_collected.data_write),UVM_MEDIUM); 
			end else begin
				`uvm_info("MONITOR",$sformatf("MEMORY DATA :%d",trans_collected.data_write),UVM_MEDIUM);
			end
			rec_ack();
			if(!trans_collected.tb_addr_data) begin 
				trans_collected.mem_addr=trans_collected.data_write;
			end else begin
				trans_collected.mem_data=trans_collected.data_write;
				item_collected_port.write(trans_collected); //send to scoreboard
			end
			trans_collected.tb_count=0;
			trans_collected.tb_addr_data=~trans_collected.tb_addr_data;
	endtask

//during read target_addr[0]==1;
	virtual task read();
			trans_collected.tb_count=0;
			repeat(8) begin
				@(posedge v_inf.scl);
				trans_collected.data_read[~trans_collected.tb_count[2:0]]=v_inf.sda;
				trans_collected.tb_count+=1;
			end
			`uvm_info("MONITOR",$sformatf("READ OPERATION :: MEMORY DATA mem[%d] :%d",trans_collected.mem_addr,trans_collected.data_read),UVM_MEDIUM); 
			rec_ack();
			trans_collected.mem_data=trans_collected.data_read;
			item_collected_port.write(trans_collected); //send to scoreboard
			trans_collected.tb_count=0;
	endtask

//monitor logic
	virtual task monitor();
			fork
			forever begin:start_condition
					@(negedge v_inf.sda iff v_inf.scl);	
					if(transaction) begin
						`uvm_info("MONITOR",$sformatf("TB : REPEATED START CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM);
						disable monitor_logic;
						disable monitor_logic.write_logic;
						disable monitor_logic.read_logic;
						trans_collected.tb_addr_data = 0;	
					end
					else begin `uvm_info("MONITOR",$sformatf("TB : START CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM); end
					-> start;
			end
			forever begin:stop_condition
					@(posedge v_inf.sda iff v_inf.scl);	
					`uvm_info("MONITOR",$sformatf("TB : STOP CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM);
					transaction=0;
					disable monitor_logic;
			end
			forever begin:monitor_logic
					wait(start.triggered);
					transaction=1;
					target();
					rec_ack();
					if(!trans_collected.target_addr[0]) begin //WRITE OPERATION
						forever begin:write_logic
							write();	
						end
					end
					else begin	//READ OPERATION
						forever begin:read_logic
							read();	
						end
					end
					
				end
			join

	endtask;

endclass
