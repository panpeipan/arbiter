module tb_arbiter ();
reg  r_bus_clk ,r_bus_rstn ;
reg  [7:0] r_bus_req ;
reg  [7:0] r_priority ; 
wire [7:0] w_bus_grant ;
always #5 r_bus_clk = ~r_bus_clk ;
initial begin
    r_bus_clk  <= 1'b1 ;
    r_bus_rstn <= 1'b0 ;
    #40 
    r_bus_rstn <= 1'b1 ; 
end 
initial begin
    r_bus_req <= 'd0 ;
    r_priority <= 8'b10000000;
    #10 
    r_bus_req <= 8'b01001000 ;
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b01000001 ;
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b00101001 ;
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b01001001 ;
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b10000011 ;
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b01010101 ; 
    #10 
    // r_priority <= 8'b00000100;
    r_bus_req <= 8'b00000001 ;
    #10 
    $finish ;
end 
initial begin
    $fsdbDumpfile("./tb_top.fsdb");
    $fsdbDumpvars(0,"+mda","+all");
    $fsdbDumpMDA();
end 
wire w_ag ;
ppa  u0
( 
    .i_prior    (r_priority ) ,
    .i_req      (r_bus_req  ) ,
    .o_grant    (w_bus_grant) ,
    .o_ag       (w_ag       ) 
);
endmodule 
