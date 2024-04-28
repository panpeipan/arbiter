module ahb_connect 
#(
//M0 
    parameter M0_ADDR_WIDTH    = 32 ,
    parameter M0_BURST_WIDTH   = 3  ,
    parameter M0_HPROT_WIDTH   = 0  ,
    parameter M0_HMASTER_WIDTH = 0  ,
    parameter M0_DATA_WIDTH    = 32 ,
    parameter M0_HWSTRB_WIDTH  = M0_DATA_WIDTH/8  ,
//M1 
    parameter M1_ADDR_WIDTH    = 32 ,
    parameter M1_BURST_WIDTH   = 3  ,
    parameter M1_HPROT_WIDTH   = 0  ,
    parameter M1_HMASTER_WIDTH = 0  ,
    parameter M1_DATA_WIDTH    = 32 , 
    parameter M1_HWSTRB_WIDTH  = M1_DATA_WIDTH/8  ,
//S0 
    parameter S0_BURST_WIDTH   = 3  ,
    parameter S0_ADDR_WIDTH    = 25 ,
    parameter S0_DATA_WIDTH    = 32 ,
//S1 
    parameter S1_BURST_WIDTH   = 3  ,
    parameter S1_ADDR_WIDTH    = 25 ,
    parameter S1_DATA_WIDTH    = 32 ,
//S2 
    parameter S2_BURST_WIDTH   = 3  ,
    parameter S2_ADDR_WIDTH    = 25 ,
    parameter S2_DATA_WIDTH    = 32 
)
(
    input  wire                         i_hclk           ,
    input  wire                         i_hresetn        ,
//manager0 请求BUS权限
    input  wire                         i_m0_hburst_req  ,
    output reg                          o_m0_hgrant      ,
//--------------------------------------------------------//
    input  wire [M0_ADDR_WIDTH-1 : 0]   i_m0_haddr       ,
    input  wire [M0_BURST_WIDTH-1: 0]   i_m0_hburst      ,
    input  wire                         i_m0_hmastlock   ,
    input  wire [M0_HPROT_WIDTH-1: 0]   i_m0_hprot       ,
    input  wire [3: 0]                  i_m0_hsize       ,
    input  wire                         i_m0_hnonsec     ,
    input  wire                         i_m0_hexcl       ,
    input  wire [M0_HMASTER_WIDTH-1: 0] i_m0_hmaster     ,
    input  wire [1 : 0]                 i_m0_htrans      ,//传输类型 IDLE BUSY NONSEQ SEQ 
    input  wire [M0_DATA_WIDTH-1: 0]    i_m0_hwdata      ,
    input  wire [M0_HWSTRB_WIDTH-1: 0]  i_m0_hwstrb      ,
    input  wire                         i_m0_hwrite      ,//写POS 读NEG
    output wire [M0_DATA_WIDTH-1 : 0]   o_m0_hrdata      ,
    output wire                         o_m0_hready      ,
    output wire                         o_m0_hresp       ,
    output wire                         o_m0_hexokay     ,
//manager1 请求BUS权限
    input  wire                         i_m1_hburst_req  ,
    output reg                          o_m1_hgrant      ,
//--------------------------------------------------------//
    input  wire [M1_ADDR_WIDTH-1 : 0]   i_m1_haddr       ,
    input  wire [M1_BURST_WIDTH-1: 0]   i_m1_hburst      ,
    //BURST类型 
    input  wire                         i_m1_hmastlock   ,
    //主机锁定传输
    input  wire [M1_HPROT_WIDTH-1: 0]   i_m1_hprot       ,
    //保护控制信号
    input  wire [3: 0]                  i_m1_hsize       ,
    //传输尺寸
    input  wire                         i_m1_hnonsec     ,
    //安全传输权限标志信号
    input  wire                         i_m1_hexcl       ,
    //独占传输标志
    input  wire [M1_HMASTER_WIDTH-1: 0] i_m1_hmaster     ,
    input  wire [1 : 0]                 i_m1_htrans      ,
    //传输类型 00IDLE 01BUSY 10NONSEQ 11SEQ 
    input  wire [M1_DATA_WIDTH-1: 0]    i_m1_hwdata      ,
    input  wire [M1_HWSTRB_WIDTH-1: 0]  i_m1_hwstrb      ,
    //字节使能信号 1对应一字节的使能
    input  wire                         i_m1_hwrite      ,
    //写POS 读NEG
    output wire [M1_DATA_WIDTH-1 : 0]   o_m1_hrdata      ,
    output wire                         o_m1_hready      ,
    output wire                         o_m1_hresp       ,
    //HRESP low indicates OKAY high inidicates ERROR 
    output wire                         o_m1_hexokay     ,
    //HEXOKAY 独占传输回应 high inidicates EA OKAY -- low inidicates EA ERROR
//slave 0 
    output wire                         o_s0_hsel        ,
    input  wire                         i_s0_hready      ,
    input  wire                         i_s0_hresp       ,
    output wire [S0_ADDR_WIDTH-1: 0]    o_s0_haddr       ,
    output wire                         o_s0_htrans      ,
    output wire                         o_s0_hwrite      ,
    output wire [S0_BURST_WIDTH-1: 0]   o_s0_hburst      ,
    output wire [3: 0]                  o_s0_hsize       ,
    output wire [S0_DATA_WIDTH-1: 0]    o_s0_hwdata      ,
    input  wire [S0_DATA_WIDTH-1: 0]    i_s0_hrdata      ,
//slave 1
    output wire                         o_s1_hsel        ,
    input  wire                         i_s1_hready      ,
    input  wire                         i_s1_hresp       ,
    output wire [S1_ADDR_WIDTH-1: 0]    o_s1_haddr       ,
    output wire                         o_s1_htrans      ,
    output wire                         o_s1_hwrite      ,
    output wire [S1_BURST_WIDTH-1: 0]   o_s1_hburst      ,
    output wire [3: 0]                  o_s1_hsize       ,
    output wire [S1_DATA_WIDTH-1: 0]    o_s1_hwdata      ,
    input  wire [S1_DATA_WIDTH-1: 0]    i_s1_hrdata      ,
//slave 2 
    output wire                         o_s2_hsel        ,
    input  wire                         i_s2_hready      ,
    input  wire                         i_s2_hresp       ,
    output wire [S2_ADDR_WIDTH-1: 0]    o_s2_haddr       ,
    output wire                         o_s2_htrans      ,
    output wire                         o_s2_hwrite      ,
    output wire [S2_BURST_WIDTH-1: 0]   o_s2_hburst      ,
    output wire [3: 0]                  o_s2_hsize       ,
    output wire [S2_DATA_WIDTH-1: 0]    o_s2_hwdata      ,
    input  wire [S2_DATA_WIDTH-1: 0]    i_s2_hrdata      
);
//----------------------------------------------------//
// local parameter
//----------------------------------------------------//
//----------------------------------------------------//
// reg
//----------------------------------------------------//


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
