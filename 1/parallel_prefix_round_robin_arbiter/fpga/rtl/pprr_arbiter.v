module pprr_arbiter  
#(
    parameter arbiter_width = 8 
)
(
    input  wire                      i_clk  , 
    input  wire                      i_rstn ,
    input  wire [arbiter_width-1: 0] i_req  ,
    // input  wire [arbiter_width-1: 0] i_prior,
    output wire [arbiter_width-1: 0] o_grant,
    output wire                      o_ag   
);
wire [arbiter_width-1:0] x ;
//----------------------------------------------------//
// assign
//----------------------------------------------------//  
reg   [arbiter_width-1:0] i_prior ;
wire  [arbiter_width-1:0] l1_a;
wire  [arbiter_width-1:0] l1_b;
wire  [arbiter_width-1:0] l2_a;
wire  [arbiter_width-1:0] l2_b;
wire  [arbiter_width-1:0] l3_a;
wire  [arbiter_width-1:0] l3_b; 
//layer 1 
pp_rtl u71( .i_a      (i_prior[7]   ) , .i_b      (~i_req[6]   ) ,
            .i_c      (i_prior[6]   ) , .i_d      (~i_req[5]   ) ,
            .o_a      (l1_a   [7]   ) , .o_b      (l1_b  [7]  )  ); 
pp_rtl u61( .i_a      (i_prior[6]   ) , .i_b      (~i_req[5]   ) ,
            .i_c      (i_prior[5]   ) , .i_d      (~i_req[4]   ) ,
            .o_a      (l1_a   [6]   ) , .o_b      (l1_b  [6]  )  ); 
pp_rtl u51( .i_a      (i_prior[5]   ) , .i_b      (~i_req[4]   ) ,
            .i_c      (i_prior[4]   ) , .i_d      (~i_req[3]   ) ,
            .o_a      (l1_a   [5]   ) , .o_b      (l1_b  [5]  )  ); 
pp_rtl u41( .i_a      (i_prior[4]   ) , .i_b      (~i_req[3]   ) ,
            .i_c      (i_prior[3]   ) , .i_d      (~i_req[2]   ) ,
            .o_a      (l1_a   [4]   ) , .o_b      (l1_b  [4]  )  ); 
pp_rtl u31( .i_a      (i_prior[3]   ) , .i_b      (~i_req[2]   ) ,
            .i_c      (i_prior[2]   ) , .i_d      (~i_req[1]   ) ,
            .o_a      (l1_a   [3]   ) , .o_b      (l1_b  [3]  )  ); 
pp_rtl u21( .i_a      (i_prior[2]   ) , .i_b      (~i_req[1]   ) ,
            .i_c      (i_prior[1]   ) , .i_d      (~i_req[0]   ) ,
            .o_a      (l1_a   [2]   ) , .o_b      (l1_b  [2]  )  ); 
pp_rtl u11( .i_a      (i_prior[1]   ) , .i_b      (~i_req[0]   ) ,
            .i_c      (i_prior[0]   ) , .i_d      (~i_req[7]   ) ,
            .o_a      (l1_a   [1]   ) , .o_b      (l1_b  [1]  )  ); 
pp_rtl u01( .i_a      (i_prior[0]   ) , .i_b      (~i_req[7]   ) ,
            .i_c      (i_prior[7]   ) , .i_d      (~i_req[6]   ) ,
            .o_a      (l1_a   [0]   ) , .o_b      (l1_b  [0]  )  );  
//layer 2 
pp_rtl u72( .i_a      (l1_a[7]   ) , .i_b      (l1_b[7]   ) ,
            .i_c      (l1_a[5]   ) , .i_d      (l1_b[5]   ) ,
            .o_a      (l2_a[7]   ) , .o_b      (l2_b[7]  )  ); 
pp_rtl u62( .i_a      (l1_a[6]   ) , .i_b      (l1_b[6]   ) ,
            .i_c      (l1_a[4]   ) , .i_d      (l1_b[4]   ) ,
            .o_a      (l2_a[6]   ) , .o_b      (l2_b[6]  )  ); 
pp_rtl u52( .i_a      (l1_a[5]   ) , .i_b      (l1_b[5]   ) ,
            .i_c      (l1_a[3]   ) , .i_d      (l1_b[3]   ) ,
            .o_a      (l2_a[5]   ) , .o_b      (l2_b[5]  )  ); 
pp_rtl u42( .i_a      (l1_a[4]   ) , .i_b      (l1_b[4]   ) ,
            .i_c      (l1_a[2]   ) , .i_d      (l1_b[2]   ) ,
            .o_a      (l2_a[4]   ) , .o_b      (l2_b[4]  )  ); 
