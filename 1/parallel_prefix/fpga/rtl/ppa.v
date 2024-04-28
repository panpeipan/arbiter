module ppa 
#(
    parameter arbiter_width = 8 
)
(
    input  wire [arbiter_width-1: 0] i_req  ,
    input  wire [arbiter_width-1: 0] i_prior,
    
    output wire [arbiter_width-1: 0] o_grant,
    output wire                      o_ag   
);
wire [arbiter_width-1:0] x ;
//----------------------------------------------------//
// assign
//----------------------------------------------------// 
reg  [2:0] i ;
reg [arbiter_width-1:0] l1_a;
reg [arbiter_width-1:0] l1_b;
reg [arbiter_width-1:0] l2_a;
reg [arbiter_width-1:0] l2_b;
reg [arbiter_width-1:0] l3_a;
reg [arbiter_width-1:0] l3_b;
always @(i_req , i_prior) begin
    for(i = arbiter_width - 1 ; i > 1 ; i = i - 1 )begin 
        pp_t ( i_prior[i]   , ~i_req[i-1],
               i_prior[i-1] , ~i_req[i-2], 
               l1_a[i]      , l1_b[i]    );
    end  
        pp_t ( i_prior[1]   , ~i_req[0],
               i_prior[0]   , ~i_req[7], 
               l1_a[1]      , l1_b[1]    );
        pp_t ( i_prior[0]   , ~i_req[7],
               i_prior[7]   , ~i_req[6], 
               l1_a[0]      , l1_b[0]    );
end 

always @(l1_a , l1_b) begin
    for(i = arbiter_width-1 ; i>1 ; i=i-1)begin 
        pp_t ( l1_a [i]  ,  l1_b[i]  ,
               l1_a [i-2],  l1_b[i-2],
               l2_a [i]  ,  l2_b[i] );
    end 
        pp_t ( l1_a[1] , l1_b[1],
               l1_a[7] , l1_b[7], 
               l2_a[1] , l2_b[1]    );
        pp_t ( l1_a[0] , l1_b[0],
               l1_a[6] , l1_b[6], 
               l2_a[0] , l2_b[0]    );
end 

always @(l2_a , l2_b) begin
    for(i = arbiter_width-1 ; i>3 ; i=i-1)begin 
        pp_t ( l2_a [i]  ,  l2_b[i]  ,
               l2_a [i-4],  l2_b[i-4],
               l3_a [i]  ,  l3_b[i] );
        pp_t ( l2_a [i-4],  l2_b[i-4],
               l2_a [i]  ,  l2_b[i]  ,
               l3_a [i-4],  l3_b[i-4]);
    end
end 
assign x       = l3_a      ;
assign o_grant = i_req & x ;
assign o_ag    = ~l3_b      ;

task pp_t 
(
    input   i_a ,  // p i
    input   i_b ,  // r i-1
    input   i_c ,  // p i-1
    input   i_d ,  // r i-2
    output  o_a ,
    output  o_b 
); 
begin 
     o_a = i_a || ( i_b & i_c ) ;
     o_b = i_b & i_d ;
end 
endtask  
endmodule  
