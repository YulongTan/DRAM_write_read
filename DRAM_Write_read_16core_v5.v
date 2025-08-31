`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/26 18:46:51
// Design Name: 
// Module Name: Write_DRAM_IO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 在Write_DRAM_IO模块中实现16个核心的读写操作，其中主要修改为添加了输入数据WBL_DATA以及输出数据DRAM_DATA_OUT继续了并转串处理
//////////////////////////////////////////////////////////////////////////////////
// 

module DRAM_write_read_16core(
    input wire clk_100m,
    input wire clk_400m,
    input wire rst_n,
    // 使能读写
    input IO_EN, 
    input [1:0] IO_MODEL, // 01写, 10读
    // CIM_CEL DATA_IN
    input wire [1:0] CIM_model, // 存算模式选择
    input wire [16:1]DATA_IN,   // LIM_IN, LIM输入 16块芯片的算输入数据
    // 每一行的8个8bit数据
    // 16块芯片的输入数据
    input wire [63:0]WBL_DATA_IN1,
    input wire [63:0]WBL_DATA_IN2,
    input wire [63:0]WBL_DATA_IN3,
    input wire [63:0]WBL_DATA_IN4,
    input wire [63:0]WBL_DATA_IN5,
    input wire [63:0]WBL_DATA_IN6,
    input wire [63:0]WBL_DATA_IN7,
    input wire [63:0]WBL_DATA_IN8,
    input wire [63:0]WBL_DATA_IN9,
    input wire [63:0]WBL_DATA_IN10,
    input wire [63:0]WBL_DATA_IN11,
    input wire [63:0]WBL_DATA_IN12,
    input wire [63:0]WBL_DATA_IN13,
    input wire [63:0]WBL_DATA_IN14,
    input wire [63:0]WBL_DATA_IN15,
    input wire [63:0]WBL_DATA_IN16,
    // 输入数据地址
    // 写地址16块一致
    input wire [5:0] WWL_ADD,
    // 读出地址 16块暂不共用
    input wire [5:0]RWL_DEC_ADD1,
    input wire [5:0]RWL_DEC_ADD2,
    input wire [5:0]RWL_DEC_ADD3,
    input wire [5:0]RWL_DEC_ADD4,
    input wire [5:0]RWL_DEC_ADD5,
    input wire [5:0]RWL_DEC_ADD6,
    input wire [5:0]RWL_DEC_ADD7,
    input wire [5:0]RWL_DEC_ADD8,
    input wire [5:0]RWL_DEC_ADD9,
    input wire [5:0]RWL_DEC_ADD10,
    input wire [5:0]RWL_DEC_ADD11,
    input wire [5:0]RWL_DEC_ADD12,
    input wire [5:0]RWL_DEC_ADD13,
    input wire [5:0]RWL_DEC_ADD14,
    input wire [5:0]RWL_DEC_ADD15,
    input wire [5:0]RWL_DEC_ADD16,
    input wire [1:0]DEMUX_ADD1,
    input wire [1:0]DEMUX_ADD2,
    input wire [1:0]DEMUX_ADD3,
    input wire [1:0]DEMUX_ADD4,
    input wire [1:0]DEMUX_ADD5,
    input wire [1:0]DEMUX_ADD6,
    input wire [1:0]DEMUX_ADD7,
    input wire [1:0]DEMUX_ADD8,
    input wire [1:0]DEMUX_ADD9,
    input wire [1:0]DEMUX_ADD10,
    input wire [1:0]DEMUX_ADD11,
    input wire [1:0]DEMUX_ADD12,
    input wire [1:0]DEMUX_ADD13,
    input wire [1:0]DEMUX_ADD14,
    input wire [1:0]DEMUX_ADD15,
    input wire [1:0]DEMUX_ADD16,
    input wire DEMUX_ADD_3,
    output reg [7:0] DRAM_DATA_OUT1, // DRAM_DATA_OUT = DRAM_data DRAM数据读出
    output reg [7:0] DRAM_DATA_OUT2, // 16块芯片的数据读出
    output reg [7:0] DRAM_DATA_OUT3,
    output reg [7:0] DRAM_DATA_OUT4,
    output reg [7:0] DRAM_DATA_OUT5,
    output reg [7:0] DRAM_DATA_OUT6,
    output reg [7:0] DRAM_DATA_OUT7,
    output reg [7:0] DRAM_DATA_OUT8,
    output reg [7:0] DRAM_DATA_OUT9,
    output reg [7:0] DRAM_DATA_OUT10,
    output reg [7:0] DRAM_DATA_OUT11,
    output reg [7:0] DRAM_DATA_OUT12,
    output reg [7:0] DRAM_DATA_OUT13,
    output reg [7:0] DRAM_DATA_OUT14,
    output reg [7:0] DRAM_DATA_OUT15,
    output reg [7:0] DRAM_DATA_OUT16,
    output reg RD_DONE, // DRAM_DATA_OUT done信号
    output reg WT_DONE, // DRAM写入完成done信号
    // DRAM_IO
    // IO数据DRAM➡FPGA
    // input wire [8:1] DRAM_data, // 单芯片
    input wire [16:1] DRAM16_data, // 16块芯片通过并转串输出
    output wire [2:0]PC_data,      /// PC并转串控制信号 PC[0]=clk PC[1]=SR/LD# PC[2]=CLK_INV
    // IO控制FPGA➡DRAM
    output reg ADD_IN,            // ADD_IN // WWL_ADD 输入 自带CP 1 to 6
    output reg ADD_VALID_IN,      // A_VALID// WWL_ADD_VALID 输入地址使能
    output reg [1:0]PC_D_IN,      /// D_IN 的串转并控制信号 PC_D_IN[1]为rst_n  PC_D_IN[0]为移位时钟
    output reg [16:1]D_IN,        /// D_IN[1:16] // 16块芯片的DATA_I
    output reg DATA_VALID_IN,     // D_VALIDv// WBL 输入数据使能
    output wire clk_out,           // 相当于带使能的100MHz时钟
    output reg WRI_EN,            // WRI_EN 写使能
    output reg [16:1]R_AD,        ///R_AD 读/算地址 串转并后高两位是DE_ADD0 1
    output reg [1:0]PC_R_AD,      ///R_AD 的串转并控制信号
    output wire [16:1]LIM_IN,     /// LIM输入 16块芯片的算输入数据
    output wire [1:0] LIM_SEL,    /// LIM_SEL 存算模式选择
    output wire DE_ADD3,           /// DE_ADD3
    output wire RD_EN,         // 读使能 RWL_EN
    output wire VSAEN,
    output reg REF_WWL
    );
    // generate clock
    // wire clk_400m;
    // wire clk_100m;
    // clk_wiz_400m u_clk_wiz_400m(
    //     .clk_400m(clk_400m),
    //     .clk_100m(clk_100m),
    //     .clk(clk)
    // );
    //
    

    
    // 100Mhz时钟下输入寄存
    reg [1:0]       IO_MODEL_nr1     ;    // 01写, 10读
    reg [1:0]      CIM_model_nr1    ;    // 存算模式选择
    reg [16:1]       DATA_IN_nr1      ;    // LIM_IN, LIM输入 16块芯片的算输入数据
    reg [63:0]  WBL_DATA_IN1_nr1 ;
    reg [63:0]  WBL_DATA_IN2_nr1 ;
    reg [63:0]  WBL_DATA_IN3_nr1 ;
    reg [63:0]  WBL_DATA_IN4_nr1 ;
    reg [63:0]  WBL_DATA_IN5_nr1 ;
    reg [63:0]  WBL_DATA_IN6_nr1 ;
    reg [63:0]  WBL_DATA_IN7_nr1 ;
    reg [63:0]  WBL_DATA_IN8_nr1 ;
    reg [63:0]  WBL_DATA_IN9_nr1 ;
    reg [63:0] WBL_DATA_IN10_nr1;
    reg [63:0] WBL_DATA_IN11_nr1;
    reg [63:0] WBL_DATA_IN12_nr1;
    reg [63:0] WBL_DATA_IN13_nr1;
    reg [63:0] WBL_DATA_IN14_nr1;
    reg [63:0] WBL_DATA_IN15_nr1;
    reg [63:0] WBL_DATA_IN16_nr1;
    reg [5:0]        WWL_ADD_nr1      ;
    reg [5:0]   RWL_DEC_ADD1_nr1 ;
    reg [5:0]   RWL_DEC_ADD2_nr1 ;
    reg [5:0]   RWL_DEC_ADD3_nr1 ;
    reg [5:0]   RWL_DEC_ADD4_nr1 ;
    reg [5:0]   RWL_DEC_ADD5_nr1 ;
    reg [5:0]   RWL_DEC_ADD6_nr1 ;
    reg [5:0]   RWL_DEC_ADD7_nr1 ;
    reg [5:0]   RWL_DEC_ADD8_nr1 ;
    reg [5:0]   RWL_DEC_ADD9_nr1 ;
    reg [5:0]  RWL_DEC_ADD10_nr1;
    reg [5:0]  RWL_DEC_ADD11_nr1;
    reg [5:0]  RWL_DEC_ADD12_nr1;
    reg [5:0]  RWL_DEC_ADD13_nr1;
    reg [5:0]  RWL_DEC_ADD14_nr1;
    reg [5:0]  RWL_DEC_ADD15_nr1;
    reg [5:0]  RWL_DEC_ADD16_nr1;
    reg [1:0]     DEMUX_ADD1_nr1   ;
    reg [1:0]     DEMUX_ADD2_nr1   ;
    reg [1:0]     DEMUX_ADD3_nr1   ;
    reg [1:0]     DEMUX_ADD4_nr1   ;
    reg [1:0]     DEMUX_ADD5_nr1   ;
    reg [1:0]     DEMUX_ADD6_nr1   ;
    reg [1:0]     DEMUX_ADD7_nr1   ;
    reg [1:0]     DEMUX_ADD8_nr1   ;
    reg [1:0]     DEMUX_ADD9_nr1   ;
    reg [1:0]    DEMUX_ADD10_nr1  ;
    reg [1:0]    DEMUX_ADD11_nr1  ;
    reg [1:0]    DEMUX_ADD12_nr1  ;
    reg [1:0]    DEMUX_ADD13_nr1  ;
    reg [1:0]    DEMUX_ADD14_nr1  ;
    reg [1:0]    DEMUX_ADD15_nr1  ;
    reg [1:0]    DEMUX_ADD16_nr1  ;
    reg          DEMUX_ADD_3_nr1  ;
    reg                IO_EN_nr1;
    // 400MHz域输出寄存以及100MHz域两级同步寄存
    reg [7:0] DRAM_DATA_OUT1_r;  reg [7:0] DRAM_DATA_OUT2_r;  reg [7:0] DRAM_DATA_OUT3_r;  reg [7:0] DRAM_DATA_OUT4_r;
    reg [7:0] DRAM_DATA_OUT5_r;  reg [7:0] DRAM_DATA_OUT6_r;  reg [7:0] DRAM_DATA_OUT7_r;  reg [7:0] DRAM_DATA_OUT8_r;
    reg [7:0] DRAM_DATA_OUT9_r;  reg [7:0] DRAM_DATA_OUT10_r; reg [7:0] DRAM_DATA_OUT11_r; reg [7:0] DRAM_DATA_OUT12_r;
    reg [7:0] DRAM_DATA_OUT13_r; reg [7:0] DRAM_DATA_OUT14_r; reg [7:0] DRAM_DATA_OUT15_r; reg [7:0] DRAM_DATA_OUT16_r;
    reg       RD_DONE_r; reg WT_DONE_r;
    reg [7:0] DRAM_DATA_OUT1_nr1;  reg [7:0] DRAM_DATA_OUT2_nr1;  reg [7:0] DRAM_DATA_OUT3_nr1;  reg [7:0] DRAM_DATA_OUT4_nr1;
    reg [7:0] DRAM_DATA_OUT5_nr1;  reg [7:0] DRAM_DATA_OUT6_nr1;  reg [7:0] DRAM_DATA_OUT7_nr1;  reg [7:0] DRAM_DATA_OUT8_nr1;
    reg [7:0] DRAM_DATA_OUT9_nr1;  reg [7:0] DRAM_DATA_OUT10_nr1; reg [7:0] DRAM_DATA_OUT11_nr1; reg [7:0] DRAM_DATA_OUT12_nr1;
    reg [7:0] DRAM_DATA_OUT13_nr1; reg [7:0] DRAM_DATA_OUT14_nr1; reg [7:0] DRAM_DATA_OUT15_nr1; reg [7:0] DRAM_DATA_OUT16_nr1;
    reg       RD_DONE_nr1; reg WT_DONE_nr1;
    always @( posedge clk_100m or negedge rst_n) begin
        if (!rst_n) begin
                IO_MODEL_nr1      <= 2'b00;
                CIM_model_nr1     <= 2'b00;
                DATA_IN_nr1       <= 16'b0;
                WBL_DATA_IN1_nr1  <= 64'b0;
                WBL_DATA_IN2_nr1  <= 64'b0;
                WBL_DATA_IN3_nr1  <= 64'b0;
                WBL_DATA_IN4_nr1  <= 64'b0;
                WBL_DATA_IN5_nr1  <= 64'b0;
                WBL_DATA_IN6_nr1  <= 64'b0;
                WBL_DATA_IN7_nr1  <= 64'b0;
                WBL_DATA_IN8_nr1  <= 64'b0;
                WBL_DATA_IN9_nr1  <= 64'b0;
                WBL_DATA_IN10_nr1 <= 64'b0;
                WBL_DATA_IN11_nr1 <= 64'b0;
                WBL_DATA_IN12_nr1 <= 64'b0;
                WBL_DATA_IN13_nr1 <= 64'b0;
                WBL_DATA_IN14_nr1 <= 64'b0;
                WBL_DATA_IN15_nr1 <= 64'b0;
                WBL_DATA_IN16_nr1 <= 64'b0;
                WWL_ADD_nr1       <= 6'b0;
                RWL_DEC_ADD1_nr1  <= 6'b0;
                RWL_DEC_ADD2_nr1  <= 6'b0;
                RWL_DEC_ADD3_nr1  <= 6'b0;
                RWL_DEC_ADD4_nr1  <= 6'b0;
                RWL_DEC_ADD5_nr1  <= 6'b0;
                RWL_DEC_ADD6_nr1  <= 6'b0;
                RWL_DEC_ADD7_nr1  <= 6'b0;
                RWL_DEC_ADD8_nr1  <= 6'b0;
                RWL_DEC_ADD9_nr1  <= 6'b0;
                RWL_DEC_ADD10_nr1 <= 6'b0;
                RWL_DEC_ADD11_nr1 <= 6'b0;
                RWL_DEC_ADD12_nr1 <= 6'b0;
                RWL_DEC_ADD13_nr1 <= 6'b0;
                RWL_DEC_ADD14_nr1 <= 6'b0;
                RWL_DEC_ADD15_nr1 <= 6'b0;
                RWL_DEC_ADD16_nr1 <= 6'b0;
                DEMUX_ADD1_nr1    <= 2'b0;
                DEMUX_ADD2_nr1    <= 2'b0;
                DEMUX_ADD3_nr1    <= 2'b0;
                DEMUX_ADD4_nr1    <= 2'b0;
                DEMUX_ADD5_nr1    <= 2'b0;
                DEMUX_ADD6_nr1    <= 2'b0;
                DEMUX_ADD7_nr1    <= 2'b0;
                DEMUX_ADD8_nr1    <= 2'b0;
                DEMUX_ADD9_nr1    <= 2'b0;
                DEMUX_ADD10_nr1   <= 2'b0;
                DEMUX_ADD11_nr1   <= 2'b0;
                DEMUX_ADD12_nr1   <= 2'b0;
                DEMUX_ADD13_nr1   <= 2'b0;
                DEMUX_ADD14_nr1   <= 2'b0;
                DEMUX_ADD15_nr1   <= 2'b0;
                DEMUX_ADD16_nr1   <= 2'b0;
                DEMUX_ADD_3_nr1   <= 1'b0;
                // IO_EN_nr1         <= 1'b0;
        end
        else if (IO_EN) begin //已经输入寄存了
                // IO_EN_nr1         <= 1'b1 ;
                IO_MODEL_nr1      <= IO_MODEL;
                CIM_model_nr1     <= CIM_model;
                DATA_IN_nr1       <= DATA_IN;
                WBL_DATA_IN1_nr1  <= WBL_DATA_IN1;
                WBL_DATA_IN2_nr1  <= WBL_DATA_IN2;
                WBL_DATA_IN3_nr1  <= WBL_DATA_IN3;
                WBL_DATA_IN4_nr1  <= WBL_DATA_IN4;
                WBL_DATA_IN5_nr1  <= WBL_DATA_IN5;
                WBL_DATA_IN6_nr1  <= WBL_DATA_IN6;
                WBL_DATA_IN7_nr1  <= WBL_DATA_IN7;
                WBL_DATA_IN8_nr1  <= WBL_DATA_IN8;
                WBL_DATA_IN9_nr1  <= WBL_DATA_IN9;
                WBL_DATA_IN10_nr1 <= WBL_DATA_IN10;
                WBL_DATA_IN11_nr1 <= WBL_DATA_IN11;
                WBL_DATA_IN12_nr1 <= WBL_DATA_IN12;
                WBL_DATA_IN13_nr1 <= WBL_DATA_IN13;
                WBL_DATA_IN14_nr1 <= WBL_DATA_IN14;
                WBL_DATA_IN15_nr1 <= WBL_DATA_IN15;
                WBL_DATA_IN16_nr1 <= WBL_DATA_IN16;
                WWL_ADD_nr1       <= WWL_ADD;
                RWL_DEC_ADD1_nr1  <= RWL_DEC_ADD1;
                RWL_DEC_ADD2_nr1  <= RWL_DEC_ADD2;
                RWL_DEC_ADD3_nr1  <= RWL_DEC_ADD3;
                RWL_DEC_ADD4_nr1  <= RWL_DEC_ADD4;
                RWL_DEC_ADD5_nr1  <= RWL_DEC_ADD5;
                RWL_DEC_ADD6_nr1  <= RWL_DEC_ADD6;
                RWL_DEC_ADD7_nr1  <= RWL_DEC_ADD7;
                RWL_DEC_ADD8_nr1  <= RWL_DEC_ADD8;
                RWL_DEC_ADD9_nr1  <= RWL_DEC_ADD9;
                RWL_DEC_ADD10_nr1 <= RWL_DEC_ADD10;
                RWL_DEC_ADD11_nr1 <= RWL_DEC_ADD11;
                RWL_DEC_ADD12_nr1 <= RWL_DEC_ADD12;
                RWL_DEC_ADD13_nr1 <= RWL_DEC_ADD13;
                RWL_DEC_ADD14_nr1 <= RWL_DEC_ADD14;
                RWL_DEC_ADD15_nr1 <= RWL_DEC_ADD15;
                RWL_DEC_ADD16_nr1 <= RWL_DEC_ADD16;
                DEMUX_ADD1_nr1    <= DEMUX_ADD1;
                DEMUX_ADD2_nr1    <= DEMUX_ADD2;
                DEMUX_ADD3_nr1    <= DEMUX_ADD3;
                DEMUX_ADD4_nr1    <= DEMUX_ADD4;
                DEMUX_ADD5_nr1    <= DEMUX_ADD5;
                DEMUX_ADD6_nr1    <= DEMUX_ADD6;
                DEMUX_ADD7_nr1    <= DEMUX_ADD7;
                DEMUX_ADD8_nr1    <= DEMUX_ADD8;
                DEMUX_ADD9_nr1    <= DEMUX_ADD9;
                DEMUX_ADD10_nr1   <= DEMUX_ADD10;
                DEMUX_ADD11_nr1   <= DEMUX_ADD11;
                DEMUX_ADD12_nr1   <= DEMUX_ADD12;
                DEMUX_ADD13_nr1   <= DEMUX_ADD13;
                DEMUX_ADD14_nr1   <= DEMUX_ADD14;
                DEMUX_ADD15_nr1   <= DEMUX_ADD15;
                DEMUX_ADD16_nr1   <= DEMUX_ADD16;
                DEMUX_ADD_3_nr1   <= DEMUX_ADD_3;           
        end
    end
    always @( posedge clk_100m or negedge rst_n) begin
        if (!rst_n) begin
                IO_EN_nr1         <= 1'b0;
        end
        else begin
                IO_EN_nr1         <= IO_EN ;
        end
    end
    // 400Mhz时钟下的第一拍
    reg [1:0]  IO_MODEL_nr2     ;    // 01写, 10读
    reg [1:0]  CIM_model_nr2    ;    // 存算模式选择
    reg [16:1] DATA_IN_nr2      ;    // LIM_IN, LIM输入 16块芯片的算输入数据
    reg [63:0] WBL_DATA_IN1_nr2 ;
    reg [63:0] WBL_DATA_IN2_nr2 ;
    reg [63:0] WBL_DATA_IN3_nr2 ;
    reg [63:0] WBL_DATA_IN4_nr2 ;
    reg [63:0] WBL_DATA_IN5_nr2 ;
    reg [63:0] WBL_DATA_IN6_nr2 ;
    reg [63:0] WBL_DATA_IN7_nr2 ;
    reg [63:0] WBL_DATA_IN8_nr2 ;
    reg [63:0] WBL_DATA_IN9_nr2 ;
    reg [63:0] WBL_DATA_IN10_nr2;
    reg [63:0] WBL_DATA_IN11_nr2;
    reg [63:0] WBL_DATA_IN12_nr2;
    reg [63:0] WBL_DATA_IN13_nr2;
    reg [63:0] WBL_DATA_IN14_nr2;
    reg [63:0] WBL_DATA_IN15_nr2;
    reg [63:0] WBL_DATA_IN16_nr2;
    reg [5:0]  WWL_ADD_nr2      ;
    reg [5:0]  RWL_DEC_ADD1_nr2 ;
    reg [5:0]  RWL_DEC_ADD2_nr2 ;
    reg [5:0]  RWL_DEC_ADD3_nr2 ;
    reg [5:0]  RWL_DEC_ADD4_nr2 ;
    reg [5:0]  RWL_DEC_ADD5_nr2 ;
    reg [5:0]  RWL_DEC_ADD6_nr2 ;
    reg [5:0]  RWL_DEC_ADD7_nr2 ;
    reg [5:0]  RWL_DEC_ADD8_nr2 ;
    reg [5:0]  RWL_DEC_ADD9_nr2 ;
    reg [5:0]  RWL_DEC_ADD10_nr2;
    reg [5:0]  RWL_DEC_ADD11_nr2;
    reg [5:0]  RWL_DEC_ADD12_nr2;
    reg [5:0]  RWL_DEC_ADD13_nr2;
    reg [5:0]  RWL_DEC_ADD14_nr2;
    reg [5:0]  RWL_DEC_ADD15_nr2;
    reg [5:0]  RWL_DEC_ADD16_nr2;
    reg [1:0]  DEMUX_ADD1_nr2   ;
    reg [1:0]  DEMUX_ADD2_nr2   ;
    reg [1:0]  DEMUX_ADD3_nr2   ;
    reg [1:0]  DEMUX_ADD4_nr2   ;
    reg [1:0]  DEMUX_ADD5_nr2   ;
    reg [1:0]  DEMUX_ADD6_nr2   ;
    reg [1:0]  DEMUX_ADD7_nr2   ;
    reg [1:0]  DEMUX_ADD8_nr2   ;
    reg [1:0]  DEMUX_ADD9_nr2   ;
    reg [1:0]  DEMUX_ADD10_nr2  ;
    reg [1:0]  DEMUX_ADD11_nr2  ;
    reg [1:0]  DEMUX_ADD12_nr2  ;
    reg [1:0]  DEMUX_ADD13_nr2  ;
    reg [1:0]  DEMUX_ADD14_nr2  ;
    reg [1:0]  DEMUX_ADD15_nr2  ;
    reg [1:0]  DEMUX_ADD16_nr2  ;
    reg        DEMUX_ADD_3_nr2  ;
    reg        IO_EN_nr2        ;
    // 400Mhz时钟下的第二拍
    reg IO_EN_FLAG; // stay 1 while working
    (*dont_touch="yes"*)reg [12:0]  counter_work;
    reg IO_EN_r;
    reg [1:0]  IO_MODEL_r     ;    // 01写, 10读
    reg [1:0]  CIM_model_r    ;    // 存算模式选择
    reg [16:1] DATA_IN_r      ;    // LIM_IN, LIM输入 16块芯片的算输入数据
    reg [63:0] WBL_DATA_IN1_r ;
    reg [63:0] WBL_DATA_IN2_r ;
    reg [63:0] WBL_DATA_IN3_r ;
    reg [63:0] WBL_DATA_IN4_r ;
    reg [63:0] WBL_DATA_IN5_r ;
    reg [63:0] WBL_DATA_IN6_r ;
    reg [63:0] WBL_DATA_IN7_r ;
    reg [63:0] WBL_DATA_IN8_r ;
    reg [63:0] WBL_DATA_IN9_r ;
    reg [63:0] WBL_DATA_IN10_r;
    reg [63:0] WBL_DATA_IN11_r;
    reg [63:0] WBL_DATA_IN12_r;
    reg [63:0] WBL_DATA_IN13_r;
    reg [63:0] WBL_DATA_IN14_r;
    reg [63:0] WBL_DATA_IN15_r;
    reg [63:0] WBL_DATA_IN16_r;
    reg [5:0]  WWL_ADD_r      ;
    reg [5:0]  RWL_DEC_ADD1_r ;
    reg [5:0]  RWL_DEC_ADD2_r ;
    reg [5:0]  RWL_DEC_ADD3_r ;
    reg [5:0]  RWL_DEC_ADD4_r ;
    reg [5:0]  RWL_DEC_ADD5_r ;
    reg [5:0]  RWL_DEC_ADD6_r ;
    reg [5:0]  RWL_DEC_ADD7_r ;
    reg [5:0]  RWL_DEC_ADD8_r ;
    reg [5:0]  RWL_DEC_ADD9_r ;
    reg [5:0]  RWL_DEC_ADD10_r;
    reg [5:0]  RWL_DEC_ADD11_r;
    reg [5:0]  RWL_DEC_ADD12_r;
    reg [5:0]  RWL_DEC_ADD13_r;
    reg [5:0]  RWL_DEC_ADD14_r;
    reg [5:0]  RWL_DEC_ADD15_r;
    reg [5:0]  RWL_DEC_ADD16_r;
    reg [1:0]  DEMUX_ADD1_r   ;
    reg [1:0]  DEMUX_ADD2_r   ;
    reg [1:0]  DEMUX_ADD3_r   ;
    reg [1:0]  DEMUX_ADD4_r   ;
    reg [1:0]  DEMUX_ADD5_r   ;
    reg [1:0]  DEMUX_ADD6_r   ;
    reg [1:0]  DEMUX_ADD7_r   ;
    reg [1:0]  DEMUX_ADD8_r   ;
    reg [1:0]  DEMUX_ADD9_r   ;
    reg [1:0]  DEMUX_ADD10_r  ;
    reg [1:0]  DEMUX_ADD11_r  ;
    reg [1:0]  DEMUX_ADD12_r  ;
    reg [1:0]  DEMUX_ADD13_r  ;
    reg [1:0]  DEMUX_ADD14_r  ;
    reg [1:0]  DEMUX_ADD15_r  ;
    reg [1:0]  DEMUX_ADD16_r  ;
    reg        DEMUX_ADD_3_r  ;
    always @( posedge clk_400m or negedge rst_n) begin
        if (!rst_n) begin
                IO_EN_nr2         <= 1'b0;
                IO_EN_r           <= 1'b0;
        end
        else begin
                IO_EN_nr2         <= IO_EN_nr1;
                IO_EN_r           <= IO_EN_nr2;
        end
    end    
    always @(posedge clk_400m or negedge rst_n)begin
        if(!rst_n)begin 
            IO_MODEL_r     <= 2'b00;IO_MODEL_nr2      <= 2'b00;
            CIM_model_r    <= 2'b00;CIM_model_nr2     <= 2'b00;
            DATA_IN_r      <= 16'b0;DATA_IN_nr2       <= 16'b0;
            WBL_DATA_IN1_r <= 64'b0;WBL_DATA_IN1_nr2  <= 64'b0;
            WBL_DATA_IN2_r <= 64'b0;WBL_DATA_IN2_nr2  <= 64'b0;
            WBL_DATA_IN3_r <= 64'b0;WBL_DATA_IN3_nr2  <= 64'b0;
            WBL_DATA_IN4_r <= 64'b0;WBL_DATA_IN4_nr2  <= 64'b0;
            WBL_DATA_IN5_r <= 64'b0;WBL_DATA_IN5_nr2  <= 64'b0;
            WBL_DATA_IN6_r <= 64'b0;WBL_DATA_IN6_nr2  <= 64'b0;
            WBL_DATA_IN7_r <= 64'b0;WBL_DATA_IN7_nr2  <= 64'b0;
            WBL_DATA_IN8_r <= 64'b0;WBL_DATA_IN8_nr2  <= 64'b0;
            WBL_DATA_IN9_r <= 64'b0;WBL_DATA_IN9_nr2  <= 64'b0;
            WBL_DATA_IN10_r<= 64'b0;WBL_DATA_IN10_nr2 <= 64'b0;
            WBL_DATA_IN11_r<= 64'b0;WBL_DATA_IN11_nr2 <= 64'b0;
            WBL_DATA_IN12_r<= 64'b0;WBL_DATA_IN12_nr2 <= 64'b0;
            WBL_DATA_IN13_r<= 64'b0;WBL_DATA_IN13_nr2 <= 64'b0;
            WBL_DATA_IN14_r<= 64'b0;WBL_DATA_IN14_nr2 <= 64'b0;
            WBL_DATA_IN15_r<= 64'b0;WBL_DATA_IN15_nr2 <= 64'b0;
            WBL_DATA_IN16_r<= 64'b0;WBL_DATA_IN16_nr2 <= 64'b0;
            WWL_ADD_r      <= 6'b0; WWL_ADD_nr2       <= 6'b0; 
            RWL_DEC_ADD1_r <= 6'b0; RWL_DEC_ADD1_nr2  <= 6'b0; 
            RWL_DEC_ADD2_r <= 6'b0; RWL_DEC_ADD2_nr2  <= 6'b0; 
            RWL_DEC_ADD3_r <= 6'b0; RWL_DEC_ADD3_nr2  <= 6'b0; 
            RWL_DEC_ADD4_r <= 6'b0; RWL_DEC_ADD4_nr2  <= 6'b0; 
            RWL_DEC_ADD5_r <= 6'b0; RWL_DEC_ADD5_nr2  <= 6'b0; 
            RWL_DEC_ADD6_r <= 6'b0; RWL_DEC_ADD6_nr2  <= 6'b0; 
            RWL_DEC_ADD7_r <= 6'b0; RWL_DEC_ADD7_nr2  <= 6'b0; 
            RWL_DEC_ADD8_r <= 6'b0; RWL_DEC_ADD8_nr2  <= 6'b0; 
            RWL_DEC_ADD9_r <= 6'b0; RWL_DEC_ADD9_nr2  <= 6'b0; 
            RWL_DEC_ADD10_r<= 6'b0; RWL_DEC_ADD10_nr2 <= 6'b0; 
            RWL_DEC_ADD11_r<= 6'b0; RWL_DEC_ADD11_nr2 <= 6'b0; 
            RWL_DEC_ADD12_r<= 6'b0; RWL_DEC_ADD12_nr2 <= 6'b0; 
            RWL_DEC_ADD13_r<= 6'b0; RWL_DEC_ADD13_nr2 <= 6'b0; 
            RWL_DEC_ADD14_r<= 6'b0; RWL_DEC_ADD14_nr2 <= 6'b0; 
            RWL_DEC_ADD15_r<= 6'b0; RWL_DEC_ADD15_nr2 <= 6'b0; 
            RWL_DEC_ADD16_r<= 6'b0; RWL_DEC_ADD16_nr2 <= 6'b0; 
            DEMUX_ADD1_r   <= 2'b0; DEMUX_ADD1_nr2    <= 2'b0; 
            DEMUX_ADD2_r   <= 2'b0; DEMUX_ADD2_nr2    <= 2'b0; 
            DEMUX_ADD3_r   <= 2'b0; DEMUX_ADD3_nr2    <= 2'b0; 
            DEMUX_ADD4_r   <= 2'b0; DEMUX_ADD4_nr2    <= 2'b0; 
            DEMUX_ADD5_r   <= 2'b0; DEMUX_ADD5_nr2    <= 2'b0; 
            DEMUX_ADD6_r   <= 2'b0; DEMUX_ADD6_nr2    <= 2'b0; 
            DEMUX_ADD7_r   <= 2'b0; DEMUX_ADD7_nr2    <= 2'b0; 
            DEMUX_ADD8_r   <= 2'b0; DEMUX_ADD8_nr2    <= 2'b0; 
            DEMUX_ADD9_r   <= 2'b0; DEMUX_ADD9_nr2    <= 2'b0; 
            DEMUX_ADD10_r  <= 2'b0; DEMUX_ADD10_nr2   <= 2'b0; 
            DEMUX_ADD11_r  <= 2'b0; DEMUX_ADD11_nr2   <= 2'b0; 
            DEMUX_ADD12_r  <= 2'b0; DEMUX_ADD12_nr2   <= 2'b0; 
            DEMUX_ADD13_r  <= 2'b0; DEMUX_ADD13_nr2   <= 2'b0; 
            DEMUX_ADD14_r  <= 2'b0; DEMUX_ADD14_nr2   <= 2'b0; 
            DEMUX_ADD15_r  <= 2'b0; DEMUX_ADD15_nr2   <= 2'b0; 
            DEMUX_ADD16_r  <= 2'b0; DEMUX_ADD16_nr2   <= 2'b0; 
            DEMUX_ADD_3_r  <= 1'b0; DEMUX_ADD_3_nr2   <= 1'b0; 
        end
        else begin
                IO_MODEL_r     <= IO_MODEL_nr2     ;IO_MODEL_nr2      <=IO_MODEL_nr1      ;
                CIM_model_r    <= CIM_model_nr2    ;CIM_model_nr2     <=CIM_model_nr1     ; 
                DATA_IN_r      <= DATA_IN_nr2      ;DATA_IN_nr2       <=DATA_IN_nr1       ; 
                WBL_DATA_IN1_r <= WBL_DATA_IN1_nr2 ;WBL_DATA_IN1_nr2  <=WBL_DATA_IN1_nr1  ;
                WBL_DATA_IN2_r <= WBL_DATA_IN2_nr2 ;WBL_DATA_IN2_nr2  <=WBL_DATA_IN2_nr1  ;
                WBL_DATA_IN3_r <= WBL_DATA_IN3_nr2 ;WBL_DATA_IN3_nr2  <=WBL_DATA_IN3_nr1  ;
                WBL_DATA_IN4_r <= WBL_DATA_IN4_nr2 ;WBL_DATA_IN4_nr2  <=WBL_DATA_IN4_nr1  ;
                WBL_DATA_IN5_r <= WBL_DATA_IN5_nr2 ;WBL_DATA_IN5_nr2  <=WBL_DATA_IN5_nr1  ;
                WBL_DATA_IN6_r <= WBL_DATA_IN6_nr2 ;WBL_DATA_IN6_nr2  <=WBL_DATA_IN6_nr1  ;
                WBL_DATA_IN7_r <= WBL_DATA_IN7_nr2 ;WBL_DATA_IN7_nr2  <=WBL_DATA_IN7_nr1  ;
                WBL_DATA_IN8_r <= WBL_DATA_IN8_nr2 ;WBL_DATA_IN8_nr2  <=WBL_DATA_IN8_nr1  ;
                WBL_DATA_IN9_r <= WBL_DATA_IN9_nr2 ;WBL_DATA_IN9_nr2  <=WBL_DATA_IN9_nr1  ;
                WBL_DATA_IN10_r<= WBL_DATA_IN10_nr2;WBL_DATA_IN10_nr2 <=WBL_DATA_IN10_nr1 ;
                WBL_DATA_IN11_r<= WBL_DATA_IN11_nr2;WBL_DATA_IN11_nr2 <=WBL_DATA_IN11_nr1 ;
                WBL_DATA_IN12_r<= WBL_DATA_IN12_nr2;WBL_DATA_IN12_nr2 <=WBL_DATA_IN12_nr1 ;
                WBL_DATA_IN13_r<= WBL_DATA_IN13_nr2;WBL_DATA_IN13_nr2 <=WBL_DATA_IN13_nr1 ;
                WBL_DATA_IN14_r<= WBL_DATA_IN14_nr2;WBL_DATA_IN14_nr2 <=WBL_DATA_IN14_nr1 ;
                WBL_DATA_IN15_r<= WBL_DATA_IN15_nr2;WBL_DATA_IN15_nr2 <=WBL_DATA_IN15_nr1 ;
                WBL_DATA_IN16_r<= WBL_DATA_IN16_nr2;WBL_DATA_IN16_nr2 <=WBL_DATA_IN16_nr1 ;
                WWL_ADD_r      <= WWL_ADD_nr2      ;WWL_ADD_nr2       <=WWL_ADD_nr1       ;
                RWL_DEC_ADD1_r <= RWL_DEC_ADD1_nr2 ;RWL_DEC_ADD1_nr2  <=RWL_DEC_ADD1_nr1  ; 
                RWL_DEC_ADD2_r <= RWL_DEC_ADD2_nr2 ;RWL_DEC_ADD2_nr2  <=RWL_DEC_ADD2_nr1  ; 
                RWL_DEC_ADD3_r <= RWL_DEC_ADD3_nr2 ;RWL_DEC_ADD3_nr2  <=RWL_DEC_ADD3_nr1  ; 
                RWL_DEC_ADD4_r <= RWL_DEC_ADD4_nr2 ;RWL_DEC_ADD4_nr2  <=RWL_DEC_ADD4_nr1  ;
                RWL_DEC_ADD5_r <= RWL_DEC_ADD5_nr2 ;RWL_DEC_ADD5_nr2  <=RWL_DEC_ADD5_nr1  ; 
                RWL_DEC_ADD6_r <= RWL_DEC_ADD6_nr2 ;RWL_DEC_ADD6_nr2  <=RWL_DEC_ADD6_nr1  ; 
                RWL_DEC_ADD7_r <= RWL_DEC_ADD7_nr2 ;RWL_DEC_ADD7_nr2  <=RWL_DEC_ADD7_nr1  ; 
                RWL_DEC_ADD8_r <= RWL_DEC_ADD8_nr2 ;RWL_DEC_ADD8_nr2  <=RWL_DEC_ADD8_nr1  ; 
                RWL_DEC_ADD9_r <= RWL_DEC_ADD9_nr2 ;RWL_DEC_ADD9_nr2  <=RWL_DEC_ADD9_nr1  ; 
                RWL_DEC_ADD10_r<= RWL_DEC_ADD10_nr2;RWL_DEC_ADD10_nr2 <=RWL_DEC_ADD10_nr1 ;
                RWL_DEC_ADD11_r<= RWL_DEC_ADD11_nr2;RWL_DEC_ADD11_nr2 <=RWL_DEC_ADD11_nr1 ;
                RWL_DEC_ADD12_r<= RWL_DEC_ADD12_nr2;RWL_DEC_ADD12_nr2 <=RWL_DEC_ADD12_nr1 ;  
                RWL_DEC_ADD13_r<= RWL_DEC_ADD13_nr2;RWL_DEC_ADD13_nr2 <=RWL_DEC_ADD13_nr1 ;
                RWL_DEC_ADD14_r<= RWL_DEC_ADD14_nr2;RWL_DEC_ADD14_nr2 <=RWL_DEC_ADD14_nr1 ; 
                RWL_DEC_ADD15_r<= RWL_DEC_ADD15_nr2;RWL_DEC_ADD15_nr2 <=RWL_DEC_ADD15_nr1 ; 
                RWL_DEC_ADD16_r<= RWL_DEC_ADD16_nr2;RWL_DEC_ADD16_nr2 <=RWL_DEC_ADD16_nr1 ;
                DEMUX_ADD1_r   <= DEMUX_ADD1_nr2   ;DEMUX_ADD1_nr2    <=DEMUX_ADD1_nr1    ;  
                DEMUX_ADD2_r   <= DEMUX_ADD2_nr2   ;DEMUX_ADD2_nr2    <=DEMUX_ADD2_nr1    ; 
                DEMUX_ADD3_r   <= DEMUX_ADD3_nr2   ;DEMUX_ADD3_nr2    <=DEMUX_ADD3_nr1    ; 
                DEMUX_ADD4_r   <= DEMUX_ADD4_nr2   ;DEMUX_ADD4_nr2    <=DEMUX_ADD4_nr1    ; 
                DEMUX_ADD5_r   <= DEMUX_ADD5_nr2   ;DEMUX_ADD5_nr2    <=DEMUX_ADD5_nr1    ; 
                DEMUX_ADD6_r   <= DEMUX_ADD6_nr2   ;DEMUX_ADD6_nr2    <=DEMUX_ADD6_nr1    ; 
                DEMUX_ADD7_r   <= DEMUX_ADD7_nr2   ;DEMUX_ADD7_nr2    <=DEMUX_ADD7_nr1    ; 
                DEMUX_ADD8_r   <= DEMUX_ADD8_nr2   ;DEMUX_ADD8_nr2    <=DEMUX_ADD8_nr1    ; 
                DEMUX_ADD9_r   <= DEMUX_ADD9_nr2   ;DEMUX_ADD9_nr2    <=DEMUX_ADD9_nr1    ; 
                DEMUX_ADD10_r  <= DEMUX_ADD10_nr2  ;DEMUX_ADD10_nr2   <=DEMUX_ADD10_nr1   ; 
                DEMUX_ADD11_r  <= DEMUX_ADD11_nr2  ;DEMUX_ADD11_nr2   <=DEMUX_ADD11_nr1   ; 
                DEMUX_ADD12_r  <= DEMUX_ADD12_nr2  ;DEMUX_ADD12_nr2   <=DEMUX_ADD12_nr1   ; 
                DEMUX_ADD13_r  <= DEMUX_ADD13_nr2  ;DEMUX_ADD13_nr2   <=DEMUX_ADD13_nr1   ; 
                DEMUX_ADD14_r  <= DEMUX_ADD14_nr2  ;DEMUX_ADD14_nr2   <=DEMUX_ADD14_nr1   ; 
                DEMUX_ADD15_r  <= DEMUX_ADD15_nr2  ;DEMUX_ADD15_nr2   <=DEMUX_ADD15_nr1   ; 
                DEMUX_ADD16_r  <= DEMUX_ADD16_nr2  ;DEMUX_ADD16_nr2   <=DEMUX_ADD16_nr1   ; 
                DEMUX_ADD_3_r  <= DEMUX_ADD_3_nr2  ;DEMUX_ADD_3_nr2   <=DEMUX_ADD_3_nr1   ; 
        end
    end
    // 
    always @ (posedge clk_400m or negedge rst_n) begin
        if(!rst_n)begin 
            IO_EN_FLAG<=1'b0;
        end
        else begin
            if (IO_EN_r) begin
                IO_EN_FLAG <= 1'b1;
            end
            else begin
                // 写入数据
                if ( (counter_work >= 13'd3230) && (IO_MODEL_r == 2'b01) ) begin
                    IO_EN_FLAG <= 1'b0;
                end
                // 读出数据
                else if ( (counter_work >= 13'd636) && (IO_MODEL_r == 2'b10) ) begin
                    IO_EN_FLAG <= 1'b0;
                end
                else begin
                    IO_EN_FLAG <= IO_EN_FLAG;
                end
            end
        end
    end

    // 400MHz -> 100MHz 跨时钟域同步，打两拍
    always @(posedge clk_100m or negedge rst_n) begin
        if(!rst_n) begin
            DRAM_DATA_OUT1_nr1 <= 8'd0;  DRAM_DATA_OUT1 <= 8'd0;
            DRAM_DATA_OUT2_nr1 <= 8'd0;  DRAM_DATA_OUT2 <= 8'd0;
            DRAM_DATA_OUT3_nr1 <= 8'd0;  DRAM_DATA_OUT3 <= 8'd0;
            DRAM_DATA_OUT4_nr1 <= 8'd0;  DRAM_DATA_OUT4 <= 8'd0;
            DRAM_DATA_OUT5_nr1 <= 8'd0;  DRAM_DATA_OUT5 <= 8'd0;
            DRAM_DATA_OUT6_nr1 <= 8'd0;  DRAM_DATA_OUT6 <= 8'd0;
            DRAM_DATA_OUT7_nr1 <= 8'd0;  DRAM_DATA_OUT7 <= 8'd0;
            DRAM_DATA_OUT8_nr1 <= 8'd0;  DRAM_DATA_OUT8 <= 8'd0;
            DRAM_DATA_OUT9_nr1 <= 8'd0;  DRAM_DATA_OUT9 <= 8'd0;
            DRAM_DATA_OUT10_nr1 <= 8'd0; DRAM_DATA_OUT10 <= 8'd0;
            DRAM_DATA_OUT11_nr1 <= 8'd0; DRAM_DATA_OUT11 <= 8'd0;
            DRAM_DATA_OUT12_nr1 <= 8'd0; DRAM_DATA_OUT12 <= 8'd0;
            DRAM_DATA_OUT13_nr1 <= 8'd0; DRAM_DATA_OUT13 <= 8'd0;
            DRAM_DATA_OUT14_nr1 <= 8'd0; DRAM_DATA_OUT14 <= 8'd0;
            DRAM_DATA_OUT15_nr1 <= 8'd0; DRAM_DATA_OUT15 <= 8'd0;
            DRAM_DATA_OUT16_nr1 <= 8'd0; DRAM_DATA_OUT16 <= 8'd0;
            RD_DONE_nr1 <= 1'b0; RD_DONE <= 1'b0;
            WT_DONE_nr1 <= 1'b0; WT_DONE <= 1'b0;
        end else begin
            DRAM_DATA_OUT1_nr1 <= DRAM_DATA_OUT1_r;  DRAM_DATA_OUT1 <= DRAM_DATA_OUT1_nr1;
            DRAM_DATA_OUT2_nr1 <= DRAM_DATA_OUT2_r;  DRAM_DATA_OUT2 <= DRAM_DATA_OUT2_nr1;
            DRAM_DATA_OUT3_nr1 <= DRAM_DATA_OUT3_r;  DRAM_DATA_OUT3 <= DRAM_DATA_OUT3_nr1;
            DRAM_DATA_OUT4_nr1 <= DRAM_DATA_OUT4_r;  DRAM_DATA_OUT4 <= DRAM_DATA_OUT4_nr1;
            DRAM_DATA_OUT5_nr1 <= DRAM_DATA_OUT5_r;  DRAM_DATA_OUT5 <= DRAM_DATA_OUT5_nr1;
            DRAM_DATA_OUT6_nr1 <= DRAM_DATA_OUT6_r;  DRAM_DATA_OUT6 <= DRAM_DATA_OUT6_nr1;
            DRAM_DATA_OUT7_nr1 <= DRAM_DATA_OUT7_r;  DRAM_DATA_OUT7 <= DRAM_DATA_OUT7_nr1;
            DRAM_DATA_OUT8_nr1 <= DRAM_DATA_OUT8_r;  DRAM_DATA_OUT8 <= DRAM_DATA_OUT8_nr1;
            DRAM_DATA_OUT9_nr1 <= DRAM_DATA_OUT9_r;  DRAM_DATA_OUT9 <= DRAM_DATA_OUT9_nr1;
            DRAM_DATA_OUT10_nr1 <= DRAM_DATA_OUT10_r; DRAM_DATA_OUT10 <= DRAM_DATA_OUT10_nr1;
            DRAM_DATA_OUT11_nr1 <= DRAM_DATA_OUT11_r; DRAM_DATA_OUT11 <= DRAM_DATA_OUT11_nr1;
            DRAM_DATA_OUT12_nr1 <= DRAM_DATA_OUT12_r; DRAM_DATA_OUT12 <= DRAM_DATA_OUT12_nr1;
            DRAM_DATA_OUT13_nr1 <= DRAM_DATA_OUT13_r; DRAM_DATA_OUT13 <= DRAM_DATA_OUT13_nr1;
            DRAM_DATA_OUT14_nr1 <= DRAM_DATA_OUT14_r; DRAM_DATA_OUT14 <= DRAM_DATA_OUT14_nr1;
            DRAM_DATA_OUT15_nr1 <= DRAM_DATA_OUT15_r; DRAM_DATA_OUT15 <= DRAM_DATA_OUT15_nr1;
            DRAM_DATA_OUT16_nr1 <= DRAM_DATA_OUT16_r; DRAM_DATA_OUT16 <= DRAM_DATA_OUT16_nr1;
            RD_DONE_nr1 <= RD_DONE_r; RD_DONE <= RD_DONE_nr1;
            WT_DONE_nr1 <= WT_DONE_r; WT_DONE <= WT_DONE_nr1;
        end
    end
    assign DE_ADD3 = DEMUX_ADD3_r;
    always @(posedge clk_400m or negedge rst_n)begin
        if(!rst_n)begin 
            counter_work<=13'd0;
        end        
        else begin
            if (IO_EN_FLAG)begin
                counter_work <= counter_work + 1'b1;
            end
            else begin
                counter_work<=13'd0;
            end
        end
    end   
    reg clk_out_WT;
    assign clk_out = clk_out_WT;
    reg WR_flag;  // 写使能信号，写的时候为高电平
    // write data to DRAM (全展开 8 轮：起始位 0..7，每轮第一层移位 8 次，随后第二层一次脉冲)
    wire Write_en;
    assign Write_en = IO_EN_FLAG && (IO_MODEL_r == 2'b01); // 写使能信号，写的时候为高电平
    reg Write_en_r;
    always @ (posedge clk_400m or negedge rst_n) begin
        if(!rst_n)begin 
            Write_en_r <= 1'b0;
        end
        else begin
            Write_en_r <= Write_en;
        end
    end
    
    always @ (posedge clk_400m or negedge rst_n) begin
        if(!rst_n)begin 
            D_IN <= 16'd0; 
            PC_D_IN <= 2'd0;
            clk_out_WT <= 1'b0;
            DATA_VALID_IN<=1; 
            ADD_IN<=0; 
            ADD_VALID_IN<=1; 
            WRI_EN<=0; 
            WR_flag<=0; // DATA_VALID_IN 低电平有效
            WT_DONE_r <= 0;
        end
        else begin
            // if (IO_EN_FLAG && (IO_MODEL_r == 2'b01) ) begin
            if ( Write_en_r ) begin
                case(counter_work)
                // D_IN PC_D_IN
                // PC_D_IN[0] = CLK10M PC_D_IN[1] = CLR^(低位有效)
                // ================= 第 1 轮（索引 0,8,16,24,32,40,48,56） =================
                13'd0:   begin
                            D_IN <= 16'd0; PC_D_IN <= 2'd0; clk_out_WT <= 1'b0;
                            DATA_VALID_IN<=1; ADD_IN<=0; ADD_VALID_IN<=1; WRI_EN<=0;  WR_flag<=0; WT_DONE_r<=0;
                        end
                13'd1:   begin
                            DATA_VALID_IN<=1; ADD_IN<=0; ADD_VALID_IN<=1; WRI_EN<=0; WR_flag<=1;
                        end
                13'd2:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[0];
                            D_IN[2]  <= WBL_DATA_IN2_r[0];
                            D_IN[3]  <= WBL_DATA_IN3_r[0];
                            D_IN[4]  <= WBL_DATA_IN4_r[0];
                            D_IN[5]  <= WBL_DATA_IN5_r[0];
                            D_IN[6]  <= WBL_DATA_IN6_r[0];
                            D_IN[7]  <= WBL_DATA_IN7_r[0];
                            D_IN[8]  <= WBL_DATA_IN8_r[0];
                            D_IN[9]  <= WBL_DATA_IN9_r[0];
                            D_IN[10]  <= WBL_DATA_IN10_r[0];
                            D_IN[11]  <= WBL_DATA_IN11_r[0];
                            D_IN[12]  <= WBL_DATA_IN12_r[0];
                            D_IN[13]  <= WBL_DATA_IN13_r[0];
                            D_IN[14]  <= WBL_DATA_IN14_r[0];
                            D_IN[15]  <= WBL_DATA_IN15_r[0];
                            D_IN[16]  <= WBL_DATA_IN16_r[0];
                        end
                13'd20:  begin PC_D_IN[1] <= 1'b1; end // 取消复位
                13'd40:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd60:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[8];
                            D_IN[2]  <= WBL_DATA_IN2_r[8];
                            D_IN[3]  <= WBL_DATA_IN3_r[8];
                            D_IN[4]  <= WBL_DATA_IN4_r[8];
                            D_IN[5]  <= WBL_DATA_IN5_r[8];
                            D_IN[6]  <= WBL_DATA_IN6_r[8];
                            D_IN[7]  <= WBL_DATA_IN7_r[8];
                            D_IN[8]  <= WBL_DATA_IN8_r[8];
                            D_IN[9]  <= WBL_DATA_IN9_r[8];
                            D_IN[10]  <= WBL_DATA_IN10_r[8];
                            D_IN[11]  <= WBL_DATA_IN11_r[8];
                            D_IN[12]  <= WBL_DATA_IN12_r[8];
                            D_IN[13]  <= WBL_DATA_IN13_r[8];
                            D_IN[14]  <= WBL_DATA_IN14_r[8];
                            D_IN[15]  <= WBL_DATA_IN15_r[8];
                            D_IN[16]  <= WBL_DATA_IN16_r[8];
                        end
                13'd80:  begin PC_D_IN[0] <= 1'b1; end
                13'd100:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[16];
                            D_IN[2]  <= WBL_DATA_IN2_r[16];
                            D_IN[3]  <= WBL_DATA_IN3_r[16];
                            D_IN[4]  <= WBL_DATA_IN4_r[16];
                            D_IN[5]  <= WBL_DATA_IN5_r[16];
                            D_IN[6]  <= WBL_DATA_IN6_r[16];
                            D_IN[7]  <= WBL_DATA_IN7_r[16];
                            D_IN[8]  <= WBL_DATA_IN8_r[16];
                            D_IN[9]  <= WBL_DATA_IN9_r[16];
                            D_IN[10]  <= WBL_DATA_IN10_r[16];
                            D_IN[11]  <= WBL_DATA_IN11_r[16];
                            D_IN[12]  <= WBL_DATA_IN12_r[16];
                            D_IN[13]  <= WBL_DATA_IN13_r[16];
                            D_IN[14]  <= WBL_DATA_IN14_r[16];
                            D_IN[15]  <= WBL_DATA_IN15_r[16];
                            D_IN[16]  <= WBL_DATA_IN16_r[16];
                        end
                13'd120:  begin PC_D_IN[0] <= 1'b1; end
                13'd140:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[24];
                            D_IN[2]  <= WBL_DATA_IN2_r[24];
                            D_IN[3]  <= WBL_DATA_IN3_r[24];
                            D_IN[4]  <= WBL_DATA_IN4_r[24];
                            D_IN[5]  <= WBL_DATA_IN5_r[24];
                            D_IN[6]  <= WBL_DATA_IN6_r[24];
                            D_IN[7]  <= WBL_DATA_IN7_r[24];
                            D_IN[8]  <= WBL_DATA_IN8_r[24];
                            D_IN[9]  <= WBL_DATA_IN9_r[24];
                            D_IN[10]  <= WBL_DATA_IN10_r[24];
                            D_IN[11]  <= WBL_DATA_IN11_r[24];
                            D_IN[12]  <= WBL_DATA_IN12_r[24];
                            D_IN[13]  <= WBL_DATA_IN13_r[24];
                            D_IN[14]  <= WBL_DATA_IN14_r[24];
                            D_IN[15]  <= WBL_DATA_IN15_r[24];
                            D_IN[16]  <= WBL_DATA_IN16_r[24];
                        end
                13'd160:  begin PC_D_IN[0] <= 1'b1; end
                13'd180:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[32];
                            D_IN[2]  <= WBL_DATA_IN2_r[32];
                            D_IN[3]  <= WBL_DATA_IN3_r[32];
                            D_IN[4]  <= WBL_DATA_IN4_r[32];
                            D_IN[5]  <= WBL_DATA_IN5_r[32];
                            D_IN[6]  <= WBL_DATA_IN6_r[32];
                            D_IN[7]  <= WBL_DATA_IN7_r[32];
                            D_IN[8]  <= WBL_DATA_IN8_r[32];
                            D_IN[9]  <= WBL_DATA_IN9_r[32];
                            D_IN[10]  <= WBL_DATA_IN10_r[32];
                            D_IN[11]  <= WBL_DATA_IN11_r[32];
                            D_IN[12]  <= WBL_DATA_IN12_r[32];
                            D_IN[13]  <= WBL_DATA_IN13_r[32];
                            D_IN[14]  <= WBL_DATA_IN14_r[32];
                            D_IN[15]  <= WBL_DATA_IN15_r[32];
                            D_IN[16]  <= WBL_DATA_IN16_r[32];
                        end
                13'd200:  begin PC_D_IN[0] <= 1'b1; end
                13'd220:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[40];
                            D_IN[2]  <= WBL_DATA_IN2_r[40];
                            D_IN[3]  <= WBL_DATA_IN3_r[40];
                            D_IN[4]  <= WBL_DATA_IN4_r[40];
                            D_IN[5]  <= WBL_DATA_IN5_r[40];
                            D_IN[6]  <= WBL_DATA_IN6_r[40];
                            D_IN[7]  <= WBL_DATA_IN7_r[40];
                            D_IN[8]  <= WBL_DATA_IN8_r[40];
                            D_IN[9]  <= WBL_DATA_IN9_r[40];
                            D_IN[10]  <= WBL_DATA_IN10_r[40];
                            D_IN[11]  <= WBL_DATA_IN11_r[40];
                            D_IN[12]  <= WBL_DATA_IN12_r[40];
                            D_IN[13]  <= WBL_DATA_IN13_r[40];
                            D_IN[14]  <= WBL_DATA_IN14_r[40];
                            D_IN[15]  <= WBL_DATA_IN15_r[40];
                            D_IN[16]  <= WBL_DATA_IN16_r[40];
                        end
                13'd240:  begin PC_D_IN[0] <= 1'b1; end
                13'd260:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[48];
                            D_IN[2]  <= WBL_DATA_IN2_r[48];
                            D_IN[3]  <= WBL_DATA_IN3_r[48];
                            D_IN[4]  <= WBL_DATA_IN4_r[48];
                            D_IN[5]  <= WBL_DATA_IN5_r[48];
                            D_IN[6]  <= WBL_DATA_IN6_r[48];
                            D_IN[7]  <= WBL_DATA_IN7_r[48];
                            D_IN[8]  <= WBL_DATA_IN8_r[48];
                            D_IN[9]  <= WBL_DATA_IN9_r[48];
                            D_IN[10]  <= WBL_DATA_IN10_r[48];
                            D_IN[11]  <= WBL_DATA_IN11_r[48];
                            D_IN[12]  <= WBL_DATA_IN12_r[48];
                            D_IN[13]  <= WBL_DATA_IN13_r[48];
                            D_IN[14]  <= WBL_DATA_IN14_r[48];
                            D_IN[15]  <= WBL_DATA_IN15_r[48];
                            D_IN[16]  <= WBL_DATA_IN16_r[48];
                        end
                13'd280:  begin PC_D_IN[0] <= 1'b1; end
                13'd300:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[56];
                            D_IN[2]  <= WBL_DATA_IN2_r[56];
                            D_IN[3]  <= WBL_DATA_IN3_r[56];
                            D_IN[4]  <= WBL_DATA_IN4_r[56];
                            D_IN[5]  <= WBL_DATA_IN5_r[56];
                            D_IN[6]  <= WBL_DATA_IN6_r[56];
                            D_IN[7]  <= WBL_DATA_IN7_r[56];
                            D_IN[8]  <= WBL_DATA_IN8_r[56];
                            D_IN[9]  <= WBL_DATA_IN9_r[56];
                            D_IN[10]  <= WBL_DATA_IN10_r[56];
                            D_IN[11]  <= WBL_DATA_IN11_r[56];
                            D_IN[12]  <= WBL_DATA_IN12_r[56];
                            D_IN[13]  <= WBL_DATA_IN13_r[56];
                            D_IN[14]  <= WBL_DATA_IN14_r[56];
                            D_IN[15]  <= WBL_DATA_IN15_r[56];
                            D_IN[16]  <= WBL_DATA_IN16_r[56];
                        end
                13'd320:  begin PC_D_IN[0] <= 1'b1; end
                13'd340: begin PC_D_IN[0] <= 1'b0; end
                13'd360: begin  end
                13'd380: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd382: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd384: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd386: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 2 轮（索引 1,9,17,25,33,41,49,57） =================
                13'd400:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd401:   begin end
                13'd402:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[1];
                            D_IN[2]  <= WBL_DATA_IN2_r[1];
                            D_IN[3]  <= WBL_DATA_IN3_r[1];
                            D_IN[4]  <= WBL_DATA_IN4_r[1];
                            D_IN[5]  <= WBL_DATA_IN5_r[1];
                            D_IN[6]  <= WBL_DATA_IN6_r[1];
                            D_IN[7]  <= WBL_DATA_IN7_r[1];
                            D_IN[8]  <= WBL_DATA_IN8_r[1];
                            D_IN[9]  <= WBL_DATA_IN9_r[1];
                            D_IN[10]  <= WBL_DATA_IN10_r[1];
                            D_IN[11]  <= WBL_DATA_IN11_r[1];
                            D_IN[12]  <= WBL_DATA_IN12_r[1];
                            D_IN[13]  <= WBL_DATA_IN13_r[1];
                            D_IN[14]  <= WBL_DATA_IN14_r[1];
                            D_IN[15]  <= WBL_DATA_IN15_r[1];
                            D_IN[16]  <= WBL_DATA_IN16_r[1];
                        end
                13'd440:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd460:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[9];
                            D_IN[2]  <= WBL_DATA_IN2_r[9];
                            D_IN[3]  <= WBL_DATA_IN3_r[9];
                            D_IN[4]  <= WBL_DATA_IN4_r[9];
                            D_IN[5]  <= WBL_DATA_IN5_r[9];
                            D_IN[6]  <= WBL_DATA_IN6_r[9];
                            D_IN[7]  <= WBL_DATA_IN7_r[9];
                            D_IN[8]  <= WBL_DATA_IN8_r[9];
                            D_IN[9]  <= WBL_DATA_IN9_r[9];
                            D_IN[10]  <= WBL_DATA_IN10_r[9];
                            D_IN[11]  <= WBL_DATA_IN11_r[9];
                            D_IN[12]  <= WBL_DATA_IN12_r[9];
                            D_IN[13]  <= WBL_DATA_IN13_r[9];
                            D_IN[14]  <= WBL_DATA_IN14_r[9];
                            D_IN[15]  <= WBL_DATA_IN15_r[9];
                            D_IN[16]  <= WBL_DATA_IN16_r[9];
                        end
                13'd480:  begin PC_D_IN[0] <= 1'b1; end
                13'd500:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[17];
                            D_IN[2]  <= WBL_DATA_IN2_r[17];
                            D_IN[3]  <= WBL_DATA_IN3_r[17];
                            D_IN[4]  <= WBL_DATA_IN4_r[17];
                            D_IN[5]  <= WBL_DATA_IN5_r[17];
                            D_IN[6]  <= WBL_DATA_IN6_r[17];
                            D_IN[7]  <= WBL_DATA_IN7_r[17];
                            D_IN[8]  <= WBL_DATA_IN8_r[17];
                            D_IN[9]  <= WBL_DATA_IN9_r[17];
                            D_IN[10]  <= WBL_DATA_IN10_r[17];
                            D_IN[11]  <= WBL_DATA_IN11_r[17];
                            D_IN[12]  <= WBL_DATA_IN12_r[17];
                            D_IN[13]  <= WBL_DATA_IN13_r[17];
                            D_IN[14]  <= WBL_DATA_IN14_r[17];
                            D_IN[15]  <= WBL_DATA_IN15_r[17];
                            D_IN[16]  <= WBL_DATA_IN16_r[17];
                        end
                13'd520:  begin PC_D_IN[0] <= 1'b1; end
                13'd540:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[25];
                            D_IN[2]  <= WBL_DATA_IN2_r[25];
                            D_IN[3]  <= WBL_DATA_IN3_r[25];
                            D_IN[4]  <= WBL_DATA_IN4_r[25];
                            D_IN[5]  <= WBL_DATA_IN5_r[25];
                            D_IN[6]  <= WBL_DATA_IN6_r[25];
                            D_IN[7]  <= WBL_DATA_IN7_r[25];
                            D_IN[8]  <= WBL_DATA_IN8_r[25];
                            D_IN[9]  <= WBL_DATA_IN9_r[25];
                            D_IN[10]  <= WBL_DATA_IN10_r[25];
                            D_IN[11]  <= WBL_DATA_IN11_r[25];
                            D_IN[12]  <= WBL_DATA_IN12_r[25];
                            D_IN[13]  <= WBL_DATA_IN13_r[25];
                            D_IN[14]  <= WBL_DATA_IN14_r[25];
                            D_IN[15]  <= WBL_DATA_IN15_r[25];
                            D_IN[16]  <= WBL_DATA_IN16_r[25];
                        end
                13'd560:  begin PC_D_IN[0] <= 1'b1; end
                13'd580:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[33];
                            D_IN[2]  <= WBL_DATA_IN2_r[33];
                            D_IN[3]  <= WBL_DATA_IN3_r[33];
                            D_IN[4]  <= WBL_DATA_IN4_r[33];
                            D_IN[5]  <= WBL_DATA_IN5_r[33];
                            D_IN[6]  <= WBL_DATA_IN6_r[33];
                            D_IN[7]  <= WBL_DATA_IN7_r[33];
                            D_IN[8]  <= WBL_DATA_IN8_r[33];
                            D_IN[9]  <= WBL_DATA_IN9_r[33];
                            D_IN[10]  <= WBL_DATA_IN10_r[33];
                            D_IN[11]  <= WBL_DATA_IN11_r[33];
                            D_IN[12]  <= WBL_DATA_IN12_r[33];
                            D_IN[13]  <= WBL_DATA_IN13_r[33];
                            D_IN[14]  <= WBL_DATA_IN14_r[33];
                            D_IN[15]  <= WBL_DATA_IN15_r[33];
                            D_IN[16]  <= WBL_DATA_IN16_r[33];
                        end
                13'd600:  begin PC_D_IN[0] <= 1'b1; end
                13'd620:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[41];
                            D_IN[2]  <= WBL_DATA_IN2_r[41];
                            D_IN[3]  <= WBL_DATA_IN3_r[41];
                            D_IN[4]  <= WBL_DATA_IN4_r[41];
                            D_IN[5]  <= WBL_DATA_IN5_r[41];
                            D_IN[6]  <= WBL_DATA_IN6_r[41];
                            D_IN[7]  <= WBL_DATA_IN7_r[41];
                            D_IN[8]  <= WBL_DATA_IN8_r[41];
                            D_IN[9]  <= WBL_DATA_IN9_r[41];
                            D_IN[10]  <= WBL_DATA_IN10_r[41];
                            D_IN[11]  <= WBL_DATA_IN11_r[41];
                            D_IN[12]  <= WBL_DATA_IN12_r[41];
                            D_IN[13]  <= WBL_DATA_IN13_r[41];
                            D_IN[14]  <= WBL_DATA_IN14_r[41];
                            D_IN[15]  <= WBL_DATA_IN15_r[41];
                            D_IN[16]  <= WBL_DATA_IN16_r[41];
                        end
                13'd640:  begin PC_D_IN[0] <= 1'b1; end
                13'd660:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[49];
                            D_IN[2]  <= WBL_DATA_IN2_r[49];
                            D_IN[3]  <= WBL_DATA_IN3_r[49];
                            D_IN[4]  <= WBL_DATA_IN4_r[49];
                            D_IN[5]  <= WBL_DATA_IN5_r[49];
                            D_IN[6]  <= WBL_DATA_IN6_r[49];
                            D_IN[7]  <= WBL_DATA_IN7_r[49];
                            D_IN[8]  <= WBL_DATA_IN8_r[49];
                            D_IN[9]  <= WBL_DATA_IN9_r[49];
                            D_IN[10]  <= WBL_DATA_IN10_r[49];
                            D_IN[11]  <= WBL_DATA_IN11_r[49];
                            D_IN[12]  <= WBL_DATA_IN12_r[49];
                            D_IN[13]  <= WBL_DATA_IN13_r[49];
                            D_IN[14]  <= WBL_DATA_IN14_r[49];
                            D_IN[15]  <= WBL_DATA_IN15_r[49];
                            D_IN[16]  <= WBL_DATA_IN16_r[49];
                        end
                13'd680:  begin PC_D_IN[0] <= 1'b1; end
                13'd700:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[57];
                            D_IN[2]  <= WBL_DATA_IN2_r[57];
                            D_IN[3]  <= WBL_DATA_IN3_r[57];
                            D_IN[4]  <= WBL_DATA_IN4_r[57];
                            D_IN[5]  <= WBL_DATA_IN5_r[57];
                            D_IN[6]  <= WBL_DATA_IN6_r[57];
                            D_IN[7]  <= WBL_DATA_IN7_r[57];
                            D_IN[8]  <= WBL_DATA_IN8_r[57];
                            D_IN[9]  <= WBL_DATA_IN9_r[57];
                            D_IN[10]  <= WBL_DATA_IN10_r[57];
                            D_IN[11]  <= WBL_DATA_IN11_r[57];
                            D_IN[12]  <= WBL_DATA_IN12_r[57];
                            D_IN[13]  <= WBL_DATA_IN13_r[57];
                            D_IN[14]  <= WBL_DATA_IN14_r[57];
                            D_IN[15]  <= WBL_DATA_IN15_r[57];
                            D_IN[16]  <= WBL_DATA_IN16_r[57];
                        end
                13'd720:  begin PC_D_IN[0] <= 1'b1; end
                13'd740: begin PC_D_IN[0] <= 1'b0; end
                13'd760: begin end
                13'd780: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd782: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd784: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd786: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 3 轮（索引 2,10,18,26,34,42,50,58） =================
                13'd800:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd801:   begin end
                13'd802:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[2];
                            D_IN[2]  <= WBL_DATA_IN2_r[2];
                            D_IN[3]  <= WBL_DATA_IN3_r[2];
                            D_IN[4]  <= WBL_DATA_IN4_r[2];
                            D_IN[5]  <= WBL_DATA_IN5_r[2];
                            D_IN[6]  <= WBL_DATA_IN6_r[2];
                            D_IN[7]  <= WBL_DATA_IN7_r[2];
                            D_IN[8]  <= WBL_DATA_IN8_r[2];
                            D_IN[9]  <= WBL_DATA_IN9_r[2];
                            D_IN[10]  <= WBL_DATA_IN10_r[2];
                            D_IN[11]  <= WBL_DATA_IN11_r[2];
                            D_IN[12]  <= WBL_DATA_IN12_r[2];
                            D_IN[13]  <= WBL_DATA_IN13_r[2];
                            D_IN[14]  <= WBL_DATA_IN14_r[2];
                            D_IN[15]  <= WBL_DATA_IN15_r[2];
                            D_IN[16]  <= WBL_DATA_IN16_r[2];
                        end
                13'd840:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd860:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[10];
                            D_IN[2]  <= WBL_DATA_IN2_r[10];
                            D_IN[3]  <= WBL_DATA_IN3_r[10];
                            D_IN[4]  <= WBL_DATA_IN4_r[10];
                            D_IN[5]  <= WBL_DATA_IN5_r[10];
                            D_IN[6]  <= WBL_DATA_IN6_r[10];
                            D_IN[7]  <= WBL_DATA_IN7_r[10];
                            D_IN[8]  <= WBL_DATA_IN8_r[10];
                            D_IN[9]  <= WBL_DATA_IN9_r[10];
                            D_IN[10]  <= WBL_DATA_IN10_r[10];
                            D_IN[11]  <= WBL_DATA_IN11_r[10];
                            D_IN[12]  <= WBL_DATA_IN12_r[10];
                            D_IN[13]  <= WBL_DATA_IN13_r[10];
                            D_IN[14]  <= WBL_DATA_IN14_r[10];
                            D_IN[15]  <= WBL_DATA_IN15_r[10];
                            D_IN[16]  <= WBL_DATA_IN16_r[10];
                        end
                13'd880:  begin PC_D_IN[0] <= 1'b1; end
                13'd900:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[18];
                            D_IN[2]  <= WBL_DATA_IN2_r[18];
                            D_IN[3]  <= WBL_DATA_IN3_r[18];
                            D_IN[4]  <= WBL_DATA_IN4_r[18];
                            D_IN[5]  <= WBL_DATA_IN5_r[18];
                            D_IN[6]  <= WBL_DATA_IN6_r[18];
                            D_IN[7]  <= WBL_DATA_IN7_r[18];
                            D_IN[8]  <= WBL_DATA_IN8_r[18];
                            D_IN[9]  <= WBL_DATA_IN9_r[18];
                            D_IN[10]  <= WBL_DATA_IN10_r[18];
                            D_IN[11]  <= WBL_DATA_IN11_r[18];
                            D_IN[12]  <= WBL_DATA_IN12_r[18];
                            D_IN[13]  <= WBL_DATA_IN13_r[18];
                            D_IN[14]  <= WBL_DATA_IN14_r[18];
                            D_IN[15]  <= WBL_DATA_IN15_r[18];
                            D_IN[16]  <= WBL_DATA_IN16_r[18];
                        end
                13'd920:  begin PC_D_IN[0] <= 1'b1; end
                13'd940:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[26];
                            D_IN[2]  <= WBL_DATA_IN2_r[26];
                            D_IN[3]  <= WBL_DATA_IN3_r[26];
                            D_IN[4]  <= WBL_DATA_IN4_r[26];
                            D_IN[5]  <= WBL_DATA_IN5_r[26];
                            D_IN[6]  <= WBL_DATA_IN6_r[26];
                            D_IN[7]  <= WBL_DATA_IN7_r[26];
                            D_IN[8]  <= WBL_DATA_IN8_r[26];
                            D_IN[9]  <= WBL_DATA_IN9_r[26];
                            D_IN[10]  <= WBL_DATA_IN10_r[26];
                            D_IN[11]  <= WBL_DATA_IN11_r[26];
                            D_IN[12]  <= WBL_DATA_IN12_r[26];
                            D_IN[13]  <= WBL_DATA_IN13_r[26];
                            D_IN[14]  <= WBL_DATA_IN14_r[26];
                            D_IN[15]  <= WBL_DATA_IN15_r[26];
                            D_IN[16]  <= WBL_DATA_IN16_r[26];
                        end
                13'd960:  begin PC_D_IN[0] <= 1'b1; end
                13'd980:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[34];
                            D_IN[2]  <= WBL_DATA_IN2_r[34];
                            D_IN[3]  <= WBL_DATA_IN3_r[34];
                            D_IN[4]  <= WBL_DATA_IN4_r[34];
                            D_IN[5]  <= WBL_DATA_IN5_r[34];
                            D_IN[6]  <= WBL_DATA_IN6_r[34];
                            D_IN[7]  <= WBL_DATA_IN7_r[34];
                            D_IN[8]  <= WBL_DATA_IN8_r[34];
                            D_IN[9]  <= WBL_DATA_IN9_r[34];
                            D_IN[10]  <= WBL_DATA_IN10_r[34];
                            D_IN[11]  <= WBL_DATA_IN11_r[34];
                            D_IN[12]  <= WBL_DATA_IN12_r[34];
                            D_IN[13]  <= WBL_DATA_IN13_r[34];
                            D_IN[14]  <= WBL_DATA_IN14_r[34];
                            D_IN[15]  <= WBL_DATA_IN15_r[34];
                            D_IN[16]  <= WBL_DATA_IN16_r[34];
                        end
                13'd1000:  begin PC_D_IN[0] <= 1'b1; end
                13'd1020:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[42];
                            D_IN[2]  <= WBL_DATA_IN2_r[42];
                            D_IN[3]  <= WBL_DATA_IN3_r[42];
                            D_IN[4]  <= WBL_DATA_IN4_r[42];
                            D_IN[5]  <= WBL_DATA_IN5_r[42];
                            D_IN[6]  <= WBL_DATA_IN6_r[42];
                            D_IN[7]  <= WBL_DATA_IN7_r[42];
                            D_IN[8]  <= WBL_DATA_IN8_r[42];
                            D_IN[9]  <= WBL_DATA_IN9_r[42];
                            D_IN[10]  <= WBL_DATA_IN10_r[42];
                            D_IN[11]  <= WBL_DATA_IN11_r[42];
                            D_IN[12]  <= WBL_DATA_IN12_r[42];
                            D_IN[13]  <= WBL_DATA_IN13_r[42];
                            D_IN[14]  <= WBL_DATA_IN14_r[42];
                            D_IN[15]  <= WBL_DATA_IN15_r[42];
                            D_IN[16]  <= WBL_DATA_IN16_r[42];
                        end
                13'd1040:  begin PC_D_IN[0] <= 1'b1; end
                13'd1060:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[50];
                            D_IN[2]  <= WBL_DATA_IN2_r[50];
                            D_IN[3]  <= WBL_DATA_IN3_r[50];
                            D_IN[4]  <= WBL_DATA_IN4_r[50];
                            D_IN[5]  <= WBL_DATA_IN5_r[50];
                            D_IN[6]  <= WBL_DATA_IN6_r[50];
                            D_IN[7]  <= WBL_DATA_IN7_r[50];
                            D_IN[8]  <= WBL_DATA_IN8_r[50];
                            D_IN[9]  <= WBL_DATA_IN9_r[50];
                            D_IN[10]  <= WBL_DATA_IN10_r[50];
                            D_IN[11]  <= WBL_DATA_IN11_r[50];
                            D_IN[12]  <= WBL_DATA_IN12_r[50];
                            D_IN[13]  <= WBL_DATA_IN13_r[50];
                            D_IN[14]  <= WBL_DATA_IN14_r[50];
                            D_IN[15]  <= WBL_DATA_IN15_r[50];
                            D_IN[16]  <= WBL_DATA_IN16_r[50];
                        end
                13'd1080:  begin PC_D_IN[0] <= 1'b1; end
                13'd1100:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[58];
                            D_IN[2]  <= WBL_DATA_IN2_r[58];
                            D_IN[3]  <= WBL_DATA_IN3_r[58];
                            D_IN[4]  <= WBL_DATA_IN4_r[58];
                            D_IN[5]  <= WBL_DATA_IN5_r[58];
                            D_IN[6]  <= WBL_DATA_IN6_r[58];
                            D_IN[7]  <= WBL_DATA_IN7_r[58];
                            D_IN[8]  <= WBL_DATA_IN8_r[58];
                            D_IN[9]  <= WBL_DATA_IN9_r[58];
                            D_IN[10]  <= WBL_DATA_IN10_r[58];
                            D_IN[11]  <= WBL_DATA_IN11_r[58];
                            D_IN[12]  <= WBL_DATA_IN12_r[58];
                            D_IN[13]  <= WBL_DATA_IN13_r[58];
                            D_IN[14]  <= WBL_DATA_IN14_r[58];
                            D_IN[15]  <= WBL_DATA_IN15_r[58];
                            D_IN[16]  <= WBL_DATA_IN16_r[58];
                        end
                13'd1120:  begin PC_D_IN[0] <= 1'b1; end
                13'd1140: begin PC_D_IN[0] <= 1'b0; end
                13'd1160: begin end
                13'd1180: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd1182: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd1184: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd1186: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 4 轮（索引 3,11,19,27,35,43,51,59） =================
                13'd1200:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd1201:   begin end
                13'd1202:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[3];
                            D_IN[2]  <= WBL_DATA_IN2_r[3];
                            D_IN[3]  <= WBL_DATA_IN3_r[3];
                            D_IN[4]  <= WBL_DATA_IN4_r[3];
                            D_IN[5]  <= WBL_DATA_IN5_r[3];
                            D_IN[6]  <= WBL_DATA_IN6_r[3];
                            D_IN[7]  <= WBL_DATA_IN7_r[3];
                            D_IN[8]  <= WBL_DATA_IN8_r[3];
                            D_IN[9]  <= WBL_DATA_IN9_r[3];
                            D_IN[10]  <= WBL_DATA_IN10_r[3];
                            D_IN[11]  <= WBL_DATA_IN11_r[3];
                            D_IN[12]  <= WBL_DATA_IN12_r[3];
                            D_IN[13]  <= WBL_DATA_IN13_r[3];
                            D_IN[14]  <= WBL_DATA_IN14_r[3];
                            D_IN[15]  <= WBL_DATA_IN15_r[3];
                            D_IN[16]  <= WBL_DATA_IN16_r[3];
                        end
                13'd1240:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd1260:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[11];
                            D_IN[2]  <= WBL_DATA_IN2_r[11];
                            D_IN[3]  <= WBL_DATA_IN3_r[11];
                            D_IN[4]  <= WBL_DATA_IN4_r[11];
                            D_IN[5]  <= WBL_DATA_IN5_r[11];
                            D_IN[6]  <= WBL_DATA_IN6_r[11];
                            D_IN[7]  <= WBL_DATA_IN7_r[11];
                            D_IN[8]  <= WBL_DATA_IN8_r[11];
                            D_IN[9]  <= WBL_DATA_IN9_r[11];
                            D_IN[10]  <= WBL_DATA_IN10_r[11];
                            D_IN[11]  <= WBL_DATA_IN11_r[11];
                            D_IN[12]  <= WBL_DATA_IN12_r[11];
                            D_IN[13]  <= WBL_DATA_IN13_r[11];
                            D_IN[14]  <= WBL_DATA_IN14_r[11];
                            D_IN[15]  <= WBL_DATA_IN15_r[11];
                            D_IN[16]  <= WBL_DATA_IN16_r[11];
                        end
                13'd1280:  begin PC_D_IN[0] <= 1'b1; end
                13'd1300:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[19];
                            D_IN[2]  <= WBL_DATA_IN2_r[19];
                            D_IN[3]  <= WBL_DATA_IN3_r[19];
                            D_IN[4]  <= WBL_DATA_IN4_r[19];
                            D_IN[5]  <= WBL_DATA_IN5_r[19];
                            D_IN[6]  <= WBL_DATA_IN6_r[19];
                            D_IN[7]  <= WBL_DATA_IN7_r[19];
                            D_IN[8]  <= WBL_DATA_IN8_r[19];
                            D_IN[9]  <= WBL_DATA_IN9_r[19];
                            D_IN[10]  <= WBL_DATA_IN10_r[19];
                            D_IN[11]  <= WBL_DATA_IN11_r[19];
                            D_IN[12]  <= WBL_DATA_IN12_r[19];
                            D_IN[13]  <= WBL_DATA_IN13_r[19];
                            D_IN[14]  <= WBL_DATA_IN14_r[19];
                            D_IN[15]  <= WBL_DATA_IN15_r[19];
                            D_IN[16]  <= WBL_DATA_IN16_r[19];
                        end
                13'd1320:  begin PC_D_IN[0] <= 1'b1; end
                13'd1340:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[27];
                            D_IN[2]  <= WBL_DATA_IN2_r[27];
                            D_IN[3]  <= WBL_DATA_IN3_r[27];
                            D_IN[4]  <= WBL_DATA_IN4_r[27];
                            D_IN[5]  <= WBL_DATA_IN5_r[27];
                            D_IN[6]  <= WBL_DATA_IN6_r[27];
                            D_IN[7]  <= WBL_DATA_IN7_r[27];
                            D_IN[8]  <= WBL_DATA_IN8_r[27];
                            D_IN[9]  <= WBL_DATA_IN9_r[27];
                            D_IN[10]  <= WBL_DATA_IN10_r[27];
                            D_IN[11]  <= WBL_DATA_IN11_r[27];
                            D_IN[12]  <= WBL_DATA_IN12_r[27];
                            D_IN[13]  <= WBL_DATA_IN13_r[27];
                            D_IN[14]  <= WBL_DATA_IN14_r[27];
                            D_IN[15]  <= WBL_DATA_IN15_r[27];
                            D_IN[16]  <= WBL_DATA_IN16_r[27];
                        end
                13'd1360:  begin PC_D_IN[0] <= 1'b1; end
                13'd1380:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[35];
                            D_IN[2]  <= WBL_DATA_IN2_r[35];
                            D_IN[3]  <= WBL_DATA_IN3_r[35];
                            D_IN[4]  <= WBL_DATA_IN4_r[35];
                            D_IN[5]  <= WBL_DATA_IN5_r[35];
                            D_IN[6]  <= WBL_DATA_IN6_r[35];
                            D_IN[7]  <= WBL_DATA_IN7_r[35];
                            D_IN[8]  <= WBL_DATA_IN8_r[35];
                            D_IN[9]  <= WBL_DATA_IN9_r[35];
                            D_IN[10]  <= WBL_DATA_IN10_r[35];
                            D_IN[11]  <= WBL_DATA_IN11_r[35];
                            D_IN[12]  <= WBL_DATA_IN12_r[35];
                            D_IN[13]  <= WBL_DATA_IN13_r[35];
                            D_IN[14]  <= WBL_DATA_IN14_r[35];
                            D_IN[15]  <= WBL_DATA_IN15_r[35];
                            D_IN[16]  <= WBL_DATA_IN16_r[35];
                        end
                13'd1400:  begin PC_D_IN[0] <= 1'b1; end
                13'd1420:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[43];
                            D_IN[2]  <= WBL_DATA_IN2_r[43];
                            D_IN[3]  <= WBL_DATA_IN3_r[43];
                            D_IN[4]  <= WBL_DATA_IN4_r[43];
                            D_IN[5]  <= WBL_DATA_IN5_r[43];
                            D_IN[6]  <= WBL_DATA_IN6_r[43];
                            D_IN[7]  <= WBL_DATA_IN7_r[43];
                            D_IN[8]  <= WBL_DATA_IN8_r[43];
                            D_IN[9]  <= WBL_DATA_IN9_r[43];
                            D_IN[10]  <= WBL_DATA_IN10_r[43];
                            D_IN[11]  <= WBL_DATA_IN11_r[43];
                            D_IN[12]  <= WBL_DATA_IN12_r[43];
                            D_IN[13]  <= WBL_DATA_IN13_r[43];
                            D_IN[14]  <= WBL_DATA_IN14_r[43];
                            D_IN[15]  <= WBL_DATA_IN15_r[43];
                            D_IN[16]  <= WBL_DATA_IN16_r[43];
                        end
                13'd1440:  begin PC_D_IN[0] <= 1'b1; end
                13'd1460:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[51];
                            D_IN[2]  <= WBL_DATA_IN2_r[51];
                            D_IN[3]  <= WBL_DATA_IN3_r[51];
                            D_IN[4]  <= WBL_DATA_IN4_r[51];
                            D_IN[5]  <= WBL_DATA_IN5_r[51];
                            D_IN[6]  <= WBL_DATA_IN6_r[51];
                            D_IN[7]  <= WBL_DATA_IN7_r[51];
                            D_IN[8]  <= WBL_DATA_IN8_r[51];
                            D_IN[9]  <= WBL_DATA_IN9_r[51];
                            D_IN[10]  <= WBL_DATA_IN10_r[51];
                            D_IN[11]  <= WBL_DATA_IN11_r[51];
                            D_IN[12]  <= WBL_DATA_IN12_r[51];
                            D_IN[13]  <= WBL_DATA_IN13_r[51];
                            D_IN[14]  <= WBL_DATA_IN14_r[51];
                            D_IN[15]  <= WBL_DATA_IN15_r[51];
                            D_IN[16]  <= WBL_DATA_IN16_r[51];
                        end
                13'd1480:  begin PC_D_IN[0] <= 1'b1; end
                13'd1500:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[59];
                            D_IN[2]  <= WBL_DATA_IN2_r[59];
                            D_IN[3]  <= WBL_DATA_IN3_r[59];
                            D_IN[4]  <= WBL_DATA_IN4_r[59];
                            D_IN[5]  <= WBL_DATA_IN5_r[59];
                            D_IN[6]  <= WBL_DATA_IN6_r[59];
                            D_IN[7]  <= WBL_DATA_IN7_r[59];
                            D_IN[8]  <= WBL_DATA_IN8_r[59];
                            D_IN[9]  <= WBL_DATA_IN9_r[59];
                            D_IN[10]  <= WBL_DATA_IN10_r[59];
                            D_IN[11]  <= WBL_DATA_IN11_r[59];
                            D_IN[12]  <= WBL_DATA_IN12_r[59];
                            D_IN[13]  <= WBL_DATA_IN13_r[59];
                            D_IN[14]  <= WBL_DATA_IN14_r[59];
                            D_IN[15]  <= WBL_DATA_IN15_r[59];
                            D_IN[16]  <= WBL_DATA_IN16_r[59];
                        end
                13'd1520:  begin PC_D_IN[0] <= 1'b1; end
                13'd1540: begin PC_D_IN[0] <= 1'b0; end
                13'd1560: begin end
                13'd1580: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd1582: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd1584: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd1586: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 5 轮（索引 4,12,20,28,36,44,52,60） =================
                13'd1600:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd1601:   begin end
                13'd1602:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[4];
                            D_IN[2]  <= WBL_DATA_IN2_r[4];
                            D_IN[3]  <= WBL_DATA_IN3_r[4];
                            D_IN[4]  <= WBL_DATA_IN4_r[4];
                            D_IN[5]  <= WBL_DATA_IN5_r[4];
                            D_IN[6]  <= WBL_DATA_IN6_r[4];
                            D_IN[7]  <= WBL_DATA_IN7_r[4];
                            D_IN[8]  <= WBL_DATA_IN8_r[4];
                            D_IN[9]  <= WBL_DATA_IN9_r[4];
                            D_IN[10]  <= WBL_DATA_IN10_r[4];
                            D_IN[11]  <= WBL_DATA_IN11_r[4];
                            D_IN[12]  <= WBL_DATA_IN12_r[4];
                            D_IN[13]  <= WBL_DATA_IN13_r[4];
                            D_IN[14]  <= WBL_DATA_IN14_r[4];
                            D_IN[15]  <= WBL_DATA_IN15_r[4];
                            D_IN[16]  <= WBL_DATA_IN16_r[4];
                        end
                13'd1640:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd1660:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[12];
                            D_IN[2]  <= WBL_DATA_IN2_r[12];
                            D_IN[3]  <= WBL_DATA_IN3_r[12];
                            D_IN[4]  <= WBL_DATA_IN4_r[12];
                            D_IN[5]  <= WBL_DATA_IN5_r[12];
                            D_IN[6]  <= WBL_DATA_IN6_r[12];
                            D_IN[7]  <= WBL_DATA_IN7_r[12];
                            D_IN[8]  <= WBL_DATA_IN8_r[12];
                            D_IN[9]  <= WBL_DATA_IN9_r[12];
                            D_IN[10]  <= WBL_DATA_IN10_r[12];
                            D_IN[11]  <= WBL_DATA_IN11_r[12];
                            D_IN[12]  <= WBL_DATA_IN12_r[12];
                            D_IN[13]  <= WBL_DATA_IN13_r[12];
                            D_IN[14]  <= WBL_DATA_IN14_r[12];
                            D_IN[15]  <= WBL_DATA_IN15_r[12];
                            D_IN[16]  <= WBL_DATA_IN16_r[12];
                        end
                13'd1680:  begin PC_D_IN[0] <= 1'b1; end
                13'd1700:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[20];
                            D_IN[2]  <= WBL_DATA_IN2_r[20];
                            D_IN[3]  <= WBL_DATA_IN3_r[20];
                            D_IN[4]  <= WBL_DATA_IN4_r[20];
                            D_IN[5]  <= WBL_DATA_IN5_r[20];
                            D_IN[6]  <= WBL_DATA_IN6_r[20];
                            D_IN[7]  <= WBL_DATA_IN7_r[20];
                            D_IN[8]  <= WBL_DATA_IN8_r[20];
                            D_IN[9]  <= WBL_DATA_IN9_r[20];
                            D_IN[10]  <= WBL_DATA_IN10_r[20];
                            D_IN[11]  <= WBL_DATA_IN11_r[20];
                            D_IN[12]  <= WBL_DATA_IN12_r[20];
                            D_IN[13]  <= WBL_DATA_IN13_r[20];
                            D_IN[14]  <= WBL_DATA_IN14_r[20];
                            D_IN[15]  <= WBL_DATA_IN15_r[20];
                            D_IN[16]  <= WBL_DATA_IN16_r[20];
                        end
                13'd1720:  begin PC_D_IN[0] <= 1'b1; end
                13'd1740:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[28];
                            D_IN[2]  <= WBL_DATA_IN2_r[28];
                            D_IN[3]  <= WBL_DATA_IN3_r[28];
                            D_IN[4]  <= WBL_DATA_IN4_r[28];
                            D_IN[5]  <= WBL_DATA_IN5_r[28];
                            D_IN[6]  <= WBL_DATA_IN6_r[28];
                            D_IN[7]  <= WBL_DATA_IN7_r[28];
                            D_IN[8]  <= WBL_DATA_IN8_r[28];
                            D_IN[9]  <= WBL_DATA_IN9_r[28];
                            D_IN[10]  <= WBL_DATA_IN10_r[28];
                            D_IN[11]  <= WBL_DATA_IN11_r[28];
                            D_IN[12]  <= WBL_DATA_IN12_r[28];
                            D_IN[13]  <= WBL_DATA_IN13_r[28];
                            D_IN[14]  <= WBL_DATA_IN14_r[28];
                            D_IN[15]  <= WBL_DATA_IN15_r[28];
                            D_IN[16]  <= WBL_DATA_IN16_r[28];
                        end
                13'd1760:  begin PC_D_IN[0] <= 1'b1; end
                13'd1780:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[36];
                            D_IN[2]  <= WBL_DATA_IN2_r[36];
                            D_IN[3]  <= WBL_DATA_IN3_r[36];
                            D_IN[4]  <= WBL_DATA_IN4_r[36];
                            D_IN[5]  <= WBL_DATA_IN5_r[36];
                            D_IN[6]  <= WBL_DATA_IN6_r[36];
                            D_IN[7]  <= WBL_DATA_IN7_r[36];
                            D_IN[8]  <= WBL_DATA_IN8_r[36];
                            D_IN[9]  <= WBL_DATA_IN9_r[36];
                            D_IN[10]  <= WBL_DATA_IN10_r[36];
                            D_IN[11]  <= WBL_DATA_IN11_r[36];
                            D_IN[12]  <= WBL_DATA_IN12_r[36];
                            D_IN[13]  <= WBL_DATA_IN13_r[36];
                            D_IN[14]  <= WBL_DATA_IN14_r[36];
                            D_IN[15]  <= WBL_DATA_IN15_r[36];
                            D_IN[16]  <= WBL_DATA_IN16_r[36];
                        end
                13'd1800:  begin PC_D_IN[0] <= 1'b1; end
                13'd1820:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[44];
                            D_IN[2]  <= WBL_DATA_IN2_r[44];
                            D_IN[3]  <= WBL_DATA_IN3_r[44];
                            D_IN[4]  <= WBL_DATA_IN4_r[44];
                            D_IN[5]  <= WBL_DATA_IN5_r[44];
                            D_IN[6]  <= WBL_DATA_IN6_r[44];
                            D_IN[7]  <= WBL_DATA_IN7_r[44];
                            D_IN[8]  <= WBL_DATA_IN8_r[44];
                            D_IN[9]  <= WBL_DATA_IN9_r[44];
                            D_IN[10]  <= WBL_DATA_IN10_r[44];
                            D_IN[11]  <= WBL_DATA_IN11_r[44];
                            D_IN[12]  <= WBL_DATA_IN12_r[44];
                            D_IN[13]  <= WBL_DATA_IN13_r[44];
                            D_IN[14]  <= WBL_DATA_IN14_r[44];
                            D_IN[15]  <= WBL_DATA_IN15_r[44];
                            D_IN[16]  <= WBL_DATA_IN16_r[44];
                        end
                13'd1840:  begin PC_D_IN[0] <= 1'b1; end
                13'd1860:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[52];
                            D_IN[2]  <= WBL_DATA_IN2_r[52];
                            D_IN[3]  <= WBL_DATA_IN3_r[52];
                            D_IN[4]  <= WBL_DATA_IN4_r[52];
                            D_IN[5]  <= WBL_DATA_IN5_r[52];
                            D_IN[6]  <= WBL_DATA_IN6_r[52];
                            D_IN[7]  <= WBL_DATA_IN7_r[52];
                            D_IN[8]  <= WBL_DATA_IN8_r[52];
                            D_IN[9]  <= WBL_DATA_IN9_r[52];
                            D_IN[10]  <= WBL_DATA_IN10_r[52];
                            D_IN[11]  <= WBL_DATA_IN11_r[52];
                            D_IN[12]  <= WBL_DATA_IN12_r[52];
                            D_IN[13]  <= WBL_DATA_IN13_r[52];
                            D_IN[14]  <= WBL_DATA_IN14_r[52];
                            D_IN[15]  <= WBL_DATA_IN15_r[52];
                            D_IN[16]  <= WBL_DATA_IN16_r[52];
                        end
                13'd1880:  begin PC_D_IN[0] <= 1'b1; end
                13'd1900:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[60];
                            D_IN[2]  <= WBL_DATA_IN2_r[60];
                            D_IN[3]  <= WBL_DATA_IN3_r[60];
                            D_IN[4]  <= WBL_DATA_IN4_r[60];
                            D_IN[5]  <= WBL_DATA_IN5_r[60];
                            D_IN[6]  <= WBL_DATA_IN6_r[60];
                            D_IN[7]  <= WBL_DATA_IN7_r[60];
                            D_IN[8]  <= WBL_DATA_IN8_r[60];
                            D_IN[9]  <= WBL_DATA_IN9_r[60];
                            D_IN[10]  <= WBL_DATA_IN10_r[60];
                            D_IN[11]  <= WBL_DATA_IN11_r[60];
                            D_IN[12]  <= WBL_DATA_IN12_r[60];
                            D_IN[13]  <= WBL_DATA_IN13_r[60];
                            D_IN[14]  <= WBL_DATA_IN14_r[60];
                            D_IN[15]  <= WBL_DATA_IN15_r[60];
                            D_IN[16]  <= WBL_DATA_IN16_r[60];
                        end
                13'd1920:  begin PC_D_IN[0] <= 1'b1; end
                13'd1940: begin PC_D_IN[0] <= 1'b0; end
                13'd1960: begin end
                13'd1980: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd1982: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd1984: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd1986: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 6 轮（索引 5,13,21,29,37,45,53,61） =================
                13'd2000:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd2001:   begin end
                13'd2002:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[5];
                            D_IN[2]  <= WBL_DATA_IN2_r[5];
                            D_IN[3]  <= WBL_DATA_IN3_r[5];
                            D_IN[4]  <= WBL_DATA_IN4_r[5];
                            D_IN[5]  <= WBL_DATA_IN5_r[5];
                            D_IN[6]  <= WBL_DATA_IN6_r[5];
                            D_IN[7]  <= WBL_DATA_IN7_r[5];
                            D_IN[8]  <= WBL_DATA_IN8_r[5];
                            D_IN[9]  <= WBL_DATA_IN9_r[5];
                            D_IN[10]  <= WBL_DATA_IN10_r[5];
                            D_IN[11]  <= WBL_DATA_IN11_r[5];
                            D_IN[12]  <= WBL_DATA_IN12_r[5];
                            D_IN[13]  <= WBL_DATA_IN13_r[5];
                            D_IN[14]  <= WBL_DATA_IN14_r[5];
                            D_IN[15]  <= WBL_DATA_IN15_r[5];
                            D_IN[16]  <= WBL_DATA_IN16_r[5];
                        end
                13'd2040:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd2060:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[13];
                            D_IN[2]  <= WBL_DATA_IN2_r[13];
                            D_IN[3]  <= WBL_DATA_IN3_r[13];
                            D_IN[4]  <= WBL_DATA_IN4_r[13];
                            D_IN[5]  <= WBL_DATA_IN5_r[13];
                            D_IN[6]  <= WBL_DATA_IN6_r[13];
                            D_IN[7]  <= WBL_DATA_IN7_r[13];
                            D_IN[8]  <= WBL_DATA_IN8_r[13];
                            D_IN[9]  <= WBL_DATA_IN9_r[13];
                            D_IN[10]  <= WBL_DATA_IN10_r[13];
                            D_IN[11]  <= WBL_DATA_IN11_r[13];
                            D_IN[12]  <= WBL_DATA_IN12_r[13];
                            D_IN[13]  <= WBL_DATA_IN13_r[13];
                            D_IN[14]  <= WBL_DATA_IN14_r[13];
                            D_IN[15]  <= WBL_DATA_IN15_r[13];
                            D_IN[16]  <= WBL_DATA_IN16_r[13];
                        end
                13'd2080:  begin PC_D_IN[0] <= 1'b1; end
                13'd2100:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[21];
                            D_IN[2]  <= WBL_DATA_IN2_r[21];
                            D_IN[3]  <= WBL_DATA_IN3_r[21];
                            D_IN[4]  <= WBL_DATA_IN4_r[21];
                            D_IN[5]  <= WBL_DATA_IN5_r[21];
                            D_IN[6]  <= WBL_DATA_IN6_r[21];
                            D_IN[7]  <= WBL_DATA_IN7_r[21];
                            D_IN[8]  <= WBL_DATA_IN8_r[21];
                            D_IN[9]  <= WBL_DATA_IN9_r[21];
                            D_IN[10]  <= WBL_DATA_IN10_r[21];
                            D_IN[11]  <= WBL_DATA_IN11_r[21];
                            D_IN[12]  <= WBL_DATA_IN12_r[21];
                            D_IN[13]  <= WBL_DATA_IN13_r[21];
                            D_IN[14]  <= WBL_DATA_IN14_r[21];
                            D_IN[15]  <= WBL_DATA_IN15_r[21];
                            D_IN[16]  <= WBL_DATA_IN16_r[21];
                        end
                13'd2120:  begin PC_D_IN[0] <= 1'b1; end
                13'd2140:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[29];
                            D_IN[2]  <= WBL_DATA_IN2_r[29];
                            D_IN[3]  <= WBL_DATA_IN3_r[29];
                            D_IN[4]  <= WBL_DATA_IN4_r[29];
                            D_IN[5]  <= WBL_DATA_IN5_r[29];
                            D_IN[6]  <= WBL_DATA_IN6_r[29];
                            D_IN[7]  <= WBL_DATA_IN7_r[29];
                            D_IN[8]  <= WBL_DATA_IN8_r[29];
                            D_IN[9]  <= WBL_DATA_IN9_r[29];
                            D_IN[10]  <= WBL_DATA_IN10_r[29];
                            D_IN[11]  <= WBL_DATA_IN11_r[29];
                            D_IN[12]  <= WBL_DATA_IN12_r[29];
                            D_IN[13]  <= WBL_DATA_IN13_r[29];
                            D_IN[14]  <= WBL_DATA_IN14_r[29];
                            D_IN[15]  <= WBL_DATA_IN15_r[29];
                            D_IN[16]  <= WBL_DATA_IN16_r[29];
                        end
                13'd2160:  begin PC_D_IN[0] <= 1'b1; end
                13'd2180:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[37];
                            D_IN[2]  <= WBL_DATA_IN2_r[37];
                            D_IN[3]  <= WBL_DATA_IN3_r[37];
                            D_IN[4]  <= WBL_DATA_IN4_r[37];
                            D_IN[5]  <= WBL_DATA_IN5_r[37];
                            D_IN[6]  <= WBL_DATA_IN6_r[37];
                            D_IN[7]  <= WBL_DATA_IN7_r[37];
                            D_IN[8]  <= WBL_DATA_IN8_r[37];
                            D_IN[9]  <= WBL_DATA_IN9_r[37];
                            D_IN[10]  <= WBL_DATA_IN10_r[37];
                            D_IN[11]  <= WBL_DATA_IN11_r[37];
                            D_IN[12]  <= WBL_DATA_IN12_r[37];
                            D_IN[13]  <= WBL_DATA_IN13_r[37];
                            D_IN[14]  <= WBL_DATA_IN14_r[37];
                            D_IN[15]  <= WBL_DATA_IN15_r[37];
                            D_IN[16]  <= WBL_DATA_IN16_r[37];
                        end
                13'd2200:  begin PC_D_IN[0] <= 1'b1; end
                13'd2220:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[45];
                            D_IN[2]  <= WBL_DATA_IN2_r[45];
                            D_IN[3]  <= WBL_DATA_IN3_r[45];
                            D_IN[4]  <= WBL_DATA_IN4_r[45];
                            D_IN[5]  <= WBL_DATA_IN5_r[45];
                            D_IN[6]  <= WBL_DATA_IN6_r[45];
                            D_IN[7]  <= WBL_DATA_IN7_r[45];
                            D_IN[8]  <= WBL_DATA_IN8_r[45];
                            D_IN[9]  <= WBL_DATA_IN9_r[45];
                            D_IN[10]  <= WBL_DATA_IN10_r[45];
                            D_IN[11]  <= WBL_DATA_IN11_r[45];
                            D_IN[12]  <= WBL_DATA_IN12_r[45];
                            D_IN[13]  <= WBL_DATA_IN13_r[45];
                            D_IN[14]  <= WBL_DATA_IN14_r[45];
                            D_IN[15]  <= WBL_DATA_IN15_r[45];
                            D_IN[16]  <= WBL_DATA_IN16_r[45];
                        end
                13'd2240:  begin PC_D_IN[0] <= 1'b1; end
                13'd2260:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[53];
                            D_IN[2]  <= WBL_DATA_IN2_r[53];
                            D_IN[3]  <= WBL_DATA_IN3_r[53];
                            D_IN[4]  <= WBL_DATA_IN4_r[53];
                            D_IN[5]  <= WBL_DATA_IN5_r[53];
                            D_IN[6]  <= WBL_DATA_IN6_r[53];
                            D_IN[7]  <= WBL_DATA_IN7_r[53];
                            D_IN[8]  <= WBL_DATA_IN8_r[53];
                            D_IN[9]  <= WBL_DATA_IN9_r[53];
                            D_IN[10]  <= WBL_DATA_IN10_r[53];
                            D_IN[11]  <= WBL_DATA_IN11_r[53];
                            D_IN[12]  <= WBL_DATA_IN12_r[53];
                            D_IN[13]  <= WBL_DATA_IN13_r[53];
                            D_IN[14]  <= WBL_DATA_IN14_r[53];
                            D_IN[15]  <= WBL_DATA_IN15_r[53];
                            D_IN[16]  <= WBL_DATA_IN16_r[53];
                        end
                13'd2280:  begin PC_D_IN[0] <= 1'b1; end
                13'd2300:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[61];
                            D_IN[2]  <= WBL_DATA_IN2_r[61];
                            D_IN[3]  <= WBL_DATA_IN3_r[61];
                            D_IN[4]  <= WBL_DATA_IN4_r[61];
                            D_IN[5]  <= WBL_DATA_IN5_r[61];
                            D_IN[6]  <= WBL_DATA_IN6_r[61];
                            D_IN[7]  <= WBL_DATA_IN7_r[61];
                            D_IN[8]  <= WBL_DATA_IN8_r[61];
                            D_IN[9]  <= WBL_DATA_IN9_r[61];
                            D_IN[10]  <= WBL_DATA_IN10_r[61];
                            D_IN[11]  <= WBL_DATA_IN11_r[61];
                            D_IN[12]  <= WBL_DATA_IN12_r[61];
                            D_IN[13]  <= WBL_DATA_IN13_r[61];
                            D_IN[14]  <= WBL_DATA_IN14_r[61];
                            D_IN[15]  <= WBL_DATA_IN15_r[61];
                            D_IN[16]  <= WBL_DATA_IN16_r[61];
                        end
                13'd2320:  begin PC_D_IN[0] <= 1'b1; end
                13'd2340: begin PC_D_IN[0] <= 1'b0; end
                13'd2360: begin end
                13'd2380: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd2382: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd2384: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd2386: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 7 轮（索引 6,14,22,30,38,46,54,62） =================
                13'd2400:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd2401:   begin end
                13'd2402:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[6];
                            D_IN[2]  <= WBL_DATA_IN2_r[6];
                            D_IN[3]  <= WBL_DATA_IN3_r[6];
                            D_IN[4]  <= WBL_DATA_IN4_r[6];
                            D_IN[5]  <= WBL_DATA_IN5_r[6];
                            D_IN[6]  <= WBL_DATA_IN6_r[6];
                            D_IN[7]  <= WBL_DATA_IN7_r[6];
                            D_IN[8]  <= WBL_DATA_IN8_r[6];
                            D_IN[9]  <= WBL_DATA_IN9_r[6];
                            D_IN[10]  <= WBL_DATA_IN10_r[6];
                            D_IN[11]  <= WBL_DATA_IN11_r[6];
                            D_IN[12]  <= WBL_DATA_IN12_r[6];
                            D_IN[13]  <= WBL_DATA_IN13_r[6];
                            D_IN[14]  <= WBL_DATA_IN14_r[6];
                            D_IN[15]  <= WBL_DATA_IN15_r[6];
                            D_IN[16]  <= WBL_DATA_IN16_r[6];
                        end
                13'd2440:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd2460:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[14];
                            D_IN[2]  <= WBL_DATA_IN2_r[14];
                            D_IN[3]  <= WBL_DATA_IN3_r[14];
                            D_IN[4]  <= WBL_DATA_IN4_r[14];
                            D_IN[5]  <= WBL_DATA_IN5_r[14];
                            D_IN[6]  <= WBL_DATA_IN6_r[14];
                            D_IN[7]  <= WBL_DATA_IN7_r[14];
                            D_IN[8]  <= WBL_DATA_IN8_r[14];
                            D_IN[9]  <= WBL_DATA_IN9_r[14];
                            D_IN[10]  <= WBL_DATA_IN10_r[14];
                            D_IN[11]  <= WBL_DATA_IN11_r[14];
                            D_IN[12]  <= WBL_DATA_IN12_r[14];
                            D_IN[13]  <= WBL_DATA_IN13_r[14];
                            D_IN[14]  <= WBL_DATA_IN14_r[14];
                            D_IN[15]  <= WBL_DATA_IN15_r[14];
                            D_IN[16]  <= WBL_DATA_IN16_r[14];
                        end
                13'd2480:  begin PC_D_IN[0] <= 1'b1; end
                13'd2500:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[22];
                            D_IN[2]  <= WBL_DATA_IN2_r[22];
                            D_IN[3]  <= WBL_DATA_IN3_r[22];
                            D_IN[4]  <= WBL_DATA_IN4_r[22];
                            D_IN[5]  <= WBL_DATA_IN5_r[22];
                            D_IN[6]  <= WBL_DATA_IN6_r[22];
                            D_IN[7]  <= WBL_DATA_IN7_r[22];
                            D_IN[8]  <= WBL_DATA_IN8_r[22];
                            D_IN[9]  <= WBL_DATA_IN9_r[22];
                            D_IN[10]  <= WBL_DATA_IN10_r[22];
                            D_IN[11]  <= WBL_DATA_IN11_r[22];
                            D_IN[12]  <= WBL_DATA_IN12_r[22];
                            D_IN[13]  <= WBL_DATA_IN13_r[22];
                            D_IN[14]  <= WBL_DATA_IN14_r[22];
                            D_IN[15]  <= WBL_DATA_IN15_r[22];
                            D_IN[16]  <= WBL_DATA_IN16_r[22];
                        end
                13'd2520:  begin PC_D_IN[0] <= 1'b1; end
                13'd2540:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[30];
                            D_IN[2]  <= WBL_DATA_IN2_r[30];
                            D_IN[3]  <= WBL_DATA_IN3_r[30];
                            D_IN[4]  <= WBL_DATA_IN4_r[30];
                            D_IN[5]  <= WBL_DATA_IN5_r[30];
                            D_IN[6]  <= WBL_DATA_IN6_r[30];
                            D_IN[7]  <= WBL_DATA_IN7_r[30];
                            D_IN[8]  <= WBL_DATA_IN8_r[30];
                            D_IN[9]  <= WBL_DATA_IN9_r[30];
                            D_IN[10]  <= WBL_DATA_IN10_r[30];
                            D_IN[11]  <= WBL_DATA_IN11_r[30];
                            D_IN[12]  <= WBL_DATA_IN12_r[30];
                            D_IN[13]  <= WBL_DATA_IN13_r[30];
                            D_IN[14]  <= WBL_DATA_IN14_r[30];
                            D_IN[15]  <= WBL_DATA_IN15_r[30];
                            D_IN[16]  <= WBL_DATA_IN16_r[30];
                        end
                13'd2560:  begin PC_D_IN[0] <= 1'b1; end
                13'd2580:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[38];
                            D_IN[2]  <= WBL_DATA_IN2_r[38];
                            D_IN[3]  <= WBL_DATA_IN3_r[38];
                            D_IN[4]  <= WBL_DATA_IN4_r[38];
                            D_IN[5]  <= WBL_DATA_IN5_r[38];
                            D_IN[6]  <= WBL_DATA_IN6_r[38];
                            D_IN[7]  <= WBL_DATA_IN7_r[38];
                            D_IN[8]  <= WBL_DATA_IN8_r[38];
                            D_IN[9]  <= WBL_DATA_IN9_r[38];
                            D_IN[10]  <= WBL_DATA_IN10_r[38];
                            D_IN[11]  <= WBL_DATA_IN11_r[38];
                            D_IN[12]  <= WBL_DATA_IN12_r[38];
                            D_IN[13]  <= WBL_DATA_IN13_r[38];
                            D_IN[14]  <= WBL_DATA_IN14_r[38];
                            D_IN[15]  <= WBL_DATA_IN15_r[38];
                            D_IN[16]  <= WBL_DATA_IN16_r[38];
                        end
                13'd2600:  begin PC_D_IN[0] <= 1'b1; end
                13'd2620:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[46];
                            D_IN[2]  <= WBL_DATA_IN2_r[46];
                            D_IN[3]  <= WBL_DATA_IN3_r[46];
                            D_IN[4]  <= WBL_DATA_IN4_r[46];
                            D_IN[5]  <= WBL_DATA_IN5_r[46];
                            D_IN[6]  <= WBL_DATA_IN6_r[46];
                            D_IN[7]  <= WBL_DATA_IN7_r[46];
                            D_IN[8]  <= WBL_DATA_IN8_r[46];
                            D_IN[9]  <= WBL_DATA_IN9_r[46];
                            D_IN[10]  <= WBL_DATA_IN10_r[46];
                            D_IN[11]  <= WBL_DATA_IN11_r[46];
                            D_IN[12]  <= WBL_DATA_IN12_r[46];
                            D_IN[13]  <= WBL_DATA_IN13_r[46];
                            D_IN[14]  <= WBL_DATA_IN14_r[46];
                            D_IN[15]  <= WBL_DATA_IN15_r[46];
                            D_IN[16]  <= WBL_DATA_IN16_r[46];
                        end
                13'd2640:  begin PC_D_IN[0] <= 1'b1; end
                13'd2660:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[54];
                            D_IN[2]  <= WBL_DATA_IN2_r[54];
                            D_IN[3]  <= WBL_DATA_IN3_r[54];
                            D_IN[4]  <= WBL_DATA_IN4_r[54];
                            D_IN[5]  <= WBL_DATA_IN5_r[54];
                            D_IN[6]  <= WBL_DATA_IN6_r[54];
                            D_IN[7]  <= WBL_DATA_IN7_r[54];
                            D_IN[8]  <= WBL_DATA_IN8_r[54];
                            D_IN[9]  <= WBL_DATA_IN9_r[54];
                            D_IN[10]  <= WBL_DATA_IN10_r[54];
                            D_IN[11]  <= WBL_DATA_IN11_r[54];
                            D_IN[12]  <= WBL_DATA_IN12_r[54];
                            D_IN[13]  <= WBL_DATA_IN13_r[54];
                            D_IN[14]  <= WBL_DATA_IN14_r[54];
                            D_IN[15]  <= WBL_DATA_IN15_r[54];
                            D_IN[16]  <= WBL_DATA_IN16_r[54];
                        end
                13'd2680:  begin PC_D_IN[0] <= 1'b1; end
                13'd2700:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[62];
                            D_IN[2]  <= WBL_DATA_IN2_r[62];
                            D_IN[3]  <= WBL_DATA_IN3_r[62];
                            D_IN[4]  <= WBL_DATA_IN4_r[62];
                            D_IN[5]  <= WBL_DATA_IN5_r[62];
                            D_IN[6]  <= WBL_DATA_IN6_r[62];
                            D_IN[7]  <= WBL_DATA_IN7_r[62];
                            D_IN[8]  <= WBL_DATA_IN8_r[62];
                            D_IN[9]  <= WBL_DATA_IN9_r[62];
                            D_IN[10]  <= WBL_DATA_IN10_r[62];
                            D_IN[11]  <= WBL_DATA_IN11_r[62];
                            D_IN[12]  <= WBL_DATA_IN12_r[62];
                            D_IN[13]  <= WBL_DATA_IN13_r[62];
                            D_IN[14]  <= WBL_DATA_IN14_r[62];
                            D_IN[15]  <= WBL_DATA_IN15_r[62];
                            D_IN[16]  <= WBL_DATA_IN16_r[62];
                        end
                13'd2720:  begin PC_D_IN[0] <= 1'b1; end
                13'd2740: begin PC_D_IN[0] <= 1'b0; end
                13'd2760: begin end
                13'd2780: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd2782: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd2784: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd2786: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止
                        end
                // ================= 第 8 轮（索引 7,15,23,31,39,47,55,63） =================
                13'd2800:   begin
                            PC_D_IN[0] <= 1'b0; clk_out_WT <= 1'b0; DATA_VALID_IN<=1;
                        end
                13'd2801:   begin end
                13'd2802:   begin 
                            D_IN[1]  <= WBL_DATA_IN1_r[7];
                            D_IN[2]  <= WBL_DATA_IN2_r[7];
                            D_IN[3]  <= WBL_DATA_IN3_r[7];
                            D_IN[4]  <= WBL_DATA_IN4_r[7];
                            D_IN[5]  <= WBL_DATA_IN5_r[7];
                            D_IN[6]  <= WBL_DATA_IN6_r[7];
                            D_IN[7]  <= WBL_DATA_IN7_r[7];
                            D_IN[8]  <= WBL_DATA_IN8_r[7];
                            D_IN[9]  <= WBL_DATA_IN9_r[7];
                            D_IN[10]  <= WBL_DATA_IN10_r[7];
                            D_IN[11]  <= WBL_DATA_IN11_r[7];
                            D_IN[12]  <= WBL_DATA_IN12_r[7];
                            D_IN[13]  <= WBL_DATA_IN13_r[7];
                            D_IN[14]  <= WBL_DATA_IN14_r[7];
                            D_IN[15]  <= WBL_DATA_IN15_r[7];
                            D_IN[16]  <= WBL_DATA_IN16_r[7];
                        end
                13'd2840:  begin PC_D_IN[0] <= 1'b1; end // 第一层CLK↑
                13'd2860:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[15];
                            D_IN[2]  <= WBL_DATA_IN2_r[15];
                            D_IN[3]  <= WBL_DATA_IN3_r[15];
                            D_IN[4]  <= WBL_DATA_IN4_r[15];
                            D_IN[5]  <= WBL_DATA_IN5_r[15];
                            D_IN[6]  <= WBL_DATA_IN6_r[15];
                            D_IN[7]  <= WBL_DATA_IN7_r[15];
                            D_IN[8]  <= WBL_DATA_IN8_r[15];
                            D_IN[9]  <= WBL_DATA_IN9_r[15];
                            D_IN[10]  <= WBL_DATA_IN10_r[15];
                            D_IN[11]  <= WBL_DATA_IN11_r[15];
                            D_IN[12]  <= WBL_DATA_IN12_r[15];
                            D_IN[13]  <= WBL_DATA_IN13_r[15];
                            D_IN[14]  <= WBL_DATA_IN14_r[15];
                            D_IN[15]  <= WBL_DATA_IN15_r[15];
                            D_IN[16]  <= WBL_DATA_IN16_r[15];
                        end
                13'd2880:  begin PC_D_IN[0] <= 1'b1; end
                13'd2900:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[23];
                            D_IN[2]  <= WBL_DATA_IN2_r[23];
                            D_IN[3]  <= WBL_DATA_IN3_r[23];
                            D_IN[4]  <= WBL_DATA_IN4_r[23];
                            D_IN[5]  <= WBL_DATA_IN5_r[23];
                            D_IN[6]  <= WBL_DATA_IN6_r[23];
                            D_IN[7]  <= WBL_DATA_IN7_r[23];
                            D_IN[8]  <= WBL_DATA_IN8_r[23];
                            D_IN[9]  <= WBL_DATA_IN9_r[23];
                            D_IN[10]  <= WBL_DATA_IN10_r[23];
                            D_IN[11]  <= WBL_DATA_IN11_r[23];
                            D_IN[12]  <= WBL_DATA_IN12_r[23];
                            D_IN[13]  <= WBL_DATA_IN13_r[23];
                            D_IN[14]  <= WBL_DATA_IN14_r[23];
                            D_IN[15]  <= WBL_DATA_IN15_r[23];
                            D_IN[16]  <= WBL_DATA_IN16_r[23];
                        end
                13'd2920:  begin PC_D_IN[0] <= 1'b1; end
                13'd2940:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[31];
                            D_IN[2]  <= WBL_DATA_IN2_r[31];
                            D_IN[3]  <= WBL_DATA_IN3_r[31];
                            D_IN[4]  <= WBL_DATA_IN4_r[31];
                            D_IN[5]  <= WBL_DATA_IN5_r[31];
                            D_IN[6]  <= WBL_DATA_IN6_r[31];
                            D_IN[7]  <= WBL_DATA_IN7_r[31];
                            D_IN[8]  <= WBL_DATA_IN8_r[31];
                            D_IN[9]  <= WBL_DATA_IN9_r[31];
                            D_IN[10]  <= WBL_DATA_IN10_r[31];
                            D_IN[11]  <= WBL_DATA_IN11_r[31];
                            D_IN[12]  <= WBL_DATA_IN12_r[31];
                            D_IN[13]  <= WBL_DATA_IN13_r[31];
                            D_IN[14]  <= WBL_DATA_IN14_r[31];
                            D_IN[15]  <= WBL_DATA_IN15_r[31];
                            D_IN[16]  <= WBL_DATA_IN16_r[31];
                        end
                13'd2960:  begin PC_D_IN[0] <= 1'b1; end
                13'd2980:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[39];
                            D_IN[2]  <= WBL_DATA_IN2_r[39];
                            D_IN[3]  <= WBL_DATA_IN3_r[39];
                            D_IN[4]  <= WBL_DATA_IN4_r[39];
                            D_IN[5]  <= WBL_DATA_IN5_r[39];
                            D_IN[6]  <= WBL_DATA_IN6_r[39];
                            D_IN[7]  <= WBL_DATA_IN7_r[39];
                            D_IN[8]  <= WBL_DATA_IN8_r[39];
                            D_IN[9]  <= WBL_DATA_IN9_r[39];
                            D_IN[10]  <= WBL_DATA_IN10_r[39];
                            D_IN[11]  <= WBL_DATA_IN11_r[39];
                            D_IN[12]  <= WBL_DATA_IN12_r[39];
                            D_IN[13]  <= WBL_DATA_IN13_r[39];
                            D_IN[14]  <= WBL_DATA_IN14_r[39];
                            D_IN[15]  <= WBL_DATA_IN15_r[39];
                            D_IN[16]  <= WBL_DATA_IN16_r[39];
                        end
                13'd3000:  begin PC_D_IN[0] <= 1'b1; end
                13'd3020:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[47];
                            D_IN[2]  <= WBL_DATA_IN2_r[47];
                            D_IN[3]  <= WBL_DATA_IN3_r[47];
                            D_IN[4]  <= WBL_DATA_IN4_r[47];
                            D_IN[5]  <= WBL_DATA_IN5_r[47];
                            D_IN[6]  <= WBL_DATA_IN6_r[47];
                            D_IN[7]  <= WBL_DATA_IN7_r[47];
                            D_IN[8]  <= WBL_DATA_IN8_r[47];
                            D_IN[9]  <= WBL_DATA_IN9_r[47];
                            D_IN[10]  <= WBL_DATA_IN10_r[47];
                            D_IN[11]  <= WBL_DATA_IN11_r[47];
                            D_IN[12]  <= WBL_DATA_IN12_r[47];
                            D_IN[13]  <= WBL_DATA_IN13_r[47];
                            D_IN[14]  <= WBL_DATA_IN14_r[47];
                            D_IN[15]  <= WBL_DATA_IN15_r[47];
                            D_IN[16]  <= WBL_DATA_IN16_r[47];
                        end
                13'd3040:  begin PC_D_IN[0] <= 1'b1; end
                13'd3060:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[55];
                            D_IN[2]  <= WBL_DATA_IN2_r[55];
                            D_IN[3]  <= WBL_DATA_IN3_r[55];
                            D_IN[4]  <= WBL_DATA_IN4_r[55];
                            D_IN[5]  <= WBL_DATA_IN5_r[55];
                            D_IN[6]  <= WBL_DATA_IN6_r[55];
                            D_IN[7]  <= WBL_DATA_IN7_r[55];
                            D_IN[8]  <= WBL_DATA_IN8_r[55];
                            D_IN[9]  <= WBL_DATA_IN9_r[55];
                            D_IN[10]  <= WBL_DATA_IN10_r[55];
                            D_IN[11]  <= WBL_DATA_IN11_r[55];
                            D_IN[12]  <= WBL_DATA_IN12_r[55];
                            D_IN[13]  <= WBL_DATA_IN13_r[55];
                            D_IN[14]  <= WBL_DATA_IN14_r[55];
                            D_IN[15]  <= WBL_DATA_IN15_r[55];
                            D_IN[16]  <= WBL_DATA_IN16_r[55];
                        end
                13'd3080:  begin PC_D_IN[0] <= 1'b1; end
                13'd3100:  begin 
                            PC_D_IN[0] <= 1'b0; 
                            D_IN[1]  <= WBL_DATA_IN1_r[63];
                            D_IN[2]  <= WBL_DATA_IN2_r[63];
                            D_IN[3]  <= WBL_DATA_IN3_r[63];
                            D_IN[4]  <= WBL_DATA_IN4_r[63];
                            D_IN[5]  <= WBL_DATA_IN5_r[63];
                            D_IN[6]  <= WBL_DATA_IN6_r[63];
                            D_IN[7]  <= WBL_DATA_IN7_r[63];
                            D_IN[8]  <= WBL_DATA_IN8_r[63];
                            D_IN[9]  <= WBL_DATA_IN9_r[63];
                            D_IN[10]  <= WBL_DATA_IN10_r[63];
                            D_IN[11]  <= WBL_DATA_IN11_r[63];
                            D_IN[12]  <= WBL_DATA_IN12_r[63];
                            D_IN[13]  <= WBL_DATA_IN13_r[63];
                            D_IN[14]  <= WBL_DATA_IN14_r[63];
                            D_IN[15]  <= WBL_DATA_IN15_r[63];
                            D_IN[16]  <= WBL_DATA_IN16_r[63];
                        end
                13'd3120:  begin PC_D_IN[0] <= 1'b1; end
                13'd3140: begin PC_D_IN[0] <= 1'b0; end
                13'd3160: begin end
                13'd3180: begin PC_D_IN[0] <= 1'b0; end

                // ================= 第二层并转串——单次写周期 =================
                13'd3182: begin 
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b0; // 使能串转并  
                        end
                13'd3184: begin
                            clk_out_WT <= 1'b1; DATA_VALID_IN <= 1'b0; // 保持使能  
                        end
                13'd3186: begin
                            clk_out_WT <= 1'b0; DATA_VALID_IN <= 1'b1; // 停止数据准备
                            // 输入地址的串转并
                            ADD_IN <= WWL_ADD_r[5]; ADD_VALID_IN <= 1'b0;// 有效是低电平
                        end
                // 完成输入数据的串转并
                // 准备输入地址的串转并
                13'd3188: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3190: begin
                            clk_out_WT <= 1'b0;
                            ADD_IN <= WWL_ADD_r[4];
                        end
                13'd3192: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3194: begin
                            clk_out_WT <= 1'b0;
                            ADD_IN <= WWL_ADD_r[3];
                        end
                13'd3196: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3198: begin
                            clk_out_WT <= 1'b0;
                            ADD_IN <= WWL_ADD_r[2];
                        end
                13'd3200: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3202: begin
                            clk_out_WT <= 1'b0;
                            ADD_IN <= WWL_ADD_r[1];
                        end
                13'd3204: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3206: begin
                            clk_out_WT <= 1'b0;
                            ADD_IN <= WWL_ADD_r[0];
                        end
                13'd3208: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3210: begin
                            clk_out_WT <= 1'b0;
                            ADD_VALID_IN <= 1'b1;// 结束地址移位
                        end
                13'd3212: begin
                            clk_out_WT <= 1'b1;
                        end
                13'd3214: begin
                            clk_out_WT <= 1'b0;
                        end
                13'd3216: begin WRI_EN<=1;end
                13'd3218: begin end
                13'd3220: begin end
                13'd3222: begin end
                13'd3224: begin WRI_EN<=0; WR_flag<=0; end
                13'd3226: begin  WT_DONE_r <= 1; end
                13'd3230: begin  WT_DONE_r <= 0; end
                default: begin end
                endcase
            end
            else begin
                // 非写或未使能：保持输出安全值（可根据需要清零）
                D_IN <= D_IN; 
                PC_D_IN <= PC_D_IN; 
                clk_out_WT <= clk_out_WT;
                DATA_VALID_IN<=DATA_VALID_IN; 
                ADD_IN<=ADD_IN; 
                ADD_VALID_IN<=ADD_VALID_IN; 
                WRI_EN<=WRI_EN; 
                WR_flag<=WR_flag;
            end
        end
    end
//
    // read data from DRAM 
    reg RD_EN_pre;
    // reg CLK_out_RD;
    // reg read_data; // DRAM寄存数据
    reg PC_DATA_CLK;
    reg PC_DATA_CLK_INH; // 一直为低电平
    reg PC_DATA_SHLD;
    //PC并转串控制信号 PC[0]=clk PC[1]=SR/LD# PC[2]=CLK_INV
    assign PC_data = {PC_DATA_CLK_INH, PC_DATA_SHLD, PC_DATA_CLK}; 

    wire Read_en;
    assign Read_en = IO_EN_FLAG && (IO_MODEL_r == 2'b10); // 写使能信号，写的时候为高电平
    reg Read_en_r;
    always @ (posedge clk_400m or negedge rst_n) begin
        if(!rst_n)begin 
            Read_en_r <= 1'b0;
        end
        else begin
            Read_en_r <= Read_en;
        end
    end
    always @(posedge clk_400m or negedge rst_n) begin
        if(!rst_n)begin
            DRAM_DATA_OUT1_r <= 8'd0; DRAM_DATA_OUT2_r <= 8'd0; DRAM_DATA_OUT3_r <= 8'd0; DRAM_DATA_OUT4_r <= 8'd0; DRAM_DATA_OUT5_r <= 8'd0; DRAM_DATA_OUT6_r <= 8'd0; DRAM_DATA_OUT7_r <= 8'd0; DRAM_DATA_OUT8_r <= 8'd0;
            DRAM_DATA_OUT9_r <= 8'd0; DRAM_DATA_OUT10_r <= 8'd0; DRAM_DATA_OUT11_r <= 8'd0; DRAM_DATA_OUT12_r <= 8'd0; DRAM_DATA_OUT13_r <= 8'd0; DRAM_DATA_OUT14_r <= 8'd0; DRAM_DATA_OUT15_r <= 8'd0; DRAM_DATA_OUT16_r <= 8'd0;
            RD_DONE_r <= 1'b0; RD_EN_pre <= 1'b0; REF_WWL <= 1'b1;
            PC_R_AD <= 2'd0; R_AD <= 16'd0;
            // PC_DATA串转并控制信号
            PC_DATA_CLK <= 1'b0;
            PC_DATA_CLK_INH <= 1'b0;
            PC_DATA_SHLD <= 1'b0;
        end
        else begin
            // if ( IO_EN_FLAG && (IO_MODEL_r == 2'b10) ) begin
            if ( Read_en_r ) begin
                case(counter_work)
                13'd0: begin
                    DRAM_DATA_OUT1_r <= 8'd0; DRAM_DATA_OUT2_r <= 8'd0; DRAM_DATA_OUT3_r <= 8'd0; DRAM_DATA_OUT4_r <= 8'd0; DRAM_DATA_OUT5_r <= 8'd0; DRAM_DATA_OUT6_r <= 8'd0; DRAM_DATA_OUT7_r <= 8'd0; DRAM_DATA_OUT8_r <= 8'd0;
                    DRAM_DATA_OUT9_r <= 8'd0; DRAM_DATA_OUT10_r <= 8'd0; DRAM_DATA_OUT11_r <= 8'd0; DRAM_DATA_OUT12_r <= 8'd0; DRAM_DATA_OUT13_r <= 8'd0; DRAM_DATA_OUT14_r <= 8'd0; DRAM_DATA_OUT15_r <= 8'd0; DRAM_DATA_OUT16_r <= 8'd0;
                    RD_DONE_r <= 1'b0; RD_EN_pre <= 1'b0; REF_WWL <= 1'b1;
                    PC_R_AD <= 2'd0; R_AD <= 16'd0;
                    PC_DATA_CLK <= 1'b0;
                    PC_DATA_CLK_INH <= 1'b0;
                    PC_DATA_SHLD <= 1'b0;
                end
                13'd1: begin
                    R_AD[1] <=  DEMUX_ADD1 [1]; 
                    R_AD[2] <=  DEMUX_ADD2 [1]; 
                    R_AD[3] <=  DEMUX_ADD3 [1]; 
                    R_AD[4] <=  DEMUX_ADD4 [1]; 
                    R_AD[5] <=  DEMUX_ADD5 [1]; 
                    R_AD[6] <=  DEMUX_ADD6 [1]; 
                    R_AD[7] <=  DEMUX_ADD7 [1]; 
                    R_AD[8] <=  DEMUX_ADD8 [1]; 
                    R_AD[9] <=  DEMUX_ADD9 [1]; 
                    R_AD[10] <= DEMUX_ADD10[1]; 
                    R_AD[11] <= DEMUX_ADD11[1]; 
                    R_AD[12] <= DEMUX_ADD12[1]; 
                    R_AD[13] <= DEMUX_ADD13[1]; 
                    R_AD[14] <= DEMUX_ADD14[1]; 
                    R_AD[15] <= DEMUX_ADD15[1]; 
                    R_AD[16] <= DEMUX_ADD16[1]; 
                end
                13'd20: begin PC_R_AD[1] <= 1'b1; end// 取消复位
                13'd40: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd60: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  DEMUX_ADD1 [0]; 
                    R_AD[2] <=  DEMUX_ADD2 [0]; 
                    R_AD[3] <=  DEMUX_ADD3 [0]; 
                    R_AD[4] <=  DEMUX_ADD4 [0]; 
                    R_AD[5] <=  DEMUX_ADD5 [0]; 
                    R_AD[6] <=  DEMUX_ADD6 [0]; 
                    R_AD[7] <=  DEMUX_ADD7 [0]; 
                    R_AD[8] <=  DEMUX_ADD8 [0]; 
                    R_AD[9] <=  DEMUX_ADD9 [0]; 
                    R_AD[10] <= DEMUX_ADD10[0]; 
                    R_AD[11] <= DEMUX_ADD11[0]; 
                    R_AD[12] <= DEMUX_ADD12[0]; 
                    R_AD[13] <= DEMUX_ADD13[0]; 
                    R_AD[14] <= DEMUX_ADD14[0]; 
                    R_AD[15] <= DEMUX_ADD15[0]; 
                    R_AD[16] <= DEMUX_ADD16[0];
                end 
                13'd80: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd100: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [5]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [5]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [5]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [5]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [5]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [5]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [5]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [5]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [5]; 
                    R_AD[10] <= RWL_DEC_ADD10[5]; 
                    R_AD[11] <= RWL_DEC_ADD11[5]; 
                    R_AD[12] <= RWL_DEC_ADD12[5]; 
                    R_AD[13] <= RWL_DEC_ADD13[5]; 
                    R_AD[14] <= RWL_DEC_ADD14[5]; 
                    R_AD[15] <= RWL_DEC_ADD15[5]; 
                    R_AD[16] <= RWL_DEC_ADD16[5];                     
                end 
                13'd120: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd140: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [4]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [4]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [4]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [4]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [4]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [4]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [4]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [4]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [4]; 
                    R_AD[10] <= RWL_DEC_ADD10[4]; 
                    R_AD[11] <= RWL_DEC_ADD11[4]; 
                    R_AD[12] <= RWL_DEC_ADD12[4]; 
                    R_AD[13] <= RWL_DEC_ADD13[4]; 
                    R_AD[14] <= RWL_DEC_ADD14[4]; 
                    R_AD[15] <= RWL_DEC_ADD15[4]; 
                    R_AD[16] <= RWL_DEC_ADD16[4];                     
                end 
                13'd160: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd180: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [3]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [3]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [3]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [3]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [3]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [3]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [3]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [3]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [3]; 
                    R_AD[10] <= RWL_DEC_ADD10[3]; 
                    R_AD[11] <= RWL_DEC_ADD11[3]; 
                    R_AD[12] <= RWL_DEC_ADD12[3]; 
                    R_AD[13] <= RWL_DEC_ADD13[3]; 
                    R_AD[14] <= RWL_DEC_ADD14[3]; 
                    R_AD[15] <= RWL_DEC_ADD15[3]; 
                    R_AD[16] <= RWL_DEC_ADD16[3];                     
                end 
                13'd200: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd220: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [2]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [2]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [2]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [2]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [2]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [2]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [2]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [2]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [2]; 
                    R_AD[10] <= RWL_DEC_ADD10[2]; 
                    R_AD[11] <= RWL_DEC_ADD11[2]; 
                    R_AD[12] <= RWL_DEC_ADD12[2]; 
                    R_AD[13] <= RWL_DEC_ADD13[2]; 
                    R_AD[14] <= RWL_DEC_ADD14[2]; 
                    R_AD[15] <= RWL_DEC_ADD15[2]; 
                    R_AD[16] <= RWL_DEC_ADD16[2];                     
                end 
                13'd240: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd260: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [1]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [1]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [1]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [1]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [1]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [1]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [1]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [1]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [1]; 
                    R_AD[10] <= RWL_DEC_ADD10[1]; 
                    R_AD[11] <= RWL_DEC_ADD11[1]; 
                    R_AD[12] <= RWL_DEC_ADD12[1]; 
                    R_AD[13] <= RWL_DEC_ADD13[1]; 
                    R_AD[14] <= RWL_DEC_ADD14[1]; 
                    R_AD[15] <= RWL_DEC_ADD15[1]; 
                    R_AD[16] <= RWL_DEC_ADD16[1];                     
                end 
                13'd280: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿 
                13'd300: begin 
                    PC_R_AD[1] <= 1'b0; 
                    R_AD[1] <=  RWL_DEC_ADD1 [0]; 
                    R_AD[2] <=  RWL_DEC_ADD2 [0]; 
                    R_AD[3] <=  RWL_DEC_ADD3 [0]; 
                    R_AD[4] <=  RWL_DEC_ADD4 [0]; 
                    R_AD[5] <=  RWL_DEC_ADD5 [0]; 
                    R_AD[6] <=  RWL_DEC_ADD6 [0]; 
                    R_AD[7] <=  RWL_DEC_ADD7 [0]; 
                    R_AD[8] <=  RWL_DEC_ADD8 [0]; 
                    R_AD[9] <=  RWL_DEC_ADD9 [0]; 
                    R_AD[10] <= RWL_DEC_ADD10[0]; 
                    R_AD[11] <= RWL_DEC_ADD11[0]; 
                    R_AD[12] <= RWL_DEC_ADD12[0]; 
                    R_AD[13] <= RWL_DEC_ADD13[0]; 
                    R_AD[14] <= RWL_DEC_ADD14[0]; 
                    R_AD[15] <= RWL_DEC_ADD15[0]; 
                    R_AD[16] <= RWL_DEC_ADD16[0];                     
                end 
                13'd320: begin PC_R_AD[0] <= 1'b1; end // CLK上升沿
                13'd340: begin PC_R_AD[0] <= 1'b0; end
                13'd341: begin end
                13'd342: begin end
                13'd341: begin REF_WWL<=0; RD_EN_pre<=1; end
                13'd342: begin RD_EN_pre<=0; end
                13'd343: begin REF_WWL<=1; end
                // 位串行寄存输出数据
                // PC_DATA_CLK <= 1'b0;
                // PC_DATA_CLK_INH <= 1'b0;
                // PC_DATA_SHLD <= 1'b0;
                // SH/LD保持一段时间来寄存输出 保持10ns以上
                13'd344: begin end
                13'd345: begin end
                13'd346: begin end
                13'd347: begin end
                13'd348: begin end
                13'd349: begin end
                13'd350: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [0] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [0] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [0] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [0] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [0] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [0] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [0] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [0] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [0] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [0] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [0] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [0] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [0] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [0] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [0] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [0] <= DRAM16_data[16];
                end
                13'd370: begin PC_DATA_CLK <= 1'b1; end
                13'd390: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [1] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [1] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [1] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [1] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [1] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [1] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [1] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [1] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [1] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [1] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [1] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [1] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [1] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [1] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [1] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [1] <= DRAM16_data[16];
                end
                13'd410: begin PC_DATA_CLK <= 1'b1; end
                13'd430: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [2] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [2] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [2] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [2] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [2] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [2] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [2] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [2] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [2] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [2] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [2] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [2] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [2] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [2] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [2] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [2] <= DRAM16_data[16];
                end
                13'd450: begin PC_DATA_CLK <= 1'b1; end
                13'd470: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [3] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [3] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [3] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [3] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [3] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [3] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [3] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [3] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [3] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [3] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [3] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [3] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [3] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [3] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [3] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [3] <= DRAM16_data[16];
                end
                13'd490: begin PC_DATA_CLK <= 1'b1; end
                13'd510: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [4] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [4] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [4] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [4] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [4] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [4] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [4] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [4] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [4] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [4] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [4] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [4] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [4] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [4] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [4] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [4] <= DRAM16_data[16];
                end
                13'd530: begin PC_DATA_CLK <= 1'b1; end
                13'd550: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [5] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [5] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [5] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [5] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [5] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [5] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [5] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [5] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [5] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [5] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [5] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [5] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [5] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [5] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [5] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [5] <= DRAM16_data[16];
                end
                13'd570: begin PC_DATA_CLK <= 1'b1; end
                13'd590: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [6] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [6] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [6] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [6] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [6] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [6] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [6] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [6] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [6] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [6] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [6] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [6] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [6] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [6] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [6] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [6] <= DRAM16_data[16];
                end
                13'd610: begin PC_DATA_CLK <= 1'b1; end
                13'd630: begin 
                    PC_DATA_CLK <= 1'b0;
                    DRAM_DATA_OUT1_r [7] <= DRAM16_data[1];
                    DRAM_DATA_OUT2_r [7] <= DRAM16_data[2];
                    DRAM_DATA_OUT3_r [7] <= DRAM16_data[3];
                    DRAM_DATA_OUT4_r [7] <= DRAM16_data[4];
                    DRAM_DATA_OUT5_r [7] <= DRAM16_data[5];
                    DRAM_DATA_OUT6_r [7] <= DRAM16_data[6];
                    DRAM_DATA_OUT7_r [7] <= DRAM16_data[7];
                    DRAM_DATA_OUT8_r [7] <= DRAM16_data[8];
                    DRAM_DATA_OUT9_r [7] <= DRAM16_data[9];
                    DRAM_DATA_OUT10_r [7] <= DRAM16_data[10];
                    DRAM_DATA_OUT11_r [7] <= DRAM16_data[11];
                    DRAM_DATA_OUT12_r [7] <= DRAM16_data[12];
                    DRAM_DATA_OUT13_r [7] <= DRAM16_data[13];
                    DRAM_DATA_OUT14_r [7] <= DRAM16_data[14];
                    DRAM_DATA_OUT15_r [7] <= DRAM16_data[15];
                    DRAM_DATA_OUT16_r [7] <= DRAM16_data[16];
                end
                // 读出完毕
                13'd632: begin RD_DONE_r <= 1; end
                13'd636: begin RD_DONE_r <= 0; end
                default: begin end
                endcase
            end
        end
    end
    
    assign LIM_IN=DATA_IN_r;     // LIM_IN, LIM输入 16块芯片的算输入数据
    assign LIM_SEL=CIM_model_r;  // 存算模式选择
    // 插入逻辑门延时  具体延时多少是试出来的
    //read delay generate
    (*dont_touch="yes"*)wire RD_EN1;
    (*dont_touch="yes"*)wire RD_EN2;
    (*dont_touch="yes"*)wire RD_EN3;
    (*dont_touch="yes"*)wire RD_EN4;
    (*dont_touch="yes"*)wire RD_EN5;
    (*dont_touch="yes"*)wire RD_EN6;
    (*dont_touch="yes"*)assign RD_EN1=RD_EN_pre&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN2=RD_EN1&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN3=RD_EN2&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN4=RD_EN3&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN=RD_EN4&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN5=RD_EN&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN6=RD_EN5&(!WR_flag);
    //(*dont_touch="yes"*)assign VSAEN=RD_EN6&(!WR_flag);
    (*dont_touch="yes"*)wire RD_EN7;
    (*dont_touch="yes"*)wire RD_EN8;
    (*dont_touch="yes"*)assign RD_EN7=RD_EN6&(!WR_flag);
    (*dont_touch="yes"*)assign RD_EN8=RD_EN7&(!WR_flag);
    (*dont_touch="yes"*)assign VSAEN=RD_EN8&(!WR_flag);

endmodule
