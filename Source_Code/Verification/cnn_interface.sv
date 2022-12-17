interface cnn_interface (
   input	logic			clk
  ,input	logic			rst_n
);
  
  logic			valid_in;
  logic	[31:0]	data_in;
  logic			valid_out;
  logic	[31:0]	data_out;
  
  clocking cb_master_tb @(posedge clk);
    default input #1 output #1;
    input 	valid_out;
    input 	data_out;
    output	valid_in;
    output	data_in;
  endclocking
    
  modport master (
     input		clk
    ,input		valid_out
    ,input		data_out
    ,output		valid_in
    ,output		data_in
    ,clocking	cb_master_tb
  );
        
  modport slave (
     input	clk
    ,input	rst_n
    ,input	valid_in
    ,input	data_in
    ,output	valid_out
    ,output	data_out
  );
    
endinterface
