  module sigmoid #(
    parameter DATA_WIDTH = 32,
    parameter FRAC_BITS = 16
)(
    input                              rst_n,
    input                              clk,
  	input							   i_valid,
 	input  signed [DATA_WIDTH-1:0] i_data,
    output reg 						   o_valid,
  	output reg signed [DATA_WIDTH-1:0] o_data
    
);
    
    localparam INT_BITS = DATA_WIDTH - FRAC_BITS;

    localparam signed [DATA_WIDTH-1:0] NUM_5     = {{INT_BITS-3{1'b0}}, 3'b101,           {FRAC_BITS{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_2P37  = {{INT_BITS-2{1'b0}}, 2'b10,    3'b011, {FRAC_BITS-3{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_1     = {{INT_BITS-1{1'b0}}, 1'b1,             {FRAC_BITS{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_0P84  = {{INT_BITS{1'b0}},   5'b11011,         {FRAC_BITS-5{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_0P62  = {{INT_BITS{1'b0}},   3'b101,           {FRAC_BITS-3{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_0P5   = {{INT_BITS{1'b0}},   1'b1,             {FRAC_BITS-1{1'b0}}};
    localparam signed [DATA_WIDTH-1:0] NUM_0     = {DATA_WIDTH{1'b0}};
    

//input
  reg signed [DATA_WIDTH-1:0] data;
  always @(posedge rst_n, posedge clk) begin
      if (rst_n==1'b0)
            o_valid <= 1'b0;
      else if (i_valid == 1'b1)
          	o_valid <= 1'b1;
      		data <= i_data;
    end
  
        
//Compare and choose value
    // abs_data = |i_data|
  wire signed [DATA_WIDTH-1:0] abs_data = (data[DATA_WIDTH-1])? {1'b0, ~data[DATA_WIDTH-2:0]} : data;
    // shifter abs_data
    wire signed [DATA_WIDTH-1:0] left_5 = {5'b0, abs_data[DATA_WIDTH-1:5]};
    wire signed [DATA_WIDTH-1:0] left_3 = {3'b0, abs_data[DATA_WIDTH-1:3]};
    wire signed [DATA_WIDTH-1:0] left_2 = {2'b0, abs_data[DATA_WIDTH-1:2]};
    //choose constant and value after shift
    wire signed [DATA_WIDTH-1:0] constant   = (abs_data >= NUM_5)? NUM_1 : (abs_data >= NUM_2P37)? NUM_0P84 : (abs_data >= NUM_1)? NUM_0P62 : NUM_0P5;
    wire signed [DATA_WIDTH-1:0] shift_data = (abs_data >= NUM_5)? NUM_0 : (abs_data >= NUM_2P37)? left_5 : (abs_data >= NUM_1)? left_3 : left_2;

// Add/Sub 
    wire signed [DATA_WIDTH-1:0] positive_sigmoid = shift_data + constant;
    wire signed [DATA_WIDTH-1:0] negative_sigmoid = NUM_1 - positive_sigmoid;

// output
  //assign o_data = (!out_en)? {DATA_WIDTH{1'bz}}: (data[DATA_WIDTH-1])? negative_sigmoid : positive_sigmoid;
  wire signed [DATA_WIDTH-1:0] w_o_data = (data[DATA_WIDTH-1])? negative_sigmoid : positive_sigmoid;
//  assign w_o_data = (data[DATA_WIDTH-1])? negative_sigmoid : positive_sigmoid;
  always @(posedge clk)
    if (o_valid == 1'b1)
    	o_data <= w_o_data;
endmodule

