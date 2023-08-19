`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:27:50
// Design Name: 
// Module Name: IF
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
module IFID(pcin,instruct,pcout,instructout,clk,ifidwrite,flush);
    input [31:0] pcin;
    input [31:0] instruct;
    input ifidwrite,flush;
    input clk;
    output reg [31:0] instructout;
    output reg [31:0] pcout;
    always@ (posedge clk) begin
        if (flush == 1)begin
            pcout = pcout;
            instructout = 32'b0;
        end
        else if(ifidwrite) begin
            pcout = pcin;
            instructout = instruct;
        end
    end
endmodule

module Pcupdate(pcsrc,pc_imm,clk,pcout,pcwrite);
    input pcsrc,clk,pcwrite;
    input [31:0] pc_imm;
    output reg [31:0] pcout;
    initial begin
        pcout = 0;
    end
    always @(posedge clk) begin
        if (pcsrc == 1 && pcwrite) pcout = pc_imm;
        else if (pcwrite) pcout = pcout + 4;
        else pcout = pcout;
    end
    //always @(pcsrc) begin
        //if (pcsrc == 1 && pcwrite) pcout = pc_imm;
    //end
endmodule

module InstructionMem(pc,instruct);
    input [31:0] pc;
    output [31:0] instruct;
    reg [31:0] inmem[78:0];
    initial begin
        $readmemb("instruction.txt",inmem);
    end
    assign instruct = inmem[(pc>>2)];
endmodule