class tb_driver extends uvm_driver #(trans1);

    `uvm_component_utils(tb_driver)
	int rep,i;
	bit flag; 	
    virtual dut_inf v_inf;
  
    // Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dut_inf)::get(this, "", "v_inf", v_inf))
            `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".v_inf"});
    endfunction
    
    virtual task run_phase(uvm_phase phase);
    forever begin
		seq_item_port.get_next_item(req);
        drive();
        seq_item_port.item_done();
    end
    endtask 

//start condition
	task start_condition(int delay);
		#delay;
		v_inf.scl_drv=1;
		v_inf.mst_sda_ctrl = 1;
		v_inf.sda_out = 0;
		`uvm_info("DRIVER",$sformatf("TB : START CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM);
	endtask

//repeated start condition
	task repeated_start_condition();
		@(negedge v_inf.scl); v_inf.mst_sda_ctrl=1; v_inf.sda_out=1;
		@(posedge v_inf.scl); v_inf.sda_out=0;
		`uvm_info("DRIVER",$sformatf("TB : REPEATED START CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM);
	endtask

// stop condition
	task stop_condition();
		@(negedge v_inf.scl) v_inf.mst_sda_ctrl=1; v_inf.sda_out=0;
		@(posedge v_inf.scl);
		`uvm_info("DRIVER",$sformatf("TB : STOP CONDITION...sda=%b\tscl=%b",v_inf.sda, v_inf.scl),UVM_MEDIUM);
		v_inf.scl_drv=0; v_inf.mst_sda_ctrl=1; v_inf.sda_out=1;
	endtask

// give control to master of SDA and assign 1-bit from MSB to LSB to SDA
	task input_byte(input bit [7:0] in_byte);
		for(int i=0; i<8; i++) begin
			@(negedge v_inf.scl);
			v_inf.mst_sda_ctrl=1;
			v_inf.sda_out = in_byte[7-i];
		end
	endtask

// give control to slave of SDA and store SDA 1-bit from MSB to LSB in data_read
	task output_byte();
		@(negedge v_inf.scl);
		for(int i=0; i<8; i++) begin
			@(posedge v_inf.scl);
			v_inf.mst_sda_ctrl=0;
			req.data_read[7-i]=v_inf.sda;
			v_inf.data_read=req.data_read;
		end
	endtask

// free SDA so slave can send ack
	task receive_ack();
		@(negedge v_inf.scl) v_inf.mst_sda_ctrl=0;
		//if(v_inf.sda_out) begin v_inf.mst_sda_ctrl=1; stop_condition;end
	endtask

// take control of SDA and send ack to slave
	task send_ack();
		@(negedge v_inf.scl) v_inf.mst_sda_ctrl=1;
		v_inf.sda_out=0;
	endtask

//during reset wait here
	task idle();
		if(!v_inf.reset)
			@(posedge v_inf.reset);
	endtask
		
//driver logic
    virtual task drive();
		if(!v_inf.reset) begin
			idle;
		end
		if(v_inf.reset) begin

			if(!flag)start_condition(20000); 

			if(!req.wr) begin //write
				#0 `uvm_info("DRIVER",$sformatf("TARGET ADDRESS=%0d",{`SLAVE_ID,req.wr}),UVM_MEDIUM);
				input_byte({1111111, req.wr});
				receive_ack();
				rep=0;
				i=1;
				repeat(bytes*2) begin //write all the packets
					if(rep%2) begin	//get memory data
						v_inf.data_write=req.data.pop_front(); 
						`uvm_info("DRIVER",$sformatf("WRITE OPREATION :: memory data=%0d",v_inf.data_write),UVM_MEDIUM);
					end
					else begin //get memory address
						v_inf.data_write=req.addr.pop_front();
						`uvm_info("DRIVER",$sformatf("WRITE OPREATION :: memory address=%0d",v_inf.data_write),UVM_MEDIUM);
					end
					input_byte(v_inf.data_write);
					receive_ack();
					rep+=1;
				end
			end
			else begin //read
				repeat(bytes) begin //read all the packets
				   #0 `uvm_info("DRIVER",$sformatf("TARGET ADDRESS=%0d",{`SLAVE_ID,!req.wr}),UVM_MEDIUM);
					input_byte({`SLAVE_ID, !req.wr});
					receive_ack();
					v_inf.data_write=req.addr.pop_front(); //get memory address
					`uvm_info("DRIVER",$sformatf("READ OPREATION :: memory address=%0d",v_inf.data_write),UVM_MEDIUM);
					input_byte(v_inf.data_write);
					receive_ack();
					repeated_start_condition();
				    #0 `uvm_info("DRIVER",$sformatf("TARGET ADDRESS=%0d",{`SLAVE_ID,req.wr}),UVM_MEDIUM);
					input_byte({`SLAVE_ID, req.wr});
					receive_ack();
					output_byte(); //get memory data
					send_ack();
					`uvm_info("DRIVER",$sformatf("READ OPERATION :: memory[%0d]=%0d",v_inf.data_write,v_inf.data_read),UVM_MEDIUM);
					if(req.addr.size()!=0) repeated_start_condition();
				end

			end

			if(rep_start) begin
				repeated_start_condition();
				flag=1;
			end
			else begin 
				stop_condition();
				flag=0;
				#20000;
			end
			rep=0;	
		end

    endtask


endclass 
