`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/29 19:26:05
// Design Name: 
// Module Name: tb_write_read
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
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_write_read;

    // 信号声明
    reg clk;
    reg rst_n;
    reg IO_EN;
    reg [1:0] IO_MODEL;
    reg [16:1] DRAM16_data;
    wire RD_DONE;
    wire WT_DONE;
    wire [2:0] PC_data;
    wire ADD_IN;
    wire ADD_VALID_IN;
    wire [1:0] PC_D_IN;
    wire [16:1] D_IN;
    wire DATA_VALID_IN;
    wire clk_out;
    wire WRI_EN;
    wire [16:1] R_AD;
    wire [1:0] PC_R_AD;
    wire [16:1] LIM_IN;
    wire [1:0] LIM_SEL;
    wire DE_ADD3;
    wire RD_EN;
    wire VSAEN;
    wire REF_WWL;
    initial begin 
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        // rst_n = 0;
        // IO_EN = 0;
        // IO_MODEL = 2'b00;
        // DRAM16_data = 16'hA5A5;
        // #600;
        // #10;
        // rst_n = 1;
        // #10;
        // IO_EN = 1;
        // IO_MODEL = 2'b01;
        // #10;
        // IO_EN = 0;
        // // #10;
        // // IO_EN = 1;
        // // IO_MODEL = 2'b10;
        // // #10;
        // // IO_EN = 0;
        // #10;
        // wait(WT_DONE);
        
        rst_n = 0;
        IO_EN = 0;
        IO_MODEL = 2'b00;
        DRAM16_data = 16'hA5A5;
        #600;
        #10;
        rst_n = 1;
        #10;
        IO_EN = 1;
        IO_MODEL = 2'b10;
        // #10;
        // IO_EN = 0;
        // #10;
        // IO_EN = 1;
        // IO_MODEL = 2'b10;
        #10;
        IO_EN = 0;
        #10;
        wait(RD_DONE);
        $finish;
    end

    // DUT实例化
    test_write_read utest_write_read (
        .clk(clk),
        .rst_n(rst_n),
        .IO_EN(IO_EN),
        .IO_MODEL(IO_MODEL),
        .DRAM16_data(DRAM16_data),
        .RD_DONE(RD_DONE),
        .WT_DONE(WT_DONE),
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

    // 时钟和复位等激励可在此添加

endmodule
