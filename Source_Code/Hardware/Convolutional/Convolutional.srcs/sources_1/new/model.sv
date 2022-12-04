module model #(
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
  ,input  logic [pDATA_WIDTH-1:0]                 padding
  ,input  logic                                   load_weight
  ,input  logic [pWEIGHT_WIDTH-1:0]               weight_in
  ,input  logic [pWEIGHT_ADDR-1:0]                weight_addr
  ,input  logic [pDATA_WIDTH*pIN_CHANNEL-1:0]     data_in
  ,output logic [4*pDATA_WIDTH*pOUT_CHANNEL-1:0]  data_out
  ,output logic                                   valid
  ,output logic                                   done
);

  logic [pDATA_WIDTH*pIN_CHANNEL-1:0] fifo_out;
  logic empty;
  logic rd_en;

  fifo #(
     .pDATA_WIDTH ( pDATA_WIDTH*pIN_CHANNEL )
    ,.pDEPTH      ( 1024                    )
  ) u_fifo (
     .clk     ( clk       )
    ,.rst     ( rst       )
    ,.wr_en   ( en        )
    ,.rd_en   ( rd_en     )
    ,.wr_data ( data_in   )
    ,.rd_data ( fifo_out  )
    ,.empty   ( empty     )
  );
  
  conv #(
     .pINPUT_WIDTH  ( pINPUT_WIDTH  )
    ,.pINPUT_HEIGHT ( pINPUT_HEIGHT )
    ,.pDATA_WIDTH   ( pDATA_WIDTH   )
    ,.pKERNEL_SIZE  ( pKERNEL_SIZE  )
    ,.pPADDING      ( pPADDING      )
    ,.pSTRIDE       ( pSTRIDE       )
    ,.pIN_CHANNEL   ( pIN_CHANNEL   )
    ,.pOUT_CHANNEL  ( pOUT_CHANNEL  )
  ) u_conv (
     .clk         ( clk         )
    ,.rst         ( rst         )
    ,.en          ( !empty      )
    ,.padding     ( padding     )
    ,.load_weight ( load_weight )
    ,.weight_in   ( weight_in   )
    ,.weight_addr ( weight_addr )
    ,.data_in     ( fifo_out    )
    ,.data_out    ( data_out    )
    ,.rd_en       ( rd_en       )
    ,.valid       ( valid       )
    ,.done        ( done        )
  );
  
endmodule
