`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2020 16:48:16
// Design Name: 
// Module Name: top
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


module top(
    input CLK100MHZ,
    input BTNC, // start button
    input BTNL, // shift left button
    input BTNR, // shift right button
    input BTNU, // reset button
    output [7:0]SegmentDrivers,
    output [7:0]SevenSegment
    );
    reg ena = 1;
    reg wea = 0;
    reg [11:0] addra = 0;
    reg [7:0] dina = 0;
    wire [7:0] douta;
    reg [7:0] lshift = 0;
    reg [7:0] value = 0;
    reg [5:0] SSValue [7:0];
    reg [7:0] letter [127:0]; // array of ascii number of each letter
    reg [6:0] c = 0; // c used to loop through 128 letters in the image. From 0 to 127
    reg [2:0] cSS = 0; // couinter to loop through the message to Sevent segment number
    reg [7:0] ssShift = 0;
    reg [2:0] b = 6; // b used to loop through bits in a byte. From 0 to 7 ###REMEMBER THIS MAY NEED TO BE CHANGED WHEN PROTOTYPING
    reg [0:0] bStop = 1;
    
      
      //Add the reset
    wire Reset;
    Delay_Reset DReset(CLK100MHZ, BTNC, Reset);
    
    
    //Debouncing Buttons
    wire LButton;
    wire RButton;
    
    Debounce L_Button(CLK100MHZ,BTNL,LButton);
    Debounce R_Button(CLK100MHZ,BTNR,RButton);  
    
    
    
blk_mem_gen_0 BRAM (
    .clka(CLK100MHZ),
    .ena(ena),
    .wea(wea),
    .addra(addra),
    .dina(dina), 
    .douta(douta));
    //  ,.rsta(arp_switch));

integer k = 0;
integer i;

initial
begin
    for (k = 0; k < 128; k = k + 1) begin
        letter[k] = 36;
    end
end


always @(posedge CLK100MHZ) begin
    if(Reset) begin
        cSS <= 0;
        ssShift <= 0;
        if (bStop == 0 & cSS < (c-1))
        begin
            for (i = 0; i < 8; i = i + 1) begin
                SSValue[i] = letter[i+1];
                cSS = cSS + 1;
            end
            
        end
    end



    if(LButton) begin
        ssShift <= ssShift - 1;
        cSS <= 0;
        if (bStop == 0 & cSS < (c-1))
        begin
            for (i = 0; i < 8; i = i + 1) begin
                SSValue[i] = letter[ssShift+i];
                cSS = cSS + 1;
            end
            
        end
    end
    
    if(RButton) begin
        ssShift <= ssShift + 1;
        cSS <= 0;
        if (bStop == 0 & cSS < (c-1))
        begin
            for (i = 0; i < 8; i = i + 1) begin
                SSValue[i] = letter[ssShift+i];
                cSS = cSS + 1;
            end
            
        end 
    end

    if (bStop == 1)
    begin
        addra <= addra + 1;
        if (b<9) begin
            b <= b + 1;
            if (b == 0 ) begin
                if (value == 0 && c>1)
                begin
                    bStop = 0;
                end

                if (value == 0 || value == 32) 
                begin
                    value = 36; // set value to default of BCD case (no display)
                end
                else if (value >= 48 && value <= 57)
                begin
                    value = value - 48;
                end
                else if (value >= 65 && value <= 90)
                begin
                    value = value -  55;
                end
                else if (value >= 97 )
                begin
                    value = value - 87;
                end
                
                letter[c] = value;

                c <= c+1;
                value = 0;
                
            end
            lshift = (8'b00000001 & douta) << (7-(b));
            value = value + lshift;
            
            //letter[c] = letter[c] + (douta << (8-b)); // 0000 0000(0) + 1000 0000(128) + 0100 0000(64) + 0010 0000(32) etc
         
        end
    end // if bStop

    
end // end always posedge clk


SS_Driver SS_Driver1(
    CLK100MHZ, BTNU,
	SSValue[0], SSValue[1], SSValue[2], SSValue[3],  SSValue[4], SSValue[5], SSValue[6], SSValue[7],// Use temporary test values before adding hours2, hours1, mins2, mins1
	SegmentDrivers,
	SevenSegment
);

endmodule
