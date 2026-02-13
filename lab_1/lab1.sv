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

      // Define hex display 
      logic [11:0] disp_hex;

      // Display (Either read base SW or offset SW)
      assign disp_hex = {2'b00, SW} + offset;

      // Offset for incrementing / decrementing display + Memory Address
      logic [11:0] offset;

      assign clk = CLOCK_50;
      
      range #(256, 8) // RAM_WORDS = 256, RAM_ADDR_BITS = 8)
            r ( .* ); // Connect everything with matching names

      wire p0 = ~KEY[0], p1 = ~KEY[1], p2 = ~KEY[2], p3 = ~KEY[3];

      logic h0, h1, h2, h3;          // held (debounced) for inc/dec
      logic c0, c1, c2, c3;  // click events (one-cycle on release)

      // Repeat Counter
      // logic [22:0] rep_cnt;

      // Debouncing Buttons
      localparam int CLK_HZ = 50_000_000;

      // debounce_click #(CLK_HZ, 100) db0(clk, p0, h0, c0);
      // debounce_click #(CLK_HZ, 100) db1(clk, p1, h1, c1);
      // debounce_click #(CLK_HZ, 100) db2(clk, p2, h2, c2);
      // debounce_click #(CLK_HZ, 100) db3(clk, p3, h3, c3);
      Button b0(.clk(clk), .raw_pressed(p0), .held(h0), .click(c0));
      Button b1(.clk(clk), .raw_pressed(p1), .held(h1), .click(c1));
      Button b2(.clk(clk), .raw_pressed(p2), .held(h2), .click(c2));
      Button b3(.clk(clk), .raw_pressed(p3), .held(h3), .click(c3));


      // HEX displays
      hex7seg H0(.a(count[ 3:0]), .y(HEX0));
      hex7seg H1(.a(count[ 7:4]), .y(HEX1));
      hex7seg H2(.a(count[11:8]), .y(HEX2));
      hex7seg H3(.a(disp_hex[ 3:0]), .y(HEX3));
      hex7seg H4(.a(disp_hex[ 7:4]), .y(HEX4));
      hex7seg H5(.a(disp_hex[11:8]), .y(HEX5));

      // Increment / decrement display with buttons
      // Repeat counter for ~5 Hz increment
      // always_ff @(posedge clk) begin
            // // Default
            // rep_cnt <= rep_cnt + 23'd1;
            // go <= 1'b0;

            // // Keep count stable until done

            // // click increments 
            // if (c3) begin
            //       go <= 1'b1;
            // end
            // else if (c0)
            //       offset <= offset + 12'd1;
            // else if (c1)
            //       offset <= offset - 12'd1;
            // else if (c2)
            //       offset <= 12'd0;
            // // hold increments (repeated at ~5 Hz)
            // else if (rep_cnt == 23'd0) begin
            //       if (h0)
            //             offset <= offset + 12'd1;
            //       else if (h1)
            //             offset <= offset - 12'd1;
            // end
      // end


            // Defaults
            typedef enum logic [2:0] {
                  IDLE    = 3'b000,
                  GO      = 3'b001,
                  RUNNING = 3'b010,
                  FINISH  = 3'b011,
                  RESET   = 3'b100
            } state_t;

            state_t state;


            // Button Clicks
            always_ff @(posedge clk) begin
                  // DEFAULT
                  go <= 1'b0;

                  case (state)
                        IDLE: begin
                              // OUTPUT
                              start <= {24'b0, SW};

                              // GO transition
                              if (c3 && !c2 && !c1 && !c0) state <= GO;
                        end

                        GO: begin
                              // OUTPUT
                              go <= 1'b1;
                              state <= RUNNING;
                        end

                        RUNNING: begin
                              if (done) begin
                                    state <= FINISH;
                                    start <= {24'b0, offset[7:0]};
                              end 
                        end

                        FINISH: begin
                              if (c0 && !c1 && !c2 && !c3) begin
                                    // Bound offset to 0-255
                                    if (offset != 8'hFF)
                                          offset <= offset + 12'd1;
                                          start <= {24'b0, offset[7:0]};
                              end else if (!c0 && c1 && !c2 && !c3) begin
                                    // Bound offset to 0-255
                                    if (offset != 8'h00)
                                          offset <= offset - 12'd1;
                                          start <= {24'b0, offset[7:0]};
                              end else if (!c0 && !c1 && c2 && !c3) begin
                                    offset <= 12'd0;
                                    // RETURN TO RESET
                                    state <= RESET;
                              end
                        end

                        RESET: begin
                              state <= IDLE;
                        end
                  endcase  
            end
endmodule



// Debounced click detector
// Active-low buttons must be stable-low for MS milliseconds.
// A "click" is generated on release after a valid stable press.
// module debounce_click #(
//   parameter int CLK_HZ = 50_000_000,
//   parameter int MS     = 100
// )(
//   input  logic clk,
//   input  logic raw_pressed,  // 1 = pressed (already inverted)
//   output logic held,         // debounced pressed
//   output logic click         // 1-cycle pulse on release
// );

//   localparam int TICKS = (CLK_HZ/1000)*MS;
//   localparam int CW    = $clog2(TICKS+1);

//   logic [CW-1:0] cnt;
//   logic armed;

//   always_ff @(posedge clk) begin
//     click <= 1'b0;

//       if (raw_pressed) begin
//             cnt <= '0;
//             if (held) begin
//             held <= 1'b0;
//             if (armed) begin
//             click <= 1'b1;
//             armed <= 1'b0;
//             end
//             end else (!held) begin
//             if (cnt < TICKS[CW-1:0]) cnt <= cnt + 1'b1;
//             if (cnt == TICKS-1) begin
//             held  <= 1'b1;
//             armed <= 1'b1;
//             end
//             end
//       end
//   end

// endmodule

/* verilator lint_off DECLFILENAME */
module Button
   #(parameter int TIME_OUT = 9_500_000) // 50 MHz * 0.5 s
(
      input  logic clk,
      input  logic raw_pressed,
      output logic held,
      output logic click
);

      logic [24:0] clk_cnt;  // 25 bits to hold up to 25M

      typedef enum logic [1:0] {
            IDLE  = 2'b00,
            CLICK = 2'b01,
            WAIT  = 2'b10,
            HOLD  = 2'b11
      } state_t;

      state_t state;

      always_ff @(posedge clk) begin
            click <= 1'b0;
            held  <= 1'b0;

            // Update clock counter
            clk_cnt <= clk_cnt + 25'b1;

            case (state)
                  IDLE: begin
                        if (raw_pressed)
                              state <= CLICK;
                  end

                  CLICK: begin
                        click <= 1'b1;
                        held <= 1'b1;
                        state <= WAIT;

                        // Set Timer
                        clk_cnt <= 25'b0;
                  end

                  WAIT: begin
                        if (clk_cnt == TIME_OUT && raw_pressed)
                              state <= HOLD;
                        else if (clk_cnt >= TIME_OUT && !raw_pressed)
                              state <= IDLE;
                  end
                  HOLD: begin
                        held <= 1'b1;
                        if (!raw_pressed)
                              state <= IDLE;
                  end
            endcase
      end

endmodule