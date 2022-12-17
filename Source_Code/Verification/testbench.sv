`include "cnn_pkg.sv"

module testbench ();
  import cnn_pkg::*;
  
  localparam pPERIOD = 10;
  localparam pDATA_WIDTH  = 32;
  localparam pFRACTION = 16;
  
  logic clk;
  logic rst_n;      

  cnn_interface intf (
     .clk	(	clk		)
    ,.rst_n	(	rst_n	)
  );
  
  cnn_top #(
     .pDATA_WIDTH	( pDATA_WIDTH	)
    ,.pFRACTION		( pFRACTION	  	)
  ) u_inst (
    .intf			(	intf.slave	)
  );
	
  always #(pPERIOD/2) clk <= !clk;
  
  
  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    
    #pPERIOD;
    rst_n = 1'b1;
  end
  
  initial begin
    uvm_config_db #(virtual cnn_interface)::set(uvm_root::get(), "*", "vif", intf);
    run_test();
  end

endmodule
