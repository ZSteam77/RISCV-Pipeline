`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/02 19:28:06
// Design Name: 
// Module Name: Pipeline
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


module Pipeline(clk);
    input clk;
    wire pcsel,pcwrite,ifidwrite,ifidflush,
    branch_id,memread_id,memtoreg_id,memwrite_id,alusrc_id,regwrite_id,jalr_id,jal_id,sel,
    branch_out_id,memread_out_id,memtoreg_out_id,memwrite_out_id,alusrc_out_id,regwrite_out_id,jalr_out_id,jal_out_id,
    memread_ex,branch_ex,memtoreg_ex,memwrite_ex,alusrc_ex,regwrite_ex,jalr_ex,jal_ex,bitype_ex,unsign_ex,zero_ex,
    memread_mem,regwrite_mem,branch_mem,memwrite_mem,memtoreg_mem,zero_mem,bitype_mem,unsign_mem,memsrc,
    regwrite_wb,memtoreg_wb,memread_wb;
    wire [31:0] pc_imm,pc_if,instruct_if,
    pc_id,instruct_id,readdata1_id,readdata2_id,readdata1out_id,readdata2out_id,imm_id,
    pc_ex,readdata1_ex,readdata2_ex,imm_ex,aluresult_ex,readdata1out_ex,readdata2out_ex,
    aluresult_mem,writedata_mem,readdata_mem,
    readdata_wb,writedata_wb,aluresult_wb;
    wire [1:0] aluop_id,aluop_out_id,aluop_ex,forwardA,forwardB,forward1_id,forward2_id;
    wire [3:0] aluctrin_ex,aluctrout_ex;
    wire [4:0] rs1_ex,rs2_ex,rs1_mem,rs2_mem,rs1_wb,rs2_wb,rd_wb,rd_ex,rd_mem;
    
    Pcupdate pu(pcsel,pc_imm,clk,pc_if,pcwrite);
    InstructionMem im(pc_if,instruct_if);
    IFID ifid(pc_if,instruct_if,pc_id,instruct_id,clk,ifidwrite,ifidflush);
    
    Control ctr(instruct_id[6:0],branch_id,memread_id,memtoreg_id,aluop_id,memwrite_id,alusrc_id,regwrite_id,jalr_id,jal_id);
    RegFile rf(instruct_id[19:15],instruct_id[24:20],rd_wb,writedata_wb,regwrite_wb,readdata1_id,readdata2_id,clk);
    ImmGen ig(instruct_id,imm_id);
    Pcsrc ps(sel,branch_id,readdata1out_id,readdata2out_id,aluop_id,{instruct_id[30],instruct_id[14:12]},jal_id,jalr_id,pcsel,ifidflush);
    Hazard_detect hd(jal_id,jalr_id,regwrite_wb,rd_wb,instruct_id[19:15],instruct_id[24:20],memread_ex,memread_mem,rd_ex,memwrite_id,branch_id,rd_mem,memwrite_ex,memwrite_mem,ifidwrite,pcwrite,sel,forward1_id,forward2_id);
    ControlMux ctrMux(branch_id,memread_id,memtoreg_id,aluop_id,memwrite_id,alusrc_id,regwrite_id,jalr_id,jal_id,sel,branch_out_id,memread_out_id,memtoreg_out_id,aluop_out_id,memwrite_out_id,alusrc_out_id,regwrite_out_id,jalr_out_id,jal_out_id);
    Mux32bit mx1(readdata1_id,aluresult_mem,writedata_wb,forward1_id,readdata1out_id);
    Mux32bit mx2(readdata2_id,aluresult_mem,writedata_wb,forward2_id,readdata2out_id);
    Adder ad(readdata1out_id,jalr_id,pc_id,imm_id,pc_imm);
    IDEX idex(clk,branch_out_id,memread_out_id,memtoreg_out_id,aluop_out_id,memwrite_out_id,alusrc_out_id,regwrite_out_id,jal_out_id,jalr_out_id,pc_id,readdata1out_id,readdata2out_id,imm_id,{instruct_id[30],instruct_id[14:12]},instruct_id[19:15],instruct_id[24:20],instruct_id[11:7],
    branch_ex,memread_ex,memtoreg_ex,aluop_ex,memwrite_ex,alusrc_ex,regwrite_ex,jal_ex,jalr_ex,pc_ex,readdata1_ex,readdata2_ex,imm_ex,aluctrin_ex,rs1_ex,rs2_ex,rd_ex);
    
    ALUcontrol aluctr(aluctrin_ex,aluop_ex,aluctrout_ex,bitype_ex,unsign_ex);
    Forward f(rs1_ex,rs2_ex,rd_mem,rd_wb,regwrite_mem,regwrite_wb,forwardA,forwardB);
    Mux_forward mfA(forwardA,readdata1_ex,writedata_wb,aluresult_mem,readdata1out_ex);
    Mux_forward mfB(forwardB,readdata2_ex,writedata_wb,aluresult_mem,readdata2out_ex);
    ALU alu(pc_ex,jal_ex,jalr_ex,readdata1out_ex,readdata2out_ex,imm_ex,aluctrout_ex,alusrc_ex,zero_ex,aluresult_ex);
    EXMEM exmem(clk,readdata2out_ex,branch_ex,memread_ex,memtoreg_ex,memwrite_ex,regwrite_ex,zero_ex,bitype_ex,unsign_ex,aluresult_ex,rs1_ex,rs2_ex,rd_ex,
    writedata_mem,branch_mem,memread_mem,memwrite_mem,regwrite_mem,memtoreg_mem,zero_mem,bitype_mem,unsign_mem,aluresult_mem,rs1_mem,rs2_mem,rd_mem);
    
    LwswHazard lh(rs2_mem,rd_wb,memread_wb,memwrite_mem,memsrc);
    DataMem dm(readdata_wb,memsrc,aluresult_mem,writedata_mem,memwrite_mem,memread_mem,readdata_mem,bitype_mem,unsign_mem,clk);
    MEMWB memwb(clk,regwrite_mem,memtoreg_mem,memread_mem,readdata_mem,aluresult_mem,rd_mem,regwrite_wb,memtoreg_wb,memread_wb,readdata_wb,aluresult_wb,rd_wb);
    
    WB wb(memtoreg_wb,readdata_wb,aluresult_wb,writedata_wb);
endmodule
