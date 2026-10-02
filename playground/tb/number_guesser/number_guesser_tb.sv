module number_guesser_tb;

    localparam int unsigned WIDTH = 8;
    localparam logic [WIDTH-1:0] SECRET = 173;

    logic clk = 1'b0;
    logic reset;

    logic higher;
    logic lower;
    logic correct;

    wire [WIDTH-1:0] low;
    wire [WIDTH-1:0] high;
    wire [WIDTH-1:0] guess;

    wire done;


    number_guesser #(
        .WIDTH(WIDTH)
    ) dut (
        .clk  (clk),
        .reset(reset),

        .higher (higher),
        .lower  (lower),
        .correct(correct),

        .low  (low),
        .high (high),
        .guess(guess),

        .done(done)
    );


    // 10 ns period
    always #5 clk = ~clk;


    initial begin
        $dumpfile("number_guesser.fst");
        $dumpvars(0, number_guesser_tb);

        reset   = 1'b1;

        higher  = 1'b0;
        lower   = 1'b0;
        correct = 1'b0;


        // -------------------------------------------------
        // Controller reset -> INIT
        // -------------------------------------------------

        @(posedge clk);

        // Release reset away from active edge.
        @(negedge clk);
        reset = 1'b0;


        // -------------------------------------------------
        // INIT cycle
        //
        // On this edge:
        //
        // control: INIT -> RUNNING
        // datapath:
        //     low  <- 0
        //     high <- 255
        // -------------------------------------------------

        @(posedge clk);
        #1;

        if (low !== 8'd0 || high !== 8'd255 || guess !== 8'd127)
            $fatal(1, "Initial state wrong: low=%0d high=%0d guess=%0d", low, high, guess);

        $display("INIT: range=[%0d,%0d] guess=%0d", low, high, guess);


        // -------------------------------------------------
        // Play until the hardware finds SECRET.
        // -------------------------------------------------

        while (!done) begin

            // Drive response safely away from posedge.
            @(negedge clk);

            higher  = 1'b0;
            lower   = 1'b0;
            correct = 1'b0;


            $display("range=[%0d,%0d] guess=%0d", low, high, guess);


            if (guess < SECRET) begin
                higher = 1'b1;
                $display("  -> HIGHER");
            end else if (guess > SECRET) begin
                lower = 1'b1;
                $display("  -> LOWER");
            end else begin
                correct = 1'b1;
                $display("  -> CORRECT");
            end


            // DUT captures command.
            @(posedge clk);
            #1;

        end


        // -------------------------------------------------
        // Remove response safely.
        // -------------------------------------------------

        @(negedge clk);

        higher  = 1'b0;
        lower   = 1'b0;
        correct = 1'b0;


        // -------------------------------------------------
        // Final verification
        // -------------------------------------------------

        if (guess !== SECRET)
            $fatal(1, "DONE with wrong answer: guess=%0d secret=%0d", guess, SECRET);


        $display("");
        $display("FOUND SECRET: %0d", guess);
        $display("FULL NUMBER GUESSER TEST PASSED");

        $finish;
    end

endmodule
