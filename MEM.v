`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:27:50
// Design Name: 
// Module Name: MEM
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



module MEMWB(clk,regwrite,memtoreg,memread,readdata,aluresult,rd_in,regwrite_out,memtoreg_out,memread_out,readdata_out,aluresult_out,rd_out);
    input clk,regwrite,memtoreg,memread;
    input [31:0] readdata;
    input [31:0] aluresult;
    input [4:0] rd_in;
    output reg regwrite_out,memtoreg_out,memread_out;
    output reg [31:0] readdata_out;
    output reg [31:0] aluresult_out;
    output reg [4:0] rd_out;
    always @(posedge clk) begin
        regwrite_out = regwrite;
        memtoreg_out = memtoreg;
        readdata_out = readdata;
        aluresult_out = aluresult;
        rd_out = rd_in;
        memread_out = memread;
    end
endmodule

module LwswHazard(rs2_mem,rd_wb,memread_wb,memwrite_mem,memsrc);
    input memread_wb,memwrite_mem;
    input [4:0] rs2_mem;
    input [4:0] rd_wb;
    output reg memsrc;
    initial begin
        memsrc = 0;
    end
    always @(*) begin
        if (memread_wb && memwrite_mem && rs2_mem == rd_wb) memsrc = 1;
        else memsrc = 0;
    end
endmodule

module DataMem(readdata_wb,memsrc,aluresult,writedata,memwrite,memread,dataout,bitype,unsign,clk);
    input [31:0] readdata_wb;
    input [31:0] aluresult;
    input [31:0] writedata;
    input memwrite, memread, clk,bitype,unsign,memsrc;
    output reg [31:0] dataout;
    reg [7:0] memory[31:0];
    integer i; 
    initial begin
        for (i = 0; i < 32; i = i + 1) memory[i] = 32'b0;
        dataout = 32'b0;
    end
    always @(posedge clk) begin
        if (memsrc==1) begin
            if (memwrite && bitype) begin
                memory[aluresult] = readdata_wb;
                dataout = 32'b0;
            end
            else if(memwrite) begin
                memory[aluresult] = readdata_wb[7:0];
                memory[aluresult+1] = readdata_wb[15:8];
                memory[aluresult+2] = readdata_wb[23:16];
                memory[aluresult+3] = readdata_wb[31:24];
                dataout = 32'b0;
            end
        end
        else begin
            if (memwrite && bitype) begin
                memory[aluresult] = writedata;
                dataout = 32'b0;
            end
            else if(memwrite) begin
                memory[aluresult] = writedata[7:0];
                memory[aluresult+1] = writedata[15:8];
                memory[aluresult+2] = writedata[23:16];
                memory[aluresult+3] = writedata[31:24];
                dataout = 32'b0;
            end
        end
    end
    always @(posedge clk) begin
        if (memread == 1'b1 && aluresult >= 0) begin
            if(bitype && unsign) dataout = {24'b0,memory[aluresult]};
            else if(bitype) dataout = $signed(memory[aluresult]);
            else dataout = {memory[aluresult+3],memory[aluresult+2],memory[aluresult+1],memory[aluresult]};
        end
    end
    always @(memread or aluresult or bitype or unsign) begin
        if (memread == 1'b1 && aluresult >= 0) begin
            if(bitype && unsign) dataout = {24'b0,memory[aluresult]};
            else if(bitype) dataout = $signed(memory[aluresult]);
            else dataout = {memory[aluresult+3],memory[aluresult+2],memory[aluresult+1],memory[aluresult]};
        end
    end
endmodule
