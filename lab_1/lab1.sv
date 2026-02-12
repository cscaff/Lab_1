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
   
   assign clk = CLOCK_50;

   logic [31:0] dout_wire;

   collatz c (
    .clk  (clk),
    .go   (go),
    .n    ({20'b0, base_latched + {4'b0, offset}}),  
    .dout (dout_wire),
    .done (done)
  );
 
   range #(256, 8) // RAM_WORDS = 256, RAM_ADDR_BITS = 8)
         r ( .* ); // Connect everything with matching names

   // Replace this comment and the code below it with your own code;
   // The code below is merely to suppress Verilator lint warnings
   
   // ---------------- Debounced UI ----------------
   localparam int CLK_HZ = 50_000_000;

   // Active-low buttons → pressed = 1
   wire p0 = ~KEY[0], p1 = ~KEY[1], p2 = ~KEY[2], p3 = ~KEY[3];

   logic h0, h1, h2, h3;          // held (debounced) for inc/dec
   logic c0, c1, c2, c3;  // click events (one-cycle on release)

   // Debouncers
   debounce_click #(CLK_HZ, 100) db0(clk, p0, h0, c0);
   debounce_click #(CLK_HZ, 100) db1(clk, p1, h1, c1);
   debounce_click #(CLK_HZ, 100) db2(clk, p2, h2, c2);
   debounce_click #(CLK_HZ, 100) db3(clk, p3, h3, c3);

   logic [11:0] base_sw, base_latched, disp_n;
   logic [7:0]  offset;

   // ~5 Hz repeat
   logic [23:0] repdiv;
   wire tick5 = (repdiv == 24'd9_999_999);

   assign count = dout_wire[15:0];
   assign base_sw = {2'b00, SW};
   assign disp_n  = base_latched + {4'b0, offset};

   // start value to range
   always_comb
     start = done ? {24'b0, offset} : {20'b0, base_latched};

   // LEDs
   always_comb begin
     LEDR = 10'b0;
     LEDR[9]   = done;
     LEDR[8]   = ~done;
     LEDR[7:0] = offset;
   end

   always_ff @(posedge clk) begin
     go <= 1'b0;

     // repeat divider
     if (tick5) repdiv <= 24'd0;
     else       repdiv <= repdiv + 24'd1;

     // run on debounced click
     if (c2) begin
       base_latched <= base_sw;
       offset       <= 8'd0;
       go           <= 1'b1;
     end

     // reset offset
     if (c3) offset <= 8'd0;

     // inc / dec
     if (!(h0 && h1)) begin
       if (c0 && offset != 8'hFF) offset <= offset + 8'd1;
       if (c1 && offset != 8'h00) offset <= offset - 8'd1;

       if (tick5) begin
         if (h0 && offset != 8'hFF) offset <= offset + 8'd1;
         if (h1 && offset != 8'h00) offset <= offset - 8'd1;
       end
     end
   end

   // HEX displays
   hex7seg H0(.a(count[ 3:0]), .y(HEX0));
   hex7seg H1(.a(count[ 7:4]), .y(HEX1));
   hex7seg H2(.a(count[11:8]), .y(HEX2));
   hex7seg H3(.a(disp_n[ 3:0]), .y(HEX3));
   hex7seg H4(.a(disp_n[ 7:4]), .y(HEX4));
   hex7seg H5(.a(disp_n[11:8]), .y(HEX5));
endmodule

// ------------------------------------------------------------
// Debounced click detector
// Active-low buttons must be stable-low for MS milliseconds.
// A "click" is generated on release after a valid stable press.
// ------------------------------------------------------------
module debounce_click #(
  parameter int CLK_HZ = 50_000_000,
  parameter int MS     = 100
)(
  input  logic clk,
  input  logic raw_pressed,  // 1 = pressed (already inverted)
  output logic held,         // debounced pressed
  output logic click         // 1-cycle pulse on release
);

  localparam int TICKS = (CLK_HZ/1000)*MS;
  localparam int CW    = $clog2(TICKS+1);

  logic [CW-1:0] cnt;
  logic armed;

  always_ff @(posedge clk) begin
    click <= 1'b0;

    if (raw_pressed) begin
      if (!held) begin
        if (cnt < TICKS[CW-1:0]) cnt <= cnt + 1'b1;
        if (cnt == TICKS-1) begin
          held  <= 1'b1;
          armed <= 1'b1;
        end
      end
    end else begin
      cnt <= '0;
      if (held) begin
        held <= 1'b0;
        if (armed) begin
          click <= 1'b1;
          armed <= 1'b0;
        end
      end
    end
  end

endmodule