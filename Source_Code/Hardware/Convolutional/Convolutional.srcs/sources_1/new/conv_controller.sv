module conv_controller #(
   parameter  pINPUT_WIDTH  = 640
  ,parameter  pINPUT_HEIGHT = 480
  ,parameter  pPADDING      = 1
  ,parameter  pSTRIDE       = 1
)(
   input  logic                               clk
  ,(* direct_reset = "true" *)  input  logic  rst
  ,(* direct_enable = "true" *) input  logic  en
  ,output logic                               is_padding
  ,output logic                               pe_en
  ,output logic                               done
);
  
  // internal counter
  (* direct_enable = "true" *) logic row_en;
  logic [$clog2(pINPUT_WIDTH+2*pPADDING)-1:0] col_count_r;
  logic [$clog2(pINPUT_HEIGHT+2*pPADDING)-1:0] row_count_r;
  logic col_stride_r [pSTRIDE-1:0];
  logic row_stride_r [pSTRIDE-1:0];
    
  // state machine
  localparam pSTATE_WIDTH = 2;
  localparam pSTATE_IDLE        = 2'b00;
  localparam pSTATE_COMPUTATION = 2'b01;
  localparam pSTATE_PADDING     = 2'b11;
  localparam pSTATE_FINISH      = 2'b10;
 
  logic [pSTATE_WIDTH-1:0] next_state;
  logic [pSTATE_WIDTH-1:0] curr_state_r;
  
  logic [$clog2(pINPUT_WIDTH)-1:0] pe_count_r; 
  logic computation;
  
  // column counter
  always_ff @(posedge clk) begin
    if (rst) begin
      col_count_r <= 'b0;
    end else begin
      if (en || is_padding) begin
        if (col_count_r == pINPUT_WIDTH+2*pPADDING-1)
          col_count_r <= 'b0;
        else
          col_count_r <= col_count_r + 1'b1;   
      end else begin
        col_count_r <= col_count_r;
      end
    end 
  end
  
  // row counter
  assign row_en = col_count_r == pINPUT_WIDTH+2*pPADDING-1;
  always_ff @(posedge clk) begin
    if (rst) begin 
      row_count_r <= 'b0;
    end else begin
      if (row_en) begin
        if (row_count_r == pINPUT_HEIGHT+2*pPADDING-1)
          row_count_r <= 'b0;
        else
          row_count_r <= row_count_r + 1'b1;
      end else begin
        row_count_r <= row_count_r;
      end
    end       
  end
  
  // pe counter
  always_ff @(posedge clk) begin
    if (rst)
      pe_count_r <= 'b0;
    else
      if (curr_state_r == pSTATE_IDLE || curr_state_r == pSTATE_FINISH)
        pe_count_r <= 'b0;
      else if (en || is_padding)
        pe_count_r <= pe_count_r + 1'b1;
      else
        pe_count_r <= pe_count_r;
  end
  
  // next state 
  always_comb begin
    case (curr_state_r)
      pSTATE_IDLE         : next_state = (col_count_r == 2 && row_count_r == 2) ? pSTATE_COMPUTATION : pSTATE_IDLE;
      pSTATE_COMPUTATION  : next_state = (pe_count_r == pINPUT_WIDTH+pPADDING*2-3) ? pSTATE_PADDING : pSTATE_COMPUTATION;
      pSTATE_PADDING      : next_state = pSTATE_FINISH;
      pSTATE_FINISH       : next_state = (row_count_r == 0) ? pSTATE_IDLE : pSTATE_COMPUTATION;
    endcase
  end
  
  // current state
  always_ff @(posedge clk) begin
    if (rst)
      curr_state_r <= pSTATE_IDLE;
    else
      curr_state_r <= next_state;
  end
  
  assign computation = curr_state_r == pSTATE_COMPUTATION ? 1'b1 : 1'b0;
  
  // stride

  
  assign is_padding = (col_count_r < pPADDING) || (col_count_r > pINPUT_WIDTH+pPADDING-1) ||
                      (row_count_r < pPADDING) || (row_count_r > pINPUT_WIDTH+pPADDING-1);
  assign pe_en = computation;
  assign done = (col_count_r  == pINPUT_WIDTH+pPADDING*2-1) && (row_count_r == pINPUT_HEIGHT+pPADDING*2-1);
      
endmodule
