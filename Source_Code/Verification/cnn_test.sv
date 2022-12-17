class cnn_test extends uvm_test;
  `uvm_component_utils(cnn_test);
  
  cnn_sequence seq;
  cnn_env env;
  
  function new (string name = "test", uvm_component parent = null);
    super.new(name, parent);
    seq = cnn_sequence::type_id::create("sequence", this);
    env = cnn_env::type_id::create("environment", this);
  endfunction
  
  virtual function void end_of_elaborate;
    uvm_top.print_topology();
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask
  
endclass
