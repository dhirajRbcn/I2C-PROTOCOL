class tb_env extends uvm_env;
  
    //---------------------------------------
    // agent and scoreboard instance
    //---------------------------------------
    //tb_agent#(parameter variables)      tb_agnt;
    tb_agent agt;
    tb_scoreboard scb;
    
    `uvm_component_utils(tb_env)
    //--------------------------------------- 
    // constructor
    //---------------------------------------
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //---------------------------------------
    // build_phase - crate the components
    //---------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = tb_agent::type_id::create("agt", this);
        scb  = tb_scoreboard::type_id::create("scb", this);
    endfunction
  
    //---------------------------------------
    // connect_phase - connecting monitor and scoreboard port
    //---------------------------------------
    function void connect_phase(uvm_phase phase);
        agt.monitor.item_collected_port.connect(scb.item_collected_export);
    endfunction

endclass
