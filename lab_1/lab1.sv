// CSEE 4840 Lab 1: Run and Display Collatz Conjecture Iteration Counts
//
// Spring 2023
//
// By: <your name here>
// Uni: <your uni here>

module lab1( input logic        CLOCK_50,  // 50 MHz Clock input
	     
	     input logic [3:0] 	KEY, // Pushbuttons; KEY[0] is rightmost

	     input logic [9:0] 	SW, // Switches; SW[0] is rightmost

	     // 7-segment LED displays; HEX0 is rightmost
	     output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,

	     output logic [9:0] LEDR // LEDs above the switches; LED[0] on right
	     );

   logic 			clk, go, done;   
   logic [31:0] 		start;
   logic [15:0] 		count;

   logic [11:0] 		n;


   // Define hex display 
   logic [11:0] disp_hex;

   assign disp_hex = {2'b00, SW};

   assign clk = CLOCK_50;
 
   range #(256, 8) // RAM_WORDS = 256, RAM_ADDR_BITS = 8)
         r ( .* ); // Connect everything with matching names

   // Replace this comment and the code below it with your own code;
   // The code below is merely to suppress Verilator lint warnings
//    assign HEX0 = {KEY[2:0], KEY[3:0]};
//    assign HEX1 = SW[6:0];
//    assign HEX2 = {(n == 12'b0), (count == 16'b0) ^ KEY[1],
// 		  go, done ^ KEY[0], SW[9:7]};
//    assign HEX3 = HEX0;
//    assign HEX4 = HEX1;
//    assign HEX5 = HEX2;
//    assign LEDR = SW;
//    assign go = KEY[0];
//    assign start = {SW[1:0], SW, SW, SW};
//    assign n = {SW[1:0], SW};


    // We want to display switch value on the display
   // HEX displays
      hex7seg H0(.a(count[ 3:0]), .y(HEX0));
      hex7seg H1(.a(count[ 7:4]), .y(HEX1));
      hex7seg H2(.a(count[11:8]), .y(HEX2));
      hex7seg H3(.a(disp_hex[ 3:0]), .y(HEX3));
      hex7seg H4(.a(disp_hex[ 7:4]), .y(HEX4));
      hex7seg H5(.a(disp_hex[11:8]), .y(HEX5));

   
   
  
endmodule