pp_rtl u32( .i_a      (l1_a[3]   ) , .i_b      (l1_b[3]   ) ,
            .i_c      (l1_a[1]   ) , .i_d      (l1_b[1]   ) ,
            .o_a      (l2_a[3]   ) , .o_b      (l2_b[3]  )  ); 
pp_rtl u22( .i_a      (l1_a[2]   ) , .i_b      (l1_b[2]   ) ,
            .i_c      (l1_a[0]   ) , .i_d      (l1_b[0]   ) ,
            .o_a      (l2_a[2]   ) , .o_b      (l2_b[2]  )  ); 
pp_rtl u12( .i_a      (l1_a[1]   ) , .i_b      (l1_b[1]   ) ,
            .i_c      (l1_a[7]   ) , .i_d      (l1_b[7]   ) ,
            .o_a      (l2_a[1]   ) , .o_b      (l2_b[1]  )  ); 
pp_rtl u02( .i_a      (l1_a[0]   ) , .i_b      (l1_b[0]   ) ,
            .i_c      (l1_a[6]   ) , .i_d      (l1_b[6]   ) ,
            .o_a      (l2_a[0]   ) , .o_b      (l2_b[0]  )  );  
//layer 3 
pp_rtl u73( .i_a      (l2_a[7]   ) , .i_b      (l2_b[7]   ) ,
            .i_c      (l2_a[3]   ) , .i_d      (l2_b[3]   ) ,
            .o_a      (l3_a[7]   ) , .o_b      (l3_b[7]  )  ); 
pp_rtl u63( .i_a      (l2_a[6]   ) , .i_b      (l2_b[6]   ) ,
            .i_c      (l2_a[2]   ) , .i_d      (l2_b[2]   ) ,
            .o_a      (l3_a[6]   ) , .o_b      (l3_b[6]  )  ); 
pp_rtl u53( .i_a      (l2_a[5]   ) , .i_b      (l2_b[5]   ) ,
            .i_c      (l2_a[1]   ) , .i_d      (l2_b[1]   ) ,
            .o_a      (l3_a[5]   ) , .o_b      (l3_b[5]  )  ); 
pp_rtl u43( .i_a      (l2_a[4]   ) , .i_b      (l2_b[4]   ) ,
            .i_c      (l2_a[0]   ) , .i_d      (l2_b[0]   ) ,
            .o_a      (l3_a[4]   ) , .o_b      (l3_b[4]  )  ); 
pp_rtl u33( .i_a      (l2_a[3]   ) , .i_b      (l2_b[3]   ) ,
            .i_c      (l2_a[7]   ) , .i_d      (l2_b[7]   ) ,
            .o_a      (l3_a[3]   ) , .o_b      (l3_b[3]  )  ); 
pp_rtl u23( .i_a      (l2_a[2]   ) , .i_b      (l2_b[2]   ) ,
            .i_c      (l2_a[6]   ) , .i_d      (l2_b[6]   ) ,
            .o_a      (l3_a[2]   ) , .o_b      (l3_b[2]  )  ); 
pp_rtl u13( .i_a      (l2_a[1]   ) , .i_b      (l2_b[1]   ) ,
            .i_c      (l2_a[5]   ) , .i_d      (l2_b[5]   ) ,
            .o_a      (l3_a[1]   ) , .o_b      (l3_b[1]  )  ); 
pp_rtl u03( .i_a      (l2_a[0]   ) , .i_b      (l2_b[0]   ) ,
            .i_c      (l2_a[4]   ) , .i_d      (l2_b[4]   ) ,
            .o_a      (l3_a[0]   ) , .o_b      (l3_b[0]  )  ); 


always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        i_prior <= 8'd1 ;
    end 
    else if (o_ag) begin
        i_prior <= {o_grant[arbiter_width-2:0],o_grant[arbiter_width-1]};
    end
end

assign x       = l3_a      ;
assign o_grant = i_req & x ;
assign o_ag    = ~l3_b      ;
// module pp 
// (
    // input  wire i_a ,
    // input  wire i_b ,
    // input  wire i_c ,
    // input  wire i_d ,
    // output wire o_a ,
    // output wire o_b 
// ); 
// assign o_a = i_a | ( i_b & i_c ) ;
// assign o_b = i_b & i_d ;
// endmodule  //
//pp  ( .i_a      (    ) , .i_b      (    ) ,
//      .i_c      (    ) , .i_d      (    ) ,
//      .o_a      (    ) , .o_b      (    )  ); 
endmodule 
