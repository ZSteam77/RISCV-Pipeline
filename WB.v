`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:27:50
// Design Name: 
// Module Name: WB
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
module WB(memtoreg,readdata,aluresult,writedata);
    input memtoreg;
    input [31:0] readdata;
    input [31:0] aluresult;
    output reg [31:0] writedata;
    always @(*) begin
        if (memtoreg == 1'b1) writedata = readdata;
        else writedata = aluresult;
    end
endmodule
