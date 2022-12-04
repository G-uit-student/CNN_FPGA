module adder_tree #(
   parameter  pDATA_WIDTH     = 8
  ,parameter  pINPUT_NUM      = 12
  
  ,localparam pTRUE_INPUT     = pINPUT_NUM%3 == 0 ? pINPUT_NUM : pINPUT_NUM + (3 - pINPUT_NUM%3)
  ,localparam pPIPE_STAGE_NUM = cal_stage_num(pTRUE_INPUT)
)( 
   input  bit                                 clk
  ,(* direct_reset = "true" *)  input  logic  rst
  ,input  logic                               valid_in
  ,input  logic [pDATA_WIDTH*pINPUT_NUM-1:0]  data_in
  ,output logic [2*pDATA_WIDTH-1:0]           data_out
  ,output logic                               valid_out
);
   
  logic signed [pDATA_WIDTH+pPIPE_STAGE_NUM-1:0] adder_out_pipe [pPIPE_STAGE_NUM-1:0][pINPUT_NUM-1:0];
  logic [pPIPE_STAGE_NUM-1:0] valid_pipe_r;

  genvar reg_idx;
  genvar stage_idx;
  
  generate
    // valid reg
    for (reg_idx = 0; reg_idx < pPIPE_STAGE_NUM; reg_idx = reg_idx+1) begin: VALID_REG_GEN
      logic valid_pipe_in;
      
      if (reg_idx == 0)
        assign valid_pipe_in = valid_in;
      else
        assign valid_pipe_in = valid_pipe_r[reg_idx-1];
      
      always_ff @(posedge clk) begin
        if (rst)
          valid_pipe_r[reg_idx] <= 'b0;
        else
          valid_pipe_r[reg_idx] <= valid_pipe_in;
      end
    end: VALID_REG_GEN
  
    // adder stage
    for (stage_idx = 0; stage_idx < pPIPE_STAGE_NUM; stage_idx = stage_idx+1) begin: PIPE_STAGE_GEN
      localparam pCURR_REG_NUM = int'($ceil(real'(pTRUE_INPUT) / real'(3**(stage_idx+1))));
      localparam pPRE_REG_NUM = int'($ceil(real'(pTRUE_INPUT) / real'(3**stage_idx)));
      
      logic signed [pDATA_WIDTH+pPIPE_STAGE_NUM-1:0] adder_pipe_r [pCURR_REG_NUM-1:0];   
            
      // adder reg
      for (reg_idx = 0; reg_idx < pCURR_REG_NUM; reg_idx = reg_idx+1) begin: PIPE_REG_GEN
        logic signed [pDATA_WIDTH+pPIPE_STAGE_NUM-1:0] adder_in_pipe;
      
        if (stage_idx == 0) begin
          if (reg_idx*3+1 == pINPUT_NUM)
            assign adder_in_pipe = {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+1)*pDATA_WIDTH-1]}}, data_in[reg_idx*3*pDATA_WIDTH +: pDATA_WIDTH]};
          else if (reg_idx*3+2 == pINPUT_NUM)
            assign adder_in_pipe = {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+1)*pDATA_WIDTH-1]}}, data_in[reg_idx*3*pDATA_WIDTH +: pDATA_WIDTH]}
                                 + {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+2)*pDATA_WIDTH-1]}}, data_in[(reg_idx*3+1)*pDATA_WIDTH +: pDATA_WIDTH]};
          else
            assign adder_in_pipe = {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+1)*pDATA_WIDTH-1]}}, data_in[reg_idx*3*pDATA_WIDTH +: pDATA_WIDTH]}
                                 + {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+2)*pDATA_WIDTH-1]}}, data_in[(reg_idx*3+1)*pDATA_WIDTH +: pDATA_WIDTH]}
                                 + {{pPIPE_STAGE_NUM{data_in[(reg_idx*3+3)*pDATA_WIDTH-1]}}, data_in[(reg_idx*3+2)*pDATA_WIDTH +: pDATA_WIDTH]};
        end else begin
          if (reg_idx*3+1 == pPRE_REG_NUM)
            assign adder_in_pipe = adder_out_pipe[stage_idx-1][reg_idx*3];
          else if (reg_idx*3+2 == pPRE_REG_NUM)
            assign adder_in_pipe = adder_out_pipe[stage_idx-1][reg_idx*3] + adder_out_pipe[stage_idx-1][reg_idx*3+1];
          else
            assign adder_in_pipe = adder_out_pipe[stage_idx-1][reg_idx*3] + adder_out_pipe[stage_idx-1][reg_idx*3+1] + 
                                                                          + adder_out_pipe[stage_idx-1][reg_idx*3+2];
        end
          
        always_ff @(posedge clk) begin
          if (rst)
            adder_pipe_r[reg_idx] <= 'b0;
          else
            adder_pipe_r[reg_idx] <= adder_in_pipe;
        end
                   
        assign adder_out_pipe[stage_idx][reg_idx] = adder_pipe_r[reg_idx];

      end: PIPE_REG_GEN
    end: PIPE_STAGE_GEN
  endgenerate

  assign valid_out = valid_pipe_r[pPIPE_STAGE_NUM-1];
  assign data_out = {{(2*pDATA_WIDTH-pPIPE_STAGE_NUM){adder_out_pipe[pPIPE_STAGE_NUM-1][0][pDATA_WIDTH+pPIPE_STAGE_NUM-1]}}, adder_out_pipe[pPIPE_STAGE_NUM-1][0]};
  
  function automatic int cal_stage_num (int input_num);
    int stage_num = 0;
    
    while (input_num != 1) begin
      input_num = $ceil(input_num/3);
      stage_num += 1;
    end
    
    return stage_num;
  endfunction

endmodule
