`timescale 1ns/1ps

module tb_pe();
  localparam pDATA_WIDTH  = 8;
  localparam pKERNEL_SIZE = 3;
  localparam pIN_CHANNEL  = 1;
  localparam pOUT_CHANNEL = 2;
  localparam pWINDOW_SIZE  = pKERNEL_SIZE * pKERNEL_SIZE;
  localparam pWINDOW_WIDTH = pDATA_WIDTH * pWINDOW_SIZE;
  
  logic clk;
  logic rst;
  logic valid_in;
  logic valid_out;
  logic [pWINDOW_WIDTH*pIN_CHANNEL*pOUT_CHANNEL-1:0] kernel_in;
  logic [pWINDOW_WIDTH*pIN_CHANNEL-1:0] data_in;
  logic [2*pDATA_WIDTH*pOUT_CHANNEL-1:0] data_out;
  
  initial begin
    clk = 'b0;
    rst = 'b1;
    
    #150;
    rst = 'b0;
    valid_in = 'b1;
    
    kernel_in = 144'b001111101010000000001000101101000100110110011011011011101010100000011000111111010011011010011010010100100010000011000011110000100010110100111010;
    data_in = 72'b101001101111010000010110110110101000100010011100110111001001100011110011;
    
    #200 $finish;
  end
  
  always @(clk) #2.5 clk <= !clk;
  
  pe_dual_dsp #(
     .pDATA_WIDTH   ( pDATA_WIDTH   )
    ,.pKERNEL_SIZE  ( pKERNEL_SIZE  )
    ,.pIN_CHANNEL   ( pIN_CHANNEL   )
    ,.pOUT_CHANNEL  ( pOUT_CHANNEL  )
  ) u_pe_dual_dsp (
     .clk       ( clk       )
    ,.rst       ( rst       )
    ,.valid_in  ( valid_in  )
    ,.kernel_in ( kernel_in )
    ,.data_in   ( data_in   )
    ,.data_out  ( data_out  )
    ,.valid_out ( valid_out )
  );
  
endmodule
