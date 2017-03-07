`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2017 00:08:50
// Design Name: 
// Module Name: sim1
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


module sim1 (
);
// Inputs
	reg video_on;
	reg [9:0] pixelx, pixely;
	reg [2:0] rgbswitches;
	// Outputs
	wire [2:0] rgbtext;
	// Instantiate the Unit Under Test (UUT)
	Generador_Letra prueba(
	    .video_on(video_on),
		.rgbswitches(rgbswitches),
		.pixelx(pixelx),
		.pixely(pixely),
		.rgbtext(rgbtext)  
		);
		
initial
	begin
		video_on=1;
		pixelx= 298;
		pixely=232;
		rgbswitches=1;
    end
	always
	begin 
        pixelx=pixelx+1;
	end
endmodule
