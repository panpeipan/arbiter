module ahb_master_if_fifo #(
    parameter ADDR_WIDTH = 32 
)( 
    input  wire                   i_clk ,
    input  wire                   i_rstn,
    input  wire                   i_wfifo_en               ,
    input  wire                   i_wfifo_write            ,
    input  wire [2: 0]            i_wfifo_user_burst_type  , 
    input  wire [ADDR_WIDTH-1: 0] i_wfifo_user_addr        ,
    input  wire                   i_rfifo_en               ,
    output reg                    o_rfifo_write            ,
    output reg  [2: 0]            o_rfifo_user_burst_type  , 
    output reg  [ADDR_WIDTH-1: 0] o_rfifo_user_addr        ,
    output reg                    o_fifo_full              ,
    output reg                    o_fifo_empty            
);
//----------------------------------------------------//
// reg
//----------------------------------------------------//
reg    [3:0]    r_user_write                   ;
reg    [3:0]    r_user_burst  [2:0]            ;
reg    [3:0]    r_user_addr   [ADDR_WIDTH-1:0] ;
reg    [2:0]    r_write_tp                     ;
reg    [2:0]    r_read_tp                      ;
//----------------------------------------------------//
// wire
//----------------------------------------------------//

    
//----------------------------------------------------//
// main_code
//----------------------------------------------------//


//----------------------------------------------------//
// assign
//----------------------------------------------------//

endmodule 
