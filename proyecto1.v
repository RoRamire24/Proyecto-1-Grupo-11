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
    //output [8:0] nousar
    );
    
   // wire nouso = 9'b000000000;
    wire clk_25m;
    //assign nousar = nouso;
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
    assign hsync = ~h_sync;
    assign vsync = ~v_sync;
    assign clk_25m = clk_d;
    
    
    //Generador de caracteres
    //wire [2:0] rgbswitches;
    //wire [9:0] pixelx, pixely; 
    //reg [2:0] rgbtext;
    
    // CONSTANTES Y DECLARACIONES
    
    wire [2:0] lsbx;
    wire [3:0] lsby;
    assign lsbx = ~pixel_x[2:0] ;
    assign lsby = pixel_y[3:0];
    
    reg [2:0] letter_rgb;
    
    wire [7:0] Data;
    reg [1:0] as;

    // x , y coordinates (0.0) to (639,479)
    //localparam maxx = 640;
    //localparam maxy = 480;
    
    // Letter boundaries
    localparam fxl = 296;
    localparam fxr = 303;
    localparam rxl = 312;
    localparam rxr = 319;
    localparam jxl = 328;
    localparam jxr = 335;
    
    localparam yt = 224;
    localparam yb = 239;
    
    
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
    
    always @* 
       begin
        if (fon)
            as <= 2'b01; 
        else if (ron)
            as <= 2'b10;
        else if (jon)
            as <= 2'b11;
        else
            as <= 2'b00;   
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

    reg [7:0]adress;
    
    always @*
        adress <= {as,lsby};
    
    always @*
        case (adress)
        
        8'h00: data = 8'b00000000;
        8'h01: data = 8'b00000000; 
        8'h02: data = 8'b00000000; 
        8'h03: data = 8'b00000000; 
        8'h04: data = 8'b00000000; 
        8'h05: data = 8'b00000000;  
        8'h06: data = 8'b00000000;
        8'h07: data = 8'b00000000; 
        8'h08: data = 8'b00000000; 
        8'h09: data = 8'b00000000;
        8'h0a: data = 8'b00000000;
        8'h0b: data = 8'b00000000; 
        8'h0c: data = 8'b00000000; 
        8'h0d: data = 8'b00000000;
        8'h0e: data = 8'b00000000;
        8'h0f: data = 8'b00000000; 

         //code letter F
        8'h010: data = 8'b00000000; //11111111
        8'h011: data = 8'b01111110; //11111111
        8'h012: data = 8'b01111110; //11100000
        8'h013: data = 8'b01100000; //11100000
        8'h014: data = 8'b01100000; //11100000
        8'h015: data = 8'b01100000; //11100000
        8'h016: data = 8'b01100000; //11100000
        8'h017: data = 8'b01111110; //11111111
        8'h018: data = 8'b01100000; //11100000
        8'h019: data = 8'b01100000; //11100000
        8'h01a: data = 8'b01100000; //11100000
        8'h01b: data = 8'b01100000; //11100000
        8'h01c: data = 8'b01100000; //11100000
        8'h01d: data = 8'b01100000; //11100000
        8'h01e: data = 8'b01100000; //11100000
        8'h01f: data = 8'b00000000; //11100000
        //code letter R
        8'h020: data = 8'b00000000; //11111111
        8'h021: data = 8'b01111100; //11100111
        8'h022: data = 8'b01100110; //11100011
        8'h023: data = 8'b01100110; //11100011
        8'h024: data = 8'b01100110; //11100011
        8'h025: data = 8'b01100110; //11100111
        8'h026: data = 8'b01100110; //11111110
        8'h027: data = 8'b01111100; //11111100
        8'h028: data = 8'b01111100; //11111100
        8'h029: data = 8'b01100110; //11101110
        8'h02a: data = 8'b01100110; //11101110
        8'h02b: data = 8'b01100110; //11100111
        8'h02c: data = 8'b01100110; //11100111
        8'h02d: data = 8'b01100110; //11100011
        8'h02e: data = 8'b01100110; //11100011
        8'h02f: data = 8'b00000000; //11100011
        //code letter J
        8'h030: data = 8'b00000000; //00000111
        8'h031: data = 8'b00000110; //00000111
        8'h032: data = 8'b00000110; //00000111
        8'h033: data = 8'b00000110; //00000111
        8'h034: data = 8'b00000110; //00000111
        8'h035: data = 8'b00000110; //00000111
        8'h036: data = 8'b00000110; //00000111
        8'h037: data = 8'b00000110; //00000111
        8'h038: data = 8'b00000110; //00000111
        8'h039: data = 8'b00000110; //00000111
        8'h03A: data = 8'b00000110; //00000111
        8'h03B: data = 8'b00000110; //00000111
        8'h03C: data = 8'b00000110; //00001110
        8'h03D: data = 8'b01100110; //11001110
        8'h03E: data = 8'b00111100; //00111000
        8'h03F: data = 8'b00000000; //00010000
            
        default : data = 8'b00000000;
    endcase
    
endmodule
