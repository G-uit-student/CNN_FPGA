module pe_dual_out_dsp #(
   parameter  pDATA_WIDTH       = 8
   
  ,parameter  pKERNEL_SIZE      = 3
  ,parameter  pIN_CHANNEL       = 1
  ,parameter  pOUT_CHANNEL      = 16
  
  ,localparam pWINDOW_SIZE      = pKERNEL_SIZE * pKERNEL_SIZE
  ,localparam pWINDOW_WIDTH     = pDATA_WIDTH * pWINDOW_SIZE
  ,localparam pCHANNEL_WIDTH    = pDATA_WIDTH * pIN_CHANNEL
  
  // kernel ram
  ,parameter  pWEIGHT_WIDTH     = 32
  ,localparam pWEIGHT_NUM       = pIN_CHANNEL*pOUT_CHANNEL*pWINDOW_SIZE*pDATA_WIDTH/pWEIGHT_WIDTH
  ,localparam pWEIGHT_ADDR      = $clog2(pWEIGHT_NUM)
  
  // multiplier pipeline stage
  ,localparam pMULT_PIPE_STAGE  = 5
)(
   input  logic                                   clk
  ,(* direct_reset = "true" *)  input  logic      rst
  ,input  logic                                   valid_in
  ,(* direct_enable = "true" *) input  logic      load_weight
  ,input  logic [pWEIGHT_WIDTH-1:0]               weight_in
  ,input  logic [pWEIGHT_ADDR-1:0]                weight_addr
  ,input  logic [0:pWINDOW_WIDTH*pIN_CHANNEL-1]   data_in
  ,output logic [4*pDATA_WIDTH*pOUT_CHANNEL-1:0]  data_out
  ,output logic                                   valid_out
);   
    
  genvar in_channel_idx;
  genvar out_channel_idx;
  genvar reg_idx;
  
  logic [pMULT_PIPE_STAGE-1:0] valid_mult_pipe_r;
  
  (* ram_style = "bram" *) logic [0:pWEIGHT_NUM-1][pWEIGHT_WIDTH-1:0] kernel_r;
  logic [0:pWEIGHT_NUM*pWEIGHT_WIDTH-1] kernel;
  
  assign kernel = kernel_r;
  
  generate
    // kernel
    always_ff @(posedge clk) begin
      if (rst)
        kernel_r <= 'b0;
      if (load_weight)
        kernel_r[weight_addr] <= weight_in;
    end
  
    // valid register
    for (reg_idx = 0; reg_idx < pMULT_PIPE_STAGE; reg_idx = reg_idx+1) begin: VALID_MULT_REG_GEN
      logic valid_mult_pipe_in;

      if (reg_idx == 0)
        assign valid_mult_pipe_in = valid_in;
      else
        assign valid_mult_pipe_in = valid_mult_pipe_r[reg_idx-1]; 
      
      always_ff @(posedge clk) begin
        if (rst)
          valid_mult_pipe_r[reg_idx] <= 'b0;
        else
          valid_mult_pipe_r[reg_idx] <= valid_mult_pipe_in;
      end
    end: VALID_MULT_REG_GEN
  
    // multiplier stage
    for (out_channel_idx = 0; out_channel_idx < pOUT_CHANNEL; out_channel_idx = out_channel_idx+2) begin: OUT_CHANNEL_GEN
      logic signed [pIN_CHANNEL-1:0][pWINDOW_SIZE-1:0][2*pDATA_WIDTH-1:0] mult_out [1:0];
      logic [1:0] adder_valid_out;

      for (in_channel_idx = 0; in_channel_idx < pIN_CHANNEL; in_channel_idx = in_channel_idx+1) begin: IN_CHANNEL_GEN
        for (reg_idx = 0; reg_idx < pWINDOW_SIZE; reg_idx = reg_idx+1) begin: KERNEL_GEN
          dual_mult_dsp u_dual_mult_dsp (
             .clk ( clk                                                                                                       )
            ,.rst ( rst                                                                                                       )
            ,.a   ( kernel[(out_channel_idx*pIN_CHANNEL+in_channel_idx)*pWINDOW_WIDTH+reg_idx*pDATA_WIDTH +: pDATA_WIDTH]     )
            ,.b   ( kernel[((out_channel_idx+1)*pIN_CHANNEL+in_channel_idx)*pWINDOW_WIDTH+reg_idx*pDATA_WIDTH +: pDATA_WIDTH] )
            ,.c   ( data_in[reg_idx*pCHANNEL_WIDTH+in_channel_idx*pDATA_WIDTH +: pDATA_WIDTH]                                 ) 
            ,.ac  ( mult_out[0][in_channel_idx][reg_idx]                                                                      )
            ,.bc  ( mult_out[1][in_channel_idx][reg_idx]                                                                      )
          );
        end: KERNEL_GEN
      end: IN_CHANNEL_GEN
      
      // tree adder stage
      adder_tree #(
         .pDATA_WIDTH ( 2*pDATA_WIDTH             )
        ,.pINPUT_NUM  ( pWINDOW_SIZE*pIN_CHANNEL  )
      ) u_adder_tree_kernel_0 (
         .clk       ( clk                                                       )
        ,.rst       ( rst                                                       )
        ,.valid_in  ( valid_mult_pipe_r[pMULT_PIPE_STAGE-1]                     )
        ,.data_in   ( mult_out[0]                                               )
        ,.data_out  ( data_out[4*pDATA_WIDTH*out_channel_idx +: 4*pDATA_WIDTH]  )
        ,.valid_out ( adder_valid_out[0]                                        )
      );
      
      adder_tree #(
         .pDATA_WIDTH ( 2*pDATA_WIDTH             )
        ,.pINPUT_NUM  ( pWINDOW_SIZE*pIN_CHANNEL  )
      ) u_adder_tree_kernel_1 (
         .clk       ( clk                                                           )
        ,.rst       ( rst                                                           )
        ,.valid_in  ( valid_mult_pipe_r[pMULT_PIPE_STAGE-1]                         )
        ,.data_in   ( mult_out[1]                                                   )
        ,.data_out  ( data_out[4*pDATA_WIDTH*(out_channel_idx+1) +: 4*pDATA_WIDTH]  )
        ,.valid_out ( adder_valid_out[1]                                            )
      );
      
      if (out_channel_idx == 0)
        assign valid_out = adder_valid_out[0];
    end: OUT_CHANNEL_GEN
  endgenerate
  
endmodule