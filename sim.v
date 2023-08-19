`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/09 15:46:11
// Design Name: 
// Module Name: sim
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


module sim();
    reg clk;
	Pipeline test(clk);
	
    initial begin
        #0 clk = 0;
        forever #1   clk = ~ clk;
    end
    initial begin
        while ($time < 62) @(posedge clk)begin
            $display("===============================================");
            $display("Clock cycle %d, PC = %H", $time/2, test.pc_if);
            $display("ra = %H, t0 = %H, t1 = %H", test.rf.memory[1], test.rf.memory[5], test.rf.memory[6]);
            $display("t2 = %H, t3 = %H, t4 = %H", test.rf.memory[7], test.rf.memory[28], test.rf.memory[29]);
            $display("===============================================");
        end
    end
    initial begin
        #160 $stop;
    end
endmodule
