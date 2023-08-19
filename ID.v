`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:27:50
// Design Name: 
// Module Name: ID
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

module IDEX(clk,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite,jal,jalr,pc_in,readdata1,readdata2,imm,aluctrin_in,rs1,rs2,rd,branch_out,memread_out,memtoreg_out,aluop_out,memwrite_out,alusrc_out,regwrite_out,jal_out,jalr_out,pc_out,readdata1_out,readdata2_out,imm_out,aluctrin_out,rs1_out,rs2_out,rd_out);
    input [1:0] aluop;
    input branch,memread,memtoreg,memwrite,alusrc,regwrite,clk,jal,jalr;
    input [31:0] pc_in;
    input [31:0] readdata1;
    input [31:0] readdata2;
    input [31:0] imm;
    input [4:0] rd;
    input [4:0] rs1;
    input [4:0] rs2;
    input [3:0] aluctrin_in;
    output reg [1:0] aluop_out;
    output reg branch_out,memread_out,memtoreg_out,memwrite_out,alusrc_out,regwrite_out,jal_out,jalr_out;
    output reg [31:0] pc_out;
    output reg [31:0] readdata1_out;
    output reg [31:0] readdata2_out;
    output reg [31:0] imm_out;
    output reg [3:0] aluctrin_out;
    output reg [4:0] rd_out;
    output reg [4:0] rs1_out;
    output reg [4:0] rs2_out;
    always @(posedge clk) begin
        aluop_out = aluop;
        branch_out = branch;
        memread_out = memread;
        memtoreg_out = memtoreg;
        memwrite_out = memwrite;
        alusrc_out = alusrc;
        regwrite_out = regwrite;
        pc_out = pc_in;
        readdata1_out = readdata1;
        readdata2_out = readdata2;
        imm_out = imm;
        aluctrin_out = aluctrin_in;
        rd_out = rd;
        jal_out = jal;
        jalr_out = jalr;
        rs1_out = rs1;
        rs2_out = rs2;
    end
endmodule

module Adder(rs1,jalr,pcin,imm,pcout);
    input [31:0] rs1,pcin;
    input [31:0] imm;
    input jalr;
    output reg [31:0] pcout;
    always @(*)begin
        if(jalr) pcout = rs1+imm;
        else pcout = pcin + (imm << 1);
    end
endmodule

module Mux32bit(readdata_id,readdata_exmem,writedata_wb,sel,readdata_out_id);
    input [31:0] readdata_id;
    input [31:0] readdata_exmem;
    input [31:0] writedata_wb;
    input [1:0] sel;
    output reg [31:0] readdata_out_id;
    always @(*) begin
        if (sel == 0) readdata_out_id = readdata_id;
        else if (sel == 1) readdata_out_id = writedata_wb;
        else readdata_out_id = readdata_exmem;
    end
endmodule

module Hazard_detect(jal,jalr,regwrite_wb,rd_memwb,rs1_ifid,rs2_ifid,memread_idex,memread_exmem,rd_idex,memwrite_id,branch_id,rd_exmem,memwrite_idex,memwrite_exmem,ifidwrite,pcwrite,sel,forward1_id,forward2_id);
    input [4:0] rs1_ifid;
    input [4:0] rs2_ifid;
    input [4:0] rd_idex;
    input [4:0] rd_exmem;
    input [4:0] rd_memwb;
    input jal,jalr,regwrite_wb,memread_idex,memread_exmem,branch_id,memwrite_id,memwrite_idex,memwrite_exmem;
    output reg ifidwrite;
    output reg [1:0] forward1_id;
    output reg [1:0] forward2_id;
    output reg pcwrite;
    output reg sel;
    initial begin
        forward1_id = 0;
        forward2_id = 0;
        ifidwrite = 1;
        sel = 1;
        pcwrite = 1;
    end
    always @(*) begin
        if (memwrite_id==0 && jal!=1 && jalr!=1 && memread_idex == 1 && (rs1_ifid == rd_idex || rs2_ifid == rd_idex))begin
            sel = 0;
            pcwrite = 0;
            ifidwrite = 0;
            forward1_id = 0;
            forward2_id = 0;
        end
        else if(branch_id == 1 && jal!=1 && jalr!=1 && memwrite_idex !=1 && (rs1_ifid == rd_idex || rs2_ifid == rd_idex)) begin
            sel = 0;
            pcwrite = 0;
            ifidwrite = 0;
            forward1_id = 0;
            forward2_id = 0;
        end
        else if (memread_exmem == 1 && branch_id == 1 && jal!=1 && jalr!=1 && (rs1_ifid == rd_exmem || rs2_ifid == rd_exmem)) begin
            sel = 0;
            pcwrite = 0;
            ifidwrite = 0;
            forward1_id = 0;
            forward2_id = 0;
        end
        else begin
            forward1_id = 0;
            forward2_id = 0;
            ifidwrite = 1;
            sel = 1;
            pcwrite = 1;
        end
        if (branch_id == 1 && jal!=1 && jalr!=1 && memwrite_exmem !=1 && (rs1_ifid == rd_exmem || rs2_ifid == rd_exmem)) begin
            if (rs1_ifid == rd_exmem) forward1_id = 1;
            if (rs2_ifid == rd_exmem) forward2_id = 1;
        end
        if (branch_id == 1 && jal!=1 && jalr!=1 && regwrite_wb && (rs1_ifid == rd_memwb || rs2_ifid == rd_memwb)) begin
            if (rs1_ifid == rd_exmem) forward1_id = 2'b10;
            if (rs2_ifid == rd_exmem) forward2_id = 2'b10;
        end
    end
endmodule

module Pcsrc(sel,branch,readdata1,readdata2,aluop,inst,jal,jalr,pcsrc,flush);
    input sel,branch,jal,jalr;
    input [31:0] readdata1;
    input [31:0] readdata2;
    input [1:0] aluop;
    input [3:0] inst;
    output reg pcsrc;
    output reg flush;
    initial begin
        pcsrc = 0;
        flush = 0;
    end
    always @(*) begin
    if(sel == 1)begin
        if (aluop == 2'b01 && inst[2:0] == 3'b000) begin//beq
            pcsrc = (readdata1 == readdata2 && branch == 1)?1:0;
            flush = (readdata1 == readdata2 && branch == 1)?1:0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b001) begin //bne branch
            pcsrc = (readdata1 != readdata2 && branch == 1)?1:0;
            flush = (readdata1 != readdata2 && branch == 1)?1:0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b100) begin//blt branch
            pcsrc = (readdata1 < readdata2 && branch == 1)?1:0;
            flush = (readdata1 < readdata2 && branch == 1)?1:0;
        end
        else if (aluop == 2'b01 && inst[2:0] == 3'b101) begin//bge branch
            pcsrc = (readdata1 >= readdata2 && branch == 1)?1:0;
            flush = (readdata1 >= readdata2 && branch == 1)?1:0;
        end
        else if (jal == 1) begin//jal
            pcsrc = 1;
            flush = 1;
        end
        else if (jalr == 1) begin//jalr
            pcsrc = 1;
            flush = 1;
        end
        else begin
            flush = 0;
            pcsrc = 0;
        end
    end
    else begin
        flush = 0;
        pcsrc = 0;
    end
    end
endmodule

module RegFile(readreg1,readreg2,writereg,writedata,regwrite,readdata1,readdata2,clk);
    input [4:0] readreg1;
    input [4:0] readreg2;
    input [4:0] writereg;
    input [31:0] writedata;
    input regwrite,clk;
    output [31:0] readdata1;
    output [31:0] readdata2;
    reg [31:0] memory[31:0];
    integer i = 0;
    initial begin
        for (i = 0; i < 32; i = i + 1) memory[i] = 32'b0;
    end
    always @(negedge clk) begin
        if (regwrite && (!(writereg==0))) memory[writereg] = writedata;
    end
    assign readdata1 = memory[readreg1];
    assign readdata2 = memory[readreg2];
endmodule


module ControlMux(branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite,jalr,jal,sel,branch_out,memread_out,memtoreg_out,aluop_out,memwrite_out,alusrc_out,regwrite_out,jalr_out,jal_out);
    input branch,memread,memtoreg,memwrite,alusrc,regwrite,jalr,jal,sel;
    input [1:0] aluop;
    output reg [1:0] aluop_out;
    output reg branch_out,memread_out,memtoreg_out,memwrite_out,alusrc_out,regwrite_out,jalr_out,jal_out;
    initial begin
        branch_out = 0;
        memread_out = 0;
        memtoreg_out = 0;
        aluop_out = 2'b00;
        memwrite_out = 0;
        alusrc_out = 0;
        regwrite_out = 0;
        jalr_out = 0;
        jal_out =0;
    end
    always @(*) begin
        if (sel==0) begin
            branch_out = 0;
            memread_out = 0;
            memtoreg_out = 0;
            aluop_out = 2'b00;
            memwrite_out = 0;
            alusrc_out = 0;
            regwrite_out = 0;
            jalr_out = 0;
            jal_out =0;
        end
        else begin
            aluop_out = aluop;
            branch_out = branch;
            memread_out = memread;
            memtoreg_out = memtoreg;
            memwrite_out = memwrite;
            alusrc_out = alusrc;
            regwrite_out = regwrite;
            jal_out = jal;
            jalr_out = jalr;
        end
    end
endmodule


module Control(opcode,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite,jalr,jal);
    input [6:0] opcode;
    output reg [1:0] aluop;
    output reg branch,memread,memtoreg,memwrite,alusrc,regwrite,jalr,jal;
    initial begin
        branch = 0;
        memread = 0;
        memtoreg = 0;
        aluop = 2'b00;
        memwrite = 0;
        alusrc = 0;
        regwrite = 0;
        jalr = 0;
        jal =0;
    end
    always @(*) begin
        
        case(opcode)            
            7'b0000011:begin //load type
                
                branch = 0;
                memread = 1;
                memtoreg = 1;
                aluop = 2'b00;
                memwrite = 0;
                alusrc =1;
                regwrite = 1;
                jalr = 0;
                jal =0;
            end
            7'b0010011: begin // addi andi slli srli
                branch = 0;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b00;
                memwrite = 0;
                alusrc =1;
                regwrite = 1;
                jalr = 0;
                jal =0;
            end
            7'b1100111: begin //jalr
                branch = 1;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b00;
                memwrite = 0;
                alusrc =0;
                regwrite = 1;
                jalr = 1;
                jal =0;
            end
            7'b1101111: begin //jal
                branch = 1;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b00;
                memwrite = 0;
                alusrc =0;
                regwrite = 1;
                jalr = 0;
                jal = 1;
            end
            7'b0100011:begin //S-type
                branch = 0;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b00;
                memwrite = 1;
                alusrc = 1;
                regwrite = 0;
                jalr = 0;
                jal =0;
            end
            7'b0110011:begin //R-type
                branch = 0;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b10;
                memwrite = 0;
                alusrc = 0;
                regwrite = 1;
                jalr = 0;
                jal =0;
            end
            7'b1100011:begin //B-type
                branch = 1;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b01;
                memwrite = 0;
                alusrc = 0;
                regwrite = 0;
                jalr = 0;
                jal =0;
            end
            default: begin
                branch = 0;
                memread = 0;
                memtoreg = 0;
                aluop = 2'b0;
                memwrite = 0;
                alusrc = 0;
                regwrite = 0;
                jalr = 0;
                jal =0;
            end
      endcase
   end
endmodule

module ImmGen(instruction,imm);
    input [31:0] instruction;
    output reg [31:0] imm;
    initial begin
        imm = 32'b0;
    end
    always @(*) begin
        case(instruction[6:0])
            7'b0000011:begin //load type
                imm = $signed({instruction[31:20]});
            end
            7'b1100111:begin //jalr type
                imm = $signed({instruction[31:20]});
            end
            7'b0010011:begin //I-type
                imm = $signed({instruction[31:20]});
            end
            7'b0100011:begin //S-type
                imm = $signed({instruction[31:25],instruction[11:7]});
            end
            7'b0110011:begin //R-type
                imm = 32'b0;
            end
            7'b1100011:begin //B-type
                imm = $signed({instruction[31],instruction[7],instruction[30:25],instruction[11:8]});
            end
            7'b0110111:begin //U-type
                imm = $signed(instruction[31:12]);
            end
            7'b1101111:begin //J-type
                imm = $signed({instruction[31],instruction[19:12],instruction[20],instruction[30:21]});
            end
            default: begin
                imm = 32'b0;
            end
         endcase
    end
endmodule
