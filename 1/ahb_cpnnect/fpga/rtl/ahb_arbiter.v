module ahb_arbiter #(
    parameter  master_num = 4 
)
(
    input  wire                   i_bus_clk       ,
    input  wire                   i_bus_rstn      ,
    input  wire [master_num-1: 0] i_master_req    ,
    output wire [master_num-1: 0] o_master_grant  
);
reg   [master_num-1:0] ex_grant ;
wire  [2*master_num-1:0] grant    ;
//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_bus_clk or negedge i_bus_rstn) begin
    if (!i_bus_rstn) begin
        ex_grant <= 'd1;                //此时的优先级 0>1>2>3
    end 
    else if (|i_master_req) begin       //位或
        ex_grant <= {o_master_grant[master_num-2:0],o_master_grant[master_num-1]} ;  
        //当前grant是对REQ的回应，但是下一次取反+ex_grant『搜索的数字』，需要
        //对当前grant进行左移一位.
    end 
    else begin
        ex_grant <= ex_grant ;
    end
end
//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign grant = {i_master_req,i_master_req}&(~{i_master_req,i_master_req}+ex_grant); 
assign o_master_grant = grant[(2*master_num-1):master_num]|grant[master_num-1:0] ;
endmodule 
