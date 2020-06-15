module SS_Driver(
    input Clk, Reset,
    input [5:0]  BCD7, BCD6, BCD5, BCD4, BCD3, BCD2, BCD1, BCD0, // Binary-coded decimal input
    output reg [7:0] SegmentDrivers, // Digit drivers (active low) //AN0-
    output reg [7:0] SevenSegment // Segments (active low)
);
//H1H2:M1M2

// Make use of a subcircuit to decode the BCD to seven-segment (SS)
wire [6:0]SS[7:0]; //2D array

BCD_Decoder BCD_Decoder0 (BCD0, SS[0]);
BCD_Decoder BCD_Decoder1 (BCD1, SS[1]);
BCD_Decoder BCD_Decoder2 (BCD2, SS[2]);
BCD_Decoder BCD_Decoder3 (BCD3, SS[3]);

BCD_Decoder BCD_Decoder4 (BCD4, SS[4]);
BCD_Decoder BCD_Decoder5 (BCD5, SS[5]);
BCD_Decoder BCD_Decoder6 (BCD6, SS[6]);
BCD_Decoder BCD_Decoder7 (BCD7, SS[7]);


// Counter to reduce the 100 MHz clock to 762.939 Hz (100 MHz / 2^17)
reg [16:0]Count = 0;


//reg [16:0]Count;
// Scroll through the digits, switching one on at a time add a count value so we can shift values?

always @(posedge Clk) begin
 Count <= Count + 1'b1; //1
    if ( Reset) SegmentDrivers <= 8'hFE; //d14  = b1111 1110  SegmentDriver[0] = 0 
 else if(&Count) begin
 SegmentDrivers <= {SegmentDrivers[6:0], SegmentDrivers[7]}; // Bit 012 -> 123 Bit 3 -> Bit 0 Shifting
 end
                                                                                // b1111 1110-> b 1111 1101
end																				//	1 -> 2

//------------------------------------------------------------------------------

//Instead, we can use the combinatorial and add an AND gate 
//with the PWM signal (by adding an if statement before connecting the signals) to see if need to turn the seven segment on or not.


always @(*) begin // This describes a purely combinational circuit
    SevenSegment[7] <= 1'b1; // Decimal point always off
    if (Reset) begin
        SevenSegment[6:0] <= 7'h7F;//7'h55; // All off during Reset //SevenSegment[7:0] = 11111111 //8?
    end 
    else begin
        case(~SegmentDrivers) // Connect the correct signals,    //0001                            //Not segment drivers
            8'h1 : SevenSegment[6:0] <= ~SS[0]; // depending on which digit is on at        //if ~SegmentDrivers = 0001 :  SevenSegment[6:0]
            8'h2 : SevenSegment[6:0] <= ~SS[1]; // this point                               //0010 :
            8'h4 : SevenSegment[6:0] <= ~SS[2];                                             //0100 :
            8'h8 : SevenSegment[6:0] <= ~SS[3];                                             //1000 :
            
            8'h10 : SevenSegment[6:0] <= ~SS[4]; // depending on which digit is on at        //if ~SegmentDrivers = 0001 :  SevenSegment[6:0]
            8'h20 : SevenSegment[6:0] <= ~SS[5]; // this point                               //0010 :
            8'h40 : SevenSegment[6:0] <= ~SS[6];                                             //0100 :
            8'h80 : SevenSegment[6:0] <= ~SS[7];                                             //1000 : 
            
            default: SevenSegment[6:0] <= 7'h7F;//7'h55
        endcase
    end
end

endmodule
