module conv_buffer #(
   parameter    pINPUT_WIDTH  = 640
  ,parameter    pDATA_WIDTH   = 8
  ,parameter    pKERNEL_SIZE  = 3
  ,parameter    pPADDING      = 1
  ,localparam   pBUFFER_WIDTH = pINPUT_WIDTH + 2*pPADDING - pKERNEL_SIZE
  ,localparam   pWINDOW_SIZE  = pKERNEL_SIZE * pKERNEL_SIZE
)(
   input  logic                                 clk
  ,(* direct_reset = "true" *)  input logic     rst
  ,(* direct_enable = "true" *) input logic     en
  ,input  logic [pDATA_WIDTH-1:0]               data_in
  ,output logic [pDATA_WIDTH*pWINDOW_SIZE-1:0]  data_out
);   
   
  logic [0:pKERNEL_SIZE-1][0:pKERNEL_SIZE-1][pDATA_WIDTH-1:0] window_r;
  logic [pDATA_WIDTH-1:0] buffer_out [pKERNEL_SIZE-2:0];
    
  genvar line_idx;
  genvar reg_idx;
  
  generate
    // line buffers
    for (line_idx = 0; line_idx < pKERNEL_SIZE-1; line_idx = line_idx+1) begin: LINE_BUFFER_GEN
      line_buffer #(
         .pBUFFER_WIDTH ( pBUFFER_WIDTH )
        ,.pDATA_WIDTH   ( pDATA_WIDTH   )
      ) u_line_buffer (
         .clk       ( clk                     )
        ,.rst       ( rst                     )
        ,.en        ( en                      )
        ,.data_in   ( window_r[line_idx+1][0] )
        ,.data_out  ( buffer_out[line_idx]    )
      );
    end: LINE_BUFFER_GEN
  
    // window [----------------buffer----------------] - rn - ... - r1 - r0
    for (line_idx = 0; line_idx < pKERNEL_SIZE; line_idx = line_idx+1) begin: WINDOW_VER_GEN
      for (reg_idx = pKERNEL_SIZE-1; reg_idx >= 0; reg_idx = reg_idx-1) begin: WINDOW_HOR_GEN
        logic [pDATA_WIDTH-1:0] window_in;
        
        if (reg_idx == pKERNEL_SIZE-1)
          if (line_idx == pKERNEL_SIZE-1)
            assign window_in = data_in;
          else
            assign window_in = buffer_out[line_idx];
        else
          assign window_in = window_r[line_idx][reg_idx+1];
        
        always_ff @(posedge clk) begin
          if (rst)
            window_r[line_idx][reg_idx] <= 'b0;
          else
            if (en)
              window_r[line_idx][reg_idx] <= window_in;
            else
              window_r[line_idx][reg_idx] <= window_r[line_idx][reg_idx];
        end
      end: WINDOW_HOR_GEN
    end: WINDOW_VER_GEN
  endgenerate
  
  assign data_out = window_r;
  
endmodule
