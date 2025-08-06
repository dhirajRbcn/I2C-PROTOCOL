
class tr_sequence extends uvm_sequence#(trans1);
    
	bit opn;
	logic [8-1:0] adr;
    
	`uvm_object_utils(tr_sequence)

    function new(string name = "tr_sequence");
        super.new(name);
    endfunction

	virtual task opt(bit op=0,logic [8-1:0] ad=20);
		opn=op;
		adr=ad;
	endtask

endclass
//class write_sequence extends uvm_sequence#(trans1);
class write_sequence extends tr_sequence;
    
    `uvm_object_utils(write_sequence)
	int i;

    function new(string name = "write_sequence");
        super.new(name);
    endfunction


    virtual task body();
			req=trans1::type_id::create("req");
			wait_for_grant();
			i=0;
			repeat(bytes) begin
				req.randomize() with {req.wr==0;};
				if(opn) begin	
					req.addr.push_back(adr);
				end 
				else begin 
					req.addr.push_back(req.mem_addr);
				end
					req.data.push_back(req.mem_data);
				cfg::temp_addr[i]=req.addr[i];
				i+=1;
			end
			send_request(req);
			wait_for_item_done();
    endtask

endclass

//class read_sequence extends uvm_sequence#(trans1);
class read_sequence extends tr_sequence;
    
    `uvm_object_utils(read_sequence)

	int i;
    function new(string name = "read_sequence");
        super.new(name);
    endfunction

    virtual task body();
		req=trans1::type_id::create("req");
		wait_for_grant();
		i=0;
		repeat(bytes) begin
			req.randomize() with {req.wr==1;};
			req.addr.push_back(cfg::temp_addr[i]);
			i+=1;
		end
		send_request(req);
		wait_for_item_done();
    endtask

endclass
