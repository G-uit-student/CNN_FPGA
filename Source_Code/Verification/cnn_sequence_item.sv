class cnn_sequence_item #(
   parameter pDATA_WIDTH = 32
) extends uvm_sequence_item;
  	
  rand	bit	[pDATA_WIDTH-1:0] data_in;
  		bit	[pDATA_WIDTH-1:0] data_out;
  		bit					  valid_in;
  		bit					  valid_out;
  
  `uvm_object_utils_begin(cnn_sequence_item)
  	`uvm_field_int(data_in, UVM_ALL_ON)
  	`uvm_field_int(data_out, UVM_ALL_ON)
  	`uvm_field_int(valid_in, UVM_ALL_ON)
  	`uvm_field_int(valid_out, UVM_ALL_ON)
  `uvm_object_utils_end
  	
  function new (string name = "cnn_sequence_item");
    super.new(name);	
  endfunction
  
endclass
