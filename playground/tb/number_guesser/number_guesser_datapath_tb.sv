module number_guesser_datapath_tb;

    localparam int unsigned WIDTH = 8;

    logic clk = 1'b0;

    logic init;
    logic update_low;
    logic update_high;

    wire [WIDTH-1:0] low;
    wire [WIDTH-1:0] high;
    wire [WIDTH-1:0] guess;


    number_guesser_datapath #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),

        .init       (init),
        .update_low (update_low),
        .update_high(update_high),

        .low  (low),
        .high (high),
        .guess(guess)
    );


    // 10 ns clock period
    always #5 clk = ~clk;


    task automatic check_state(input logic [WIDTH-1:0] expected_low,
                               input logic [WIDTH-1:0] expected_high,
                               input logic [WIDTH-1:0] expected_guess, input string name);
        #1;

        if (low !== expected_low || high !== expected_high || guess !== expected_guess) begin
            $fatal(1,
                   "%s FAILED: got low=%0d high=%0d guess=%0d; expected low=%0d high=%0d guess=%0d",
                   name, low, high, guess, expected_low, expected_high, expected_guess);
        end

        $display("%s PASS: low=%0d high=%0d guess=%0d", name, low, high, guess);
    endtask


    initial begin
        $dumpfile("number_guesser_datapath.fst");
        $dumpvars(0, number_guesser_datapath_tb);


        // -------------------------------------------------
        // Initial control inputs
        //
        // The datapath registers themselves have no reset.
        // INIT explicitly loads:
        //
        // low  = 0
        // high = 255
        // -------------------------------------------------

        init        = 1'b1;
        update_low  = 1'b0;
        update_high = 1'b0;


        // -------------------------------------------------
        // INIT
        // -------------------------------------------------

        @(posedge clk);

        check_state(8'd0, 8'd255, 8'd127, "initialise");

        @(negedge clk);
        init = 1'b0;


        // -------------------------------------------------
        // 127 -> HIGHER
        //
        // low = 128
        // high = 255
        //
        // guess = floor((128 + 255) / 2)
        //       = 191
        // -------------------------------------------------

        update_low = 1'b1;

        @(posedge clk);

        check_state(8'd128, 8'd255, 8'd191, "higher after 127");

        @(negedge clk);
        update_low  = 1'b0;


        // -------------------------------------------------
        // 191 -> LOWER
        //
        // low = 128
        // high = 190
        //
        // guess = 159
        // -------------------------------------------------

        update_high = 1'b1;

        @(posedge clk);

        check_state(8'd128, 8'd190, 8'd159, "lower after 191");

        @(negedge clk);
        update_high = 1'b0;


        // -------------------------------------------------
        // 159 -> HIGHER
        //
        // low = 160
        // high = 190
        //
        // guess = 175
        // -------------------------------------------------

        update_low  = 1'b1;

        @(posedge clk);

        check_state(8'd160, 8'd190, 8'd175, "higher after 159");

        @(negedge clk);
        update_low  = 1'b0;


        // -------------------------------------------------
        // 175 -> LOWER
        //
        // low = 160
        // high = 174
        //
        // guess = 167
        // -------------------------------------------------

        update_high = 1'b1;

        @(posedge clk);

        check_state(8'd160, 8'd174, 8'd167, "lower after 175");

        @(negedge clk);
        update_high = 1'b0;


        // -------------------------------------------------
        // HOLD
        //
        // Neither load signal is asserted.
        // Both registers must retain their values.
        // -------------------------------------------------

        @(posedge clk);

        check_state(8'd160, 8'd174, 8'd167, "hold");


        // -------------------------------------------------
        // INIT should restore the original range
        //
        // Also assert update signals here deliberately:
        // INIT should select the initial values regardless.
        // -------------------------------------------------

        @(negedge clk);

        init        = 1'b1;
        update_low  = 1'b1;
        update_high = 1'b1;

        @(posedge clk);

        check_state(8'd0, 8'd255, 8'd127, "reinitialise");


        @(negedge clk);

        init        = 1'b0;
        update_low  = 1'b0;
        update_high = 1'b0;


        $display("");
        $display("ALL DATAPATH TESTS PASSED");
        $finish;
    end

endmodule
