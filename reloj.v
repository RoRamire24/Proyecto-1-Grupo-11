`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2017 02:03:25 PM
// Design Name: 
// Module Name: reloj
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


module reloj(
    input clk,
    input reset, 
    output clk_div
    );
    
    localparam num_div = 2;
    reg falta;
    reg [1:0] count;     
    always @ (posedge (clk), posedge (reset))
    begin
        if (reset == 1'b1)
            count <= 2'b0;
        else if (count == num_div - 1)
            count <= 2'b0;
        else 
            count <= count + 1;
    end
    
    always @ (posedge (clk), posedge (reset))
    begin
        if (reset == 1'b1)
                falta <= 2'b0;
        else if (count == num_div - 1)
                falta <= ~falta;
        else 
                falta <= falta;
    end
    assign clk_div = falta;
endmodule
