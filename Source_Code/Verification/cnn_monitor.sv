class cnn_monitor extends uvm_monitor;
  `uvm_component_utils(cnn_monitor);
  
  virtual cnn_interface vif;
  cnn_sequence_item trans_collected;
  uvm_analysis_port #(cnn_sequence_item) item_collected_port;
  
  function new (string name = "cnn_monitor", uvm_component parent = null);
    super.new(name, parent);
    trans_collected = cnn_sequence_item #(32)::type_id::create();
    item_collected_port = new("item_collected_port", this);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db #(virtual cnn_interface)::get(this, "", "vif", vif))
      `uvm_fatal("CFG_ERROR", "Driver DUT interface not set");
  endfunction
  
  virtual task run_phase (uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (vif.master.valid_in || vif.master.valid_out) begin
        trans_collected.data_in = vif.master.data_in;
        trans_collected.data_out = vif.master.data_out;
        trans_collected.valid_in = vif.master.valid_in;
        trans_collected.valid_out = vif.master.valid_out;
        item_collected_port.write(trans_collected);
      end
    end
  endtask
  
endclass
