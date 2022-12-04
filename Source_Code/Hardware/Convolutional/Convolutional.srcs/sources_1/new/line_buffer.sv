module line_buffer #(
   parameter  pBUFFER_WIDTH = 640
  ,parameter  pDATA_WIDTH   = 8
)(
   input  logic                               clk
  ,(* direct_reset = "true" *)  input  logic  rst
  ,(* direct_enable = "true" *) input  logic  en
  ,input  logic [pDATA_WIDTH-1:0]             data_in
  ,output logic [pDATA_WIDTH-1:0]             data_out
);
 
  logic [pDATA_WIDTH-1:0] buffer_r [pBUFFER_WIDTH-1:0];
  
  genvar reg_idx;
  
  generate
    for (reg_idx = 0; reg_idx < pBUFFER_WIDTH; reg_idx = reg_idx+1) begin: REG_GEN
      logic [pDATA_WIDTH-1:0] buffer_in;
      
      if (reg_idx == 0)
        assign buffer_in = data_in;
      else
        assign buffer_in = buffer_r[reg_idx-1];
      
      always_ff @(posedge clk) begin
        if (rst)
          buffer_r[reg_idx] <= 'b0;
        else
          if (en)
            buffer_r[reg_idx] <= buffer_in;
          else
            buffer_r[reg_idx] <= buffer_r[reg_idx];
        end
    end: REG_GEN
  endgenerate
    
  assign data_out = buffer_r[pBUFFER_WIDTH-1];
   
endmodule
