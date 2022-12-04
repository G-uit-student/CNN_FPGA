//module bram_kernel_single_port #(
//   parameter  pINPUT_WIDTH  = 32
//  ,parameter  pDATA_WIDTH   = 8
//  ,parameter  pKERNEL_SIZE  = 9
//  ,parameter  pKERNEL_NUM   = 32
//  ,localparam pADDR_WIDTH   = $clog2(pKERNEL_NUM)
//)(
//   input  logic                               clk
//  ,input  logic                               rst
//  ,input  logic                               wr_en
//  ,input  logic [pADDR_WIDTH-1:0]             wr_addr
//  ,input  logic [pADDR_WIDTH-1:0]             wr_addr
//  ,input  logic [pADDR_WIDTH-1:0]             rd_addr
//  ,input  logic [pDATA_WIDTH-1:0]             kernel_in
//  ,output logic [pOUT_WIDTH*pKERNEL_SIZE-1:0] kernel_out
//);

//  (* ram_style = bram *) reg [pDATA_WIDTH-1:0] kernel_r [pDEPTH-1:0];
  
//  genvar kernel_idx;
//  genvar reg_idx;
  
//  generate
////    for (reg_idx
//    always_ff @(posedge clk) begin      
//    end
//  endgenerate

//endmodule
