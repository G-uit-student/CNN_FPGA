module dual_mult_dsp (
   input  logic                 clk
  ,input  logic                 rst
  ,input  logic signed  [7:0]   a
  ,input  logic signed  [7:0]   b
  ,input  logic signed  [7:0]   c
  ,output logic signed  [15:0]  ac
  ,output logic signed  [15:0]  bc
);

  logic signed [23:0] dsp_a;
  logic signed [24:0] dsp_d;
  logic signed [7:0] dsp_b;
  logic signed [32:0] dsp_p;
  
  assign dsp_a = {a, {16{1'b0}}};
  assign dsp_d = {{17{b[7]}}, b};
  assign dsp_b = c;
    
  dual_mult_dsp_ip u_dsp_ip (
     .CLK   ( clk   )
    ,.SCLR  ( rst   )
    ,.A     ( dsp_a )
    ,.D     ( dsp_d )
    ,.B     ( dsp_b )
    ,.P     ( dsp_p )
  );
  
  always_ff @(posedge clk) begin
    if (rst) begin
      ac <= 'b0;
      bc <= 'b0;
    end else begin
      ac <= dsp_p[31:16] + dsp_p[15];
      bc <= dsp_p[15:0];
    end
  end
    
endmodule
