//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:57:30 05/30/2017 
// Design Name: 
// Module Name:    PWM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PWM(
    input clk,			//input clock
    input [7:0] switch, 
    output reg pwm_out 	//output of PWM	
);
reg [16:0] count; // internal accumulator
wire [16:0] shift = 17'b11111111000000000;	
always @(posedge clk) begin
	if(count ==shift)
		count <=0;
    count <= count +1'b1;
    if(count <=(switch<<9))
    begin
        pwm_out <=1;	
   end else
   begin
        pwm_out <=0;
   end  
end
	
endmodule
