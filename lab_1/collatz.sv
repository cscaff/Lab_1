module collatz( input logic         clk,   // Clock
		input logic 	    go,    // Load value from n; start iterating
		input logic  [31:0] n,     // Start value; only read when go = 1
		output logic [31:0] dout,  // Iteration value: true after go = 1
		output logic 	    done); // True when dout reaches 1

   // done is true whenever dout has reached 1
   always_comb begin
      done = (dout == 32'd1);
   end

   always_ff @(posedge clk) begin
      if (go) begin
         // Restart sequence from n
         dout <= n;
      end else begin
         // Iterate once per clock until reaching 1
         if (dout != 32'd1) begin
            if (dout % 32'd2 == 32'd0) begin
               // even: n = n/2
               dout <= (dout >> 1);
            end else begin
               // odd: n = 3n + 1  (shift/add)
               dout <= (dout << 1) + dout + 32'd1;
            end
         end
      end
   end

endmodule

