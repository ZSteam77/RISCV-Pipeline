`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:27:50
// Design Name: 
// Module Name: EX
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



module EXMEM(clk,writedata,branch,memread,memtoreg,memwrite,regwrite,zero,bitype,unsign,aluresult,rs1,rs2,rd,writedata_out,branch_out,memread_out,memwrite_out,regwrite_out,memtoreg_out,zero_out,bitype_out,unsign_out,aluresult_out,rs1_out,rs2_out,rd_out);
    input clk,branch,memread,memtoreg,memwrite,regwrite,zero,bitype,unsign;
    //input [31:0] pc_in;
    input [31:0] writedata;
    input [31:0] aluresult;
    input [4:0] rs1;
    input [4:0] rs2;
    input [4:0] rd;
    output reg branch_out,memread_out,memtoreg_out,memwrite_out,regwrite_out,zero_out,bitype_out,unsign_out;
    //output reg[31:0] pc_out;
    output reg[31:0] writedata_out;
    output reg[31:0] aluresult_out;
    output reg[4:0] rd_out;
    output reg[4:0] rs1_out;
    output reg[4:0] rs2_out;
    always@(posedge clk)begin
        branch_out = branch;
        memread_out = memread;
        memtoreg_out = memtoreg;
        memwrite_out = memwrite;
        regwrite_out = regwrite;
        zero_out = zero;
        aluresult_out = aluresult;
        rs2_out = rs2;
        rs1_out = rs1;
        rd_out = rd;
        bitype_out = bitype;
        unsign_out = unsign;
        writedata_out = writedata;
    end
endmodule

module Forward(rs1_idex,rs2_idex,rd_exmem,rd_memwb,regwrite_exmem,regwrite_memwb,forwardA,forwardB);
    input [4:0] rs1_idex;
    input [4:0] rs2_idex;
    input [4:0] rd_exmem;
    input [4:0] rd_memwb;
    input regwrite_exmem,regwrite_memwb;
    output reg [1:0] forwardA;
    output reg [1:0] forwardB;
    initial begin
        forwardA = 2'b00;
        forwardB = 2'b00;
    end
    always @(*) begin
        forwardA = 2'b00;
        forwardB = 2'b00;
        if (rs1_idex == rd_exmem && regwrite_exmem && rd_exmem!=0) forwardA = 2'b10;
        if (rs2_idex == rd_exmem && regwrite_exmem && rd_exmem!=0) forwardB = 2'b10;
        if ((rs1_idex == rd_memwb && regwrite_exmem && rd_memwb!=0) && (!(rs1_idex == rd_exmem && regwrite_exmem && rd_exmem!=0))) forwardA = 2'b01;
        if ((rs2_idex == rd_memwb && regwrite_exmem && rd_memwb!=0) && (!(rs2_idex == rd_exmem && regwrite_exmem && rd_exmem!=0))) forwardB = 2'b01;
    end
endmodule


module ALUcontrol(inst,aluop,aluctr_out,bitype,unsign);
    input [3:0] inst;
    input [1:0] aluop;
    output reg bitype;
    output reg unsign;
    output reg [3:0] aluctr_out;
    initial begin
        aluctr_out = 4'b0000;
        bitype = 0;
        unsign = 0;
    end
    always @(*) begin
        if (aluop == 2'b00) begin
            if( inst[2:0] == 3'b001) begin
                aluctr_out = 4'b0111; //slli
                bitype = 0;
                unsign = 0;
            end
            else if (inst[2:0] == 3'b101) begin
                aluctr_out = 4'b1000;//srli
                bitype = 0;
                unsign = 0;
            end
            else if (inst[2:0] == 3'b111) begin
                aluctr_out = 4'b0000;//andi
                bitype = 0;
                unsign = 0;
            end
            else if (inst[2:0] == 3'b000) begin
                aluctr_out = 4'b0010;//lb sb
                bitype = 1;
                unsign = 0;
            end
            else if (inst[2:0] == 3'b100) begin
                aluctr_out = 4'b0010;//lbu
                bitype = 1;
                unsign = 1;
            end
            else begin
                aluctr_out = 4'b0010; //lw sw addi jal jalr
                bitype = 0;
                unsign = 0;
            end
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b000) begin
            aluctr_out = 4'b0110;//beq
            bitype = 0;
            unsign = 0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b001) begin
            aluctr_out = 4'b0011; //bne branch
            bitype = 0;
            unsign = 0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b100) begin
            aluctr_out = 4'b0100; //blt branch
            bitype = 0;
            unsign = 0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b101) begin
            aluctr_out = 4'b0101; //bge branch
            bitype = 0;
           unsign = 0;
        end
        else if (aluop == 2'b10) begin
            if (inst == 4'b0000) begin
                aluctr_out = 4'b0010; //add
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b1000) begin
                aluctr_out = 4'b0110; //sub
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b0001) begin
                aluctr_out = 4'b0111; //sll
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b0101) begin
                aluctr_out = 4'b1000; //srl
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b1101) begin
                aluctr_out = 4'b1001; //sra
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b0111) begin
                aluctr_out = 4'b0000; //and
                bitype = 0;
                unsign = 0;
            end
            else if (inst == 4'b0110) begin
                aluctr_out = 4'b0001; //or
                bitype = 0;
                unsign = 0;
            end
        end
    end
endmodule

module Mux_forward(forward,in0,in1,in2,out);
    input [1:0] forward;
    input [31:0] in0;
    input [31:0] in1;
    input [31:0] in2;
    output reg [31:0] out;
    always @(*) begin
        if (forward == 2'b00) out = in0;
        else if (forward == 2'b01) out = in1;
        else if (forward == 2'b10) out = in2;
    end
endmodule

module ALU(pc,jal,jalr,data1,data2,imm,aluctr,alusrc,zero,result);
    input [31:0] pc;
    input signed [31:0] data1;
    input signed [31:0] data2;
    input [31:0] imm;
    input [3:0] aluctr;
    input alusrc,jal,jalr;
    output reg zero;
    output reg signed [31:0] result;
    initial begin
        result = 32'b0;
        zero = 0;
    end
    always @(*) begin
        if (jal == 1'b1 || jalr == 1'b1) begin
            zero = 1;
            result = pc+4;
        end
        else if (alusrc == 1'b0) begin
            case(aluctr)
                4'b0000: begin
                    result = data1 & data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0001: begin
                    result = data1 | data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0010: begin
                    result = data1 + data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0011: begin //bne branch
                    result = data1 - data2;
                    zero = (result == 32'b0)?1'b0:1'b1;
                end
                4'b0100: begin //blt branch
                    result = data1 - data2;
                    zero = (data1 < data2)?1'b1:1'b0;
                end
                4'b0101: begin //bge branch
                    result = data1 - data2;
                    zero = (data1 >= data2)?1'b1:1'b0;
                end
                4'b0110: begin
                    result = data1 - data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0111: begin //sll slli
                    result = data1 << data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b1000: begin //srli srl
                    result = data1 >> data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b1001: begin //sra
                    result = data1 >>> data2;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
            endcase
        end
        else begin
            case(aluctr)
                4'b0000: begin
                    result = data1 & imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0001: begin
                    result = data1 | imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0010: begin
                    result = data1 + imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0011: begin //bne branch
                    result = data1 - imm;
                    zero = (result == 32'b0)?1'b0:1'b1;
                end
                4'b0100: begin //blt branch
                    result = data1 - imm;
                    zero = (result < 32'b0)?1'b1:1'b0;
                end
                4'b0101: begin //bge branch
                    result = data1 - imm;
                    zero = (result > 32'b0)?1'b1:1'b0;
                end
                4'b0110: begin
                    result = data1 - imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b0111: begin //sll slli
                    result = data1 << imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b1000: begin //srli srl
                    result = data1 >> imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
                4'b1001: begin //sra
                    result = data1 >>> imm;
                    zero = (result == 32'b0)?1'b1:1'b0;
                end
            endcase
        end
    end
endmodule
