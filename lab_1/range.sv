module range
   #(parameter
     RAM_WORDS = 16,            // Number of counts to store in RAM
     RAM_ADDR_BITS = 4)         // Number of RAM address bits
   (input logic         clk,    // Clock
    input logic 	go,     // Read start and start testing
    input logic [31:0] 	start,  // Number to start from or count to read
    output logic 	done,   // True once memory is filled
    output logic [15:0] count); // Iteration count once finished

   logic 		cgo;    // "go" for the Collatz iterator
   logic                cdone;  // "done" from the Collatz iterator
   logic [31:0] 	n;      // number to start the Collatz iterator

// verilator lint_off PINCONNECTEMPTY
   
   // Instantiate the Collatz iterator
   collatz c1(.clk(clk),
	      .go(cgo),
	      .n(n),
	      .done(cdone),
	      .dout());

   logic [RAM_ADDR_BITS - 1:0] 	 num;         // The RAM address to write
   logic 			 running; // True during the iterations

   typedef enum logic [1:0] {IDLE, RUN, WRITE, FINISH} state_t;
   state_t state ;//= IDLE;

   // logic [15:0] acc;

   always_ff @(posedge clk) begin
      if (go) state <= IDLE;
   end

   // always_ff @(posedge clk) begin
   //    // Defaults each cycle
   //    cgo <= 1'b0;
   //    we  <= 1'b0;
   //    // din <= acc;
   //    done <= (state == FINISH);

   //    case (state)
   //       // RESET: begin
   //       //    running <= 1'b0;
   //       //    num <= '0;
   //       //    acc <= 16'd0;
   //       //    state <= IDLE;
   //       // end
   //       IDLE: begin
   //          // IDLE STATE: AWAITING FOR GO SIGNAL
   //          running <= 1'b0;
   //          num <= '0;
   //          din <= 16'd0;

   //          if (go) begin
   //             running <= 1'b1;

   //             // Set signals for the Collatz iteration
   //             cgo <= 1'b1;
   //             n <= start;
   //             din <= 16'd1;

   //             state <= RUN;
   //          end
   //       end
   //       RUN: begin
   //          if (running) begin
   //             if (cdone) begin
   //                state <= WRITE;

   //             end else begin
   //                // Count the steps in the Collatz iteration
   //                running <= 1'b1;
   //                din <= din + 16'd1;
   //             end
   //          end 
   //       end
   //       WRITE: begin
   //          // Write Count to RAM
   //          //din <= acc;
   //          we <= 1'b1;
   //          // din <= acc;

   //          // Terminate when RAM is filled
   //          if (num == RAM_ADDR_BITS'(RAM_WORDS - 1)) begin
   //             //running <= 1'b0;
   //             state <= FINISH;
   //          end else begin
   //             // Advance to next memory address
   //             num <= num + 1'b1;
   //             din <= 16'd1;

   //             // Determine next base value
   //             n <= start + {{(32-RAM_ADDR_BITS){1'b0}}, (num + 1'b1)};
   //             cgo <= 1'b1;
   //             state <= RUN;
   //          end
   //       end
   //       FINISH: begin
   //         running <= 1'b0;
   //       end
   //    endcase
   // end 

   always_ff @(posedge clk) begin
   // Defaults each cycle
   cgo <= 1'b0;
   we  <= 1'b0;
   done <= (state == FINISH);

   case (state)
      IDLE: begin
         // IDLE STATE: AWAITING FOR GO SIGNAL
         running <= 1'b0;
         num <= '0;
         din <= 16'd0;
         
         if (go) begin
            running <= 1'b1;
            // Set signals for the Collatz iteration
            cgo <= 1'b1;
            n <= start;
            din <= 16'd1;  // Start counting from 1
            state <= RUN;
         end
      end
      
      RUN: begin
         if (running) begin
            if (cdone) begin
               we <= 1'b1; // Enable writing to RAM
               state <= WRITE;
            end else begin
               // Count the steps in the Collatz iteration
               running <= 1'b1;
               din <= din + 16'd1;
            end
         end
      end
      
      WRITE: begin
         // Don't write again - the write from RUN->WRITE transition already happened
         // Just prepare for next iteration
         
         // Terminate when RAM is filled
         if (num == RAM_ADDR_BITS'(RAM_WORDS - 1)) begin
            state <= FINISH;
         end else begin
            // Advance to next memory address
            num <= num + 1'b1;
            din <= 16'd1;  // Reset count for next number
            // Determine next base value
            n <= start + {{(32-RAM_ADDR_BITS){1'b0}}, (num + 1'b1)};
            cgo <= 1'b1;
            state <= RUN;
         end
      end
      
      FINISH: begin
         running <= 1'b0;
      end
   endcase
end 

   logic 			 we;                    // Write din to addr
   logic [15:0] 		 din;                   // Data to write
   logic [15:0] 		 mem[RAM_WORDS - 1:0];  // The RAM itself
   logic [RAM_ADDR_BITS - 1:0] 	 addr;                  // Address to read/write

   assign addr = we ? num : start[RAM_ADDR_BITS-1:0];
   
   always_ff @(posedge clk) begin
      if (we) mem[addr] <= din;
      count <= mem[addr];      
   end

endmodule
	     
