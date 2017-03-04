`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/02/2017 11:48:03 PM
// Design Name: 
// Module Name: proyecto1
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


module proyecto1(
    input reset, clk,
    input wire [2:0] rgbswitches,
    output reg [2:0] rgbtext,
    output wire hsync, vsync
    );
    
    wire clk_25m;
    
    wire video_on;
    
    wire [9:0] pixel_x, pixel_y;    
    reg clk_d;
    reg [1:0] count;
    wire clk_div;
        
    always @(posedge (clk), posedge (reset))
    begin
        if (reset == 1)
        begin
            count <= 'b0;
            clk_d <= 0;
        end
        else if (count == 3)
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
    
    //Horizontal
    localparam areavisibleh = 640;
    localparam backporch = 48;
    localparam frontporch = 16;
    localparam retraceh = 96;
    //Vertical
    localparam areavisiblev = 480;
    localparam fronttop = 10;
    localparam backtop = 33;
    localparam retracev = 2;
    
    reg [9:0] hcount, vcount;
    reg v_sync, h_sync;
    wire v_sync_next , h_sync_next;
    
    always @ (posedge (clk), posedge (reset))
    begin
        if (reset == 1)
        begin
            hcount <= 'b0;
            vcount <= 'b0;
            v_sync <= 'b0;
            h_sync <= 'b0;
        end
        else if (clk_div == 1)
        begin
            if (hcount == (areavisibleh + backporch + frontporch + retraceh -1))
            begin
                hcount <= 'b0;
                if (vcount == (areavisiblev + backtop + fronttop + retracev -1)) 
                    vcount <= 'b0;
                else 
                    vcount <= vcount + 1;
            end
            else 
                hcount <= hcount + 1;
                
        end
        else 
        begin
            hcount <= hcount;
            vcount <= vcount;
            h_sync <= h_sync_next;
            v_sync <= v_sync_next;
        end
        
    end
    
//    //reinicio horizontal
//    always @*
//    begin
//        if (clk_div && hcount == (areavisibleh + backporch + frontporch + retraceh -1))
//        begin
//            hcount <= 'b0;
//        end
//        else
//            hcount <= hcount;
//    end
    
//    // reinicio vertical
//    always @*
//    begin
//        if (clk_div && hcount == (areavisibleh + backporch + frontporch + retraceh -1))
//        begin
//            if (vcount == (areavisiblev + backtop + fronttop + retracev -1))
//                vcount <= 'b0;
//            else 
//                vcount <= vcount + 1;
//        end
//        else 
//            vcount <= vcount;
//    end
//  pulsos
    
    assign h_sync_next = ((hcount >= 'd659) && (hcount <= 'd751));
    assign v_sync_next = ((vcount >= 'd490) && (vcount <= 'd491));
    
    // vedeo on on/of
    assign video_on = ((hcount < areavisibleh) && (vcount < areavisiblev));
    
    //salidas
    
    assign pixel_x = hcount;
    assign pixel_y = vcount;
    assign hsync = h_sync;
    assign vsync = v_sync;
    assign clk_25m = clk_d;
    
    
    //Generador de caracteres
    //wire [2:0] rgbswitches;
    //wire [9:0] pixelx, pixely; 
    //reg [2:0] rgbtext;
    
    // CONSTANTES Y DECLARACIONES
    
    wire [2:0] lsbx;
    wire [3:0] lsby;
    assign lsbx = pixel_x[2:0];
    assign lsby = pixel_y[3:0];
    
    reg [2:0] letter_rgb;
    
    wire [7:0] Data;
    reg [1:0] as;

    // x , y coordinates (0.0) to (639,479)
    //localparam maxx = 640;
    //localparam maxy = 480;
    
    // Letter boundaries
    localparam fxl = 300;
    localparam fxr = 307;
    localparam rxl = 316;
    localparam rxr = 323;
    localparam jxl = 332;
    localparam jxr = 339;
    
    localparam yt = 232;
    localparam yb = 247;
    
    
    // letter output signals
    wire fon, ron, jon;
    
    
    // CUERPO
    
    // pixel within letters 
    assign fon =
    (fxl<=pixel_x) && (pixel_x<=fxr) &&
    (yt<=pixel_y) && (pixel_y<=yb);
    
    assign ron =
    (rxl<=pixel_x) && (pixel_x<=rxr) &&
    (yt<=pixel_y) && (pixel_y<=yb);
    
    assign jon =
    (jxl<=pixel_x) && (pixel_x<=jxr) &&
    (yt<=pixel_y) && (pixel_y<=yb);
    
    always @* begin
        if (fon)
            as <= 2'h1; 
        else if (ron)
            as <= 2'h2;
        else if (jon)
            as <= 2'h1;
        else
            as <= 2'h0;   
       end
     
    ROM FONT(as,lsby,Data); 
    
    reg pixelbit;
    
    always @*
        case (lsbx)
        3'h0: pixelbit <= Data[0];
        3'h1: pixelbit <= Data[1];
        3'h2: pixelbit <= Data[2];
        3'h3: pixelbit <= Data[3];
        3'h4: pixelbit <= Data[4];
        3'h5: pixelbit <= Data[5];
        3'h6: pixelbit <= Data[6];
        3'h7: pixelbit <= Data[7];
    endcase
    
    always @*
        if (pixelbit)
            letter_rgb <= rgbswitches;
        else
            letter_rgb <= 3'b000;
    
    // rgb multiplexing circuit
    always @*
        if (~video_on)
            rgbtext = 3'b000; // blank 
        else if (fon|ron|jon)  
            rgbtext = letter_rgb; 
        else
            rgbtext = 3'b000; // black background
endmodule
    
module ROM (
    input wire [1:0]as,
    input wire [3:0]lsby,
    output reg [7:0]data 
    );

    reg [5:0]adress;
    
    always @*
        adress <= {as,lsby};
    
    always @*
        case (adress)
        
        6'h00: data = 8'b00000000;
        6'h01: data = 8'b00000000; 
        6'h02: data = 8'b00000000; 
        6'h03: data = 8'b00000000; 
        6'h04: data = 8'b00000000; 
        6'h05: data = 8'b00000000;  
        6'h06: data = 8'b00000000;
        6'h07: data = 8'b00000000; 
        6'h08: data = 8'b00000000; 
        6'h09: data = 8'b00000000;
        6'h0a: data = 8'b00000000;
        6'h0b: data = 8'b00000000; 
        6'h0c: data = 8'b00000000; 
        6'h0d: data = 8'b00000000;
        6'h0e: data = 8'b00000000;
        6'h0f: data = 8'b00000000; 

         //code letter F
        6'h010: data = 8'b00111111; //
        6'h011: data = 8'b00111111; //
        6'h012: data = 8'b00111000; //
        6'h013: data = 8'b00111000; //
        6'h014: data = 8'b00111000; //
        6'h015: data = 8'b00111000; //
        6'h016: data = 8'b00111000; //
        6'h017: data = 8'b11111111; //
        6'h018: data = 8'b00111000; //
        6'h019: data = 8'b00111000; //
        6'h01a: data = 8'b00111000; //
        6'h01b: data = 8'b00111000; //
        6'h01c: data = 8'b00111000; //
        6'h01d: data = 8'b00111000; //
        6'h01e: data = 8'b00000000; //
        6'h01f: data = 8'b00000000; //
        //code letter R
        6'h020: data = 8'b11111111; //
        6'h021: data = 8'b11111111; //
        6'h022: data = 8'b11000011; //
        6'h023: data = 8'b11000011; //
        6'h024: data = 8'b11000011; //
        6'h025: data = 8'b11111111; //
        6'h026: data = 8'b11111111; //
        6'h027: data = 8'b11110000; //
        6'h028: data = 8'b11110000; //
        6'h029: data = 8'b11001100; //
        6'h02a: data = 8'b11001100; //
        6'h02b: data = 8'b11000011; //
        6'h02c: data = 8'b11000011; //
        6'h02d: data = 8'b00000000; //
        6'h02e: data = 8'b00000000; //
        6'h02f: data = 8'b00000000; //
        //code letter J
        6'h030: data = 8'b11111111; //
        6'h031: data = 8'b11111111; //
        6'h032: data = 8'b00001100; //
        6'h033: data = 8'b00001100; //
        6'h034: data = 8'b00001100; //
        6'h035: data = 8'b00001100; //
        6'h036: data = 8'b00001100; //
        6'h037: data = 8'b00001100; //
        6'h038: data = 8'b00001100; //
        6'h039: data = 8'b00001100; //
        6'h03a: data = 8'b00011000; //
        6'h03b: data = 8'b00011000; //
        6'h03c: data = 8'b00110000; //
        6'h03d: data = 8'b01000000; //
        6'h03e: data = 8'b11000000; //
        6'h03f: data = 8'b00000000; //
            
        default : data = 8'b00000000;
    endcase
    
endmodule
