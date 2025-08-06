/*
Active and Passive agent
   set_config_int("path_to_agent", "is_active", UVM_ACTIVE);
   set_config_int("path_to_agent", "is_active", UVM_PASSIVE);
   get_is_active() Returns UVM_ACTIVE if the agent is acting as an active agent and UVM_PASSIVE if the agent acting as a passive agent.
*/

class tb_agent extends uvm_agent;
  
    //declaring agent components
    tb_driver    driver;
    tb_sequencer sequencer;
    tb_monitor   monitor;

    // UVM automation macros for general components
    `uvm_component_utils(tb_agent)

    // constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            driver = tb_driver::type_id::create("driver", this);
            sequencer = tb_sequencer::type_id::create("sequencer", this);
        end
        monitor = tb_monitor::type_id::create("monitor", this);
    endfunction

    // connect_phase
    function void connect_phase(uvm_phase phase);
        if(get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    endfunction

endclass
