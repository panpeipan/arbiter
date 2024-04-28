module ahb_master_if_v0 
#( 
    parameter ADDR_WIDTH    = 32 ,
    parameter BURST_WIDTH   = 3  ,
    parameter HPROT_WIDTH   = 1  ,
    parameter HMASTER_WIDTH = 0  ,
    parameter DATA_WIDTH    = 32 ,
    parameter HWSTRB_WIDTH  = DATA_WIDTH/8  
)
( 
    input   wire                         i_hclk        ,
    input   wire                         i_hresetn     ,
//manager0 请求BUS权限                   
    output  reg                          o_hburst_req  ,
    input   wire                         i_hgrant      ,
//--------------------------------------------------------//
    output  reg  [ADDR_WIDTH-1 : 0]      o_haddr                  ,
    output  reg  [BURST_WIDTH-1: 0]      o_hburst                 ,
    output  reg                          o_hmastlock              ,
    output  reg  [HPROT_WIDTH-1: 0]      o_hprot                  , //NULL 
    output  reg  [2: 0]                  o_hsize                  , //NULL 
    output  reg                          o_hnonsec                , //NULL 
    output  reg  [HMASTER_WIDTH-1: 0]    o_hmaster                , //NULL 
    output  reg  [1 : 0]                 o_htrans                 ,//传输类型 IDLE BUSY NONSEQ SEQ 
    output  reg  [DATA_WIDTH-1: 0]       o_hwdata                 ,
    output  reg  [HWSTRB_WIDTH-1: 0]     o_hwstrb                 ,
    output  reg                          o_hwrite                 ,//写POS 读NEG
    input   wire [DATA_WIDTH-1 : 0]      i_hrdata                 ,
    input   wire                         i_hready                 ,
    input   wire                         i_hresp                  ,//0:trans ok 1:trans error
    input   wire                         i_hexokay                ,//NULL
//--------------------------------------------------------//
//user if  
    input   wire                         i_user_cmd_valid         ,
    output  wire                         o_user_cmd_ready         ,
    input   wire [2: 0]                  i_user_burst_type        ,
    output  wire                         o_user_done              ,
    input   wire [ADDR_WIDTH-1: 0]       i_user_addr              ,
    input   wire                         i_user_write             , //
    input   wire [DATA_WIDTH-1: 0]       i_user_wdata             ,
    input   wire                         i_user_wdvalid           ,
    output  reg                          o_user_wdready           ,
    output  wire [DATA_WIDTH-1: 0]       o_user_rdata             ,
    output  reg                          o_user_rdvalid           ,
    input   wire                         i_user_rdready           ,
    input   wire                         i_user_undef_incr_last   ,
    output  reg                          o_user_undef_incr_stage  , // 1:当前传输为UNDEF_INCR 
    output  reg                          o_user_error             ,
    output  reg [2: 0]                   o_user_error_burst_type  ,
    output  reg [ADDR_WIDTH-1: 0]        o_user_error_addr        ,
    output  reg                          o_user_error_write        //
); 
//----------------------------------------------------//
// local parameter
//----------------------------------------------------//
    //HTRANS 
    localparam TRANS_IDLE   = 2'b00 , TRANS_BUSY = 2'b01 ,
               TRANS_NONSEQ = 2'b10 , TRANS_SEQ  = 2'b11 ;  
    //BURST_TYPE 
    localparam SINGLE = 3'b000 , NONDEF_INCR = 3'b001 ,
               WRAP4  = 3'b010 , INCR4       = 3'b011 ,
               WRAP8  = 3'b100 , INCR8       = 3'b101 ,
               WRAP16 = 3'b110 , INCR16      = 3'b111 ;  
    //AHB FSM 
    localparam ST_IDLE       = 3'b000 , ST_BUS_REQ    = 3'b001 ,
               ST_TRANS_ERROR= 3'b010 , ST_TRANS_SINGLE = 3'b111 ,
               ST_TRANS_WRAP = 3'b100 , ST_TRANS_INCR = 3'b101 ,
               ST_TRANS_NONDEF_INCR = 3'b110 ,
               ST_TRANS_LOCKED_IDLE = 3'b011 ;
