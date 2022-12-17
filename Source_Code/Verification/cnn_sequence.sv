class cnn_sequence extends uvm_sequence #(cnn_sequence_item);

  `uvm_object_utils(cnn_sequence);
  
  function new (string name = "cnn_sequence");
    super.new(name);
  endfunction
    
  virtual task body ();
    bit signed [15:0] int_part;
    bit [15:0] frac_part;
    
    for (int_part = -5; int_part < -5; int_part = int_part+1) begin
      for (frac_part = 16'h0000; frac_part < 16'hffff; frac_part = frac_part+1) begin
        `uvm_do_with(req, {
          data_in[31:16] == int_part;
          data_in[15:0] == frac_part;
        });
      end
    end
  endtask
  
endclass
  