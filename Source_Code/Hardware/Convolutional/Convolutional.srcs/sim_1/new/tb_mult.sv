`timescale 1ns/1ps

module tb_mult();

  logic clk;
  logic rst;
  logic signed [7:0] a;
  logic signed [7:0] b;
  logic signed [7:0] c;
  logic signed [15:0] ac;
  logic signed [15:0] bc;
  
  initial begin
    clk = 'b0;
    
    #200;
    rst = 'b0;
    a = -98;
    b = -128;
    c = 45;
    
    #160;
    a = -12;
    b = -23;
    c = 123;
    #200 $finish;
  end
  
  always @(clk) #5 clk <= !clk;
  
  dual_mult_dsp u_dual_mult_dsp (
     .clk ( clk )
    ,.rst ( rst )
    ,.a   ( a   )
    ,.b   ( b   )
    ,.c   ( c   )
    ,.ac  ( ac  )
    ,.bc  ( bc  )
  );
  
endmodule
