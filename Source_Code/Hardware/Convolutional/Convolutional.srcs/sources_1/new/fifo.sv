module fifo #(
   parameter  pDATA_WIDTH = 32
  ,parameter  pDEPTH      = 1024
  ,localparam pADDR_WIDTH = $clog2(pDEPTH)
)(
   input  logic                               clk
  ,(* direct_reset = "true" *)  input  logic  rst
  ,input  logic                               wr_en
  ,input  logic                               rd_en
  ,input  logic [pDATA_WIDTH-1:0]             wr_data
  ,output logic [pDATA_WIDTH-1:0]             rd_data
  ,output logic                               full
  ,output logic                               empty
);

  logic [pDEPTH-1:0][pDATA_WIDTH-1:0] mem_r;
  logic [pADDR_WIDTH-1:0] counter_r;
  logic [pADDR_WIDTH-1:0] wr_ptr_r;
  logic [pADDR_WIDTH-1:0] rd_ptr_r;
  
  // write data
  always_ff @(posedge clk) begin
    if (rst)
      mem_r <= 'b0;
    else
      if (wr_en && !full)
        mem_r[wr_ptr_r] <= wr_data;
      else
        mem_r[wr_ptr_r] <= mem_r[wr_ptr_r];
  end
  
  // counter used for empty and full signal
  always_ff @(posedge clk) begin
    if (rst)
      counter_r <= 'b0;
    else
      if ((wr_en && !full) && (rd_en && !empty))
        counter_r <= counter_r;
      else if (wr_en && !full)
        counter_r <= counter_r + 1'b1;
      else if (rd_en && !empty)
        counter_r <= counter_r -  1'b1;
      else
        counter_r <= counter_r;
  end
  
  // read write pointer use for write and read data
  always_ff @(posedge clk) begin
    if (rst) begin
      wr_ptr_r <= 'b0;
      rd_ptr_r <= 'b0;
    end else begin
      if (wr_en && !full)
        wr_ptr_r <= wr_ptr_r + 1'b1;
      else
        wr_ptr_r <= wr_ptr_r;
         
      if (rd_en && !empty)
        rd_ptr_r <= rd_ptr_r + 1'b1;
      else
        rd_ptr_r <= rd_ptr_r;
    end
  end
  
  assign full = counter_r == pDEPTH;
  assign empty = counter_r == 0;
  assign rd_data = mem_r[rd_ptr_r];

endmodule
