module conv #(
   parameter  pINPUT_WIDTH  = 28
  ,parameter  pINPUT_HEIGHT = 28
  ,parameter  pDATA_WIDTH   = 8
  
  ,parameter  pKERNEL_SIZE  = 3
  ,parameter  pPADDING      = 1
  ,parameter  pSTRIDE       = 1
   
  ,parameter  pIN_CHANNEL   = 1
  ,parameter  pOUT_CHANNEL  = 32
  
  ,localparam pWINDOW_SIZE  = pKERNEL_SIZE * pKERNEL_SIZE
  ,localparam pWINDOW_WIDTH = pDATA_WIDTH * pWINDOW_SIZE
  
  // kernel ram
  ,parameter  pWEIGHT_WIDTH = 32
  ,localparam pWEIGHT_ADDR  = $clog2(pIN_CHANNEL*pOUT_CHANNEL*pWINDOW_SIZE*pDATA_WIDTH/pWEIGHT_WIDTH)
)(
   input  logic                                   clk
  ,input  logic                                   rst
  ,input  logic                                   en
  ,input  logic                                   load_weight
  ,input  logic [pWEIGHT_WIDTH-1:0]               weight_in
  ,input  logic [pWEIGHT_ADDR-1:0]                weight_addr
  ,input  logic [pDATA_WIDTH-1:0]                 padding
  ,input  logic [pDATA_WIDTH*pIN_CHANNEL-1:0]     data_in
  ,output logic [4*pDATA_WIDTH*pOUT_CHANNEL-1:0]  data_out
  ,output logic                                   rd_en
  ,output logic                                   valid
  ,output logic                                   done
);
  
  logic [pDATA_WIDTH*pIN_CHANNEL-1:0] buffer_in;
  logic [pDATA_WIDTH*pIN_CHANNEL*pWINDOW_SIZE-1:0] buffer_out;
  logic is_padding;
  logic buffer_en;
  logic pe_en;
  
  assign buffer_en = en || is_padding;
  assign buffer_in = is_padding ? {pIN_CHANNEL{padding}} : data_in;
  assign rd_en = en && !is_padding;
  
  conv_controller #(
     .pINPUT_WIDTH  ( pINPUT_WIDTH  )
    ,.pINPUT_HEIGHT ( pINPUT_HEIGHT )
    ,.pPADDING      ( pPADDING      )
    ,.pSTRIDE       ( pSTRIDE       )
  ) u_controller (
     .clk         ( clk         )
    ,.rst         ( rst         )
    ,.en          ( en          )
    ,.is_padding  ( is_padding  )
    ,.pe_en       ( pe_en       )
    ,.done        ( done        )
  );
      
  conv_buffer #(
     .pINPUT_WIDTH  ( pINPUT_WIDTH            )
    ,.pDATA_WIDTH   ( pDATA_WIDTH*pIN_CHANNEL )
    ,.pKERNEL_SIZE  ( pKERNEL_SIZE            )
    ,.pPADDING      ( pPADDING                )
  ) u_buffer (
     .clk       ( clk         )
    ,.rst       ( rst         )
    ,.en        ( buffer_en   )
    ,.data_in   ( buffer_in   )
    ,.data_out  ( buffer_out  )
  );

  pe_dual_out_dsp #(
     .pDATA_WIDTH   ( pDATA_WIDTH   )
    ,.pKERNEL_SIZE  ( pKERNEL_SIZE  )
    ,.pIN_CHANNEL   ( pIN_CHANNEL   )
    ,.pOUT_CHANNEL  ( pOUT_CHANNEL  )
  ) u_pe_dual_out (
     .clk         ( clk         )
    ,.rst         ( rst         )
    ,.valid_in    ( pe_en       )
    ,.load_weight ( load_weight )
    ,.weight_in   ( weight_in   )
    ,.weight_addr ( weight_addr )
    ,.data_in     ( buffer_out  )
    ,.data_out    ( data_out    )
    ,.valid_out   ( valid       )
  );   
        
endmodule
