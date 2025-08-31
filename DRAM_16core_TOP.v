`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/30 20:24:42
// Design Name: 
// Module Name: DRAM_16core_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  与功能实现DRAM读取
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DRAM_16core_TOP(
    input wire clk,
    input wire rst_n,
    // 使能读写
    input IO_EN, 
    input [1:0] IO_MODEL, // 01写, 10读
    // 16块芯片的输入数据
    input wire [63:0]WT_DATA1,
    input wire [63:0]WT_DATA2,
    input wire [63:0]WT_DATA3,
    input wire [63:0]WT_DATA4,
    input wire [63:0]WT_DATA5,
    input wire [63:0]WT_DATA6,
    input wire [63:0]WT_DATA7,
    input wire [63:0]WT_DATA8,
    input wire [63:0]WT_DATA9,
    input wire [63:0]WT_DATA10,
    input wire [63:0]WT_DATA11,
    input wire [63:0]WT_DATA12,
    input wire [63:0]WT_DATA13,
    input wire [63:0]WT_DATA14,
    input wire [63:0]WT_DATA15,
    input wire [63:0]WT_DATA16,
    // 16块芯片的输入地址
    input wire [5:0] WT_address,
    // 读出
    input [7:0] RD_address,
    // 输出输出
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
    // 读出使能信号
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
    // 读出地址 16块暂不共用
    reg [5:0]RWL_DEC_ADD1;
    reg [5:0]RWL_DEC_ADD2;
    reg [5:0]RWL_DEC_ADD3;
    reg [5:0]RWL_DEC_ADD4;
    reg [5:0]RWL_DEC_ADD5;
    reg [5:0]RWL_DEC_ADD6;
    reg [5:0]RWL_DEC_ADD7;
    reg [5:0]RWL_DEC_ADD8;
    reg [5:0]RWL_DEC_ADD9;
    reg [5:0]RWL_DEC_ADD10;
    reg [5:0]RWL_DEC_ADD11;
    reg [5:0]RWL_DEC_ADD12;
    reg [5:0]RWL_DEC_ADD13;
    reg [5:0]RWL_DEC_ADD14;
    reg [5:0]RWL_DEC_ADD15;
    reg [5:0]RWL_DEC_ADD16;
    reg [1:0]DEMUX_ADD1;
    reg [1:0]DEMUX_ADD2;
    reg [1:0]DEMUX_ADD3;
    reg [1:0]DEMUX_ADD4;
    reg [1:0]DEMUX_ADD5;
    reg [1:0]DEMUX_ADD6;
    reg [1:0]DEMUX_ADD7;
    reg [1:0]DEMUX_ADD8;
    reg [1:0]DEMUX_ADD9;
    reg [1:0]DEMUX_ADD10;
    reg [1:0]DEMUX_ADD11;
    reg [1:0]DEMUX_ADD12;
    reg [1:0]DEMUX_ADD13;
    reg [1:0]DEMUX_ADD14;
    reg [1:0]DEMUX_ADD15;
    reg [1:0]DEMUX_ADD16;
    reg DEMUX_ADD_3;
    // generate clock
    wire clk_400m;
    wire clk_100m;
    wire clk_locked;
    wire rst_n_locked;
    assign rst_n_locked = rst_n & clk_locked;
    clk_wiz_400m u_clk_wiz_400m(
        .clk_400m(clk_400m),
        .clk_100m(clk_100m),
        .locked(clk_locked),
        .clk(clk)
    );
    DRAM_write_read_16core u_DRAM_write_read_16core (
        .clk_100m(clk_100m), 
        .clk_400m(clk_400m), 
        .rst_n(rst_n), 
        .IO_EN(IO_EN), 
        .IO_MODEL(IO_MODEL), 
        .CIM_model(CIM_model),       // 与功能 10
        .DATA_IN(DATA_IN),           // 全拉高
        .WBL_DATA_IN1(WBL_DATA_IN1), 
        .WBL_DATA_IN2(WBL_DATA_IN2), 
        .WBL_DATA_IN3(WBL_DATA_IN3), 
        .WBL_DATA_IN4(WBL_DATA_IN4), 
        .WBL_DATA_IN5(WBL_DATA_IN5), 
        .WBL_DATA_IN6(WBL_DATA_IN6), 
        .WBL_DATA_IN7(WBL_DATA_IN7), 
        .WBL_DATA_IN8(WBL_DATA_IN8), 
        .WBL_DATA_IN9(WBL_DATA_IN9), 
        .WBL_DATA_IN10(WBL_DATA_IN10), 
        .WBL_DATA_IN11(WBL_DATA_IN11), 
        .WBL_DATA_IN12(WBL_DATA_IN12), 
        .WBL_DATA_IN13(WBL_DATA_IN13), 
        .WBL_DATA_IN14(WBL_DATA_IN14), 
        .WBL_DATA_IN15(WBL_DATA_IN15), 
        .WBL_DATA_IN16(WBL_DATA_IN16), 
        .WWL_ADD(WWL_ADD), 
        .RWL_DEC_ADD1(RWL_DEC_ADD1), 
        .RWL_DEC_ADD2(RWL_DEC_ADD2), 
        .RWL_DEC_ADD3(RWL_DEC_ADD3), 
        .RWL_DEC_ADD4(RWL_DEC_ADD4), 
        .RWL_DEC_ADD5(RWL_DEC_ADD5), 
        .RWL_DEC_ADD6(RWL_DEC_ADD6), 
        .RWL_DEC_ADD7(RWL_DEC_ADD7), 
        .RWL_DEC_ADD8(RWL_DEC_ADD8), 
        .RWL_DEC_ADD9(RWL_DEC_ADD9), 
        .RWL_DEC_ADD10(RWL_DEC_ADD10), 
        .RWL_DEC_ADD11(RWL_DEC_ADD11), 
        .RWL_DEC_ADD12(RWL_DEC_ADD12), 
        .RWL_DEC_ADD13(RWL_DEC_ADD13), 
        .RWL_DEC_ADD14(RWL_DEC_ADD14), 
        .RWL_DEC_ADD15(RWL_DEC_ADD15), 
        .RWL_DEC_ADD16(RWL_DEC_ADD16), 
        .DEMUX_ADD1(DEMUX_ADD1), 
        .DEMUX_ADD2(DEMUX_ADD2), 
        .DEMUX_ADD3(DEMUX_ADD3), 
        .DEMUX_ADD4(DEMUX_ADD4), 
        .DEMUX_ADD5(DEMUX_ADD5), 
        .DEMUX_ADD6(DEMUX_ADD6), 
        .DEMUX_ADD7(DEMUX_ADD7), 
        .DEMUX_ADD8(DEMUX_ADD8), 
        .DEMUX_ADD9(DEMUX_ADD9), 
        .DEMUX_ADD10(DEMUX_ADD10), 
        .DEMUX_ADD11(DEMUX_ADD11), 
        .DEMUX_ADD12(DEMUX_ADD12), 
        .DEMUX_ADD13(DEMUX_ADD13), 
        .DEMUX_ADD14(DEMUX_ADD14), 
        .DEMUX_ADD15(DEMUX_ADD15), 
        .DEMUX_ADD16(DEMUX_ADD16), 
        .DEMUX_ADD_3(DEMUX_ADD_3), 
        .DRAM_DATA_OUT1(DRAM_DATA_OUT1), 
        .DRAM_DATA_OUT2(DRAM_DATA_OUT2), 
        .DRAM_DATA_OUT3(DRAM_DATA_OUT3), 
        .DRAM_DATA_OUT4(DRAM_DATA_OUT4), 
        .DRAM_DATA_OUT5(DRAM_DATA_OUT5), 
        .DRAM_DATA_OUT6(DRAM_DATA_OUT6), 
        .DRAM_DATA_OUT7(DRAM_DATA_OUT7), 
        .DRAM_DATA_OUT8(DRAM_DATA_OUT8), 
        .DRAM_DATA_OUT9(DRAM_DATA_OUT9), 
        .DRAM_DATA_OUT10(DRAM_DATA_OUT10), 
        .DRAM_DATA_OUT11(DRAM_DATA_OUT11), 
        .DRAM_DATA_OUT12(DRAM_DATA_OUT12), 
        .DRAM_DATA_OUT13(DRAM_DATA_OUT13), 
        .DRAM_DATA_OUT14(DRAM_DATA_OUT14), 
        .DRAM_DATA_OUT15(DRAM_DATA_OUT15), 
        .DRAM_DATA_OUT16(DRAM_DATA_OUT16), 
        .RD_DONE(RD_DONE), 
        .WT_DONE(WT_DONE), 
        .DRAM16_data(DRAM16_data), 
        .PC_data(PC_data), 
        .ADD_IN(ADD_IN), 
        .ADD_VALID_IN(ADD_VALID_IN), 
        .PC_D_IN(PC_D_IN), 
        .D_IN(D_IN), 
        .DATA_VALID_IN(DATA_VALID_IN), 
        .clk_out(clk_out), 
        .WRI_EN(WRI_EN), 
        .R_AD(R_AD), 
        .PC_R_AD(PC_R_AD), 
        .LIM_IN(LIM_IN), 
        .LIM_SEL(LIM_SEL), 
        .DE_ADD3(DE_ADD3), 
        .RD_EN(RD_EN), 
        .VSAEN(VSAEN), 
        .REF_WWL(REF_WWL)
    );


endmodule
