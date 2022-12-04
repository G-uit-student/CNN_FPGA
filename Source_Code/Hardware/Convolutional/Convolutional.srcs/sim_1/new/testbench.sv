`timescale 1ns/1ps

module testbench();
  localparam pINPUT_WIDTH = 28;
  localparam pINPUT_HEIGHT = 28;
  localparam pDATA_WIDTH  = 8;
  
  localparam pKERNEL_SIZE = 3;
  localparam pPADDING = 1;
  localparam pSTRIDE = 1;
  
  localparam pIN_CHANNEL  = 1;
  localparam pOUT_CHANNEL = 32;
  
  localparam pWINDOW_SIZE  = pKERNEL_SIZE * pKERNEL_SIZE;
  localparam pWINDOW_WIDTH = pDATA_WIDTH * pWINDOW_SIZE;
  
  localparam pWEIGHT_WIDTH = 32;
  localparam pWEIGHT_NUM = pIN_CHANNEL*pOUT_CHANNEL*pWINDOW_SIZE*pDATA_WIDTH/pWEIGHT_WIDTH;
  localparam pWEIGHT_ADDR = $clog2(pWEIGHT_NUM);
  
  localparam pPERIOD = 10;
    
  logic clk;
  logic rst;
  logic en;
  logic valid;
  logic done;
  logic load_weight;
  logic [pWEIGHT_WIDTH-1:0] weight_in;
  logic [pWEIGHT_ADDR-1:0] weight_addr;
  logic [pDATA_WIDTH*pIN_CHANNEL-1:0] data_in;
  logic [4*pDATA_WIDTH*pOUT_CHANNEL-1:0] data_out;
  
  logic [pWEIGHT_WIDTH-1:0] weights [0:pWEIGHT_NUM-1];
  logic [pDATA_WIDTH*pIN_CHANNEL-1:0] image [0:pINPUT_WIDTH*pINPUT_HEIGHT];
  
  integer output_file [pOUT_CHANNEL];
  string output_path = "E:\\Smart_Camera_FPGA\\Source_Code\\Results\\out_";
  string idx;
  
  always @(clk) #(pPERIOD/2) clk <= !clk;
  
  initial begin
    $readmemh("E:\\Smart_Camera_FPGA\\Source_Code\\Python\\image.txt", image);
    $readmemh("E:\\Smart_Camera_FPGA\\Source_Code\\Python\\weights.txt", weights);
    
    for (integer i=0; i < pOUT_CHANNEL; i = i+1) begin
      idx.itoa(i);
      output_file[i] = $fopen({output_path, idx, ".txt"}, "w");
    end

    clk = 1'b0;
    rst = 1'b1;
    en = 1'b0;
    load_weight = 1'b0;
    weight_in = 'b0;
    weight_addr = 'b0;
    data_in = 'b0;
    
    #pPERIOD;
    rst = 1'b0;
    load_weight = 1'b1;
    
    for (int i = 0; i < pWEIGHT_NUM; i = i+1) begin
      weight_in = weights[i];
      weight_addr = i;
      #pPERIOD;
    end
    
    #pPERIOD;
    load_weight = 'b10;
    en = 1'b1;
            
    for (integer i=0; i<pINPUT_WIDTH*pINPUT_HEIGHT; i=i+1) begin
      data_in = image[i];
      #pPERIOD;
    end
    
    en = 1'b0;
    
    @(posedge done);
    @(negedge valid);

    for (int i=0; i < pOUT_CHANNEL; i = i+1) begin
      $fclose(output_file[i]);
    end
    $finish;
  end
   
  always @(posedge clk) begin
    if (valid) begin
      for (int i=0; i < pOUT_CHANNEL; i = i+1) begin
        $fwrite(output_file[i], "%h", data_out[4*pDATA_WIDTH*i +: 4*pDATA_WIDTH]);
        $fwrite(output_file[i], "\n");
      end
    end
  end
  
  model #(
     .pINPUT_WIDTH  ( pINPUT_WIDTH  )
    ,.pINPUT_HEIGHT ( pINPUT_HEIGHT )
    ,.pDATA_WIDTH   ( pDATA_WIDTH   )
    ,.pKERNEL_SIZE  ( pKERNEL_SIZE  )
    ,.pPADDING      ( pPADDING      )
    ,.pSTRIDE       ( pSTRIDE       )
    ,.pIN_CHANNEL   ( pIN_CHANNEL   )
    ,.pOUT_CHANNEL  ( pOUT_CHANNEL  )
  ) u_model (
     .clk         ( clk         )
    ,.rst         ( rst         )
    ,.en          ( en          )
    ,.padding     ( 'b0         )
    ,.load_weight ( load_weight )
    ,.weight_in   ( weight_in   )
    ,.weight_addr ( weight_addr )
    ,.data_in     ( data_in     )
    ,.data_out    ( data_out    )
    ,.valid       ( valid       )
    ,.done        ( done        )
  );
  
endmodule
