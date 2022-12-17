class cnn_scoreboard #(
   parameter pDATA_WIDTH = 32
  ,parameter pFRACTION = 16
) extends uvm_scoreboard;
  
  `uvm_component_utils(cnn_scoreboard);
  
  localparam SF = 2.0**(-pFRACTION);
  uvm_analysis_imp #(cnn_sequence_item, cnn_scoreboard) item_collected_export;
  
  uvm_queue #(real) results;
  real x;
  real error;
  int results_file;

  function new (string name = "cnn_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    results = new();
    item_collected_export = new("item_collected_exprt", this);

    results_file = $fopen("./results.log", "w");
    $fclose(results_file);
  endfunction
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);  
  endfunction
  
  virtual function void write (cnn_sequence_item item);
    if (item.valid_in) begin
      x = $itor(item.data_in*SF);
      if (item.data_in[31])
        x = x-2**16;
      results.push_front(sigmoid_func(x));
      
      results_file = $fopen("./results.log", "a");
      $fwrite(results_file, $sformatf("x: %f\n", x));
      $fclose(results_file);
    end
     
    if (item.valid_out) begin
      error = results.pop_back() - $itor(item.data_out*SF);
      results_file = $fopen("./results.log", "a");
      $fwrite(results_file, $sformatf("error: %f\n", $abs(error)));
      $fclose(results_file);
    end
  endfunction
  
  function real sigmoid_func (real x);
    return 1.0 / (1.0 + $exp(-x));
  endfunction
  
endclass
