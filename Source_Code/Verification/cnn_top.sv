`include "sigmoid.sv"
`include "cnn_interface.sv"

module cnn_top #(
   parameter pDATA_WIDTH  = 32
  ,parameter pFRACTION	  = 16
)(
   cnn_interface.slave		intf
);
     
   sigmoid #(
      .DATA_WIDTH	( pDATA_WIDTH )
     ,.FRAC_BITS	( pFRACTION	  )
   ) u_sigmoid (
     .clk		(	intf.clk		)
     ,.rst_n	(	intf.rst_n		)
     ,.i_valid	(	intf.valid_in	)
     ,.i_data	(	intf.data_in	)
     ,.o_valid	(	intf.valid_out	)
     ,.o_data	(	intf.data_out	)
   );

endmodule

