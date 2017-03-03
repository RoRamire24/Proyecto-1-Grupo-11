`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2017 17:03:27
// Design Name: 
// Module Name: controlacaract
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



module Controlador_VGA_tb;

//Declaración de entradas
	reg clk_tb;
	reg reset_tb;
	reg [2:0] sw_tb;

//Declaración de salidas
	wire [2:0] rgbtext_tb;
	wire hsync_tb;
	wire vsync_tb;
		
//Instanación del DUT		
	Controlador_VGA dut(
	.clk(clk_tb),
	.reset(reset_tb),
	.rgbtext (rgbtext_tb),
	.hsync (hsync_tb),
	.vsync (vsync_tb)
	);

	initial
	begin
		clk_tb = 0;
	forever
		begin
		 #10 clk_tb = ~clk_tb; 
		end
	end
	



endmodule