`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2017 08:41:08 PM
// Design Name: 
// Module Name: rj
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


module rj(
    input clk, reset,
    output clk_div
    );
    reg clk_d;
    reg [3:0] count;
    
    always @(posedge (clk), posedge (reset))
    begin
        if (reset == 1)
        begin
            count <= 'b0;
            clk_d <= 0;
        end
        else if (count == 4)
        begin
            clk_d <= 1;
            count <= 'b0;        
        end
        else 
        begin
            clk_d <= 0;
            count <= count +1;
        end
    end
    assign clk_div = clk_d;
endmodule
