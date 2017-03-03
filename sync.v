`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2017 10:43:51 PM
// Design Name: 
// Module Name: sync
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


module sync(
    input reset, clk,
    output wire hsync, vsync, video_on,
    output wire clk_25m,
    output wire [9:0] pixel_x, pixel_y
    );
    
    reg clk_d;
    reg [3:0] count;
    wire clk_div;
        
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
    
endmodule
