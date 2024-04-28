// always output the first data , if R_EN , means receive success. 
module grey_coder#(
    parameter width = 7
)
(
    input  wire [width-1:0] code_i,
    output wire [width-1:0] code_o
);
    assign code_o = (code_i >> 1) ^ code_i;

endmodule

module buffer_dual_dd#(
    parameter width = 7
)
(
    input  wire clk,
    input  wire rst_n,
    input  wire [width-1:0] signal_i,
    output wire [width-1:0] signal_o
);
    reg [width-1:0] signal_temp1,signal_temp2;
    always @(posedge clk or negedge rst_n) begin
        if (rst_n== 1'b0) begin
            signal_temp1 <= {width{1'b0}};
            signal_temp2 <= {width{1'b0}};
        end 
        else begin
            signal_temp1 <= signal_i;
            signal_temp2 <= signal_temp1;
        end
    end
    assign signal_o = signal_temp2;

endmodule

module fifo_test_v1
#(
    parameter fifo_depth = 4,
    parameter rfifo_width = 32,
    parameter ADDR_WIDTH = 32 ,
    parameter fifo_addr  = 3    
)
(
    input wire W_CLK,
    input wire W_RST_N,
    input wire W_EN,
    input  wire                   i_wfifo_write            ,
    input  wire [2: 0]            i_wfifo_user_burst_type  , 
    input  wire [ADDR_WIDTH-1: 0] i_wfifo_user_addr        ,
    input wire R_CLK,
    input wire R_RST_N,
    input wire R_EN,
    output reg                    o_rfifo_write            ,
    output reg  [2: 0]            o_rfifo_user_burst_type  , 
    output reg  [ADDR_WIDTH-1: 0] o_rfifo_user_addr        ,    
    output wire FIFO_FULL,
    output wire FIFO_EMPTY,
    output wire [fifo_addr-1:0]FIFO_LEN
    
);
    reg                   r_user_write_type [fifo_depth-1:0];
    reg    [2:0]          r_user_burst_type [fifo_depth-1:0];
    reg [ADDR_WIDTH-1:0]  r_user_addr_type  [fifo_depth-1:0];

    reg [fifo_addr-1:0] w_prt , r_prt;
    wire[fifo_addr-1:0] w_prt_grey , r_prt_grey;
    reg [fifo_addr-1:0] w_prt_grey_reg , r_prt_grey_reg ;
    wire[fifo_addr-1:0] r_prt_grey_sys , w_prt_grey_sys ;
    wire [fifo_addr-1:0] w_prt_sys;
    wire [fifo_addr-2:0] w_addr , r_addr;
    reg [rfifo_width-1:0] data_out;
    assign w_addr = w_prt[fifo_addr-2:0];
    assign r_addr = r_prt[fifo_addr-2:0];
    wire ERROR;

    integer i;
    always @(posedge W_CLK or negedge W_RST_N) begin
        if (W_RST_N == 1'b0) begin
            w_prt <= 0;
        end 
        else if (W_EN == 1'b1 && ~FIFO_FULL) begin
            w_prt <= w_prt + 1; 
        end 
        else begin
            w_prt <= w_prt;
        end
    end 
    always @(posedge R_CLK or negedge R_RST_N) begin
        if (R_RST_N == 1'b0) begin
            r_prt <= 0;
        end 
        else if (R_EN == 1'b1 && ~FIFO_EMPTY) begin
            r_prt <= r_prt + 1;
        end
        else begin
            r_prt <= r_prt;
        end
    end 
    always @(posedge W_CLK or negedge W_RST_N ) begin
        if (W_RST_N == 1'b0) begin
            for (i = 0; i < fifo_depth; i=i+1) begin
                r_user_write_type [i] <= 0;
                r_user_burst_type [i] <= 0;
                r_user_addr_type [i] <= 0;
            end
        end 
        else if (W_EN) begin
                r_user_write_type [w_addr] <= i_wfifo_write;
                r_user_burst_type [w_addr] <= i_wfifo_user_burst_type;
                r_user_addr_type  [w_addr] <= i_wfifo_user_addr;
        end 
        else begin
            r_user_write_type  [w_addr] <= r_user_write_type [w_addr];
            r_user_burst_type [w_addr] <= r_user_burst_type [w_addr];
            r_user_addr_type [w_addr] <= r_user_addr_type [w_addr];
        end
    end 
    always @(posedge W_CLK or negedge W_RST_N) begin
        if (W_RST_N == 1'b0) begin
            w_prt_grey_reg <= {fifo_addr{1'b0}};
        end 
        else begin
            w_prt_grey_reg <= w_prt_grey;
        end
    end
    always @(posedge R_CLK or negedge R_RST_N) begin
        if (R_RST_N == 1'b0) begin
            r_prt_grey_reg <= {fifo_addr{1'b0}};
        end 
        else begin
            r_prt_grey_reg <= r_prt_grey;
        end
    end 
    always @(posedge R_CLK or negedge R_RST_N) begin
        if (R_RST_N == 1'b0) begin
            o_rfifo_write <= 'dz;
            o_rfifo_user_addr<= 32'dz ;
            o_rfifo_user_burst_type <= 3'dz ;
        end 
        else if (R_EN && !FIFO_EMPTY) begin
            o_rfifo_write            <= r_user_write_type[r_addr+1];
            o_rfifo_user_burst_type  <= r_user_burst_type[r_addr+1]; 
            o_rfifo_user_addr        <= r_user_addr_type[r_addr+1];    
        end 
        else begin
            o_rfifo_write            <= r_user_write_type[r_addr];
            o_rfifo_user_burst_type  <= r_user_burst_type[r_addr]; 
            o_rfifo_user_addr        <= r_user_addr_type [r_addr];    
        end
    end
     assign  FIFO_FULL  = ( w_prt_grey[fifo_addr-1]!= r_prt_grey_sys[fifo_addr-1])&&(  w_prt_grey[fifo_addr-2]!= r_prt_grey_sys[fifo_addr-2] ) && (w_prt_grey[fifo_addr-3:0] == r_prt_grey_sys[fifo_addr-3:0]);//CANT WRITE
     assign  FIFO_EMPTY = ( r_prt_grey == w_prt_grey_sys) ? 1'b1:1'b0;//CANT READ
     assign  FIFO_LEN = (w_prt_sys[fifo_addr-1]==1'b0&&r_prt[fifo_addr-1]==1'b1) ? ({fifo_addr{1'b1}}-r_prt+w_prt_sys):(w_prt_sys-r_prt);//CANT READ w_prt_sys r_prt;
     assign ERROR = FIFO_FULL && FIFO_EMPTY;
     // assign  R_DATA  = FIFO_EMPTY ? 32'hzzzz : {dual_ram [r_addr+1],dual_ram [r_addr]};
      assign  R_DATA  =  data_out;
    grey_coder#(
    .width (fifo_addr)
)
    wp_grey(
        .code_i(w_prt),
        .code_o(w_prt_grey)
    );
    grey_coder#(
    .width (fifo_addr)
)
    rp_grey(
        .code_i(r_prt),
        .code_o(r_prt_grey)
    );
    buffer_dual_dd #(
    .width (fifo_addr)
)
    w_dd(
        .clk (W_CLK),
        .rst_n(W_RST_N),
        .signal_i(r_prt_grey_reg),
        .signal_o(r_prt_grey_sys)
    );
    buffer_dual_dd#(
    .width (fifo_addr)
)
    r_dd(
        .clk(R_CLK),
        .rst_n(R_RST_N),
        .signal_i(w_prt_grey_reg),
        .signal_o(w_prt_grey_sys)
    );
    buffer_dual_dd#(
    .width (fifo_addr)
)
    fifo_len(
        .clk(R_CLK),
        .rst_n(R_RST_N),
        .signal_i(w_prt),
        .signal_o(w_prt_sys)
    );

endmodule 
