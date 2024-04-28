//pp  ( .i_a      (    ) , .i_b      (    ) ,
     // .i_c      (    ) , .i_d      (    ) ,
     // .o_a      (    ) , .o_b      (    )  ); 
module pp_rtl 
(
    input  wire i_a ,
    input  wire i_b ,
    input  wire i_c ,
    input  wire i_d ,
    output wire o_a ,
    output wire o_b 
); 
assign o_a = i_a | ( i_b & i_c ) ;
assign o_b = i_b & i_d ;
endmodule  
