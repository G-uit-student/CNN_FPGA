module processing_element #(
   parameter    pDATA_WIDTH   = 8
  ,parameter    pKERNEL_SIZE  = 3
  ,parameter    pIN_CHANNEL   = 1
  ,parameter    pOUT_CHANNEL  = 1
  ,localparam   pWINDOW_SIZE  = pKERNEL_SIZE * pKERNEL_SIZE
  ,localparam   pWINDOW_WIDTH = pDATA_WIDTH * pWINDOW_SIZE
)(
   input  logic                                               clk
  ,(* direct_reset = "true" *)  input  logic                  rst
  ,input  logic                                               valid_in
  ,input  logic signed  [pDATA_WIDTH*pOUT_CHANNEL-1:0]        bias_in
  ,input  logic [pWINDOW_WIDTH*pIN_CHANNEL*pOUT_CHANNEL-1:0]  kernel_in
  ,input  logic [pWINDOW_WIDTH*pIN_CHANNEL-1:0]               data_in
  ,output logic [2*pDATA_WIDTH*pOUT_CHANNEL-1:0]              data_out
  ,output logic                                               valid_out
);   
    
//  genvar in_channel_idx;
//  genvar out_channel_idx;
//  genvar reg_idx;
  
//  logic [3:0] mult_valid_reg_in_pipe;
//  logic [3:0] mult_valid_reg_pipe_r;
  
//  generate
//    for (reg_idx = 0; reg_idx < 3; reg_idx = reg_idx+1) begin: VALID_REG_GEN
//      if (reg_idx == 0)
//        assign mult_valid_reg_in_pipe[reg_idx] = valid_in;
//      else
//        assign mult_valid_reg_in_pipe[reg_idx] = mult_valid_reg_pipe_r[reg_idx-1]; 
      
//      always_ff @(posedge clk) begin
//        if (rst)
//        mult_valid_reg_pipe_r[reg_idx] <= 'b0;
//      else
//        mult_valid_reg_pipe_r[reg_idx] <= mult_valid_reg_in_pipe[reg_idx];
//      end
//    end: VALID_REG_GEN
  
//    for (out_channel_idx = 0; out_channel_idx < pOUT_CHANNEL; out_channel_idx = out_channel_idx+1) begin: OUT_CHANNEL_GEN
//      logic signed [pIN_CHANNEL-1:0][pWINDOW_SIZE-1:0][2*pDATA_WIDTH-1:0] mult_reg_out;

//      for (in_channel_idx = 0; in_channel_idx < pIN_CHANNEL; in_channel_idx = in_channel_idx+1) begin: IN_CHANNEL_GEN
//        for (reg_idx = 0; reg_idx < pWINDOW_SIZE; reg_idx = reg_idx+1) begin: KERNEL_GEN
//          mult_dsp #(
//             .pDATA_WIDTH ( pDATA_WIDTH )
//          ) u_mult (
//             .clk ( clk                                                                         )
//            ,.rst ( rst                                                                         )
//            ,.a   ( data_in[in_channel_idx*pWINDOW_WIDTH+reg_idx*pDATA_WIDTH +: pDATA_WIDTH]    )
//            ,.b   ( kernel_in[out_channel_idx*pWINDOW_WIDTH+reg_idx*pDATA_WIDTH +: pDATA_WIDTH] )
//            ,.p   ( mult_reg_out[in_channel_idx][reg_idx]                                       )
//          );
//        end: KERNEL_GEN
        
//        adder_tree #(
//           .pDATA_WIDTH ( 2*pDATA_WIDTH )
//          ,.pINPUT_NUM  ( pWINDOW_SIZE  )
//        ) u_adder_tree_kernel (
//           .clk       ( clk                                                       )
//          ,.rst       ( rst                                                       )
//          ,.valid_in  ( mult_valid_reg_pipe_r[2]                                  )
//          ,.data_in   ( mult_reg_out[in_channel_idx]                              )
//          ,.data_out  ( data_out[2*pDATA_WIDTH*out_channel_idx +: 2*pDATA_WIDTH]  )
//          ,.valid_out ( valid_out                                                 )
//        );
//      end: IN_CHANNEL_GEN
//    end: OUT_CHANNEL_GEN
//  endgenerate
  
endmodule