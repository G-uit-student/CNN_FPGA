class cnn_driver extends uvm_driver #(cnn_sequence_item);
  `uvm_component_utils(cnn_driver);
  
  protected virtual cnn_interface vif;
  
  function new (string name = "cnn_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db #(virtual cnn_interface)::get(this, "", "vif", vif))
      `uvm_fatal("CFG_ERROR", "Driver DUT interface not set");
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask
  
  virtual task drive ();
    @(posedge vif.master.clk)
    vif.master.cb_master_tb.data_in <= req.data_in;
    vif.master.cb_master_tb.valid_in <= 1'b1;
  endtask
  
endclass