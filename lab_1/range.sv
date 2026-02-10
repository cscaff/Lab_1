module range
   #(parameter
     RAM_WORDS = 16,            // Number of counts to store in RAM
     RAM_ADDR_BITS = 4)         // Number of RAM address bits
   (input  logic         clk,    // Clock
    input  logic         go,     // Read start and start testing
    input  logic [31:0]  start,  // Number to start from or count to read
    output logic         done,   // True once memory is filled
    output logic [15:0]  count); // Iteration count once finished

   logic        cgo;    // "go" for the Collatz iterator
   logic        cdone;  // "done" from the Collatz iterator
   logic [31:0] n;      // number to start the Collatz iterator

   // verilator lint_off PINCONNECTEMPTY
   collatz c1(.clk(clk),
              .go(cgo),
              .n(n),
              .done(cdone),
              .dout());

   logic [RAM_ADDR_BITS-1:0] num;     // RAM address to write
   logic                     running; // True during iterations
   logic                     launch_pending; // 1 => pulse cgo next cycle

   logic                     we;      // Write enable
   logic [15:0]              din;     // Data to write
   logic [15:0]              mem[RAM_WORDS-1:0];
   logic [RAM_ADDR_BITS-1:0] addr;

   // Edge detectors
   logic go_d, cdone_d;
   wire  go_rise    = go    & ~go_d;
   wire  cdone_rise = cdone & ~cdone_d;

   // Write exactly once when cdone rises
   assign we = running & cdone_rise;

   // -----------------------------
   // No-FSM control (robust launch)
   // -----------------------------
   always_ff @(posedge clk) begin
      // track edges
      go_d    <= go;
      cdone_d <= cdone;

      // default: no pulse
      cgo <= 1'b0;

      // Start new sweep on go rising edge
      if (go_rise) begin
         running        <= 1'b1;
         done           <= 1'b0;

         num            <= '0;
         n              <= start;

         din            <= 16'd1;      // count convention (length incl. start & 1)
         launch_pending <= 1'b1;       // pulse cgo next cycle (after n is stable)
      end
      else if (running) begin
         // Issue the one-cycle cgo pulse when pending
         if (launch_pending) begin
            cgo           <= 1'b1;
            launch_pending <= 1'b0;
         end

         // Count cycles only after launch has happened and before done
         if (!launch_pending && !cdone) begin
            din <= din + 16'd1;
         end

         // On completion (one time), advance / finish
         if (cdone_rise) begin
            if (num == RAM_ADDR_BITS'(RAM_WORDS-1)) begin
               running <= 1'b0;
               done    <= 1'b1;
            end
            else begin
               num            <= num + 1'b1;
               n              <= n + 32'd1;

               din            <= 16'd1;
               launch_pending <= 1'b1; // start next n on the following cycle
            end
         end
      end
   end

   // -----------------------------
   // RAM read/write
   // -----------------------------
   assign addr = we ? num : start[RAM_ADDR_BITS-1:0];

   always_ff @(posedge clk) begin
      if (we) mem[addr] <= din;
      count <= mem[addr];
   end

endmodule

