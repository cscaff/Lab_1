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
   logic [31:0]         cdout;  // current Collatz value (optional but useful)

// verilator lint_off PINCONNECTEMPTY

   // Instantiate the Collatz iterator
   collatz c1(.clk(clk),
	      .go(cgo),
	      .n(n),
	      .done(cdone),
	      .dout(cdout));

   logic [RAM_ADDR_BITS - 1:0] 	 num;         // The RAM address to write
   logic 			 running = 0; // True during the iterations

   logic 			 we;                    // Write din to addr
   logic [15:0] 		 din;                   // Data to write
   logic [15:0] 		 mem[RAM_WORDS - 1:0];  // The RAM itself
   logic [RAM_ADDR_BITS - 1:0] 	 addr;                  // Address to read/write

   assign addr = we ? num : start[RAM_ADDR_BITS-1:0];

   // Simple controller:
   // - On go: latch base=start, start collatz at base+0
   // - Count steps until collatz done, write to mem[num]
   // - Repeat for all num, then assert done
   typedef enum logic [1:0] {IDLE, RUN, WRITE, FINISH} state_t;
   state_t state = IDLE;

   logic [31:0] base;
   logic [15:0] steps;

   always_ff @(posedge clk) begin
      // defaults each cycle
      cgo  <= 1'b0;
      we   <= 1'b0;
      din  <= steps;
      done <= (state == FINISH);

      case (state)

        IDLE: begin
          running <= 1'b0;
          num     <= '0;
          steps   <= 16'd0;

          if (go) begin
            base    <= start;
            running <= 1'b1;

            // start collatz for base + 0
            n   <= start;
            cgo <= 1'b1;
            state <= RUN;
          end
        end

        RUN: begin
          // Wait for collatz to reach 1; count steps per cycle while not done
          if (!cdone) begin
            steps <= steps + 16'd1;
          end else begin
            state <= WRITE;
          end
        end

        WRITE: begin
          // Write the step count to RAM at address = num
          we  <= 1'b1;
          din <= steps;

          if (num == RAM_WORDS-1) begin
            running <= 1'b0;
            state   <= FINISH;
          end else begin
            // advance to next entry
            num   <= num + 1'b1;
            steps <= 16'd0;

            // kick off next collatz run: base + (num+1)
            n   <= base + {{(32-RAM_ADDR_BITS){1'b0}}, (num + 1'b1)};
            cgo <= 1'b1;
            state <= RUN;
          end
        end

        FINISH: begin
          running <= 1'b0;
          // stay done until a new go arrives (restart)
          if (go) state <= IDLE;
        end

      endcase
   end

   always_ff @(posedge clk) begin
      if (we) mem[addr] <= din;
      count <= mem[addr];
   end

endmodule

