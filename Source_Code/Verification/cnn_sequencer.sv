class cnn_sequencer extends uvm_sequencer #(cnn_sequence_item);
  `uvm_sequencer_utils(cnn_sequencer);
  
  function new (string name = "cnn_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