//----------------------------------------------------//
// reg
//----------------------------------------------------//
// reg                        r_trans_busy     ;  
// 传输阶段 0表示没有传输 1表示正在传输 
reg                        r_trans_locked   ; 
// 用于表征当前是否是locked传输 0:没有LOCKED 1：开启LOCKED  
//
reg  [ADDR_WIDTH-1 : 0]    r_addr_b0        ;
reg  [2: 0]                r_burst_type_b0  ;
reg                        r_write_b0       ;
//
reg  [ADDR_WIDTH-1 : 0]    r_addr_b1        ;
reg  [4: 0]                r_burst_type_b1  ;
reg                        r_write_b1       ; 
//
reg                        r_bank           ;
reg  [1: 0]                r_bank_st        ; //0 表示没有使用 1 表示在占用
reg  [5 : 0]               r_trans_cnt           ; 
reg                        r_load_basetrans_flag ;
reg  [2 : 0]               r_ahb_burst_type      ;
reg                        r_ahb_write           ; 
reg                        r_trans_done     ; 
reg                        r_trans_en_flag ; 
reg  [10:0]                r_addr_step_len  ;
//----------------------------------------------------//
// FSM
//----------------------------------------------------// 
reg  [2: 0]                cur_state             ;
reg  [2: 0]                next_state        ;
//----------------------------------------------------//
// wire
//----------------------------------------------------//
wire  [ADDR_WIDTH-1 : 0]   w_exe_addr       ;
wire  [2 : 0]              w_exe_burst_type ;
wire                       w_exe_write      ;
wire  [ADDR_WIDTH-1 : 0]   w_next_addr      ;
wire  [2 : 0]              w_next_burst_type;
wire                       w_next_write     ;
wire  [1 : 0]              w_user_task_num  ;   
wire                       w_load_next_basetrans_flag  ;
wire                       w_user_cmd_vr ;
//----------------------------------------------------//
// main_code
//----------------------------------------------------//
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_addr_b0 <= 'd0 ;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[0]) begin 
        r_addr_b0 <= i_user_addr ;
    end 
    else begin
        r_addr_b0 <= r_addr_b0 ;
    end
end
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_burst_type_b0 <= 'd0;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[0]) begin 
        r_burst_type_b0 <= i_user_burst_type ;
    end 
    else begin
        r_burst_type_b0 <= r_burst_type_b0 ;
    end
end
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_write_b0 <= 'd0;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[0]) begin 
        r_write_b0 <= i_user_write ;
    end 
    else begin
        r_write_b0 <= r_write_b0 ;
    end
end 

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_addr_b1 <= 'd0 ;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[1]) begin 
        r_addr_b1 <= i_user_addr ;
    end 
    else begin
        r_addr_b1 <= r_addr_b1 ;
    end
end
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_burst_type_b1 <= 'd0;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[1]) begin 
        r_burst_type_b1 <= i_user_burst_type ;
    end 
    else begin
        r_burst_type_b1 <= r_burst_type_b1 ;
    end
end
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_write_b1 <= 'd0;
    end 
    else if (w_user_cmd_vr&&~r_bank_st[1]) begin 
        r_write_b1 <= i_user_write ;
    end 
    else begin
        r_write_b1 <= r_write_b1 ;
    end
end    


//-------------------------------------------------
//r_bank r_bank_st  
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_bank <= 1'b0 ;
        r_bank_st <= 2'b00 ;
    end 
    else if ((w_user_cmd_vr||o_user_done)) begin
        case (r_bank_st)
            2'b00: begin 
                if (w_user_cmd_vr) begin
                    r_bank_st <= 2'b01 ;     // 当前【0】有请求 
                    r_bank    <= 1'b0  ;     // 当前任务进行在那个BANK 
                end 
            end  
            2'b01:begin 
                if (w_user_cmd_vr&&~o_user_done) begin
                    r_bank_st <= 2'b11 ;
                    r_bank    <= r_bank;
                end 
                else if (~w_user_cmd_vr&&o_user_done) begin
                    r_bank_st <= 2'b00 ;
                    r_bank    <= r_bank;
                end 
                else begin
                    r_bank_st <= 2'b10 ;
                    r_bank    <= 1'b1  ;
                end
            end 
            2'b10:begin 
                if (w_user_cmd_vr&&~o_user_done) begin
                    r_bank_st <= 2'b11 ;
                    r_bank    <= r_bank;
                end 
                else if (~w_user_cmd_vr&&o_user_done) begin
                    r_bank_st <= 2'b00 ;
                    r_bank    <= r_bank;
                end 
                else begin
                    r_bank_st <= 2'b01 ;
                    r_bank    <= 1'b0  ;
                end
            end  
            2'b11:begin 
                if (w_user_cmd_vr&&~o_user_done) begin
                    r_bank_st <= 2'b11 ;
                    r_bank    <= r_bank;
                end 
                else if (~w_user_cmd_vr&&o_user_done) begin
                    r_bank_st <= r_bank ? 2'b01 : 2'b10 ;
                    r_bank    <= ~r_bank;
                end 
                else begin
                    r_bank_st <= 2'b11 ;
                    r_bank    <= ~r_bank  ;
                end
            end 
        endcase   
    end 
    else begin 
        r_bank           <= r_bank      ;
        r_bank_st        <= r_bank_st   ;
    end
end 
//o_user_done  取决于 TRANS 计数是否完成 
//------------------------------------------------//
//AMBA AHB 5     
//fsm  
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        cur_state <= 3'b000 ;
    end 
    else begin
        cur_state <= next_state ; 
    end
end  

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        next_state <= 3'b000 ;
    end 
    else begin
        case (next_state)
            ST_IDLE: begin
                if (w_user_cmd_vr) begin
                    next_state <= ST_BUS_REQ ; 
                end 
                else begin
                    next_state <= ST_IDLE ;
                end
            end 
            ST_BUS_REQ :begin 
                if (o_hburst_req & i_hgrant) begin 
                    case (w_exe_burst_type)
                        SINGLE: begin
                            next_state <= ST_TRANS_SINGLE ;
                        end 
                        NONDEF_INCR:begin 
                            next_state <= ST_TRANS_NONDEF_INCR ;
                        end  
                        INCR4,INCR8,INCR16 :begin 
                            next_state <= ST_TRANS_INCR ;
                        end  
                        WRAP4,WRAP8,WRAP16:begin 
                            next_state <= ST_TRANS_WRAP ;
                        end  
                    endcase
                end 
                else begin
                    next_state <= next_state ;
                end
            end 
            ST_TRANS_SINGLE : begin 
                if (i_hresp&&~i_hready) begin
                    next_state <= ST_TRANS_ERROR ;
                end
                else if (r_bank_st==2'b11) begin
                        case (w_next_burst_type)
                        SINGLE: begin
                            next_state <= ST_TRANS_SINGLE ;
                        end 
                        NONDEF_INCR:begin 
                            next_state <= ST_TRANS_NONDEF_INCR ;
                        end  
                        INCR4,INCR8,INCR16 :begin 
                            next_state <= ST_TRANS_INCR ;
                        end  
                        WRAP4,WRAP8,WRAP16:begin 
                            next_state <= ST_TRANS_WRAP ;
                        end  
                        endcase
               end 
               else if (r_trans_locked) begin
                   next_state <= ST_TRANS_LOCKED_IDLE ;
               end
               else begin
                   next_state <= ST_IDLE;
               end
            end 
            ST_TRANS_INCR : begin 
                // if (i_hresp&&~i_hready) begin
                    // next_state <= ST_TRANS_ERROR ;
                // end
                // else if (r_trans_done) begin
                    // if (r_bank_st==2'b11) begin
                        // case (w_next_burst_type)
                        // SINGLE: begin
                            // next_state <= ST_TRANS_SINGLE ;
                        // end 
                        // NONDEF_INCR:begin 
                            // next_state <= ST_TRANS_NONDEF_INCR ;
                        // end  
                        // INCR4,INCR8,INCR16 :begin 
                            // next_state <= ST_TRANS_INCR ;
                        // end  
                        // WRAP4,WRAP8,WRAP16:begin 
                            // next_state <= ST_TRANS_WRAP ;
                        // end  
                        // endcase
                    // end 
                    // else if (r_trans_locked) begin
                        // next_state <= ST_TRANS_LOCKED_IDLE ;
                    // end
                    // else begin
                        // next_state <= ST_IDLE;
                    // end
                // end 
                // else begin
                    // next_state <= next_state ;
                // end
            // end 
                if (i_hresp&&~i_hready) begin
                    next_state <= ST_TRANS_ERROR ;
                end
                else if(i_hready)begin
                    case (w_exe_burst_type)
                    INCR4:begin  
                        if (r_trans_cnt==2) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end 
                            else begin
                                next_state <= ST_IDLE ;
                            end
                        end 
                        else begin
                            next_state <= next_state;
                        end 
                    end 
                    INCR8:begin 
                        if (r_trans_cnt==6) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end  
                            else begin
                                next_state <= ST_IDLE;
                            end
                        end 
                        else begin
                            next_state <= next_state;
                        end
                    end 
                    INCR16:begin 
                        if (r_trans_cnt==14) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end 
                            else begin
                                 next_state <= ST_IDLE;
                            end 
                        end 
                        else begin
                             next_state <= next_state;
                         end 
                    end 
                    endcase 
                end 
            end 
            ST_TRANS_WRAP : begin 
                // if (i_hresp&&~i_hready) begin
                    // next_state <= ST_TRANS_ERROR ;
                // end
                // else if (r_trans_done) begin
                    // if (r_bank_st==2'b11) begin
                        // case (w_next_burst_type)
                        // SINGLE: begin
                            // next_state <= ST_TRANS_SINGLE ;
                        // end 
                        // NONDEF_INCR:begin 
                            // next_state <= ST_TRANS_NONDEF_INCR ;
                        // end  
                        // INCR4,INCR8,INCR16 :begin 
                            // next_state <= ST_TRANS_INCR ;
                        // end  
                        // WRAP4,WRAP8,WRAP16:begin 
                            // next_state <= ST_TRANS_WRAP ;
                        // end  
                        // endcase
                    // end 
                    // else if (r_trans_locked) begin
                        // next_state <= ST_TRANS_LOCKED_IDLE ;
                    // end
                    // else begin
                        // next_state <= ST_IDLE;
                    // end
                // end 
                // else begin
                    // next_state <= next_state ;
                // end 
            // end 
                if (i_hresp&&~i_hready) begin
                    next_state <= ST_TRANS_ERROR ;
                end
                else if(i_hready)begin
                    case (w_exe_burst_type)
                    WRAP4:begin  
                        if (r_trans_cnt==2) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end 
                            else begin
                                next_state <= ST_IDLE ;
                            end
                        end 
                        else begin
                            next_state <= next_state;
                        end 
                    end 
                    WRAP8:begin 
                        if (r_trans_cnt==6) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end  
                            else begin
                                next_state <= ST_IDLE;
                            end
                        end 
                        else begin
                            next_state <= next_state;
                        end
                    end 
                    WRAP16:begin 
                        if (r_trans_cnt==14) begin
                            if (r_bank_st==2'b11) begin
                                case (w_next_burst_type)
                                SINGLE: begin
                                    next_state <= ST_TRANS_SINGLE ;
                                end 
                                NONDEF_INCR:begin 
                                    next_state <= ST_TRANS_NONDEF_INCR ;
                                end  
                                INCR4,INCR8,INCR16 :begin 
                                    next_state <= ST_TRANS_INCR ;
                                end  
                                WRAP4,WRAP8,WRAP16:begin 
                                    next_state <= ST_TRANS_WRAP ;
                                end  
                                endcase 
                            end 
                            else if (r_trans_locked) begin
                                next_state <= ST_TRANS_LOCKED_IDLE ;
                            end 
                            else begin
                                 next_state <= ST_IDLE;
                            end 
                        end 
                        else begin
                             next_state <= next_state;
                         end 
                    end 
                    endcase 
                end 
            end 
            ST_TRANS_NONDEF_INCR :begin 
                if (i_hresp&&~i_hready) begin
                    next_state <= ST_TRANS_ERROR ;
                end
                else if (i_user_undef_incr_last) begin
                    if (r_bank_st==2'b11) begin
                        case (w_next_burst_type)
                        SINGLE: begin
                            next_state <= ST_TRANS_SINGLE ;
                        end 
                        NONDEF_INCR:begin 
                            next_state <= ST_TRANS_NONDEF_INCR ;
                        end  
                        INCR4,INCR8,INCR16 :begin 
                            next_state <= ST_TRANS_INCR ;
                        end  
                        WRAP4,WRAP8,WRAP16:begin 
                            next_state <= ST_TRANS_WRAP ;
                        end  
                        endcase
                    end 
                    else if (r_trans_locked) begin
                        next_state <= ST_TRANS_LOCKED_IDLE ;
                    end 
                    else begin
                        next_state <= ST_IDLE;
                    end
                end 
                else begin
                    next_state <= next_state ;
                end
            end 
            ST_TRANS_ERROR : begin 
                // Eclusive Access 
                if (r_trans_done) begin
                    if (r_bank_st==2'b11) begin
                        case (w_next_burst_type)
                        SINGLE: begin
                            next_state <= ST_TRANS_SINGLE ;
                        end 
                        NONDEF_INCR:begin 
                            next_state <= ST_TRANS_NONDEF_INCR ;
                        end  
                        INCR4,INCR8,INCR16 :begin 
                            next_state <= ST_TRANS_INCR ;
                        end  
                        WRAP4,WRAP8,WRAP16:begin 
                            next_state <= ST_TRANS_WRAP ;
                        end  
                        endcase
                    end 
                    else if (r_trans_locked) begin
                        next_state <= ST_TRANS_LOCKED_IDLE ;
                    end 
                    else begin
                        next_state <= ST_IDLE ;
                    end
                end 
                else begin
                    next_state <= next_state ;
                end
            end 
            default: begin
                next_state <= ST_IDLE ;
            end
        endcase
    end
end
//o_user_undef_incr_stage 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_user_undef_incr_stage <= 1'b0 ;
    end   
    else if (i_user_undef_incr_last) begin
        o_user_undef_incr_stage <= 1'b0;
    end 
    else if (next_state==ST_TRANS_NONDEF_INCR) begin
        o_user_undef_incr_stage <= 1'b1 ;
    end 
    else begin
        o_user_undef_incr_stage <= o_user_undef_incr_stage;
    end
end 
//
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hburst_req <= 1'b0 ;
    end 
    else if (i_hgrant) begin
        o_hburst_req <= 1'b0 ;
    end
    else if (r_bank_st!=2'b00) begin
        o_hburst_req <= 1'b1 ;
    end 
    else begin
        o_hburst_req <= 1'b0 ;
    end
end  
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_load_basetrans_flag <= 1'b0 ;
    end 
    else if (next_state==ST_BUS_REQ&&o_hburst_req&&i_hgrant ) begin
        r_load_basetrans_flag <= 1'b1 ;
    end  
    else if(i_hready)begin
        r_load_basetrans_flag <= 1'b0 ;
    end 
    else begin
        r_load_basetrans_flag <= r_load_basetrans_flag ; 
    end
end
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_ahb_burst_type <= 'd0 ;   
        r_ahb_write      <= 'd0 ;
    end 
    else if (cur_state == ST_IDLE && next_state == ST_BUS_REQ) begin
        r_ahb_burst_type <= w_exe_burst_type ;
        r_ahb_write      <= w_exe_addr       ;
    end 
    else if (cur_state[2]&&r_trans_done&&r_bank_st==2'b11) begin
        r_ahb_burst_type <= w_next_burst_type;
        r_ahb_write      <= w_next_write     ;
    end
    else begin
        r_ahb_burst_type <= r_ahb_burst_type ;
        r_ahb_write      <= r_ahb_write      ;
    end
end
reg     r_bank_task_done_flag ;
//o_haddr 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_trans_done <= 'd0 ;
        r_bank_task_done_flag <= 1'b0 ;
    end 
    else if (i_hresp&&~i_hready) begin
        r_trans_done <= 1'b1 ;
        r_bank_task_done_flag <= 1'b1 ;
    end
    else if (~i_hready) begin
        r_trans_done <= 1'b0;
        r_bank_task_done_flag <= 1'b0 ;
    end
    else if (r_load_basetrans_flag||w_load_next_basetrans_flag) begin
        if (next_state == ST_TRANS_SINGLE) begin
            r_trans_done <= 1'b1  ;
            r_bank_task_done_flag <= 1'b1 ;
        end 
        else begin
            r_trans_done <= 1'b0  ;
            r_bank_task_done_flag <= 1'b0 ;
        end
    end 
    else begin 
        case (next_state)
            // ST_TRANS_SINGLE:begin 
                // o_haddr <= o_haddr ;
            // end 
            ST_TRANS_INCR: begin
                case (r_ahb_burst_type)
                    INCR4: begin
                        if (r_trans_cnt==1) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end 
                        else if (r_trans_cnt==2) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    INCR8: begin
                        if (r_trans_cnt==5) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end 
                        if (r_trans_cnt==6) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    INCR16: begin
                        if (r_trans_cnt==13) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end 
                        else if (r_trans_cnt==14) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    default: begin
                        r_trans_done <= 1'b0 ; 
                        r_bank_task_done_flag <= 1'b0 ;
                    end
                endcase
            end 
            ST_TRANS_WRAP:begin 
                case (r_ahb_burst_type)
                    WRAP4: begin
                        if (r_trans_cnt==1) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end 
                        else if (r_trans_cnt==2) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    WRAP8: begin 
                        if (r_trans_cnt == 5) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end
                        else if (r_trans_cnt==6) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    WRAP16: begin 
                        if (r_trans_cnt==13) begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b1 ;
                        end
                        else if (r_trans_cnt==14) begin
                            r_trans_done <= 1'b1 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end 
                        else begin
                            r_trans_done <= 1'b0 ;
                            r_bank_task_done_flag <= 1'b0 ;
                        end
                    end
                    default: begin
                        r_trans_done <= 1'b0 ; 
                        r_bank_task_done_flag <= 1'b0 ;
                    end 
                endcase 
            end   
            ST_TRANS_NONDEF_INCR:begin 
                if (i_user_undef_incr_last) begin
                    r_trans_done <= 1'b1;
                    r_bank_task_done_flag <= 1'b1 ;
                end 
                else begin
                    r_trans_done <= 1'b0 ;
                    r_bank_task_done_flag <= 1'b0 ;
                end
            end 
            default: begin
                r_trans_done <= 1'b0 ;
                r_bank_task_done_flag <= 1'b0 ;
            end
        endcase
    end 
end 


//o_haddr 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_haddr      <= 'd0 ;   
        r_trans_cnt  <= 'd0 ;
    end 
    else if (i_hresp) begin
        o_haddr      <=  'd0 ;   
        r_trans_cnt  <=  'd0 ;
    end
    else if (~i_hready) begin
        o_haddr      <= o_haddr     ;   
        r_trans_cnt  <= r_trans_cnt ;
    end
    else if (r_load_basetrans_flag) begin
        o_haddr     <= w_exe_addr ;
        r_trans_cnt <= 'd0        ;
    end 
    else if(w_load_next_basetrans_flag)begin
        o_haddr      <= w_next_addr ; 
        r_trans_cnt  <= 'd0         ; 
    end 
    else if ((w_exe_write&&~i_user_wdvalid)||(~w_exe_write&&~i_user_rdready)) begin
        o_haddr     <= o_haddr ;
        r_trans_cnt <= r_trans_cnt ;
    end
    else begin 
        case (next_state)
            // ST_TRANS_SINGLE:begin 
                // o_haddr <= o_haddr ;
            // end 
            ST_TRANS_INCR: begin
                case (r_ahb_burst_type)
                    INCR4: begin
                        if (i_hready&&r_trans_cnt<3) begin
                            o_haddr     <= o_haddr + r_addr_step_len ; 
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    INCR8: begin
                        if (i_hready&&r_trans_cnt<7) begin
                            o_haddr     <= o_haddr + r_addr_step_len ;   
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    INCR16: begin
                        if (i_hready&&r_trans_cnt<15) begin
                            o_haddr     <= o_haddr + r_addr_step_len ; 
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    default: begin
                        o_haddr     <= o_haddr ; 
                        r_trans_cnt <= r_trans_cnt ;
                    end
                endcase
            end 
            ST_TRANS_WRAP:begin 
                case (r_ahb_burst_type)
                    WRAP4: begin
                        if (i_hready&&r_trans_cnt<3) begin
                            o_haddr[3:0]<= o_haddr[3:0] + r_addr_step_len ; 
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    WRAP8: begin
                        if (i_hready&&r_trans_cnt<7) begin
                            o_haddr[4:0]<= o_haddr[4:0] + r_addr_step_len ; 
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    WRAP16: begin
                        if (i_hready&&r_trans_cnt<15) begin     //wrap16 16=[3:0] hsize 32/8=4=[1:0]  
                            o_haddr[5:0]<= o_haddr[5:0]+ r_addr_step_len ; 
                            r_trans_cnt <= r_trans_cnt + 1 ;
                        end 
                        else begin
                            o_haddr     <= o_haddr ; 
                            r_trans_cnt <= r_trans_cnt ;
                        end
                    end
                    default: begin
                        o_haddr     <= o_haddr ; 
                        r_trans_cnt <= r_trans_cnt ;
                    end 
                endcase 
            end   
            ST_TRANS_NONDEF_INCR:begin 
                if (i_user_undef_incr_last) begin
                    o_haddr <= o_haddr + r_addr_step_len ;
                end
                else if (o_user_undef_incr_stage) begin
                    o_haddr <= o_haddr + r_addr_step_len ;
                end   
                else begin
                    o_haddr <= o_haddr ;
                end
            end 
            default: begin
                o_haddr <= o_haddr ;
            end
        endcase
    end 
end 

//------------------------------------------------//
//                    错误处理                    //
//------------------------------------------------//
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin 
        o_user_error            <= 'd0 ;
        o_user_error_burst_type <= 'd0 ;
        o_user_error_write      <= 'd0 ;
        o_user_error_addr       <= 'd0 ;
    end 
    else if (next_state == ST_TRANS_ERROR) begin 
        o_user_error            <= 1'b1 ;
        o_user_error_burst_type <= w_exe_burst_type ;
        o_user_error_write      <= w_exe_write ;
        o_user_error_addr       <= w_exe_addr  ;
    end 
    else begin
        o_user_error            <= 'd0 ;
        o_user_error_burst_type <= 'd0 ;
        o_user_error_write      <= 'd0 ;
        o_user_error_addr       <= 'd0 ;
    end
end    
//------------------------------------------------//
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hburst <= 'd0 ;
    end 
    else if (r_load_basetrans_flag) begin
        o_hburst <= w_exe_burst_type ;
    end 
    else if(w_load_next_basetrans_flag&&i_hready)begin
        o_hburst <= w_next_burst_type ;
    end 
    else begin
        o_hburst <= o_hburst ;
    end
end   

//------------------------------------------------//
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hwrite <= 'd0 ;
    end 
    else if (r_load_basetrans_flag) begin
        o_hwrite <= w_exe_write ;
    end 
    else if(w_load_next_basetrans_flag&&i_hready)begin
        o_hwrite <= w_next_write ;
    end 
    else begin
        o_hwrite <= o_hwrite ;
    end
end   

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_htrans <= TRANS_IDLE ;
        r_trans_en_flag <= 'd0 ;
    end 
    else if (~i_hready&&i_hresp) begin
        o_htrans <= TRANS_IDLE ;
        r_trans_en_flag <= 1'b0 ;
    end
    else if (~i_hready) begin
        o_htrans <= o_htrans ;
        r_trans_en_flag <= r_trans_en_flag ;
    end
    else if (r_load_basetrans_flag) begin
        o_htrans <= TRANS_NONSEQ ;
        r_trans_en_flag <= 1'b1 ;
    end 
    else if(w_load_next_basetrans_flag&&i_hready)begin
        o_htrans <= TRANS_NONSEQ ;
        r_trans_en_flag <= 1'b1 ;
    end  
    else if (i_hready&&r_trans_en_flag) begin
        if ((w_exe_write&&~i_user_wdvalid)||(~w_exe_write&&~i_user_rdready)) begin
            o_htrans <= TRANS_BUSY ;
        end  
        else begin 
            o_htrans <= TRANS_SEQ ; 
        end
    end
    else if (next_state == ST_TRANS_LOCKED_IDLE) begin //lock 
        o_htrans <= TRANS_IDLE ;
    end 
    else if (r_trans_done) begin //trans_done 
        o_htrans <= TRANS_IDLE ;
        r_trans_en_flag <= 1'b0 ;
    end
    else begin  
        o_htrans <= o_htrans ;
        r_trans_en_flag <= r_trans_en_flag ;
    end
end 
//o_hwdata o_user_wdready 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hwdata       <= 'd0 ;
        o_user_wdready <= 1'b0 ;
    end 
    else if ( ~i_hready ) begin
        o_hwdata       <= o_hwdata ;
        o_user_wdready <= 1'b0 ;
    end
    else if (r_load_basetrans_flag&&w_exe_write&&i_user_wdvalid) begin
        o_hwdata       <= i_user_wdata ;
        o_user_wdready <= 1'b1 ;
    end 
    else if(w_load_next_basetrans_flag&&w_next_write&&i_user_wdvalid)begin
        o_hwdata       <= i_user_wdata ;
        o_user_wdready <= 1'b1 ;
    end  
    else if (r_trans_en_flag&&w_exe_write&&i_user_wdvalid) begin
        o_hwdata       <= i_user_wdata ;
        o_user_wdready <= 1'b1 ;
    end 
    else if (next_state==ST_TRANS_NONDEF_INCR&&o_user_undef_incr_stage) begin
        o_hwdata       <= i_user_wdata ;
        o_user_wdready <= 1'b1 ;
    end
    else if (next_state == ST_TRANS_LOCKED_IDLE) begin //lock 
        o_hwdata       <= o_hwdata ;
        o_user_wdready <= 1'b0 ;
    end 
    else if (r_trans_done) begin //trans_done 
        o_hwdata       <= o_hwdata ;
        o_user_wdready <= 1'b0 ;
    end
    else begin  
        o_hwdata       <= o_hwdata ;
        o_user_wdready <= 1'b0 ;
    end
end  
reg    r_rddata_flag ; 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        r_rddata_flag <= 1'b0 ;
    end  
    else if ((o_htrans==TRANS_NONSEQ||o_htrans==TRANS_SEQ)&&~o_hwrite) begin
        r_rddata_flag <= 1'b1 ;
    end  
    else begin
        r_rddata_flag <= 1'b0 ;
    end
end 
//o_user_rdvalid 
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_user_rdvalid <= 1'b0 ;
    end 
    else if (~i_hready) begin
        o_user_rdvalid <= 1'b0 ;
    end
    else if (~w_exe_write&&~i_hresp&&r_rddata_flag) begin
        o_user_rdvalid <= 1'b1 ;
    end 
    else begin  
        o_user_rdvalid <= 1'b0 ;
    end
end  
//--------------------------------------------------
//     固定值 NULL hprot hsize hnonsec hmaster 
//--------------------------------------------------
always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hprot  <= 'd0 ; 
    end 
end 

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hsize  <= 3'b010 ; // 000 001 010
    end 
end 

always @(*) begin
    if (!i_hresetn) begin
        r_addr_step_len  <= 8'd0 ; // 000 001 010
    end 
    else begin
        case (o_hsize)
            3'b000: begin
                r_addr_step_len <= 8'd1 ;
            end 
            3'b001: begin
                r_addr_step_len <= 8'd2 ;
            end 
            3'b010: begin
                r_addr_step_len <= 8'd4 ;
            end 
            3'b011: begin
                r_addr_step_len <= 8'd8 ;
            end 
            3'b100: begin
                r_addr_step_len <= 8'd16 ;
            end 
            3'b101: begin
                r_addr_step_len <= 8'd32 ;
            end 
            3'b110: begin
                r_addr_step_len <= 8'd64 ;
            end 
            3'b111: begin
                r_addr_step_len <= 8'd128 ;
            end 
            default: begin
                r_addr_step_len <= 8'd8 ;   
            end
        endcase
    end
end 

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hnonsec  <= 'd0 ; // 
    end 
end  

always @(posedge i_hclk or negedge i_hresetn) begin
    if (!i_hresetn) begin
        o_hmaster  <= 'd1 ; // 
    end 
end 

//----------------------------------------------------//
// assign
//----------------------------------------------------//
assign  w_exe_addr = r_bank ? r_addr_b1 : r_addr_b0 ;
assign  w_exe_burst_type = r_bank ? r_burst_type_b1 : r_burst_type_b0 ;
assign  w_exe_write = r_bank ? r_write_b1 : r_write_b0 ;


assign  w_next_addr = ~r_bank ? r_addr_b1 : r_addr_b0 ;
assign  w_next_burst_type = ~r_bank ? r_burst_type_b1 : r_burst_type_b0 ;
assign  w_next_write = ~r_bank ? r_write_b1 : r_write_b0 ;

assign  w_user_task_num = ( r_bank_st == 2'b11 ) ? 2'b10 : (
                          ( r_bank_st == 2'b00 ) ? 2'b00 : 2'b01 );
assign  w_load_next_basetrans_flag = next_state[2]&&r_trans_done&&r_bank_st==2'b11 ; 
assign  o_user_rdata = i_hrdata ;
assign  o_user_done = r_trans_done ;
assign  w_user_cmd_vr = i_user_cmd_valid & o_user_cmd_ready ;  
assign  o_user_cmd_ready =   r_bank_st != 2'b11  ;
endmodule 
